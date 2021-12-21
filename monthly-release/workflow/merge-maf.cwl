cwlVersion: v1.0
class: Workflow
id: merge-maf
requirements:
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement

inputs:
  input_maf: { type: "File[]" }
  output_basename: string

outputs:
  output_merged_maf: { type: File, outputSource: merge_maf/output_merged_maf }

steps:
  merge_maf:
    run: ../tools/merge_maf.cwl
    in:
      input_maf: input_maf
      output_basename: output_basename
    out: [output_merged_maf]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4
