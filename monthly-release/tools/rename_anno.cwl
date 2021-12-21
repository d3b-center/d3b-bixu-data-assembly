class: CommandLineTool
cwlVersion: v1.0
id: rename_anno
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 1000
  - class: DockerRequirement
    dockerPull: 'xiaoyan0106/monthly-release:1.0'
  - class: InlineJavascriptRequirement
baseCommand: [Rscript /scripts/merge-fusion/rename-annots-arriba-fusion-files.R]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      --arribafusion $(inputs.annot_arriba.path) --outdir ./
      --outname_prefix $(inputs.output_basename)
inputs:
  annot_arriba: File
  output_basename: string
outputs:
  merged_format_anno_arriba_fusion:
    type: File
    outputBinding:
      glob: '*-arriba_formated.annotated.tsv.gz'

