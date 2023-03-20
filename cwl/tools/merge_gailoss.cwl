class: CommandLineTool
cwlVersion: v1.0
id: merge_cnvkit
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

      zgrep -v "BS_ID" $(inputs.input_gainloss.path) |gzip >temp.gz && cat $(inputs.input_previous_merged_gainloss.path) temp.gz > gainloss.$(inputs.biospecimen_id).txt.gz && rm temp.gz
inputs:
  input_gainloss: File
  input_previous_merged_gainloss: File
  biospecimen_id: string
outputs:
  output_merged_gainloss:
    type: File
    outputBinding:
      glob: '*.gz'
