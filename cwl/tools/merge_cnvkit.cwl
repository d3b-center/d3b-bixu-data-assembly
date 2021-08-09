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

      zgrep -v "loc.start" $(inputs.input_cnvkit.path) |gzip >temp.gz && cat $(inputs.input_previous_merged_cnvkit.path) temp.gz > pbta-cnv-cnvkit.$(inputs.biospecimen_id).seg.gz && rm temp.gz
inputs:
  input_cnvkit: File
  input_previous_merged_cnvkit: File
  biospecimen_id: string
outputs:
  output_merged_cnvkit:
    type: File
    outputBinding:
      glob: '*.gz'
