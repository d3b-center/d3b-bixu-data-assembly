class: CommandLineTool
cwlVersion: v1.0
id: merge_histology
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 1000
  - class: DockerRequirement
    dockerPull: 'xiaoyan0106/monthly-release:1.0'
  - class: InlineJavascriptRequirement
baseCommand: [python /scripts/bix-histology/merge_histology.py]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      -histology $(inputs.input_histology.path) -theta2
      $(inputs.merged_n2.path)  -ploidy $(inputs.merged_ploidy.path)
      -xyratio $(inputs.merged_ratio.path) -out $(inputs.output_basename)

inputs:
  merged_n2: File
  merged_ratio: File
  merged_ploidy: File
  input_histology: File
  output_basename: string
outputs:
  output_merged_histology:
    type: File
    outputBinding:
      glob: '*histologies-ops.tsv'
