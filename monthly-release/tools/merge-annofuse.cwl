class: CommandLineTool
cwlVersion: v1.0
id: merge_annofuse
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 1000
  - class: DockerRequirement
    dockerPull: 'xiaoyan0106/monthly-release:1.0'
  - class: InlineJavascriptRequirement
baseCommand: [Rscript /scripts/merge-fusion/merge-annofuse-files.R]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      --annofuselist $(inputs.input_annofuse[0].dirname)  --outdir ./
      --outname_prefix $(inputs.output_basename)
inputs:
  input_annofuse: 'File[]'
  output_basename: string
outputs:
  output_merged_annofuse:
    type: File
    outputBinding:
      glob: '*annoFuse_filter.tsv.gz'