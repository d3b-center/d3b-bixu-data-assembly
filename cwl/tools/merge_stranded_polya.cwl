class: CommandLineTool
cwlVersion: v1.0
id: merge_stranded_polya
requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'zhangb1/data-assembly'
  - class: InlineJavascriptRequirement
baseCommand: [Rscript /d3b-bixu-data-assembly/scripts/merge_rsem/combine-matrices.R]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      --matrices $(inputs.input_rsem_count_merged.path),$(inputs.old_rsem_count_2.path) --outfile gene-counts-rsem-expected_count.$(inputs.biospecimen_id_RNA).rds 
      && Rscript /d3b-bixu-data-assembly/scripts/merge_rsem/combine-matrices.R --matrices $(inputs.input_rsem_fpkm_merged.path),$(inputs.old_rsem_fpkm_2.path) --outfile gene-expression-rsem-fpkm.$(inputs.biospecimen_id_RNA).rds 
      && Rscript /d3b-bixu-data-assembly/scripts/merge_rsem/combine-matrices.R --matrices $(inputs.input_rsem_tpm_merged.path),$(inputs.old_rsem_tpm_2.path) --outfile gene-expression-rsem-tpm.$(inputs.biospecimen_id_RNA).rds 
inputs:
  input_rsem_count_merged: File
  input_rsem_fpkm_merged: File
  input_rsem_tpm_merged: File
  old_rsem_count_2: File
  old_rsem_fpkm_2: File
  old_rsem_tpm_2: File
  biospecimen_id_RNA: string
outputs:
  output_merged_rsem_count:
    type: File
    outputBinding:
      glob: '*gene-counts-rsem-expected_count.*rds'
  output_merged_fpkm:
    type: File
    outputBinding:
      glob: '*gene-expression-rsem-fpkm.*rds'
  output_merged_tpm:
    type: File
    outputBinding:
      glob: '*gene-expression-rsem-tpm.*rds'
