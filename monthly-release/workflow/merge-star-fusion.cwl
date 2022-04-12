cwlVersion: v1.0
class: Workflow
id: merge-star-fusion
requirements:
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement

inputs:
  input_starfusion: { type: "File[]" }
  input_manifest: { type: "File" }
  output_basename: string

outputs:
  merged_star_fusion: { type: File, outputSource: merge_star/output_merged_star_fusion }

steps:
  merge_star:
    run: ../tools/merge_star.cwl
    in:
      input_starfusion: input_starfusion
      input_manifest: input_manifest
      output_basename: output_basename
    out: [output_merged_star_fusion]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4
