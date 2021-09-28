cwlVersion: v1.0
class: Workflow
id: data_assembly_RNA_wf
requirements:
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement
inputs:

  # format fusion
  FusionGenome: { type: File }
  arriba_output_file: { type: File }
  star_fusion_output_file: { type: File }
  old_arriba: { type: File }
  old_starfusion: { type: File }

  # rsem 
  input_rsem: { type: File }
  old_rsem_count: { type: File }
  old_rsem_fpkm: { type: File }
  old_rsem_tpm: { type: File }
  old_rsem_count_2: { type: File }
  old_rsem_fpkm_2: { type: File }
  old_rsem_tpm_2: { type: File }

  library:  {type: ['null', {type: enum, name: library, symbols: ["polya", "stranded"]}]}

  biospecimen_id_RNA: string

outputs:
  new_merged_star_fusion: { type: File, outputSource: merge_fusion/output_merged_star_fusion }
  new_merged_merged_arriba:  { type: File, outputSource: merge_fusion/output_merged_arriba }
  
  new_merged_rsem_count: { type: File, outputSource: merge_rsem/output_merged_rsem_count }
  new_merged_fpkm: { type: File, outputSource: merge_rsem/output_merged_fpkm }
  new_merged_tpm: {type: File, outputSource: merge_rsem/output_merged_tpm}

  new_merged_rsem_count_stranded_and_polya: { type: File, outputSource: merge_stranded_polya/output_merged_rsem_count }
  new_merged_fpkm_stranded_and_polya: { type: File, outputSource: merge_stranded_polya/output_merged_fpkm }
  new_merged_tpm_stranded_and_polya: {type: File, outputSource: merge_stranded_polya/output_merged_tpm}


steps:
  format_fusion:
    run: ../tools/format_fusion.cwl
    in:
      arriba_output_file: arriba_output_file
      star_fusion_output_file: star_fusion_output_file
      biospecimen_id: biospecimen_id_RNA
    out: [output_formatted_starfusion,output_formatted_arriba]

  anno_fusion:
    run: ../tools/anno_fusion.cwl
    in:
      FusionGenome: FusionGenome
      output_formatted_arriba: format_fusion/output_formatted_arriba
      biospecimens_id: biospecimen_id_RNA
    out: [output_formatted_annoted_arriba] 

  merge_fusion:
    run: ../tools/merge_fusion.cwl
    in:
      input_arriba: anno_fusion/output_formatted_annoted_arriba
      input_star_fusion: format_fusion/output_formatted_starfusion
      old_arriba: old_arriba
      old_starfusion: old_starfusion
      biospecimen_id_RNA: biospecimen_id_RNA
    out: [output_merged_arriba,output_merged_star_fusion]

  merge_rsem:
    run: ../tools/merge_rsem.cwl
    in:
      input_rsem: input_rsem
      old_rsem_count: old_rsem_count
      old_rsem_fpkm: old_rsem_fpkm
      old_rsem_tpm: old_rsem_tpm
      library: library
      biospecimen_id_RNA: biospecimen_id_RNA
    out: [output_merged_rsem_count,output_merged_fpkm,output_merged_tpm]

  merge_stranded_polya:
    run: ../tools/merge_stranded_polya.cwl
    in:
      input_rsem_count_merged: merge_rsem/output_merged_rsem_count
      input_rsem_fpkm_merged: merge_rsem/output_merged_fpkm
      input_rsem_tpm_merged: merge_rsem/output_merged_tpm
      old_rsem_count_2: old_rsem_count_2
      old_rsem_fpkm_2: old_rsem_fpkm_2
      old_rsem_tpm_2: old_rsem_tpm_2
      biospecimen_id_RNA: biospecimen_id_RNA
    out: [output_merged_rsem_count,output_merged_fpkm,output_merged_tpm]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4

