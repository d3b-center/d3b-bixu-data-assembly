class: CommandLineTool
cwlVersion: v1.0
id: merge_fusion
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
  - class: DockerRequirement
    dockerPull: 'zhangb1/data-assembly'
  - class: InlineJavascriptRequirement
baseCommand: [Rscript /d3b-bixu-data-assembly/scripts/merge_fusion/01-create-and-add-fusion-files.R]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      --input_arriba $(inputs.input_arriba.path) --input_star_fusion $(inputs.input_star_fusion.path) --outdir ./ --mergefiles TRUE --old_arriba $(inputs.old_arriba.path) --old_starfusion $(inputs.old_starfusion.path) --outname_prefix pbta-$(inputs.biospecimen_id_RNA)
inputs:
  input_arriba: File
  input_star_fusion: File
  old_arriba: File
  old_starfusion: File
  biospecimen_id_RNA: string
outputs:
  output_merged_arriba:
    type: File
    outputBinding:
      glob: '*fusion-arriba.tsv.gz'
  output_merged_star_fusion:
    type: File
    outputBinding:
      glob: '*fusion-starfusion.tsv.gz'
