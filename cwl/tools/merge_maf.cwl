class: CommandLineTool
cwlVersion: v1.0
id: merge_maf
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 1000
  - class: DockerRequirement
  - class: InlineJavascriptRequirement
baseCommand: ["/bin/bash -c"]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      set -eo pipefail

      egrep -v "#version|Hugo_Symbol" $(inputs.input_maf.path) |gzip >temp.gz && cat $(inputs.input_previous_merged_maf.path) temp.gz > $(inputs.input_previous_merged_maf.nameroot).$(inputs.biospecimen_id).gz && rm temp.gz
inputs:
  input_maf: File
  input_previous_merged_maf: File
  biospecimen_id: string
outputs:
  output_merged_maf:
    type: File
    outputBinding:
      glob: '*.gz'
