# Author: Krutika Gaonkar
# Merge step from Komal Rathi's code in OpenPBTA
# Date: 05/10/2020
# Function:
# merges new RSEM files into previous version of rsem RDS object

# load libraries
suppressPackageStartupMessages(library(optparse))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(reshape2))
suppressPackageStartupMessages(library(stringr))

# read params
option_list <- list(
  make_option(c("--inputdir"),
    type = "character",
    help = "Input directory for RSEM files"
  ),
  make_option(c("--manifest"),
    type = "character",
    help = "Manifest file "
  ),
  make_option(c("--manifest_format"),
              type = "character", default = "csv",
              help = "csv if manifest downloaded from cavatic GUI,json/yaml format if provided by bix-ops"
  ),
  make_option(c("--outdir"),
    type = "character",
    help = "Path to output directory"
  ),
  make_option(c("-d", "--download"),
    type = "logical",
    help = "download from cavatica", default = TRUE
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
  make_option(c("-c", "--old_rsem_count"),
    type = "character",
    help = "Path to old count files", default = NULL
  ),
  make_option(c("-f", "--old_rsem_fpkm"),
    type = "character",
    help = "Path to old fpkm merged files", default = NULL
  ),
  make_option(c("-t", "--old_rsem_tpm"),
    type = "character",
    help = "Path to old tpm merged files", default = NULL
  ),
  make_option(c("-o", "--outname_prefix"),
    type = "character",
    help = "outname prefix"
  ),
  make_option(c("-l", "--library"),
              type = "character",
              help = "outname prefix"
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
old_rsem_fpkm <- opt$old_rsem_fpkm
old_rsem_tpm <- opt$old_rsem_tpm
old_rsem_count <- opt$old_rsem_count
outname_prefix <- opt$outname_prefix
mergefiles <- opt$mergefiles
library <- opt$library

# read manifest file
if (manifest_format == "csv"){
  manifest <- read.csv(manifest, stringsAsFactors = F)
  manifest <- manifest %>%
    select(Kids.First.Biospecimen.ID, name, id) %>% dplyr::rename(Kids_First_Biospecimen_ID = Kids.First.Biospecimen.ID)
} 


if (manifest_format=="json" || manifest_format == "yaml"){
  manifest <- rlist::list.load(manifest)
  
  manifest <- data.frame("Kids_First_Biospecimen_ID" = unlist(lapply(manifest$`rnaseq-analysis`,function(x) x$kf_biospecimen_id)),
                            "name" = unlist(lapply(manifest$`rnaseq-analysis`,function(x) 
                              gsub(".*[/]","",x$filepath))),
                            "id" = unlist(lapply(manifest$`rnaseq-analysis`,function(x) x$cavatica_id)))
  
}

manifest <- manifest[grep("[.]rsem[.]genes[.]results[.]gz", manifest$name), ]

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
  
  # read and merge RSEM genes files
  lfiles <- list.files(path = topDir, pattern = "*.rsem.genes.results.gz", recursive = TRUE)
  read.rsem <- function(x) {
    print(x)
    dat <- data.table::fread(file.path(topDir, x))
    filename <- x
    sample.id <- manifest[which(manifest$name %in% filename), "Kids_First_Biospecimen_ID"]
    dat$Sample <- sample.id
    return(dat)
  }
  expr <- lapply(lfiles, read.rsem)
  expr <- data.table::rbindlist(expr)
  expr.fpkm <- dcast(expr, gene_id ~ Sample, value.var = "FPKM") %>%
    # FPKM
    as.data.frame()
  expr.counts <- dcast(expr, gene_id ~ Sample, value.var = "expected_count") %>%
    # counts
    as.data.frame()
  expr.tpm <- dcast(expr, gene_id ~ Sample, value.var = "TPM") %>%
    # TPM
    as.data.frame()
  
  # merge per gene_id
  rnaseq.fpkm <- expr.fpkm[, c("gene_id", manifest$Kids_First_Biospecimen_ID)]
  rnaseq.counts <- expr.counts[, c("gene_id", manifest$Kids_First_Biospecimen_ID)]
  rnaseq.tpm <- expr.tpm[, c("gene_id", manifest$Kids_First_Biospecimen_ID)]
  
  
  if (!is.null(old_rsem_count)) {
    # read old file
    old_rsem_count <- readRDS(old_rsem_count)
    # get new samples
    new_samples <- setdiff(colnames(rnaseq.counts), colnames(old_rsem_count))
    print(paste0("adding ", toString(new_samples)))
    # merge with old file
    all_rnaseq_rsem.counts <- old_rsem_count %>% left_join(rnaseq.counts[, c("gene_id", new_samples)], by = "gene_id")
    # save output
    saveRDS(all_rnaseq_rsem.counts, file = file.path(outdir, paste0(outname_prefix, "-gene-counts-rsem-expected_count.",library,".rds")))
  }
  
  if (!is.null(old_rsem_fpkm)) {
    # read old file
    old_rsem_fpkm <- readRDS(old_rsem_fpkm)
    # get new samples
    new_samples <- setdiff(colnames(rnaseq.counts), colnames(old_rsem_fpkm))
    print(paste0("adding ", toString(new_samples)))
    # merge with old file
    all_rnaseq_rsem.fpkm <- old_rsem_fpkm %>% left_join(rnaseq.fpkm[, c("gene_id", new_samples)], by = "gene_id")
    # save output
    saveRDS(all_rnaseq_rsem.fpkm, file = file.path(outdir, paste0(outname_prefix, "-gene-expression-rsem-fpkm.",library,".rds")))
  }
  
  if (!is.null(old_rsem_tpm)) {
    # read old file
    old_rsem_tpm <- readRDS(old_rsem_tpm)
    # get new samples
    new_samples <- setdiff(colnames(rnaseq.counts), colnames(old_rsem_tpm))
    print(paste0("adding ", toString(new_samples)))
    # merge with old file
    all_rnaseq_rsem.tpm <- old_rsem_tpm %>% left_join(rnaseq.tpm[, c("gene_id", new_samples)], by = "gene_id")
    # save output
    saveRDS(all_rnaseq_rsem.tpm, file = file.path(outdir, paste0(outname_prefix, "-gene-expression-rsem-tpm.",library,".rds")))
  }
  
}

print("Done!")
