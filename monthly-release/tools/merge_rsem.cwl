class: CommandLineTool
cwlVersion: v1.0
id: merge_rsem
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 1000
  - class: DockerRequirement
    dockerPull: xiaoyan0106/monthly-release:1.0
  - class: InlineJavascriptRequirement
baseCommand: [Rscript /scripts/merge-rsem/merge-rsem-gene-files.R]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      --rsemlist $(inputs.input_rsem[0].dirname) 
      --manifest $(inputs.input_manifest.path) --outdir ./
      --outname_prefix $(inputs.output_basename) --library
      $(inputs.library)

inputs:
  input_rsem: 'File[]'
  input_manifest: File
  library:  {type: ['null', {type: enum, name: library, symbols: ["polya", "stranded"]}]}
  output_basename: string
outputs:
  output_merged_rsem_count:
    type: File
    outputBinding:
      glob: '*gene-counts-rsem-expected_count.*rds'
  output_merged_rsem_fpkm:
    type: File
    outputBinding:
      glob: '*gene-expression-rsem-fpkm.*rds'
  output_merged_rsem_tpm:
    type: File
    outputBinding:
      glob: '*gene-expression-rsem-tpm.*rds'
