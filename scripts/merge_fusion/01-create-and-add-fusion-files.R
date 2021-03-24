# Author: Krutika Gaonkar
# Merge step from Komal Rathi's code in OpenPBTA
# Date: 05/10/2020
# Function:
# merges new RSEM files into previous version of rsem RDS object

# load libraries
suppressPackageStartupMessages(library(optparse))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(reshape2))
suppressPackageStartupMessages(library(stringr))

# read params
option_list <- list(
  make_option(c("--input_arriba"),
              type = "character",
              help = "Input file for arriba fusion files"
  ),
  make_option(c("--input_star_fusion"),
              type = "character",
              help = "Input file for star fusion file"
  ),
  make_option(c("--outdir"),
              type = "character",
              help = "Path to output directory for merged files"
  ),
  make_option(c("-m", "--mergefiles"),
              type = "logical",default=TRUE,
              help = " TRUE to merge file and FALSE when only need them downloaded"
  ),
  make_option(c("-a", "--old_arriba"),
              type = "character",
              help = "Path to old merged arriba files", default = NULL
  ),
  make_option(c("-s", "--old_starfusion"),
              type = "character",
              help = "Path to old merged starfusion files", default = NULL
  ),
  make_option(c("-o", "--outname_prefix"),
              type = "character",
              help = "outname prefix for merged files"
  )
)

# parse the parameters
opt <- parse_args(OptionParser(option_list = option_list))

input_arriba <- opt$input_arriba
input_star_fusion <- opt$input_star_fusion
old_arriba <- opt$old_arriba
old_starfusion <- opt$old_starfusion
outname_prefix <- opt$outname_prefix
mergefiles <- opt$mergefiles
outdir <- opt$outdir

if (mergefiles) {
  
  # read and merge arriba files
#  lfiles <- list.files(path = topDir, pattern = "*.arriba_formatted.annotated.tsv", recursive = TRUE)
  lfiles <- input_arriba
  read.arriba <- function(x) {
    print(x)
    dat <- read_tsv(x,col_types = readr::cols(breakpoint1 = readr::col_character(),breakpoint2 = readr::col_character())) %>%
      dplyr::rename( "annots"="[]",
                     "strand1.gene.fusion."="strand1(gene/fusion)",
                     "strand2.gene.fusion."="strand2(gene/fusion)") %>%
      as.data.frame()
    
    return(dat)
  }
  new_arriba <- lapply(lfiles, read.arriba)
  new_arriba <- data.table::rbindlist(new_arriba)
  
  # read and merge starfusion files
#  lfiles <- list.files(path = topDir, pattern = "*.starfusion_formatted.tsv", recursive = TRUE)
  lfiles <- input_star_fusion
  read.starfusion <- function(x) {
    print(x)
    dat <- read_tsv(x,col_types = 
                      readr::cols( JunctionReadCount = readr::col_character(),
                                   SpanningFragCount = readr::col_character(),
                                   FFPM = readr::col_character(),
                                   LeftBreakEntropy = readr::col_character(),
                                   RightBreakEntropy= readr::col_character()))  %>%
      as.data.frame()
    return(dat)
  }
  new_starfusion <- lapply(lfiles, read.starfusion)
  new_starfusion <- data.table::rbindlist(new_starfusion)
  
  
  
  if (!is.null(old_arriba)) {
    # read old file
    old_arriba <- read_tsv(old_arriba,col_types = readr::cols(breakpoint1 = readr::col_character(),breakpoint2 = readr::col_character()))
    # get new samples
    new_samples <- setdiff(new_arriba$tumor_id,old_arriba$tumor_id)
    print(paste0("adding ", toString(new_samples)))
    # merge with old file
    all_arriba <- old_arriba %>% bind_rows(new_arriba[which(new_arriba$tumor_id %in% new_samples),])
    # save output
    write_tsv(all_arriba, file.path(outdir, paste0(outname_prefix,"-fusion-arriba.tsv.gz")))
  }
  
  if (!is.null(old_starfusion)) {
    # read old file
    old_starfusion <- read_tsv(old_starfusion,col_types = 
                                 readr::cols( JunctionReadCount = readr::col_character(),
                                              SpanningFragCount = readr::col_character(),
                                              FFPM = readr::col_character(),
                                              LeftBreakEntropy = readr::col_character(),
                                              RightBreakEntropy= readr::col_character()))
    # get new samples
    new_samples <- setdiff(new_starfusion$tumor_id,old_starfusion$tumor_id)
    print(paste0("adding ", toString(new_samples)))
    # merge with old file
    all_starfusion <- old_starfusion %>% bind_rows(new_starfusion[which(new_starfusion$tumor_id %in% new_samples),])
    # save output
    write_tsv(all_starfusion, file.path(outdir, paste0(outname_prefix,"-fusion-starfusion.tsv.gz")))
  }
  
}

print("Done!")
