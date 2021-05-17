class: CommandLineTool
cwlVersion: v1.0
id: format_controlfreeC_cnv
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 1000
  - class: DockerRequirement
    dockerPull: 'zhangb1/data-assembly'
  - class: InlineJavascriptRequirement
baseCommand: [perl /d3b-bixu-data-assembly/scripts/data_format/format_control-freeC.pl]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      -P_value $(inputs.input_controlfreeC_p_value.path) -INFO $(inputs.input_controlfreeC_info.path) -biospecimen_id $(inputs.biospecimen_id)|gzip >$(inputs.input_controlfreeC_info.nameroot).$(inputs.biospecimen_id).controlfreeC.gz

inputs:
  input_controlfreeC_p_value: File
  input_controlfreeC_info: File
  biospecimen_id: string
outputs:
  output_formatted_controlfreeC:
    type: File
    outputBinding:
      glob: '*.controlfreeC.gz'
