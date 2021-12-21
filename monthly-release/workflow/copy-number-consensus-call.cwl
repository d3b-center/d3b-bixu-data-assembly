cwlVersion: v1.0
class: Workflow
id: copy-number-consensus-call
requirements:
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement

inputs:
  input_formatted_cnvkit: { type: "File" }
  input_formatted_controlfreeC: { type: "File" }
  input_formatted_mantaSV: { type: "File" }
  run_WGS_or_WXS: { type: { type: 'enum', name: run_WGS_or_WXS, symbols: ["WGS", "WXS"] } }
  output_basename: string
  histology_file: { type: "File" }
  gtf_file: { type: "File" }
  gtf_annote_db: { type: "File" }


outputs:
  output_consensus_seg: { type: File, outputSource: copy-number-consensus-call/output_consensus_seg }
  consensus_seg_annotated_cn: { type: File, outputSource: focal-cn-file-preparation/consensus_seg_annotated_cn }
  consensus_seg_annotated_cn_x_and_y: { type: File, outputSource: focal-cn-file-preparation/consensus_seg_annotated_cn_x_and_y }

steps:
  copy-number-consensus-call:
    run: ../tools/copy-number-consensus-call.cwl
    in:
      input_formatted_cnvkit: input_formatted_cnvkit
      input_formatted_controlfreeC: input_formatted_controlfreeC
      input_formatted_mantaSV: input_formatted_mantaSV
      run_WGS_or_WXS: run_WGS_or_WXS
      output_basename: output_basename
    out: [output_consensus_seg]
    
  focal-cn-file-preparation:
    run: ../tools/focal-cn-file-preparation.cwl
    in:
      histology_file: histology_file
      gtf_file: gtf_file
      gtf_annote_db: gtf_annote_db
      output_basename: output_basename
      consensus_seg_file: copy-number-consensus-call/output_consensus_seg
      input_formatted_cnvkit: input_formatted_cnvkit
      run_WGS_or_WXS: run_WGS_or_WXS
    out: [consensus_seg_annotated_cn,consensus_seg_annotated_cn_x_and_y]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4

