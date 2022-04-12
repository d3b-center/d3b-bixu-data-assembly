class: CommandLineTool
cwlVersion: v1.0
id: format_dgd_maf
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 1000
  - class: DockerRequirement
    dockerPull: 'xiaoyan0106/monthly-release:1.0'
  - class: InlineJavascriptRequirement
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      Rscript /scripts/format-dgd-maf/format_dgd_maf.R
      --dgd_maf $(inputs.dgd_maf.path) --bix_maf $(inputs.example_bix_maf.path) 
      --outdir ./ --outname_prefix $(inputs.dgd_maf.nameroot)
inputs:
  dgd_maf: File
  example_bix_maf: File
outputs:
  output_format_maf:
    type: File
    outputBinding:
      glob: '*dgd_format.maf'
