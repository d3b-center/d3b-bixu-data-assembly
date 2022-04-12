class: CommandLineTool
cwlVersion: v1.0
id: merge_cnvkit
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 1000
  - class: DockerRequirement
    dockerPull: 'xiaoyan0106/monthly-release:1.0'
  - class: InlineJavascriptRequirement
baseCommand: [Rscript /scripts/merge-cnvkit/merge-cnvkit-files.R]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      --cnslist $(inputs.input_cns[0].dirname) --seglist
      $(inputs.input_seg[0].dirname) --experiment
      $(inputs.experiment_strategy)  --manifest
      $(inputs.input_manifest.path) --outdir ./ --outname_prefix
      $(inputs.output_basename)

inputs:
  input_cns: 'File[]'
  input_seg: 'File[]'
  input_manifest: File
  output_basename: string
  experiment_strategy: { type: { type: 'enum', name: experiment_strategy, symbols: ["WGS", "WXS", "All"] } }
outputs:
  output_merged_cns:
    type: File
    outputBinding:
      glob: '*-call.cns'
  output_merged_seg:
    type: File
    outputBinding:
      glob: '*-call.seg'
