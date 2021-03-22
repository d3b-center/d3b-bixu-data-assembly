
#run the Rscript for analysis of dropped genes

# load libraries
suppressPackageStartupMessages(library(optparse))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(knitr))
suppressPackageStartupMessages(library(DT))

# read params
option_list <- list(
  make_option(c("--input_collapsed_rds"),
    type = "character",
    help = "Input collapsed rds file"
  ),
  make_option(c("-s", "--strandness"),
    type = "character",
    help = "strandness info polya/stranded"
  )
)

opt <- parse_args(OptionParser(option_list = option_list))


viewDataTable <- function(dat){
  DT::datatable(dat,
                rownames = FALSE,
                filter = "bottom",
                class = 'cell-border stripe',
                options = list(pageLength = 5,
                               searchHighlight = TRUE,
                               scrollX = TRUE,
                               dom = 'tpi',
                               initComplete = JS("function(settings, json) {",
                                            "$(this.api().table().header()).css({'background-color':
                                            '#004467', 'color': '#fff'});","}"))
                )
}

annot.table <- readRDS(opt$input_collapsed_rds)
viewDataTable(annot.table %>% 
                dplyr::filter(ensembl_id == "Multiple",
                              !is.na(avg.cor)))

dat <- annot.table %>% 
  filter(expressed == "No") %>%
  group_by(gene_type)  %>%
  summarise(count = n()) 
viewDataTable(dat)

dat <- annot.table %>% 
  filter(ensembl_id == "Multiple" & keep == "No") %>%
  group_by(gene_type)  %>%
  summarise(count = n()) 
viewDataTable(dat)

data.frame(
#  strategy = c("poly-A", "stranded"),
  number_of_NA = c(nrow(annot.table %>% 
                          filter(ensembl_id == "Multiple",
                                 is.na(avg.cor))))
)

