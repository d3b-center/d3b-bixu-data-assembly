class: CommandLineTool
cwlVersion: v1.0
id: merge_controlfreec
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 1000
  - class: DockerRequirement
    dockerPull: 'xiaoyan0106/monthly-release:1.0'
  - class: InlineJavascriptRequirement
baseCommand: [python /scripts/merge-controlfreec/merge_controlfreec.py]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      -pvalue $(inputs.merged_pvalue.path) -info
      $(inputs.merged_info.path) -experiment $(inputs.experiment_strategy)
      -out $(inputs.output_basename)

inputs:
  merged_pvalue: File
  merged_info: File
  output_basename: string
  experiment_strategy: { type: { type: 'enum', name: experiment_strategy, symbols: ["WGS", "WXS", "All"] } }

outputs:
  output_merged_controlfreec:
    type: File
    outputBinding:
      glob: '*.controlfreec.info.controlfreeC.gz'

