class: CommandLineTool
cwlVersion: v1.0
id: merge_manta
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 1000
  - class: DockerRequirement
    dockerPull: 'xiaoyan0106/monthly-release:1.0'
  - class: InlineJavascriptRequirement
baseCommand: [Rscript /scripts/merge-manta/format-SV.R]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      --svlist $(inputs.input_manta[0].dirname) --manifest
      $(inputs.input_manifest.path) --outdir ./ --outname_prefix
      $(inputs.output_basename)
inputs:
  input_manta: 'File[]'
  output_basename: string
  input_manifest: File
outputs:
  output_merged_manta:
    type: File
    outputBinding:
      glob: '*.somaticSV.annotated.tsv.gz'
