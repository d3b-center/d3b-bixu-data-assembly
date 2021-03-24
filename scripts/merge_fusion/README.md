# Merge StarFusion and Arriba 


### Description

- The folder scripts are orginal written by @kgaonkar6 from here: https://github.com/d3b-center/ngs_assembly_rna/tree/main/analyses/merge_fusion

- Made some changes in the inputs, read files directly and skip the download steps


```

Usage: 01-create-and-add-fusion-files.R 

Options:
	--input_arriba=INPUT_ARRIBA
		Input file for arriba fusion files

	--input_star_fusion=INPUT_STAR_FUSION
		Input file for star fusion file

	--outdir=OUTDIR
		Path to output directory for merged files

	-m MERGEFILES, --mergefiles=MERGEFILES
		 TRUE to merge file and FALSE when only need them downloaded

	-a OLD_ARRIBA, --old_arriba=OLD_ARRIBA
		Path to old merged arriba files

	-s OLD_STARFUSION, --old_starfusion=OLD_STARFUSION
		Path to old merged starfusion files

	-o OUTNAME_PREFIX, --outname_prefix=OUTNAME_PREFIX
		outname prefix for merged files

	-h, --help
		Show this help message and exit

```
