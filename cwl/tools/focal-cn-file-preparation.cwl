class: CommandLineTool
cwlVersion: v1.0
id: focal_cn_file_preparation
requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'zhangb1/data-assembly'
  - class: InlineJavascriptRequirement
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      ${
        if (inputs.run_WGS_or_WXS == "WGS")
          return  "Rscript /d3b-bixu-data-assembly/scripts/focal-cn-file-preparation/02-add-ploidy-consensus.R --scratch ./scratch --consensus_seg_file " + inputs.consensus_seg_file.path + " --histology_file " + inputs.histology_file.path + " && mkdir ./results && snakemake -j 10 --snakefile /d3b-bixu-data-assembly/scripts/focal-cn-file-preparation/run-bedtools.snakemake && Rscript /d3b-bixu-data-assembly/scripts/focal-cn-file-preparation/04-prepare-cn-file.R  --cnv_file ./scratch/consensus_seg_with_status.tsv --metadata " + inputs.histology_file.path + " --filename_lead 'consensus_seg_annotated_cn' --seg --root_dir ./ --gtf_file " + inputs.gtf_file.path + " && cp ./results/consensus_seg_annotated_cn_autosomes.tsv.gz ./consensus_seg_annotated_cn_autosomes." + inputs.biospecimen_id + ".tsv.gz && cp ./results/consensus_seg_annotated_cn_x_and_y.tsv.gz ./consensus_seg_annotated_cn_x_and_y." + inputs.biospecimen_id + ".tsv.gz"
        else return "Rscript /d3b-bixu-data-assembly/scripts/focal-cn-file-preparation/01-add-ploidy-cnvkit.R --scratch ./scratch --cnvkit_file  " + inputs.merged_cnvkit.path + " --histology_file " + inputs.histology_file.path + " && Rscript /d3b-bixu-data-assembly/scripts/focal-cn-file-preparation/04-prepare-cn-file.R  --cnv_file ./scratch/cnvkit_with_status.tsv --metadata " + inputs.histology_file.path + " --filename_lead 'consensus_seg_annotated_cn' --seg --root_dir ./ --gtf_file " + inputs.gtf_file.path + " --runWXSonly  && cp ./results/consensus_seg_annotated_cn_wxs_autosomes.tsv.gz ./consensus_seg_annotated_cn_wxs_autosomes." + inputs.biospecimen_id + ".tsv.gz && cp ./results/consensus_seg_annotated_cn_wxs_x_and_y.tsv.gz ./consensus_seg_annotated_cn_wxs_x_and_y." + inputs.biospecimen_id + ".tsv.gz"
      }
inputs:
  consensus_seg_file: File?
  merged_cnvkit: File?
  histology_file: File
  gtf_file: File
  biospecimen_id: string
  run_WGS_or_WXS: { type: { type: 'enum', name: run_WGS_or_WXS, symbols: ["WGS", "WXS"] } }

outputs:
  consensus_seg_annotated_cn:
    type: File
    outputBinding:
      glob: 'consensus_seg_annotated_*_autosomes*.tsv.gz'
  consensus_seg_annotated_cn_x_and_y:
    type: File
    outputBinding:
      glob: 'consensus_seg_annotated_*_x_and_y*.tsv.gz'   
