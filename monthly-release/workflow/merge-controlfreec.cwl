cwlVersion: v1.0
class: Workflow
id: merge_controlfreec
requirements:
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement

inputs:
  input_manifest: { type: "File" }
  input_pvalue: { type: "File[]" }
  input_info: { type: "File[]" }
  output_basename: string
  experiment_strategy: { type: { type: 'enum', name: experiment_strategy, symbols: ["WGS", "WXS", "All"] } }

outputs:
  merged_controlfreec: { type: File, outputSource: merge_controlfreec/output_merged_controlfreec }

steps:
  format_controlfreec:
    run: ../tools/format_controlfreec.cwl
    in:
      input_pvalue: input_pvalue
      input_info: input_info
      input_manifest: input_manifest
      experiment_strategy: experiment_strategy
      output_basename: output_basename
    out: [output_merged_pvalue,output_merged_info]

  merge_controlfreec:
    run: ../tools/merge_controlfreec.cwl
    in:
      merged_pvalue: format_controlfreec/output_merged_pvalue
      merged_info: format_controlfreec/output_merged_info
      experiment_strategy: experiment_strategy
      output_basename: output_basename
    out: [output_merged_controlfreec]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4
