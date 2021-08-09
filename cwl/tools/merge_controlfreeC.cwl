class: CommandLineTool
cwlVersion: v1.0
id: merge_controlfreec
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: 'zhangb1/data-assembly'
baseCommand: ["/bin/bash -c"]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      set -eo pipefail

      zgrep -v "Kids_First_Biospecimen_ID" $(inputs.input_controlfreec.path) |gzip >temp.gz && cat $(inputs.input_previous_merged_controlfreec.path) temp.gz > pbta-cnv-controlfreec.$(inputs.biospecimen_id).tsv.gz && rm temp.gz
inputs:
  input_controlfreec: File
  input_previous_merged_controlfreec: File
  biospecimen_id: string
outputs:
  output_merged_controlfreec:
    type: File
    outputBinding:
      glob: '*.gz'
