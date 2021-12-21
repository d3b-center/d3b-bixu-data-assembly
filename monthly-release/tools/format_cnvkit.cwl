class: CommandLineTool
cwlVersion: v1.0
id: format_cnvkit
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 1000
  - class: DockerRequirement
    dockerPull: 'xiaoyan0106/monthly-release:1.0'
  - class: InlineJavascriptRequirement
baseCommand: [python /scripts/merge-cnvkit/format_CNVkit.py]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      -cns $(inputs.merged_cns.path) -seg $(inputs.merged_seg.path)
      -experiment $(inputs.experiment_strategy) -out
      $(inputs.output_basename)
inputs:
  merged_cns: File
  merged_seg: File
  output_basename: string
  experiment_strategy: { type: { type: 'enum', name: experiment_strategy, symbols: ["WGS", "WXS", "All"] } }
outputs:
  output_merged_cnvkit:
    type: File
    outputBinding:
      glob: '*.cnvkit.gz'

