class: CommandLineTool
cwlVersion: v1.0
id: format_fusion
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 1000
  - class: DockerRequirement
    dockerPull: 'kfdrc/annofuse:0.1.8'
  - class: InlineJavascriptRequirement
baseCommand: [Rscript /rocker-build/formatFusionCalls.R]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      --fusionfile $(inputs.star_fusion_output_file.path) --tumorid $(inputs.biospeimens_id) --caller starfusion --outputfile $(inputs.biospeimens_id).starfusion_formatted.tsv &&
      Rscript /rocker-build/formatFusionCalls.R --fusionfile $(inputs.arriba_output_file.path) --tumorid $(inputs.biospeimens_id) --caller arriba --outputfile $(inputs.biospeimens_id).arriba_formatted.tsv
inputs:
  arriba_output_file: File
  star_fusion_output_file: File
  biospeimens_id: string
outputs:
  output_formatted_starfusion:
    type: File
    outputBinding:
      glob: '*.starfusion_formatted.tsv'
  output_formatted_arriba:
    type: File
    outputBinding:
      glob: '*.arriba_formatted.tsv'
