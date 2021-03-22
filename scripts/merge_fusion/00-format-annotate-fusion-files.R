# Author: Krutika Gaonkar for D3b
# 
suppressPackageStartupMessages(library("sevenbridges"))
suppressPackageStartupMessages(library("tidyverse"))
suppressPackageStartupMessages(library("optparse"))
suppressPackageStartupMessages(library("dplyr"))

option_list <- list(
  make_option(c("-m","--manifest"),
              type = "character", default = NA,
              help = "manifest for the fusion files to format and combine from cavatica [CSV]"),
  make_option(c("-u", "--username"),
              type = "character", default = NA,
              help = "cavatica username
              if files need to be downloaded with --file_ids"),
  make_option(c("-p", "--projectid"),
              type = "character",
              help = " if download= TRUE mandatory; cavatica project id"
  ),
  make_option(c("-a", "--app_id"),
              type = "character", default = "kfdrc-fusion-formatting-wf",
              help = "app_id for formatting fusion eg. gaonkark/pbta-merge-fusion/kfdrc-fusion-formatting-wf")
)

root_dir <- rprojroot::find_root(rprojroot::has_dir(".git"))
setwd(root_dir)

# Get command line options, if help option encountered print help and exit,
opt <- parse_args(OptionParser(option_list = option_list))
manifest <- opt$manifest
app_id <- opt$app_id
username <- opt$username
projectid <- opt$projectid


############to run tasks and download required files##############
# your token should be provided in ~/.sevenbridges/credentials
(a <- Auth(profile_name = "cavatica", from = "file"))
a$user(username = username)


manifest<-read_csv(manifest) %>%
  #remove if pdf frrom arriba is also in manifest
  dplyr::filter(!grepl("pdf",name))
arriba_files<-manifest %>%
  dplyr::filter(grepl("arriba",name,perl = TRUE) ) %>%
  dplyr::select("Kids First Biospecimen ID","name","id")  
starfusion_files<-manifest %>%
  dplyr::filter(grepl("STAR.fusion",name)) %>%
  dplyr::select("Kids First Biospecimen ID","name","id")  

# merge starfusion and arriba files by Kids First Biospecimen ID
fusion_files<-full_join(arriba_files,starfusion_files,
                        by="Kids First Biospecimen ID",
                        suffix = c(".arriba", ".starfusion")) %>%
  as.data.frame()


run_format_fusion <-function(i=1){
  # run formatting
  p<-a$project(id=projectid)
  arriba_file<-p$file(id=fusion_files[i,"id.arriba"])
  starfusion_file<- p$file(id=fusion_files[i,"id.starfusion"]) 
  app_id<-app_id
  tsk<-a$project(projectid)$task_add(
    name = paste0("Format fusion",fusion_files[i,"Kids First Biospecimen ID"]),
    app = app_id,
    inputs = list(arriba_output_file=arriba_file,
                  star_fusion_output_file=starfusion_file,
                  output_basename=paste0(fusion_files[i,"Kids First Biospecimen ID"],".arriba_formatted"),
                  # 	kfdrc-fusion-formatting-wf the col_num is 25 
                  col_num=25,
                  sample_name=fusion_files[i,"Kids First Biospecimen ID"])
  )
  # run
  # tsk$run()
}

lapply(1:nrow(fusion_files),function(x) run_format_fusion(i=x))

#tsk <- a$project("PBTA Merge fusion")$task("FormatFusion")




