# Function:
# merges all RSEM files into RDS object

# load libraries
suppressPackageStartupMessages(library(optparse))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(reshape2))
suppressPackageStartupMessages(library(stringr))

# read params
option_list <- list(
  make_option(c("--starcountslist"),
    type = "character",
    help = "list of RSEM files"
  ),
  make_option(c("--manifest"),
    type = "character",
    help = "Manifest file "
  ),
  make_option(c("--histology"),
    type = "character",
    help = "histology file"
  ),
  make_option(c("--outdir"),
  type = "character",
  help = "Path to output directory"
),
  make_option(c("-o", "--outname_prefix"),
    type = "character",
    help = "outname prefix"
  )
)

# parse the parameters
opt <- parse_args(OptionParser(option_list = option_list))
resemdir <- opt$starcountslist
manifest <- opt$manifest
histology <- opt$histology
outdir <- opt$outdir
outname_prefix <- opt$outname_prefix

# read manifest file
manifest <- read.csv(manifest, stringsAsFactors = F)
manifest <- manifest %>%
    select(biospecimen_id, file_name) %>% dplyr::rename(Kids_First_Biospecimen_ID = biospecimen_id, name = file_name)


manifest <- manifest[grep("ReadsPerGene[.]out[.]tab[.]gz", manifest$name), ]
his <- read_tsv(histology)

# read and merge RSEM genes files
read.rsem <- function(x) {
  dat <- data.table::fread(file.path(resemdir, x))
  filename <- x
  sample.id <- manifest[which(manifest$name %in% filename), "Kids_First_Biospecimen_ID"]
  lib <- his[which(his$Kids_First_Biospecimen_ID==sample.id),"RNA_library"]
  dat$Sample <- sample.id
  dat$RNA_library <- lib
  names(dat) <- c("gene_id","un_counts","counts1","counts2","Sample","RNA_library")
  return(dat)
}

lfiles <- list.files(path = resemdir, pattern = "*ReadsPerGene.out.tab.gz", recursive = TRUE)

expr <- lapply(lfiles, read.rsem)
expr <- data.table::rbindlist(expr)
depr_df <- expr %>% 
  mutate(counts = if_else(RNA_library == 'poly-A', un_counts, counts2))

expr.counts <- dcast(depr_df, gene_id ~ Sample, value.var = "counts") %>%
  as.data.frame()

saveRDS(expr.counts, file = file.path(outdir, paste0(outname_prefix, "-gene-counts-star-counts-collapsed.rds")))

print("Done!")
