class: CommandLineTool
cwlVersion: v1.0
id: annoSV
requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'gaonkark/annotsv:latest'
  - class: InlineJavascriptRequirement
baseCommand: [export]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      ANNOTSV=/opt/AnnotSV_2.1 && $ANNOTSV/bin/AnnotSV -bedtools /usr/local/bin/bedtools -genomeBuild GRCh38 -promoterSize 2000 -SVminSize 200 -SVinputFile $(inputs.input_SV.path) -outputDir ./

inputs:
  input_SV: File?
#  conditional_run: { type: int, doc: "Placeholder variable to allow conditional running" } 
  run_WGS_or_WXS: { type: { type: 'enum', name: run_WGS_or_WXS, symbols: ["WGS", "WXS"] } }  
outputs:
  output_formatted_SV:
    type: File
    outputBinding:
      glob: '*.tsv'
