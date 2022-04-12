class: CommandLineTool
cwlVersion: v1.0
id: merge_arriba
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 1000
  - class: DockerRequirement
    dockerPull: 'xiaoyan0106/monthly-release:1.0'
  - class: InlineJavascriptRequirement
baseCommand: [Rscript /scripts/merge-fusion/merge-arriba-fusion-files.R]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      --fusionlist $(inputs.input_arribafusion[0].dirname)  --manifest
      $(inputs.input_manifest.path) --outdir ./ --outname_prefix
      $(inputs.output_basename)
inputs:
  input_arribafusion: 'File[]'
  input_manifest: File
  output_basename: string
outputs:
  output_merged_arriba_fusion:
    type: File
    outputBinding:
      glob: '*fusion-arriba.tsv.gz'