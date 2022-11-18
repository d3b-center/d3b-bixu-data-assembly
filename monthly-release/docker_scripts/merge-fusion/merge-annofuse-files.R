suppressPackageStartupMessages(library("readr"))
suppressPackageStartupMessages(library("dplyr"))
suppressPackageStartupMessages(library("optparse"))


option_list <- list(
  make_option(c("-f", "--annofuselist"),type="character",
              help="annofuse calls"),
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
annofusedir <- opt$annofuselist
outname_prefix <- opt$outname_prefix
outdir <- opt$outdir

# read and merge annofuse files
read.annofuse <- function(x) {
    print(x)
    df<-read_tsv(file.path(annofusedir, x),col_types = 
                      readr::cols( JunctionReadCount = readr::col_character(),
                                   SpanningFragCount = readr::col_character(),
                                   LeftBreakpoint = readr::col_character(),
                                   RightBreakpoint= readr::col_character()))
    f <- subset(df,select=c("Sample","FusionName"))
    tmpdf <- df[ , -which(colnames(df) %in% c("Sample","FusionName"))]
    dat <- cbind(f,tmpdf) %>%
      as.data.frame()
    return(dat)
}

lfiles <- list.files(path = annofusedir, pattern = "*.annoFuse_filter.tsv", recursive = TRUE)
new_annofuse <- lapply(lfiles, read.annofuse)
new_annofuse <- data.table::rbindlist(new_annofuse)

write_tsv(new_annofuse, file.path(outdir, paste0(outname_prefix,"-annoFuse_filter.tsv.gz")))