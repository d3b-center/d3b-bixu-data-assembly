suppressPackageStartupMessages(library("readr"))
suppressPackageStartupMessages(library("dplyr"))
suppressPackageStartupMessages(library("optparse"))


option_list <- list(
  make_option(c("-f", "--fusionlist"),type="character",
              help="Fusion calls from STARfusion"),
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
stardir <- opt$fusionlist
manifest <- opt$manifest
outname_prefix <- opt$outname_prefix
outdir <- opt$outdir

manifest <- read.csv(manifest, stringsAsFactors = F)
manifest <- manifest %>%
    select(biospecimen_id, file_name) %>% dplyr::rename(Kids_First_Biospecimen_ID = biospecimen_id, name = file_name)

manifest <- manifest[grep("[.]arriba[.]fusions[.]tsv|[.]STAR[.]fusion_predictions[.]abridged[.]coding_effect[.]tsv", manifest$name), ]

# read and merge star fusion files
read.star <- function(x) {
    print(x)
    df<-read_tsv(file.path(stardir, x),col_types = 
                      readr::cols( JunctionReadCount = readr::col_character(),
                                   SpanningFragCount = readr::col_character(),
                                   FFPM = readr::col_character(),
                                   LeftBreakEntropy = readr::col_character(),
                                   RightBreakEntropy= readr::col_character()))
    filename <- x
    colnames(df)[colnames(df) == "#FusionName"]<-"FusionName"
    sample.id <- manifest[which(manifest$name %in% filename), "Kids_First_Biospecimen_ID"]
    df$tumor_id<-rep(sample.id,nrow(df))
    dat <- df %>%
      as.data.frame()

    return(dat)
}

lfiles <- list.files(path = stardir, pattern = "*.STAR.fusion_predictions.abridged.coding_effect.tsv", recursive = TRUE)
new_star <- lapply(lfiles, read.star)
new_star <- data.table::rbindlist(new_star)

write_tsv(new_star, file.path(outdir, paste0(outname_prefix,"-fusion-starfusion.tsv.gz")))