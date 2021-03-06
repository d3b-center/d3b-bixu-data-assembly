class: CommandLineTool
cwlVersion: v1.0
id: anno_fusion
requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'gaonkark/fusionanno:latest'
  - class: InlineJavascriptRequirement
baseCommand: [tar -zxf]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      $(inputs.FusionGenome.path) && /opt/FusionAnnotator/FusionAnnotator --genome_lib_dir ./GRCh38_v27_CTAT_lib_Feb092018/ctat_genome_lib_build_dir --annotate $(inputs.output_formatted_arriba.path) --fusion_name_col 25 > $(inputs.biospecimens_id).arriba_formatted.annotated.tsv
inputs:
  FusionGenome: File
  output_formatted_arriba: File
  biospecimens_id: string
outputs:
  output_formatted_annoted_arriba:
    type: File
    outputBinding:
      glob: '*.arriba_formatted.annotated.tsv'
