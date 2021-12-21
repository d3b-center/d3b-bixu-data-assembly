cwlVersion: v1.0
class: Workflow
id: merge-rsem-gene
requirements:
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement

inputs:
  input_rsem: { type: "File[]" }
  input_manifest: { type: "File" }
  library:  {type: ['null', {type: enum, name: library, symbols: ["polya", "stranded"]}]}
  output_basename: string

outputs:
  new_merged_rsem_count: { type: File, outputSource: merge_rsem/output_merged_rsem_count }
  new_merged_rsem_fpkm: { type: File, outputSource: merge_rsem/output_merged_rsem_fpkm }
  new_merged_rsem_tpm: { type: File, outputSource: merge_rsem/output_merged_rsem_tpm }

steps:
  merge_rsem:
    run: ../tools/merge_rsem.cwl
    in:
      input_rsem: input_rsem
      input_manifest: input_manifest
      library: library
      output_basename: output_basename
    out: [output_merged_rsem_count,output_merged_rsem_fpkm,output_merged_rsem_tpm]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4
