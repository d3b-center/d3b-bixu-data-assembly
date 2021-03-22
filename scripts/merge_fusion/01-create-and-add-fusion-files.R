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
  make_option(c("--inputdir"),
              type = "character",
              help = "Input directory for fusion files"
  ),
  make_option(c("--manifest"),
              type = "character",
              help = "Manifest file with cavatica downloaded csv file with colnames `Kids First Biospecimen ID, name, id`, json file with column names  `Kids_First_Biospecimen_ID,filepath,cavatica_id`"
  ),
  make_option(c("--manifest_format"),
              type = "character", default = "csv",
              help = "csv if manifest downloaded from cavatic GUI,json/yaml format if provided by bix-ops"
  ),
  make_option(c("--outdir"),
              type = "character",
              help = "Path to output directory for merged files"
  ),
  make_option(c("-d", "--download"),
              type = "logical",
              help = "TRUE to download from cavatica", default = TRUE
  ),
  make_option(c("-u", "--username"),
              type = "character",
              help = "if download= TRUE mandatory;  cavatica username "
  ),
  make_option(c("-p", "--projectid"),
              type = "character",
              help = " if download= TRUE mandatory; cavatica project id"
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
topDir <- opt$inputdir
manifest <- opt$manifest
manifest_format <- opt$manifest_format
outdir <- opt$outdir
download <- opt$download
username <- opt$username
projectid <- opt$projectid
old_arriba <- opt$old_arriba
old_starfusion <- opt$old_starfusion
outname_prefix <- opt$outname_prefix
mergefiles <- opt$mergefiles

# read manifest file
if (manifest_format == "csv"){
  manifest <- read.csv(manifest, stringsAsFactors = F)
  manifest <- manifest %>%
    dplyr::mutate(Kids_First_Biospecimen_ID = gsub("[.].*$","",manifest$name)) %>%
    select(Kids_First_Biospecimen_ID, name, id) 
} 


if (manifest_format=="json" || manifest_format == "yaml"){
  manifest <- rlist::list.load(manifest)
  
  manifest <- data.frame("Kids_First_Biospecimen_ID" = unlist(lapply(manifest$`rnaseq-analysis`,function(x) x$kf_biospecimen_id)),
                         "name" = unlist(lapply(manifest$`rnaseq-analysis`,function(x) 
                           gsub(".*[/]","",x$filepath))),
                         "id" = unlist(lapply(manifest$`rnaseq-analysis`,function(x) x$cavatica_id)))
  
}

manifest <- manifest[grep("arriba|starfusion.*tsv", manifest$name), ]

# read histology file and split into polyA and stranded
# clin <- read.delim(clin, stringsAsFactors = F)
# polya <- clin %>%
#   filter(experimental_strategy == "RNA-Seq" & RNA_library == "poly-A")
# stranded <- clin %>%
#   filter(experimental_strategy == "RNA-Seq" & RNA_library == "stranded")


if (download) {
  # download files from manifest
  source("utils/download-files-manifest.R")
  print(head(manifest))
  download_files_manifest(
    manifest = manifest, username =
      username, projectid = projectid,
    outputfolder = topDir
  )
}

if (mergefiles) {
  
  # read and merge arriba files
  lfiles <- list.files(path = topDir, pattern = "*.arriba_formatted.annotated.tsv", recursive = TRUE)
  read.arriba <- function(x) {
    print(x)
    dat <- read_tsv(file.path(topDir,x),col_types = readr::cols(breakpoint1 = readr::col_character(),breakpoint2 = readr::col_character())) %>%
      dplyr::rename( "annots"="[]",
                     "strand1.gene.fusion."="strand1(gene/fusion)",
                     "strand2.gene.fusion."="strand2(gene/fusion)") %>%
      as.data.frame()
    
    return(dat)
  }
  new_arriba <- lapply(lfiles, read.arriba)
  new_arriba <- data.table::rbindlist(new_arriba)
  
  # read and merge starfusion files
  lfiles <- list.files(path = topDir, pattern = "*.starfusion_formatted.tsv", recursive = TRUE)
  read.starfusion <- function(x) {
    print(x)
    dat <- read_tsv(file.path(topDir,x),col_types = 
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
