class: CommandLineTool
cwlVersion: v1.0
id: copy_number_consensus_call_WXS
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 1000
  - class: DockerRequirement
    dockerPull: 'zhangb1/data-assembly'
  - class: InlineJavascriptRequirement
baseCommand: [mkdir]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      -p scratch && mkdir results && python /d3b-bixu-data-assembly/scripts/copy_number_consensus_call/scripts/merged_to_individual_files.py --cnvkit $(inputs.input_formatted_cnvkit.path) --freec $(inputs.input_formatted_controlfreeC.path) --snake ./scratch/config_snakemake.yaml --scratch ./scratch --uncalled ./results/uncalled_samples.tsv && snakemake -s /d3b-bixu-data-assembly/scripts/copy_number_consensus_call/Snakefile_WXS --configfile ./scratch/config_snakemake.yaml -j --restart-times 2 && cp ./results/data-cnv-consensus.seg.gz .

inputs:
  input_formatted_cnvkit: File
  input_formatted_controlfreeC: File
  conditional_run: { type: int, doc: "Placeholder variable to allow conditional running" }

outputs:
  output_consensus_seg:
    type: File
    outputBinding:
      glob: '*.consensus.seg.gz'