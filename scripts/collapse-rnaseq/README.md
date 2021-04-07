## Collapse RNA-seq matrices

This script is folk from OpenPBTA: https://github.com/AlexsLemonade/OpenPBTA-analysis/tree/master/analyses/collapse-rnaseq 

Also adding `expected_count` collapse matrix. 

Many downstream modules require RNA-seq data that have gene symbols as gene identifiers.
Multiple Ensembl gene identifiers map to the same gene symbol in a small proportion of cases.
This module contains the script used to create RSEM matrices with duplicate gene symbols removed, by first filtering to only genes with FPKM > 0 and then selecting the instance of the gene symbol with the maximum mean FPKM value across samples.
It produces the following files included in the data download:

```
pbta-gene-expression-rsem-fpkm-collapsed.polya.rds
pbta-gene-expression-rsem-fpkm-collapsed.stranded.rds
pbta-gene-counts-rsem-expected_count.polya.rds
pbta-gene-counts-rsem-expected_count.stranded.rds
```

To run the steps that generate the matrices and display the results of a correlation analysis, use the following command (assuming you are in this directory):

```sh
bash run-collapse-rnaseq.sh
bash run-collapse-rnaseq_count.sh
```

### R scripts and notebook

* `01-summarize_matrices.R` - this script generates the collapsed matrices as described above.
In addition, this script calculates the average Pearson correlation between the values of the gene symbol that is kept and those duplicates that are discarded.
