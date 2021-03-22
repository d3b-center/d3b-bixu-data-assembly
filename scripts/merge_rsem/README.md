# Merge rsem files

The Steps for merging the rsem files are :
 1) Download rsem gene expression quantificaton files along with a manifest to merge with existing merged files from previous releases.
 	- Manifest is mandatory it can either be downloaded from cavatica project (deefault) or bix-ops generated json format manifest.
	- Files can be downloaded using the script with --download==TRUE or manually and placed in "INPUTDIR"
 2) Download rsem isoform expression quantificaton files along with a manifest to merge with existing merged files from previous releases.
	- Manifest is mandatory it can either be downloaded from cavatica project (deefault) or bix-ops generated json format manifest
	- Files can be downloaded using the script with --download==TRUE or manually and placed in "INPUTDIR"   


```
Rscript 00-create-and-add-rsem-gene-files.R --help

Options:
	--inputdir=INPUTDIR
		Input directory for RSEM files

	--manifest=MANIFEST
		Manifest file with cavatica downloaded csv file with colnames `Kids First Biospecimen ID, name, id`, json file with column names  `Kids_First_Biospecimen_ID,filepath,cavatica_id`

	--manifest_format=MANIFEST_FORMAT
		csv if manifest downloaded from cavatic GUI,json/yaml format if provided by bix-ops

	--outdir=OUTDIR
		Path to output directory for merged files

	-d DOWNLOAD, --download=DOWNLOAD
		TRUE to download from cavatica

	-u USERNAME, --username=USERNAME
		if download= TRUE mandatory;  cavatica username 

	-p PROJECTID, --projectid=PROJECTID
		 if download= TRUE mandatory; cavatica project id

	-m MERGEFILES, --mergefiles=MERGEFILES
		 TRUE to merge file and FALSE when only need them downloaded

	-c OLD_RSEM_COUNT, --old_rsem_count=OLD_RSEM_COUNT
		Path to old merged count files

	-f OLD_RSEM_FPKM, --old_rsem_fpkm=OLD_RSEM_FPKM
		Path to old merged fpkm files

	-t OLD_RSEM_TPM, --old_rsem_tpm=OLD_RSEM_TPM
		Path to old merged tpm files

	-o OUTNAME_PREFIX, --outname_prefix=OUTNAME_PREFIX
		outname prefix for merged files

        -l LIBRARY, --library=LIBRARY
		outname prefix

	-h, --help
		Show this help message and exit


Rscript 00-create-and-add-rsem-isoforms-files.R --help

Options:
	--inputdir=INPUTDIR
		Input directory for RSEM files

	--manifest=MANIFEST
		Manifest file with cavatica downloaded csv file with colnames `Kids First Biospecimen ID, name, id`, json file with column names  `Kids_First_Biospecimen_ID,filepath,cavatica_id`

	--manifest_format=MANIFEST_FORMAT
		csv if manifest downloaded from cavatic GUI,json/yaml format if provided by bix-ops

	--outdir=OUTDIR
		Path to output directory for merged files

	-d DOWNLOAD, --download=DOWNLOAD
		TRUE download from cavatica

	-u USERNAME, --username=USERNAME
		if download= TRUE mandatory;  cavatica username 

	-p PROJECTID, --projectid=PROJECTID
		 if download= TRUE mandatory; cavatica project id

	-m MERGEFILES, --mergefiles=MERGEFILES
		 TRUE to merge file and FALSE when only need them downloaded

	-c OLD_RSEM_COUNT, --old_rsem_count=OLD_RSEM_COUNT
		Path to old meerged count files

	-f OLD_RSEM_FPKM, --old_rsem_fpkm=OLD_RSEM_FPKM
		Path to old merged fpkm files

	-t OLD_RSEM_TPM, --old_rsem_tpm=OLD_RSEM_TPM
		Path to old merged tpm files

	-o OUTNAME_PREFIX, --outname_prefix=OUTNAME_PREFIX
		outname prefix for merged files
	
        -l LIBRARY, --library=LIBRARY
		outname prefix

	-h, --help
		Show this help message and exit

```
