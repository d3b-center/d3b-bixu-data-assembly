FROM ubuntu:18.04
LABEL MAINTAINER="Xiaoyan Huang (huangx@email.chop.edu)"

RUN apt-get update -y && \
apt-get install -y python3.6 python3-pip wget git bedtools pandoc && \
apt-get install -y build-essential libcairo2-dev libxt-dev libcurl4-gnutls-dev libxml2-dev libssl-dev libmariadbclient-dev libfontconfig1-dev libmagick++-dev libharfbuzz-dev libfribidi-dev libpq-dev

#install R 3.6

ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get install -y locales
RUN locale-gen en_CA.UTF-8
ENV LC_ALL=en_CA.UTF-8
ENV LANG=en_CA.UTF-8
ENV LANGUAGE=en_CA.UTF-8

RUN apt-get install -y apt-transport-https software-properties-common && \
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 && \
add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/' && \
apt-get update -y && \
apt-get install -y r-base

RUN ln -s /usr/bin/python3.6 /usr/bin/python

#pip install fuctions for consensus CNV tools
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


ENV PYTHONIOENCODING=utf-8
RUN apt-get install locales language-pack-es -y \
    && locale-gen "en_US.UTF-8" "fr_FR.UTF-8" "es_MX.UTF-8" \
    "es_PA.UTF-8" "es_VE.UTF-8" "es_GT.UTF-8" "es_PE.UTF-8" \
    "es_ES.UTF-8"
ENV LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8" LC_ALL="en_US.UTF-8" LC_COLLATE="C" \
    PYTHONIOENCODING="UTF-8" TERM="xterm" DEBIAN_FRONTEND="noninteractive" \
    OPENBLAS_NUM_THREADS=1
COPY . ./scripts