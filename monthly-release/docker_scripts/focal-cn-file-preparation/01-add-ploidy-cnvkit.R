library(dplyr)
suppressPackageStartupMessages(library(optparse))

# read params
option_list <- list(
  make_option(c("--scratch"),
              type = "character",
              help = "scratch folder"
  ),
  make_option(c("--cnvkit_file"),
              type = "character",
              help = "Input file for cnvkit_file"
  ),
  make_option(c("--histology_file"),
              type = "character",
              help = "Path to histology file "
  )
)

# parse the parameters
opt <- parse_args(OptionParser(option_list = option_list))


scratch_dir <- opt$scratch

if(!dir.exists(scratch_dir)) {
  dir.create(scratch_dir, recursive = TRUE)
}

cnvkit_file <- opt$cnvkit_file
cnvkit_df <- readr::read_tsv(cnvkit_file)

histologies_file <- opt$histology_file
#histologies_df <- readr::read_tsv(histologies_file, guess_max = 100000)
# histologies_df <- read.table(histologies_file,sep=',',header = TRUE, stringsAsFactors = FALSE)
histologies_df <- read.csv(histologies_file, stringsAsFactors = FALSE)


# Filter to WXS tumor with no germline sex estimate
no_estimate <- histologies_df %>%
  filter(sample_type == "Tumor" & experimental_strategy == "WXS" &
           is.na(germline_sex_estimate)) %>%
  select(-germline_sex_estimate)

# Extract participant ID with no germline sex estimate
no_estimate_participants <- no_estimate %>%
  pull(Kids_First_Participant_ID) %>%
  unique()

# Find out matching WGS
# Use Kids_First_Participant_ID for filtering samples that have WGS, when WXS was performed
no_estimate_participants_match_wgs <- histologies_df %>%
  filter(Kids_First_Participant_ID %in% no_estimate_participants &
           experimental_strategy == "WGS" & sample_type == "Tumor") %>%
  select(Kids_First_Participant_ID, germline_sex_estimate)

# Merge data that was fixed with WGS germline sex estimate
no_estimate_fixed_through_wgs <- left_join(no_estimate, no_estimate_participants_match_wgs
                                           , by = "Kids_First_Participant_ID") %>%
  filter(!is.na(germline_sex_estimate))

# Identify data that was not fixed due to NA
no_estimate_still_na <- left_join(no_estimate, no_estimate_participants_match_wgs
                                  , by = "Kids_First_Participant_ID") %>%
  filter(is.na(germline_sex_estimate))

# Fix NA data using gender
no_estimate_still_na_fixed <- no_estimate_still_na %>%
  mutate(germline_sex_estimate = case_when(
                                  reported_gender == "Female" ~ "Female",
                                  reported_gender == "Male" ~ "Male",
                                  TRUE ~ as.character(NA))
         )
no_estimate_fixed_through_wgs$germline_sex_estimate <- as.character(no_estimate_fixed_through_wgs$germline_sex_estimate)

# Merge back fixed_wgs, fixed_na, and exist_germline_estimate data
histologies_df_fixed <- bind_rows(no_estimate_fixed_through_wgs, no_estimate_still_na_fixed)

# remove samples in histologies_df_fixed from histologies_df
histologies_df_rm <- histologies_df %>%
  anti_join(histologies_df_fixed, by = "Kids_First_Biospecimen_ID")

histologies_df_rm$germline_sex_estimate <- as.character(histologies_df_rm$germline_sex_estimate)

# add new rows back
histologies_df_final <- histologies_df_rm %>%
  bind_rows(histologies_df_fixed)

add_ploidy_df <- histologies_df_final  %>%
  select(Kids_First_Biospecimen_ID, tumor_ploidy, germline_sex_estimate) %>%
  inner_join(cnvkit_df, by = c("Kids_First_Biospecimen_ID" = "ID")) %>%
  select(-tumor_ploidy, -germline_sex_estimate, everything())

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

add_status_df <- dplyr::bind_rows(add_autosomes_df, add_xy_df) %>%
  dplyr::select(-germline_sex_estimate)



output_file <- file.path(scratch_dir, "cnvkit_with_status.tsv")
readr::write_tsv(add_status_df, output_file)
