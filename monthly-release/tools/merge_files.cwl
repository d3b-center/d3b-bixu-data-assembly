class: CommandLineTool
cwlVersion: v1.0
id: merge_files
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 1000
  - class: DockerRequirement
    dockerPull: 'xiaoyan0106/monthly-release:1.0'
  - class: InlineJavascriptRequirement
baseCommand: [Rscript /scripts/bix-histology/get-file-results.R]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      --theta2list $(inputs.input_theta2_n2[0].dirname)  --infolist
      $(inputs.input_controlfreec_info[0].dirname) --ratiolist
      $(inputs.input_xyratio[0].dirname)  --manifest
      $(inputs.input_manifest.path) --outdir ./ --outname_prefix
      $(inputs.output_basename)
inputs:
  input_manifest: File
  input_theta2_n2: 'File[]'
  input_xyratio: 'File[]'
  input_controlfreec_info: 'File[]'
  output_basename: string
outputs:
  merged_n2:
    type: File
    outputBinding:
      glob: '*n2.results.txt'
  merged_ratio:
    type: File
    outputBinding:
      glob: '*ratio.results.txt'
  merged_ploidy:
    type: File
    outputBinding:
      glob: '*ploidy.results.txt'

