class: CommandLineTool
cwlVersion: v1.0
id: merge_sv
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

      zgrep -v "AnnotSV.ID" $(inputs.input_sv.path) |gzip >temp.gz && cat $(inputs.input_previous_merged_sv.path) temp.gz > pbta-sv-manta.$(inputs.biospecimen_id).tsv.gz && rm temp.gz
inputs:
  input_sv: File
  input_previous_merged_sv: File
  biospecimen_id: string
outputs:
  output_merged_sv:
    type: File
    outputBinding:
      glob: '*.gz'
