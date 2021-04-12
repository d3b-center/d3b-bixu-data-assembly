FROM ubuntu:18.04
MAINTAINER Bo Zhang (zhangb1@email.chop.edu)

RUN apt-get update -y && \
apt-get install -y python3.6 python3-pip wget git bedtools pandoc && \
apt-get install -y build-essential libcairo2-dev libxt-dev libcurl4-gnutls-dev libxml2-dev libssl-dev libmariadbclient-dev libfontconfig1-dev libmagick++-dev libharfbuzz-dev libfribidi-dev libpq-dev

#install R 3.6

ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get install -y apt-transport-https software-properties-common && \
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 && \
add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/' && \
apt-get update -y && \
apt-get install -y r-base

RUN ln -s /usr/bin/python3.6 /usr/bin/python

#pip install fuctions
RUN pip3 install snakemake numpy pandas

#install R packages

RUN R -e "install.packages('devtools',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('dplyr',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('optparse',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('readr',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('matrixStats',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('tidyverse',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('cowplot',dependencies=TRUE, repos='http://cran.rstudio.com/')"

RUN R -e "install.packages('BiocManager',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "BiocManager::install('GenomicRanges', update = FALSE)"
RUN R -e "BiocManager::install('IRanges', update = FALSE)"
RUN R -e "BiocManager::install('annotatr', update = FALSE)"
RUN R -e "BiocManager::install('TxDb.Hsapiens.UCSC.hg38.knownGene', update = FALSE)"
RUN R -e "BiocManager::install('org.Hs.eg.db', update = FALSE)"
RUN R -e "BiocManager::install('AnnotationDbi', update = FALSE)"
RUN R -e "BiocManager::install('sva', update = FALSE)"
RUN R -e "BiocManager::install('ggpubr', update = FALSE)"
RUN R -e "BiocManager::install('Rtsne', update = FALSE)"

RUN git clone  https://github.com/d3b-center/d3b-bixu-data-assembly.git