suppressPackageStartupMessages(library("readr"))
suppressPackageStartupMessages(library("dplyr"))
suppressPackageStartupMessages(library("optparse"))


option_list <- list(
  make_option(c( "--cnslist"),type="character",
              help="CNVkit cns files"),
  make_option(c("--seglist"),type="character",
              help="CNVkit seg files"),
  make_option(c("--manifest"),
    type = "character",
    help = "Manifest file "
  ),
  make_option(c("--experiment"),type = "character",help = "WGS/WXS/All"),
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
cnsdir <- opt$cnslist
segdir <- opt$seglist
manifest <- opt$manifest
exper <- opt$experiment
outname_prefix <- opt$outname_prefix
outdir <- opt$outdir

manifest <- read.csv(manifest, stringsAsFactors = F)

if(exper=='WGS'){
  manifest <-subset(manifest,experiment_strategy=="WGS")
} else if (exper=='WXS'){
  manifest <-subset(manifest,experiment_strategy!="WGS")
} else {
  manifest <- manifest
}

manifest <- manifest %>%
    select(biospecimen_id, file_name) %>% dplyr::rename(Kids_First_Biospecimen_ID = biospecimen_id, name = file_name)

manifest <- manifest[grep("[.]call[.]cns|[.]call[.]seg", manifest$name), ]

# read and merge call.cns files
read.cns <- function(x) {
    df<-read_tsv(file.path(cnsdir, x),col_types = 
                      readr::cols( start = readr::col_character(),
                                   end = readr::col_character(),
                                   cn = readr::col_character()))
    filename <- x
    sample.id <- manifest[which(manifest$name %in% filename), "Kids_First_Biospecimen_ID"]
    df$ID<-rep(sample.id,nrow(df))
    dat <- df[,c("ID","chromosome","start","end","cn")] %>%
      as.data.frame()
    return(dat)
}

cns_files <- list.files(path = cnsdir, pattern = "*.call.cns", recursive = TRUE)
newcns_files <- manifest[which(manifest$name %in% cns_files), "name"]
new_cns <- lapply(newcns_files, read.cns)
new_cns <- data.table::rbindlist(new_cns)


read.seg <- function(x) {
    df<-read_tsv(file.path(segdir, x),col_types = 
                      readr::cols( loc.start = readr::col_character(),
                                   loc.end = readr::col_character(),
                                   seg.mean = readr::col_character(),
                                   num.mark = readr::col_character()))
    dat <- df %>%
      as.data.frame()
    return(dat)
}
seg_files <- list.files(path = cnsdir, pattern = "*.call.seg", recursive = TRUE)
newseg_files <- manifest[which(manifest$name %in% seg_files), "name"]
new_seg <- lapply(newseg_files, read.seg)
new_seg <- data.table::rbindlist(new_seg)

write_tsv(new_cns, file.path(outdir, paste0(outname_prefix,"-call.cns")))
write_tsv(new_seg,file.path(outdir, paste0(outname_prefix,"-call.seg")))