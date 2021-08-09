class: CommandLineTool
cwlVersion: v1.0
id: merge_rsem
requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'zhangb1/data-assembly'
  - class: InlineJavascriptRequirement
baseCommand: [Rscript /d3b-bixu-data-assembly/scripts/merge_rsem/00-create-and-add-rsem-gene-files.R]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      --input_rsem $(inputs.input_rsem.path) --outdir ./ --mergefiles TRUE --old_rsem_count $(inputs.old_rsem_count.path) --old_rsem_fpkm $(inputs.old_rsem_fpkm.path) --old_rsem_tpm $(inputs.old_rsem_tpm.path) --outname_prefix pbta-$(inputs.biospecimen_id_RNA) --library $(inputs.library) --biospecimens_id $(inputs.biospecimen_id_RNA)

inputs:
  input_rsem: File
  old_rsem_count: File
  old_rsem_fpkm: File
  old_rsem_tpm: File
  library:  {type: ['null', {type: enum, name: library, symbols: ["polya", "stranded"]}]}
  biospecimen_id_RNA: string
outputs:
  output_merged_rsem_count:
    type: File
    outputBinding:
      glob: '*rsem-expected_count.*rds'
  output_merged_fpkm:
    type: File
    outputBinding:
      glob: '*rsem-fpkm.*rds'
  output_merged_tpm:
    type: File
    outputBinding:
      glob: '*rsem-tpm.*rds'
