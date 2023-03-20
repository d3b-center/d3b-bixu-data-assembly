library(dplyr)
library(tidyverse)
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
#histologies_df <- read_csv(histologies_file, stringsAsFactors = FALSE)
histologies_df <- readr::read_tsv(histologies_file, col_types = cols(molecular_subtype = col_character()))

### Add inferred ploidy information to CNVkit results
add_ploidy_df <- histologies_df  %>%
  select(Kids_First_Biospecimen_ID, tumor_ploidy, germline_sex_estimate) %>%
  inner_join(cnvkit_df, by = c("Kids_First_Biospecimen_ID" = "ID")) %>%
  select(-tumor_ploidy, -germline_sex_estimate, everything())

### Add status column
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
