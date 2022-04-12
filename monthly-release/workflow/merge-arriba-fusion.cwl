cwlVersion: v1.0
class: Workflow
id: merge-arriba-fusion
requirements:
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement

inputs:
  input_manifest: { type: "File" }
  input_arribafusion: { type: "File[]" }
  FusionGenome: { type: "File" }
  output_basename: string
outputs:
  merged_arriba_format_annoted_fusion: { type: File, outputSource: rename_anno/merged_format_anno_arriba_fusion }

steps:
  merge_arriba:
    run: ../tools/merge_arriba.cwl
    in:
      input_arribafusion: input_arribafusion
      input_manifest: input_manifest
      output_basename: output_basename
    out: [output_merged_arriba_fusion]
  anno_arriba:
    run: ../tools/anno_arriba.cwl
    in:
      FusionGenome: FusionGenome
      output_formatted_arriba: merge_arriba/output_merged_arriba_fusion
      output_basename: output_basename
    out: [output_merged_annoted_arriba_fusion]
  rename_anno:
    run: ../tools/rename_anno.cwl
    in:
      annot_arriba: anno_arriba/output_merged_annoted_arriba_fusion
      output_basename: output_basename
    out: [merged_format_anno_arriba_fusion]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4
