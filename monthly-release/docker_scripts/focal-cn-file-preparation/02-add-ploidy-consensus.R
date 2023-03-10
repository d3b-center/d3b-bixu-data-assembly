library(tidyverse)
suppressPackageStartupMessages(library(optparse))

# read params
option_list <- list(
  make_option(c("--scratch"),
              type = "character",
              help = "scratch folder"
  ),
  make_option(c("--consensus_seg_file"),
              type = "character",
              help = "Input file for consensus_seg"
  ),
  make_option(c("--histology_file"),
              type = "character",
              help = "Path to histology file "
  )
)

# parse the parameters
opt <- parse_args(OptionParser(option_list = option_list))

scratch_dir <- opt$scratch
output_dir <- file.path(scratch_dir, "cytoband_status", "segments")

if(!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

# TODO: the consensus SEG file is not currently in the data download -- when it
# gets included we will have to change the file path here
consensus_seg_file <- opt$consensus_seg_file
histologies_file <- opt$histology_file

consensus_seg_df <- read_tsv(consensus_seg_file)


# histologies_df <- read_tsv(histologies_file,
#                            col_types = cols(
#                              molecular_subtype = col_character()
#                            ))

histologies_df <- read_csv(histologies_file,col_types = cols(molecular_subtype = col_character()))
#histologies_df <- read.table(histologies_file,sep=',',header = TRUE, stringsAsFactors = FALSE)

consensus_seg_df %>%
  filter(is.na(copy.num)) %>%
  group_by(chrom) %>%
  tally()
colnames(consensus_seg_df)[colnames(consensus_seg_df) == 'ID'] <- 'Kids_First_Biospecimen_ID'

sub_his <- select(histologies_df, 
                  Kids_First_Biospecimen_ID, 
                  tumor_ploidy,
                  germline_sex_estimate)
print(sub_his)
add_ploidy_df <- consensus_seg_df %>%
  filter(!is.na(copy.num)) %>%
  inner_join(sub_his, by = "Kids_First_Biospecimen_ID") %>%
             select(-tumor_ploidy, -germline_sex_estimate, everything())
print(add_ploidy_df)
# add_ploidy_df <- consensus_seg_df %>%
#   filter(!is.na(copy.num)) %>%
#   inner_join(select(histologies_df, 
#                     Kids_First_Biospecimen_ID, 
#                     tumor_ploidy,
#                     germline_sex_estimate), 
#              by = c("ID" = "Kids_First_Biospecimen_ID")) %>%
#   select(-tumor_ploidy, -germline_sex_estimate, everything())

add_autosomes_df <- add_ploidy_df %>%
  # x and y chromosomes must be handled differently
  filter(!(chrom %in% c("chrX", "chrY"))) %>%
  mutate(status = case_when(
    # when the copy number is less than inferred ploidy, mark this as a loss
    copy.num < tumor_ploidy ~ "loss",
    # if copy number is higher than ploidy, mark as a gain
    copy.num > tumor_ploidy ~ "gain",
    copy.num == tumor_ploidy ~ "neutral"
  ))

# this logic is consistent with what is observed in the controlfreec file
# specifically, in samples where germline sex estimate = Female, X chromosomes
# appear to be treated the same way as autosomes
add_xy_df <- add_ploidy_df %>%
  filter(chrom %in% c("chrX", "chrY")) %>%  
  mutate(status = case_when(
    germline_sex_estimate == "Male" & copy.num < (0.5 * tumor_ploidy) ~ "loss",
    germline_sex_estimate == "Male" & copy.num > (0.5 * tumor_ploidy) ~ "gain",
    germline_sex_estimate == "Male" & copy.num == (0.5 * tumor_ploidy) ~ "neutral",
    # there are some instances where there are chromosome Y segments are in
    # samples where the germline_sex_estimate is Female
    chrom == "chrY" & germline_sex_estimate == "Female" & copy.num > 0 ~ "unknown",
    chrom == "chrY" & germline_sex_estimate == "Female" & copy.num == 0 ~ "neutral",
    # mirroring controlfreec, X treated same as autosomes
    chrom == "chrX" & germline_sex_estimate == "Female" & copy.num < tumor_ploidy ~ "loss",
    chrom == "chrX" & germline_sex_estimate == "Female" & copy.num > tumor_ploidy ~ "gain",
    chrom == "chrX" & germline_sex_estimate == "Female" & copy.num == tumor_ploidy ~ "neutral"
  ))

add_status_df <- bind_rows(add_autosomes_df, add_xy_df) %>%
  select(-germline_sex_estimate)

# add_status_df <- bind_rows(add_autosomes_df, add_xy_df) %>%
#   select(-germline_sex_estimate) %>%
#   rename(Kids_First_Biospecimen_ID = ID)

add_status_df %>%
  filter(!is.na(seg.mean)) %>%
  ggplot(aes(x = status, y = seg.mean, group = status)) +
  geom_jitter()

add_status_df %>%
  filter(!is.na(seg.mean)) %>%
  group_by(status) %>%
  summarize(mean = mean(seg.mean), sd = sd(seg.mean))

output_file <- file.path(scratch_dir , "consensus_seg_with_status.tsv")
write_tsv(add_status_df, output_file)


bed_status_df <- add_status_df %>%
  select(chrom, loc.start, loc.end, everything()) %>%
  group_by(Kids_First_Biospecimen_ID) %>%
  arrange(chrom, loc.start, loc.end)

losses_bed_status_df <- bed_status_df %>%
  filter(status == "loss")

gains_bed_status_df <- bed_status_df %>%
  filter(status == "gain")

# make lists of data frames by sample
bed_status_list <- bed_status_df %>%
  group_split()
names(bed_status_list) <- bed_status_df %>%
  group_keys() %>%
  pull(Kids_First_Biospecimen_ID)

bed_loss_list <- losses_bed_status_df %>%
  group_split()
names(bed_loss_list) <- losses_bed_status_df %>%
  group_keys() %>%
  pull(Kids_First_Biospecimen_ID)

bed_gain_list <- gains_bed_status_df %>%
  group_split()
names(bed_gain_list) <- gains_bed_status_df %>%
  group_keys() %>%
  pull(Kids_First_Biospecimen_ID)

temp <- purrr::imap(bed_status_list,
                    ~ write_tsv(.x,
                                file.path(
                                  output_dir, paste0("consensus_callable.", .y, ".bed")
                                ),
                                col_names = FALSE))

if (length(bed_loss_list) == 0) {
    bed_loss_list <- data.frame()
    write_tsv(bed_loss_list, file.path(output_dir, paste0("consensus_loss.empty.bed")))
} else {
  temp_loss <- purrr::imap(bed_loss_list,
                         ~ write_tsv(.x,
                                     file.path(
                                       output_dir, paste0("consensus_loss.", .y, ".bed")
                                     ),
                                     col_names = FALSE))
}

if (length(bed_gain_list) == 0) {
  bed_gain_list <- data.frame()
  write_tsv(bed_gain_list,file.path(output_dir, paste0("consensus_gain.empty.bed")))
} else {
  temp_gain <- purrr::imap(bed_gain_list,
                         ~ write_tsv(.x,
                                     file.path(
                                       output_dir, paste0("consensus_gain.", .y, ".bed")
                                     ),
                                     col_names = FALSE))
}


sessionInfo()

