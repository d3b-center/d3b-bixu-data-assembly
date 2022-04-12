cwlVersion: v1.0
class: Workflow
id: merge_manta
requirements:
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement

inputs:
  input_manta: { type: "File[]" }
  input_manifest: { type: "File" }
  output_basename: string

outputs:
  merged_manta: { type: File, outputSource: merge_manta/output_merged_manta }

steps:
  merge_manta:
    run: ../tools/merge_manta.cwl
    in:
      input_manta: input_manta
      input_manifest: input_manifest
      output_basename: output_basename
    out: [output_merged_manta]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4
