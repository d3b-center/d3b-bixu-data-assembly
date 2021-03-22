# Author : Krutika Gaonkar for D3b
# Date: 05/10/2019
# Function:
# upload new files to cavatica


# load libraries
suppressPackageStartupMessages(library(optparse))
suppressPackageStartupMessages(library("sevenbridges"))

# read params
option_list <- list(
  make_option(c("--file"),
              type = "character",
              help = "file to upload"
  ),
  make_option(c("-u", "--username"),
              type = "character",
              help = "if download= TRUE mandatory;  cavatica username "
  ),
  make_option(c("-p", "--projectid"),
              type = "character",
              help = " if download= TRUE mandatory; cavatica project id"
  )
)

# your token should be provided in ~/.sevenbridges/credentials
(a <- Auth(profile_name = "cavatica", from = "file"))
a$user(username = opt$username)

p <- a$project(id = opt$projectid)
fl <- opt$file
fl <- p$upload(fl)

(root_folder <- p$get_root_folder())
# == Files ==
# id : 5d3090bce4b0359d9af066f1
# name : processed-data-merge
# project : cavatica/pbta
# parent : 5d2f5584e4b07ea2a7690ebc
# type : folder
folder<-p$file(id="5d3090bce4b0359d9af066f1")
list_versions <- folder$list_folder_contents()
list_versions <- data.frame("name"=unlist(lapply(list_versions , function(x) x$name)),
                            "id" = unlist(lapply(list_versions , function(x) x$id)),stringsAsFactors = FALSE)

destination_folder_id <- list_versions %>% dplyr::filter(name== opt$version_folder) %>% pull(id)

Sys.sleep(30)

fl$move_to_folder(destination_folder_id, name_new = NULL)
