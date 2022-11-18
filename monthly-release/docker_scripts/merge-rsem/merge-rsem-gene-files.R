# Function:
# merges all RSEM files into RDS object

# load libraries
suppressPackageStartupMessages(library(optparse))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(reshape2))
suppressPackageStartupMessages(library(stringr))

# read params
option_list <- list(
  make_option(c("--rsemlist"),
    type = "character",
    help = "list of RSEM files"
  ),
  make_option(c("--manifest"),
    type = "character",
    help = "Manifest file "
  ),
  make_option(c("--histology"),
    type = "character",
    help = "Manifest file "
  ),
  make_option(c("--outdir"),
    type = "character",
    help = "Path to output directory"
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
resemdir <- opt$rsemlist
manifest <- opt$manifest
histology <- opt$histology
outdir <- opt$outdir
outname_prefix <- opt$outname_prefix
library_info <- opt$library

# read manifest file
manifest <- read.csv(manifest, stringsAsFactors = F)
manifest <- manifest %>%
    select(biospecimen_id, file_name) %>% dplyr::rename(Kids_First_Biospecimen_ID = biospecimen_id, name = file_name)

manifest <- manifest[grep("[.]rsem[.]genes[.]results[.]gz", manifest$name), ]

# read histolgy file
histology <- read.table(histology,sep=',',header = TRUE, stringsAsFactors = FALSE)
histology <- histology %>%
    select(Kids_First_Biospecimen_ID, RNA_library) %>% dplyr::rename(library = RNA_library)
histology[is.na(histology)] <-  'stranded'
histology$library[which(histology$library == 'exome_capture')] <-'stranded'
histology$library[which(histology$library == 'poly-A')] <-'polya'

filter_histology <- subset(histology, library==library_info)

# read and merge RSEM genes files
read.rsem <- function(x) {
  dat <- data.table::fread(file.path(resemdir, x))
  filename <- x
  sample.id <- manifest[which(manifest$name %in% filename), "Kids_First_Biospecimen_ID"]
  dat$Sample <- sample.id
  return(dat)
}

lfiles <- list.files(path = resemdir, pattern = "*.rsem.genes.results.gz", recursive = TRUE)

exp <- lapply(lfiles, read.rsem)
exp <- data.table::rbindlist(exp)

expr <- subset(exp, Sample %in% filter_histology$Kids_First_Biospecimen_ID)

expr.fpkm <- dcast(expr, gene_id ~ Sample, value.var = "FPKM") %>%
  # FPKM
  as.data.frame()
expr.counts <- dcast(expr, gene_id ~ Sample, value.var = "expected_count") %>%
  # counts
  as.data.frame()
expr.tpm <- dcast(expr, gene_id ~ Sample, value.var = "TPM") %>%
  # TPM
  as.data.frame()

saveRDS(expr.counts, file = file.path(outdir, paste0(outname_prefix, "-gene-counts-rsem-expected_count.",library_info,".rds")))
saveRDS(expr.fpkm, file = file.path(outdir, paste0(outname_prefix, "-gene-expression-rsem-fpkm.",library_info,".rds")))
saveRDS(expr.tpm, file = file.path(outdir, paste0(outname_prefix, "-gene-expression-rsem-tpm.",library_info,".rds")))

print("Done!")
