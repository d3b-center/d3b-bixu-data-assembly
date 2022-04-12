class: CommandLineTool
cwlVersion: v1.0
id: focal-cn-file-preparation
requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'xiaoyan0106/monthly-release:1.0'
  - class: InlineJavascriptRequirement
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: |-
      ${
        if (inputs.run_WGS_or_WXS == "WGS")
          return "Rscript /scripts/focal-cn-file-preparation/02-add-ploidy-consensus.R --scratch ./scratch --consensus_seg_file " + inputs.consensus_seg_file.path + " --histology_file " +inputs.histology_file.path + " && mkdir ./results && snakemake -j 10 --snakefile /scripts/focal-cn-file-preparation/run-bedtools.snakemake && Rscript /scripts/focal-cn-file-preparation/03-add-cytoband-status-consensus.R  --scratch ./scratch &&  Rscript /scripts/focal-cn-file-preparation/04-prepare-cn-file.R  --cnv_file ./scratch/consensus_seg_with_status.tsv --prefix " + inputs.output_basename + " --gtf_file " + inputs.gtf_file.path + " --annotation_file " +inputs.gtf_annote_db.path + " --metadata "+ inputs.histology_file.path + " --filename_lead 'consensus_seg_annotated_cn' --seg --root_dir ./  && cp ./results/*autosomes.tsv.gz ./ && cp ./results/*x_and_y.tsv.gz ./ "
        else return "Rscript /scripts/focal-cn-file-preparation/01-add-ploidy-cnvkit.R --scratch ./scratch --cnvkit_file " + inputs.input_formatted_cnvkit.path + " --histology_file " + inputs.histology_file.path + " && Rscript /scripts/focal-cn-file-preparation/04-prepare-cn-file.R  --cnv_file  ./scratch/cnvkit_with_status.tsv  --prefix  " + inputs.output_basename + " --gtf_file " + inputs.gtf_file.path + " --annotation_file " +inputs.gtf_annote_db.path + " --metadata " + inputs.histology_file.path + " --filename_lead 'cnvkit_seg_annotated_cn' --seg --root_dir ./  --runWXSonly   && cp  ./results/*autosomes.tsv.gz ./ && cp ./results/*x_and_y.tsv.gz ./ "
      }

inputs:
  histology_file: File
  gtf_file: File
  gtf_annote_db: File
  consensus_seg_file: File
  input_formatted_cnvkit: File
  run_WGS_or_WXS: { type: { type: 'enum', name: run_WGS_or_WXS, symbols: ["WGS", "WXS"] } }
  output_basename: string
 
outputs:
  consensus_seg_annotated_cn:
    type: File
    outputBinding:
      glob: '*autosomes.tsv.gz'
  consensus_seg_annotated_cn_x_and_y:
    type: File
    outputBinding:
      glob: '*x_and_y.tsv.gz'
