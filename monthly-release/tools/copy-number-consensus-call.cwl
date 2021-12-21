class: CommandLineTool
cwlVersion: v1.0
id: copy-number-consensus-call
requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'xiaoyan0106/monthly-release:1.0'
  - class: InlineJavascriptRequirement
baseCommand: [mkdir]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      -p scratch && mkdir results && python
      /scripts/copy-number-consensus-call/scripts/merged_to_individual_files.py 
      --cnvkit $(inputs.input_formatted_cnvkit.path) --freec
      $(inputs.input_formatted_controlfreeC.path) --snake 
      /scratch/config_snakemake.yaml  --scratch /scratch --uncalled
      ./results/uncalled_samples.tsv $(inputs.run_WGS_or_WXS == 'WGS' ?
      '--manta ' + inputs.input_formatted_mantaSV.path : '') && snakemake
      -s /scripts/copy-number-consensus-call/$(inputs.run_WGS_or_WXS ==
      'WGS' ? 'Snakefile' : 'Snakefile_WXS')  --configfile
      /scratch/config_snakemake.yaml  -j  --restart-times 2  && cp
      ./results/pbta-cnv-consensus.seg.gz
      $(inputs.output_basename).cnv-consensus.seg.gz;

inputs:
  input_formatted_cnvkit: File
  input_formatted_controlfreeC: File
  input_formatted_mantaSV: File?
  run_WGS_or_WXS: { type: { type: 'enum', name: run_WGS_or_WXS, symbols: ["WGS", "WXS"] } }
  output_basename: string
 
outputs:
  output_consensus_seg:
    type: File
    outputBinding:
      glob: '*consensus.seg.gz'
