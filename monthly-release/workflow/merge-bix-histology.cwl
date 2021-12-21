cwlVersion: v1.0
class: Workflow
id: merge-bix-histology
requirements:
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement

inputs:
  input_manifest: { type: "File" }
  input_histology: { type: "File" }
  input_theta2_n2: { type: "File[]" }
  input_xyratio: { type: "File[]" }
  input_controlfreec_info: { type: "File[]" }
  output_basename: string

outputs:
  bix_histology: { type: File, outputSource: merge_histology/output_merged_histology }

steps:
  merge_files:
    run: ../tools/merge_files.cwl
    in:
      input_manifest: input_manifest
      input_theta2_n2: input_theta2_n2
      input_xyratio: input_xyratio
      input_controlfreec_info: input_controlfreec_info
      output_basename: output_basename
    out: [merged_n2,merged_ratio,merged_ploidy]
  merge_histology:
    run: ../tools/merge_histology.cwl
    in:
      merged_n2: merge_files/merged_n2
      merged_ratio: merge_files/merged_ratio
      merged_ploidy: merge_files/merged_ploidy
      input_histology: input_histology
      output_basename: output_basename
    out: [output_merged_histology]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4
