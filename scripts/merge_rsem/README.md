# Merge rsem files

The Steps for merging the rsem files: 

```
Usage: 00-create-and-add-rsem-gene-files.R [options]


Options:
	--input_rsem=INPUT_RSEM
		Input directory for RSEM files

	--outdir=OUTDIR
		Path to output directory

	-m MERGEFILES, --mergefiles=MERGEFILES
		 TRUE to merge file and FALSE when only need them downloaded

	-c OLD_RSEM_COUNT, --old_rsem_count=OLD_RSEM_COUNT
		Path to old count files

	-f OLD_RSEM_FPKM, --old_rsem_fpkm=OLD_RSEM_FPKM
		Path to old fpkm merged files

	-t OLD_RSEM_TPM, --old_rsem_tpm=OLD_RSEM_TPM
		Path to old tpm merged files

	-o OUTNAME_PREFIX, --outname_prefix=OUTNAME_PREFIX
		outname prefix

	-l LIBRARY, --library=LIBRARY
		outname prefix

	-b BIOSPECIMENS_ID, --biospecimens_id=BIOSPECIMENS_ID
		Biospecimens ID for the RNAseq tumor

	-h, --help
		Show this help message and exit

```
