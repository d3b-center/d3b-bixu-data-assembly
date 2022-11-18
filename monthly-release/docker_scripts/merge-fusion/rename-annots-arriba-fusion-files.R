suppressPackageStartupMessages(library("readr"))
suppressPackageStartupMessages(library("dplyr"))
suppressPackageStartupMessages(library("optparse"))


option_list <- list(
  make_option(c("-f", "--arribafusion"),type="character",
              help="Merged arriba file"),
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
arriba <- opt$arribafusion
outname_prefix <- opt$outname_prefix
outdir <- opt$outdir

df_arriba <- read_tsv(arriba,col_types = readr::cols(breakpoint1 = readr::col_character(),breakpoint2 = readr::col_character()))
new_arriba <- df_arriba %>%
      dplyr::rename("annots"="[]") %>%
      as.data.frame()
write_tsv(new_arriba, file.path(outdir, paste0(outname_prefix,"-arriba_formated.annotated.tsv.gz")))