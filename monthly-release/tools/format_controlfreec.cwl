class: CommandLineTool
cwlVersion: v1.0
id: format_controlfreec
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 1000
  - class: DockerRequirement
    dockerPull: 'xiaoyan0106/monthly-release:1.0'
  - class: InlineJavascriptRequirement
baseCommand: [Rscript /scripts/merge-controlfreec/format-controlfreec-files.R]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      --pvalue $(inputs.input_pvalue[0].dirname) --info
      $(inputs.input_info[0].dirname) --experiment
      $(inputs.experiment_strategy) --manifest
      $(inputs.input_manifest.path) --outdir ./ --outname_prefix
      $(inputs.output_basename)

inputs:
  input_pvalue: 'File[]'
  input_info: 'File[]'
  input_manifest: File
  output_basename: string
  experiment_strategy: { type: { type: 'enum', name: experiment_strategy, symbols: ["WGS", "WXS", "All"] } }

outputs:
  output_merged_pvalue:
    type: File
    outputBinding:
      glob: '*-controlfreec.CNVs.p.value.txt'
  output_merged_info:
    type: File
    outputBinding:
      glob: '*-controlfreec.info.txt'

