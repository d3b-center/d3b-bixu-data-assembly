# Author: Krutika Gaonkar for D3b
#
suppressPackageStartupMessages(library("sevenbridges"))
suppressPackageStartupMessages(library("tidyverse"))
suppressPackageStartupMessages(library("optparse"))
suppressPackageStartupMessages(library("dplyr"))

download_files_manifest <- function(manifest, username, projectid, outputfolder) {

  # create folder if missing
  if (!dir.exists(outputfolder)) {
    dir.create(outputfolder)
  } else {
    print("outputfolder already exists!")
  }

  if (!missing(manifest)) {
    ############ to download required files##############
    # your token should be provided in ~/.sevenbridges/credentials
    (a <- Auth(profile_name = "cavatica", from = "file"))
    a$user(username = username)

    # read fid for files in list
    list_fid <- manifest$id

    # to download files
    lapply(list_fid, function(x) {
      a$project(
        id = projectid
      )$file(id = as.character(x))$download(outputfolder)
    })
  } else {
    stop("Provide file with cavatica id to
       download")
  }
}
