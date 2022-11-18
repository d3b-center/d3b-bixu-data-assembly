# Function:
# merges new RSEM files into previous version of rsem RDS object

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
outdir <- opt$outdir
outname_prefix <- opt$outname_prefix
library <- opt$library

# read manifest file
manifest <- read.table(manifest, sep=",",head = TRUE)
manifest <- manifest %>%
    select(biospecimen_id, file_name) %>% dplyr::rename(Kids_First_Biospecimen_ID = biospecimen_id, name = file_name)


manifest <- manifest[grep("[.]rsem[.]isoforms[.]results[.]gz", manifest$name), ]

# read and merge RSEM isoform files
read.rsem <- function(x) {
  dat <- data.table::fread(file.path(resemdir, x))
  filename <- x
  sample.id <- manifest[which(manifest$name %in% filename), "Kids_First_Biospecimen_ID"]
  dat$Sample <- sample.id
  return(dat)
}

lfiles <- list.files(path = resemdir, pattern = "*.rsem.isoforms.results.gz", recursive = TRUE)
expr <- lapply(lfiles, read.rsem)
expr <- data.table::rbindlist(expr)

# split gene id and symbol
expr <- expr %>% 
  mutate(transcript_id = str_replace(transcript_id, "_PAR_Y_", "_"))  %>%
  separate(transcript_id, c("transcript_id", "gene_symbol"), sep = "\\_", extra = "merge") %>%
  unique()

expr.counts <- dcast(expr, transcript_id ~ Sample, value.var = "expected_count") %>%
  # counts
  as.data.frame()
expr.tpm <- dcast(expr, transcript_id ~ Sample, value.var = "TPM") %>%
  # TPM
  as.data.frame()
expr.fpkm <- dcast(expr, transcript_id ~ Sample, value.var = "FPKM") %>%
  # TPM
  as.data.frame()

saveRDS(expr.counts, file = file.path(outdir, paste0(outname_prefix, "-isoform-counts-rsem-expected_count.",library,".rds")))
saveRDS(expr.tpm, file = file.path(outdir, paste0(outname_prefix, "-isoform-expression-rsem-tpm.",library,".rds")))
saveRDS(expr.fpkm, file = file.path(outdir, paste0(outname_prefix, "-isoform-expression-rsem-fpkm.",library,".rds")))

print("Done!")