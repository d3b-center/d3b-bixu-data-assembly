cwlVersion: v1.0
class: Workflow
id: merge_annofuse
requirements:
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement

inputs:
  input_annofuse: { type: "File[]" }
  output_basename: string
outputs:
  merged_annofuse: { type: File, outputSource: merge_annofuse/output_merged_annofuse }

steps:
  merge_annofuse:
    run: ../tools/merge-annofuse.cwl
    in:
      input_annofuse: input_annofuse
      output_basename: output_basename
    out: [output_merged_annofuse]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4