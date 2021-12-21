cwlVersion: v1.0
class: Workflow
id: format-dgd-maf
requirements:
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement

inputs:
  dgd_maf: { type: "File" }
  example_bix_maf: File
outputs:
  output_format_maf: { type: File, outputSource: format_dgd_maf/output_format_maf }

steps:
  format_dgd_maf:
    run: ../tools/format-dgd-maf.cwl
    in:
      dgd_maf: dgd_maf
      example_bix_maf: example_bix_maf
    out: [output_format_maf]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4