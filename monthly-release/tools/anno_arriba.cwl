class: CommandLineTool
cwlVersion: v1.0
id: anno_arriba
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 1000
  - class: DockerRequirement
    dockerPull: 'gaonkark/fusionanno:latest'
  - class: InlineJavascriptRequirement
baseCommand: [tar -zxf]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      $(inputs.FusionGenome.path) && gunzip -c
      $(inputs.output_formatted_arriba.path) > tmp_formatted_arriba.tsv 
      && /opt/FusionAnnotator/FusionAnnotator --genome_lib_dir
      ./GRCh38_v27_CTAT_lib_Feb092018/ctat_genome_lib_build_dir --annotate
      tmp_formatted_arriba.tsv --fusion_name_col 25 | gzip >
      $(inputs.output_basename).arriba.annotated.tsv.gz

inputs:
  FusionGenome: File
  output_formatted_arriba: File
  output_basename: string
outputs:
  output_merged_annoted_arriba_fusion:
    type: File
    outputBinding:
      glob: '*.arriba.annotated.tsv.gz'
