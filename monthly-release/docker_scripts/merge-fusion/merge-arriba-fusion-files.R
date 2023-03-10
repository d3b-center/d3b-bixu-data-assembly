suppressPackageStartupMessages(library("readr"))
suppressPackageStartupMessages(library("dplyr"))
suppressPackageStartupMessages(library("optparse"))


option_list <- list(
  make_option(c("-f", "--fusionlist"),type="character",
              help="Fusion calls from Arriba"),
  make_option(c("--manifest"),
    type = "character",
    help = "Manifest file "
  ),
  make_option(c("--outdir"),
              type = "character",
              help = "Path to output directory for merged files"
  ),
  make_option(c("-o", "--outname_prefix"),
              type = "character",
              help = "outname prefix for merged files"
  )
)

# Get command line options, if help option encountered print help and exit,
opt <- parse_args(OptionParser(option_list=option_list))
arribadir <- opt$fusionlist
manifest <- opt$manifest
outname_prefix <- opt$outname_prefix
outdir <- opt$outdir

manifest <- read.csv(manifest, stringsAsFactors = F)
manifest <- manifest %>%
    select(biospecimen_id, file_name) %>% dplyr::rename(Kids_First_Biospecimen_ID = biospecimen_id, name = file_name)
manifest <- manifest[grep("[.]arriba[.]fusions[.]tsv|[.]STAR[.]fusion_predictions[.]abridged[.]coding_effect[.]tsv", manifest$name), ]

# read and merge arriba files
read.arriba <- function(x) {
    df<- read_tsv(file.path(arribadir, x),col_types = readr::cols(breakpoint1 = readr::col_character(),breakpoint2 = readr::col_character()))
    filename <- x
    sample.id <- manifest[which(manifest$name %in% filename), "Kids_First_Biospecimen_ID"]
    colnames(df)[colnames(df) == "#gene1"]<-"gene1"
    df$tumor_id<-rep(sample.id,nrow(df))
    df$`gene1--gene2`<-paste(df$gene1,df$gene2,sep="--")
    dat <- df %>%
          dplyr::rename("strand1.gene.fusion."="strand1(gene/fusion)",
                     "strand2.gene.fusion."="strand2(gene/fusion)") %>%
      as.data.frame()
    return(dat)
}

lfiles <- list.files(path = arribadir, pattern = "*.arriba.fusions.tsv", recursive = TRUE)
new_arriba <- lapply(lfiles, read.arriba)
new_arriba <- data.table::rbindlist(new_arriba)
write_tsv(new_arriba, file.path(outdir, paste0(outname_prefix,"-fusion-arriba.tsv.gz")))