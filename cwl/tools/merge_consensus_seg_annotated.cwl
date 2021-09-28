class: CommandLineTool
cwlVersion: v1.0
id: merge_consensus_seg_annotated
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

      egrep -v "biospecimen_id" $(inputs.consensus_seg_annotated_cn.path) |gzip >temp.gz && cat $(inputs.input_previous_consensus_seg.path) temp.gz > consensus_wgs_plus_cnvkit_wxs_autosomes.$(inputs.biospecimen_id).tsv.gz && rm temp.gz
      &&  egrep -v "biospecimen_id" $(inputs.consensus_seg_annotated_cn_x_and_y.path) |gzip >temp.gz && cat $(inputs.input_previous_consensus_seg_x_y.path) temp.gz > consensus_wgs_plus_cnvkit_wxs_x_and_y.$(inputs.biospecimen_id).tsv.gz && rm temp.gz
      &&  gunzip consensus_wgs_plus_cnvkit_wxs_x_and_y.$(inputs.biospecimen_id).tsv.gz |cut -f1-7 |grep -v "biospecimen_id" |gzip >temp.gz && cat consensus_wgs_plus_cnvkit_wxs_autosomes.$(inputs.biospecimen_id).tsv.gz temp.gz > consensus_wgs_plus_cnvkit_wxs.$(inputs.biospecimen_id).tsv.gz

inputs:
  input_previous_consensus_seg: File
  input_previous_consensus_seg_x_y: File
  consensus_seg_annotated_cn: File
  consensus_seg_annotated_cn_x_and_y: File
  biospecimen_id: string
outputs:
  output_merged_consensus_seg_annotated_cn_and_x_y:
    type: File
    outputBinding:
      glob: 'consensus_wgs_plus_cnvkit_wxs.*.gz'
