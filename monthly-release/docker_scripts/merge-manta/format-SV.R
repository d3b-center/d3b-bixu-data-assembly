suppressPackageStartupMessages(library("readr"))
suppressPackageStartupMessages(library("dplyr"))
suppressPackageStartupMessages(library("optparse"))


option_list <- list(
  make_option(c( "--svlist"),type="character",
              help="Fusion calls from [STARfusion | Arriba]"),
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
svdir <- opt$sv
manifest <- opt$manifest
outname_prefix <- opt$outname_prefix
outdir <- opt$outdir

manifest <- read.csv(manifest, stringsAsFactors = F)
manifest <- manifest %>% 
  select(biospecimen_id,participant_id, normal_id,tumor_id,file_name) %>% 
  dplyr::rename(Kids_First_Biospecimen_ID = biospecimen_id, Kids.First.Participant.ID = participant_id, Kids.First.Biospecimen.ID.Normal = normal_id,Kids.First.Biospecimen.ID.Tumor = tumor_id, name = file_name)

manifest <- manifest[grep("[.]somaticSV[.]", manifest$name), ]
manifest <- manifest[!grepl(".tbi",  manifest$name),]
manifest$name <- gsub("vcf.gz", "annotated.tsv", manifest$name)

# read and merge files
read.sv <- function(x) {
    df<-read_tsv(file.path(svdir, x))
    colnames(df)[14] <- 'Normal'
    colnames(df)[15] <- 'Tumor'
    filename <- x

    pt.id <- manifest[which(manifest$name %in% filename), "Kids.First.Participant.ID"]
    normal.id <- manifest[which(manifest$name %in% filename), "Kids.First.Biospecimen.ID.Normal"]
    tumor.id <- manifest[which(manifest$name %in% filename), "Kids.First.Biospecimen.ID.Tumor"]
    df$Kids.First.Participant.ID<-rep(pt.id,nrow(df))
    df$Kids.First.Biospecimen.ID.Normal<-rep(normal.id,nrow(df))
    df$Kids.First.Biospecimen.ID.Tumor<-rep(tumor.id,nrow(df))
    dat <- df %>%
      as.data.frame()
    return(dat)
}

sv_files <- list.files(path = svdir, pattern = "*.annotated.tsv", recursive = TRUE)
new_sv <- lapply(sv_files, read.sv)
new_sv<- data.table::rbindlist(new_sv)

write_tsv(new_sv, file.path(outdir, paste0(outname_prefix,".somaticSV.annotated.tsv.gz")))