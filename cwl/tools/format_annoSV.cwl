class: CommandLineTool
cwlVersion: v1.0
id: format_annoSV
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 1000
  - class: DockerRequirement
    dockerPull: 'zhangb1/data-assembly'
  - class: InlineJavascriptRequirement
baseCommand: [perl /d3b-bixu-data-assembly/scripts/data_format/format_SV.pl]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      -sv $(inputs.input_annoSV.path) -participant_id $(inputs.participant_id) -biospecimen_id_normal $(inputs.biospecimen_id_normal) -biospecimen_id_tumor $(inputs.biospecimen_id_tumor) |gzip >$(inputs.input_annoSV.nameroot).$(inputs.biospecimen_id_tumor).gz

inputs:
  input_annoSV: File[]
  participant_id: string
  biospecimen_id_tumor: string
  biospecimen_id_normal: string
  conditional_run: { type: int, doc: "Placeholder variable to allow conditional running" } 

outputs:
  output_formatted_annoSV:
    type: File
    outputBinding:
      glob: '*.gz'
