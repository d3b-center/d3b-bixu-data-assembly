# Merge StarFusion and Arriba 


The Steps for merging the fusion files are :
 1) Format arriba file to obtain annotation from FusionAnnotator using this app: gaonkark/pbta-merge-fusion/kfdrc-fusion-formatting-wf 
 2) Download formatted Arriba and Starfusion files along with a manifest to merge with existing merged files from previous releases.
	- Manifest is mandatory it can either be downloaded from cavatica project (deefault) or bix-ops generated json format manifest. 
	- Files can be downloaded using the script with --download==TRUE or manually and placed in "INPUTDIR"    

```
Rscript 00-format-annotate-fusion-files.R --help


Options:
	-m MANIFEST, --manifest=MANIFEST
		manifest for the fusion files to format and combine from cavatica [CSV]

	-u USERNAME, --username=USERNAME
		cavatica username
              if files need to be downloaded with --file_ids

	-p PROJECTID, --projectid=PROJECTID
		 if download= TRUE mandatory; cavatica project id

	-a APP_ID, --app_id=APP_ID
		app_id for formatting fusion eg. gaonkark/pbta-merge-fusion/kfdrc-fusion-formatting-wf

	-h, --help
		Show this help message and exit


Rscript 01-create-and-add-fusion-files.R --help

Options:
	--inputdir=INPUTDIR
		Input directory for fusion files

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

	-a OLD_ARRIBA, --old_arriba=OLD_ARRIBA
		Path to old merged arriba files

	-s OLD_STARFUSION, --old_starfusion=OLD_STARFUSION
		Path to old merged starfusion files

	-o OUTNAME_PREFIX, --outname_prefix=OUTNAME_PREFIX
		outname prefix for merged files

	-h, --help
		Show this help message and exit

```
