cwlVersion: v1.0
class: Workflow
id: data_assembly_DNA_wf
requirements:
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement
inputs:
  # maf
  input_maf: { type: File }
  input_previous_merged_maf: { type: File }

  
  # CNV
  input_SV: { type: File? }
  input_cnvkit_call_cns: { type: File }
  input_cnvkit_call_seg: { type: File }
  input_controlfreeC_p_value: { type: File}
  input_controlfreeC_info: { type: File }
  input_previous_merged_seg: {type: File}
  histology_file: {type: File}
  gtf_file: {type: File}
  gtf_annote_db: {type: File}

  participant_id: string
  biospecimen_id_tumor: string
  biospecimen_id_normal: string

  run_WGS: { type: boolean, doc: "require run WGS with SV" }
  
  run_WGS_or_WXS: string


outputs:
  new_merged_maf: { type: File, outputSource: merge_maf/output_merged_maf}

  formatted_cnvkit: { type: File, outputSource: format_cnvkit_cnv/output_formatted_cnvkit }
  formatted_controlfreec: { type: File, outputSource: format_controlfreeC_cnv/output_formatted_controlfreeC }
  formatted_sv: { type: 'File[]', outputSource: format_annoSV/output_formatted_annoSV }

  consensus_seg_annotated_cn: {type: File, outputSource: focal-cn-file-preparation/consensus_seg_annotated_cn}
  consensus_seg_annotated_cn_x_and_y: {type: File, outputSource: focal-cn-file-preparation/consensus_seg_annotated_cn_x_and_y}

steps:
  gatekeeper:
    run: ../tools/gatekeeper.cwl
    in:
      run_WGS: run_WGS
    out: [scatter_WGS]

  merge_maf:
    run: ../tools/merge_maf.cwl
    in:
      input_maf: input_maf
      input_previous_merged_maf: input_previous_merged_maf
      biospecimen_id: biospecimen_id_tumor

    out: [output_merged_maf]
  
  annoSV:
    run: ../tools/annoSV.cwl
    in:
      input_SV: input_SV
      conditional_run: gatekeeper/scatter_WGS
    scatter: conditional_run
    out: [output_formatted_SV]

  format_annoSV:
    run: ../tools/format_annoSV.cwl
    in:
      input_annoSV: annoSV/output_formatted_SV
      participant_id: participant_id
      biospecimen_id_tumor: biospecimen_id_tumor
      biospecimen_id_normal: biospecimen_id_normal
      conditional_run: gatekeeper/scatter_WGS
    scatter: conditional_run
    out: [output_formatted_annoSV]

  format_cnvkit_cnv:
    run: ../tools/format_cnvkit_cnv.cwl
    in:
      input_cnvkit_call_cns: input_cnvkit_call_cns
      input_cnvkit_call_seg: input_cnvkit_call_seg
      biospecimen_id: biospecimen_id_tumor
    out: [output_formatted_cnvkit]

  format_controlfreeC_cnv:
    run: ../tools/format_controlfreeC_cnv.cwl
    in:
      input_controlfreeC_p_value: input_controlfreeC_p_value
      input_controlfreeC_info: input_controlfreeC_info
      biospecimen_id: biospecimen_id_tumor
    out: [output_formatted_controlfreeC]
  
  copy_number_consensus_call:
    run: ../tools/copy_number_consensus_call.cwl
    in:
      input_formatted_cnvkit: format_cnvkit_cnv/output_formatted_cnvkit
      input_formatted_controlfreeC: format_controlfreeC_cnv/output_formatted_controlfreeC
      input_formatted_mantaSV: format_annoSV/output_formatted_annoSV
      run_WGS_or_WXS: run_WGS_or_WXS
    out: [output_consensus_seg]

  merge_seg:
    run: ../tools/merge_seg.cwl
    in:
      input_seg: copy_number_consensus_call/output_consensus_seg
      input_previous_merged_seg: input_previous_merged_seg
      biospecimen_id: biospecimen_id_tumor
    out: [output_merged_seg]
  
  focal-cn-file-preparation:
    run: ../tools/focal-cn-file-preparation.cwl
    in:
      consensus_seg_file: merge_seg/output_merged_seg
      histology_file: histology_file
      gtf_file: gtf_file
      gtf_annote_db: gtf_annote_db
      biospecimen_id: biospecimen_id_tumor
    out: [consensus_seg_annotated_cn,consensus_seg_annotated_cn_x_and_y]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4

