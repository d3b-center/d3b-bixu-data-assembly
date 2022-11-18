library(tidyverse)

suppressPackageStartupMessages(library(optparse))

# read params
option_list <- list(
  make_option(c("--scratch"),
              type = "character",
              help = "scratch folder"
  )
)

# parse the parameters
opt <- parse_args(OptionParser(option_list = option_list))

scratch_dir <- opt$scratch

all_callable_cytoband_status_df <-
  read_tsv(file.path(scratch_dir, "intersect_with_cytoband_callable.bed"),
                  col_names = FALSE)

loss_cytoband_status_df <-
  read_tsv(file.path(scratch_dir, "intersect_with_cytoband_loss.bed"),
                  col_names = FALSE)

gain_cytoband_status_df <-
  read_tsv(file.path(scratch_dir, "intersect_with_cytoband_gain.bed"),
                  col_names = FALSE)

all_callable_cytoband_status_df <-
  all_callable_cytoband_status_df %>%
  select(
    chr = X1,
    cytoband = X4,
    band_length = X8,
    callable_fraction = X9,
    Kids_First_Biospecimen_ID = X10
  ) %>%
  filter(!is.na(cytoband))

gain_cytoband_status_df <- gain_cytoband_status_df %>%
  select(
    chr = X1,
    cytoband = X4,
    gain_fraction = X9,
    Kids_First_Biospecimen_ID = X10
  ) %>%
  filter(!is.na(cytoband))

loss_cytoband_status_df <- loss_cytoband_status_df %>%
  select(
    chr = X1,
    cytoband = X4,
    loss_fraction = X9,
    Kids_First_Biospecimen_ID = X10
  ) %>%
  filter(!is.na(cytoband))

final_df <- all_callable_cytoband_status_df %>%
  left_join(gain_cytoband_status_df,
            by = c("chr", "cytoband", "Kids_First_Biospecimen_ID")) %>%
  left_join(loss_cytoband_status_df,
            by = c("chr", "cytoband", "Kids_First_Biospecimen_ID"))

# Create a dominant status column
final_df <- final_df %>%
  replace_na(list(
    gain_fraction = 0,
    loss_fraction = 0
  )) %>%
  mutate(
    dominant_status = case_when(
      callable_fraction < 0.5 ~ "uncallable",
      gain_fraction / callable_fraction > 0.5 ~ "gain",
      loss_fraction / callable_fraction > 0.5 ~ "loss",
      (gain_fraction + loss_fraction) / callable_fraction > 0.5 ~ "unstable",
      TRUE ~ "neutral"
    )
  )

# Add a column that tells us the position of the p or q and then use this to
# split the cytoband column
final_df <- final_df %>%
  mutate(
    cytoband_with_arm = paste0(gsub("chr", "", chr), cytoband),
    chromosome_arm = gsub("(p|q).*", "\\1", cytoband_with_arm)
  ) %>%
  select(
    Kids_First_Biospecimen_ID,
    chr,
    cytoband,
    dominant_status,
    band_length,
    everything(),
    -cytoband_with_arm,
  )

# Display final table with `uncallable` value added to `dominant_status` column
final_df

# Write to file
write_tsv(final_df, file.path("results", "consensus_seg_with_ucsc_cytoband_status.tsv.gz"))
