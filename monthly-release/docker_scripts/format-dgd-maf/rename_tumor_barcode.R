library(readr)
library(dplyr)
library(tibble)
library(optparse)

option_list <- list(
  make_option(c( "--dgd_maf"),type="character",
              help="DGD vep maf file"),
  make_option(c( "--manifest"),type="character",
              help="DGD maf file manifest"),
  make_option(c("--outdir"),type = "character",
              help = "Path to output directory for merged files"),
  make_option(c("-o", "--outname_prefix"),
              type = "character",
              help = "outname prefix for merged files")
)

opt <- parse_args(OptionParser(option_list=option_list))
dgd_maf <- opt$dgd_maf
dgd_manifest <- opt$manifest
outdir <- opt$outdir
outname_prefix <- opt$outname_prefix

manifest <- read.csv(dgd_manifest)
comment_name <- read_tsv(dgd_maf, n_max = 1,col_names=FALSE)


rename_bs <- function(x) {
  dat <- read_tsv(x,skip = 1)
  tumorid <- dat$Tumor_Sample_Barcode
  bsid <- manifest[which(manifest$tumor_id %in% tumorid), "biospecimen_id"]
  dat$Tumor_Sample_Barcode <- bsid
  n <- dat %>% as.data.frame()
  return(n)
}

newmaf <- lapply(dgd_maf, rename_bs)
new_maf <- data.table::rbindlist(newmaf)
new_df<- as.data.frame(new_maf)

name_t <- names(new_df)
data <- rbind(name_t,new_df)
names(data) <- comment_name$X1
write_tsv(data,file.path(outdir, paste0(outname_prefix,"_rename.maf")), na = "")
