#!/bin/bash
# Module author: Komal S. Rathi
# Shell script author: Jaclyn Taroni for ALSF CCDL
# 2019

# This script runs the steps for generating collapsed RNA-seq matrices
# and analyzing the correlation levels of multi-mapped Ensembl genes

set -e
set -o pipefail

# This script should always run as if it were being called from
# the directory it lives in.
script_directory="$(perl -e 'use File::Basename;
  use Cwd "abs_path";
  print dirname(abs_path(@ARGV[0]));' -- "$0")"
cd "$script_directory" || exit

# create results directory if it doesn't already exist
mkdir -p results

# generate collapsed matrices for poly-A and stranded datasets
libraryStrategies=("polya" "stranded")
for strategy in ${libraryStrategies[@]}; do

  Rscript --vanilla 01-summarize_matrices.R \
    -i pbta-gene-expression-rsem-fpkm.${strategy}.rds \
    -g gencode.v27.primary_assembly.annotation.gtf.gz \
    -m results/pbta-gene-expression-rsem-fpkm-collapsed.${strategy}.rds \
    -t results/pbta-gene-expression-rsem-fpkm-collapsed_table.${strategy}.rds

done

# generate collapsed matrices for poly-A and stranded datasets
libraryStrategies=("polya" "stranded")
for strategy in ${libraryStrategies[@]}; do
  Rscript --vanilla 01-summarize_matrices.R \
    -i pbta-gene-expression-rsem-tpm.${strategy}.rds \
    -g gencode.v27.primary_assembly.annotation.gtf.gz \
    -m results/pbta-gene-expression-rsem-tpm-collapsed.${strategy}.rds \
    -t results/pbta-gene-expression-rsem-tpm-collapsed_table.${strategy}.rds
done

