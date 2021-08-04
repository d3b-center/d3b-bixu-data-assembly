class: CommandLineTool
cwlVersion: v1.0
id: focal_cn_file_preparation
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
  - class: DockerRequirement
    dockerPull: 'zhangb1/data-assembly'
  - class: InlineJavascriptRequirement
baseCommand: [Rscript]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
        /d3b-bixu-data-assembly/scripts/focal-cn-file-preparation/02-add-ploidy-consensus.R --scratch ./scratch --consensus_seg_file  $(inputs.consensus_seg_file.path) --histology_file $(inputs.histology_file.path) && mkdir ./results &&
        snakemake -j 10 --snakefile /d3b-bixu-data-assembly/scripts/focal-cn-file-preparation/run-bedtools.snakemake &&
        Rscript /d3b-bixu-data-assembly/scripts/focal-cn-file-preparation/03-add-cytoband-status-consensus.R  --scratch ./scratch && 
        Rscript /d3b-bixu-data-assembly/scripts/focal-cn-file-preparation/04-prepare-cn-file.R  --cnv_file ./scratch/consensus_seg_with_status.tsv --gtf_file $(inputs.gtf_file.path) --metadata $(inputs.histology_file.path)  --filename_lead "consensus_seg_annotated_cn" --seg --root_dir ./ --annotation_file $(inputs.gtf_annote_db.path) &&
        cp ./results/consensus_seg_annotated_cn_autosomes.tsv.gz ./consensus_seg_annotated_cn_autosomes.$(inputs.biospecimen_id).tsv.gz && cp ./results/consensus_seg_annotated_cn_x_and_y.tsv.gz ./consensus_seg_annotated_cn_x_and_y.$(inputs.biospecimen_id).tsv.gz

inputs:
  consensus_seg_file: File
  histology_file: File
  gtf_file: File
  gtf_annote_db: File
  biospecimen_id: string

outputs:
  consensus_seg_annotated_cn:
    type: File
    outputBinding:
      glob: 'consensus_seg_annotated_cn_autosomes*.tsv.gz'
  consensus_seg_annotated_cn_x_and_y:
    type: File
    outputBinding:
      glob: 'consensus_seg_annotated_cn_x_and_y*.tsv.gz'   
