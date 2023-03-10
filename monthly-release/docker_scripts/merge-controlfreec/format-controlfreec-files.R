suppressPackageStartupMessages(library("readr"))
suppressPackageStartupMessages(library("dplyr"))
suppressPackageStartupMessages(library("optparse"))


option_list <- list(
  make_option(c( "--pvalue"),type="character",
              help="controlFreeC p-value files"),
  make_option(c("--info"),type="character",
              help="controlFreeC info files"),
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
pvaluedir <- opt$pvalue
infodir <- opt$info
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

manifest <- manifest[grep("[.]controlfreec|[.]CNVs[.]p[.]value[.]txt", manifest$name), ]


# read and merge files
read.pvalue <- function(x) {
    df<-read_tsv(file.path(pvaluedir, x),col_types = 
                      readr::cols( chr = readr::col_character(),
                                   start = readr::col_character(),
                                   end = readr::col_character()))
    filename <- x
    sample.id <- manifest[which(manifest$name %in% filename), "Kids_First_Biospecimen_ID"]
    df$Kids_First_Biospecimen_ID<-rep(sample.id,nrow(df))
    dat <- df %>% as.data.frame()
    return(dat)
}

pvalue_files <- list.files(path = pvaluedir, pattern = c("*.controlfreec.CNVs.p.value.txt", "*.CNVs.p.value.txt"), recursive = TRUE)
newpvalue_files <- manifest[which(manifest$name %in% pvalue_files), "name"]
new_pvalue <- lapply(newpvalue_files, read.pvalue)
new_pvalue <- data.table::rbindlist(new_pvalue)


read.info <- function(x) {
    df<-read_tsv(file.path(infodir, x),col_types = 
                      readr::cols(Program_Version = readr::col_character()))
    colnames(df)<-c("item","tumor_ploidy")
    newdf<-subset(df, item == "Output_Ploidy")
    filename <- x
    sample.id <- manifest[which(manifest$name %in% filename), "Kids_First_Biospecimen_ID"]
    newdf$Kids_First_Biospecimen_ID<-rep(sample.id,nrow(newdf))
    dat <- newdf[,c("Kids_First_Biospecimen_ID","tumor_ploidy")] %>%
      as.data.frame()
    return(dat)
}
info_files <- list.files(path = infodir, pattern = c("*.controlfreec.info.txt","*.controlfreec.reheader.info.txt"), recursive = TRUE)
newinfo_files <- manifest[which(manifest$name %in% info_files), "name"]
new_info <- lapply(newinfo_files, read.info)
new_info <- data.table::rbindlist(new_info)

write_tsv(new_pvalue, file.path(outdir, paste0(outname_prefix,"-controlfreec.CNVs.p.value.txt")))
write_tsv(new_info,file.path(outdir, paste0(outname_prefix,"-controlfreec.info.txt")))