class: CommandLineTool
cwlVersion: v1.0
id: merge_consensus_seg_annotated
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: 'zhangb1/data-assembly'
baseCommand: [mkdir]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
        results && Rscript /d3b-bixu-data-assembly/scripts/focal-cn-file-preparation/07-consensus-annotated-merge.R --cnvkit_auto $(inputs.consensus_seg_annotated_cn.path)  --cnvkit_x_and_y $(inputs.consensus_seg_annotated_cn_x_and_y.path)  --consensus_auto $(inputs.input_previous_consensus_seg.path)    --consensus_x_and_y $(inputs.input_previous_consensus_seg_x_y.path)  --outdir ./results
        && cp ./results/consensus_wgs_plus_cnvkit_wxs.tsv.gz consensus_wgs_plus_cnvkit_wxs.$(inputs.biospecimen_id).tsv.gz

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
