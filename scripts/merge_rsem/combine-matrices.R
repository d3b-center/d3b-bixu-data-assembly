# Author: Komal S. Rathi
# Function: Combine TPM matrices from various RNAseq datasets
# TPM matrices may or may not be collapsed to unique gene symbols

suppressPackageStartupMessages({
  library(optparse)
  library(tidyverse)
  library(plyr)
})

# parameters
option_list <- list(
  make_option(c("--matrices"), type = "character",
              help = "Comma separated list of expression matrices to combine (RSEM TPM, FPM or Expected counts) (.RDS)"),
  make_option(c("--collapsed"), type = "logical", default = FALSE,
              help = "Are the input rds files collapsed? Default is FALSE"),
  make_option(c("--outfile"), type = "character",
              help = "Output filename (.RDS)"))

# parse parameters
opt <- parse_args(OptionParser(option_list = option_list))
matrices <- opt$matrices
matrices <- trimws(strsplit(matrices,",")[[1]]) 
collapsed <- opt$collapsed
outfile <- opt$outfile

# function to merge all input datasets
join.all <- function(...){
  x <- lapply(..., FUN = function(x) readRDS(x))
  if(collapsed){
    # if already collapsed to unique gene symbols do this
    x <- lapply(x, FUN = function(x) x %>% rownames_to_column('gene'))# apply on each element on list and convert rownames to column
    x <- join_all(x, by = 'gene', type = 'inner')
    x <- x %>%
      column_to_rownames('gene')
  } else {
    # if input files are not collapsed, do this
    x <- join_all(x, by = 'gene_id', type = 'inner')
  }
  return(x)
}
combined.mat <- join.all(matrices)

# save output
saveRDS(combined.mat, file = outfile)
