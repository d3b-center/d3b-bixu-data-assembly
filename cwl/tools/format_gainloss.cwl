class: CommandLineTool
cwlVersion: v1.0
id: format_cnvkit_cnv
requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'zhangb1/data-assembly'
  - class: InlineJavascriptRequirement
baseCommand: [perl /d3b-bixu-data-assembly/scripts/data_format/format_gainloss.pl]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      -gainloss $(inputs.input_gainloss.path) -biospecimen_id $(inputs.biospecimen_id) |gzip >$(inputs.input_gainloss.nameroot).$(inputs.biospecimen_id).gainloss.gz

inputs:
  input_gainloss: File
  biospecimen_id: string
outputs:
  output_formatted_gailoss:
    type: File
    outputBinding:
      glob: '*.gainloss.gz'
