cwlVersion: v1.0
class: Workflow
id: merge_cnvkit
requirements:
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement

inputs:
  input_manifest: { type: "File" }
  input_cns: { type: "File[]" }
  input_seg: { type: "File[]" }
  output_basename: string
  experiment_strategy: { type: { type: 'enum', name: experiment_strategy, symbols: ["WGS", "WXS", "All"] } }

outputs:
  merged_cnvkit: { type: File, outputSource: format_cnvkit/output_merged_cnvkit }

steps:
  merge_cnvkit:
    run: ../tools/merge_cnvkit.cwl
    in:
      input_cns: input_cns
      input_seg: input_seg
      input_manifest: input_manifest
      experiment_strategy: experiment_strategy
      output_basename: output_basename
    out: [output_merged_cns,output_merged_seg]

  format_cnvkit:
    run: ../tools/format_cnvkit.cwl
    in:
      merged_cns: merge_cnvkit/output_merged_cns
      merged_seg: merge_cnvkit/output_merged_seg
      experiment_strategy: experiment_strategy
      output_basename: output_basename
    out: [output_merged_cnvkit]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4
