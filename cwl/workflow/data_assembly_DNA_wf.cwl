cwlVersion: v1.0
class: Workflow
id: data_assembly_DNA_wf
requirements:
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement
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


  participant_id: string
  biospeimens_id_tumor: string
  biospeimens_id_normal: string

  run_WGS: { type: boolean, doc: "require run WGS with SV" }


outputs:
  New_merged_maf: { type: File, outputSource: merge_maf/output_merged_maf}

  Formatted_cnvkit: { type: File, outputSource: format_cnvkit_cnv/output_formatted_cnvkit }
  formatted_controlfreeC: { type: File, outputSource: format_controlfreeC_cnv/output_formatted_controlfreeC }
  Formatted_SV: { type: File, outputSource: format_annoSV/output_formatted_annoSV }

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
      biospecimens_id: biospeimens_id_tumor

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
      biospeimens_id_tumor: biospeimens_id_tumor
      biospeimens_id_normal: biospeimens_id_normal
      conditional_run: gatekeeper/scatter_WGS
    scatter: conditional_run
    out: [output_formatted_annoSV]

  format_cnvkit_cnv:
    run: ../tools/format_cnvkit_cnv.cwl
    in:
      input_cnvkit_call_cns: input_cnvkit_call_cns
      input_cnvkit_call_seg: input_cnvkit_call_seg
      biospecimens_id: biospeimens_id_tumor
    out: [output_formatted_cnvkit]

  format_controlfreeC_cnv:
    run: ../tools/format_controlfreeC_cnv.cwl
    in:
      input_controlfreeC_p_value: input_controlfreeC_p_value
      input_controlfreeC_info: input_controlfreeC_info
      biospecimens_id: biospeimens_id_tumor
    out: [output_formatted_controlfreeC]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4

