class: CommandLineTool
cwlVersion: v1.0
id: merge_seg
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

      egrep -v "loc.start" $(inputs.input_seg.path) |gzip >temp.gz && cat $(inputs.input_previous_merged_seg.path) temp.gz > $(inputs.input_previous_merged_seg.nameroot).$(inputs.biospecimen_id).gz && rm temp.gz
inputs:
  input_seg: File
  input_previous_merged_seg: File
  biospecimen_id: File
outputs:
  output_merged_seg:
    type: File
    outputBinding:
      glob: '*.gz'