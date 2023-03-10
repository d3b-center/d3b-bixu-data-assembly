library(readr)
library(dplyr)
library(tibble)
library(optparse)

option_list <- list(
  make_option(c( "--dgd_maf"),type="character",
              help="DGD vep maf file"),
  make_option(c("--bix_maf"),type="character",
              help="an example bix vep maf file"),
  make_option(c("--outdir"),type = "character",
              help = "Path to output directory for merged files"),
  make_option(c("-o", "--outname_prefix"),
              type = "character",
              help = "outname prefix for merged files")
)

opt <- parse_args(OptionParser(option_list=option_list))
dgd_maf <- opt$dgd_maf
bix_maf <- opt$bix_maf
outdir <- opt$outdir
outname_prefix <- opt$outname_prefix

example <- read.table(bix_maf,sep='\t',header = TRUE)
example_colnames <- colnames(example)

comment_name <- read_tsv(dgd_maf, n_max = 1,col_names=FALSE)
df <- read_tsv(dgd_maf,skip = 1)
df_colnames <- colnames(df)


keep_columns <- df_colnames[df_colnames %in% example_colnames]
add_columns <- example_colnames[!example_colnames %in% df_colnames]

df2 <- select(df, keep_columns)
for (newcol in add_columns){
  df2[newcol]= NA
}

name_t <- names(df2)
data <- rbind(name_t,df2)
names(data) <- comment_name

dat <- data %>% as.data.frame()
write_tsv(dat,file.path(outdir, paste0(outname_prefix,".dgd_format.maf")),na = "")
