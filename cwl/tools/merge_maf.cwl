class: CommandLineTool
cwlVersion: v1.0
id: merge_maf
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

      egrep -v "#version|Hugo_Symbol" $(inputs.input_maf.path) |gzip >temp.gz && cat $(inputs.input_previous_merged_maf.path) temp.gz > snv-consensus-plus-hotspots.$(inputs.biospecimen_id).maf.gz && rm temp.gz
inputs:
  input_maf: File
  input_previous_merged_maf: File
  biospecimen_id: string
outputs:
  output_merged_maf:
    type: File
    outputBinding:
      glob: '*.gz'
