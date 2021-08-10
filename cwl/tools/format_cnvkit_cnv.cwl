class: CommandLineTool
cwlVersion: v1.0
id: format_cnvkit_cnv
requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'zhangb1/data-assembly'
  - class: InlineJavascriptRequirement
baseCommand: [perl /d3b-bixu-data-assembly/scripts/data_format/format_CNVkit.pl]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      -call_cns $(inputs.input_cnvkit_call_cns.path) -call_seg $(inputs.input_cnvkit_call_seg.path) |gzip >$(inputs.input_cnvkit_call_seg.nameroot).$(inputs.biospecimen_id).cnvkit.gz

inputs:
  input_cnvkit_call_cns: File
  input_cnvkit_call_seg: File
  biospecimen_id: string
outputs:
  output_formatted_cnvkit:
    type: File
    outputBinding:
      glob: '*.cnvkit.gz'
