class: CommandLineTool
cwlVersion: v1.0
id: copy_number_consensus_call
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 1000
  - class: DockerRequirement
    dockerPull: 'zhangb1/data-assembly'
  - class: InlineJavascriptRequirement
baseCommand: ["/bin/bash -c"]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      set -eo pipefail
      ${
        if (inputs.run_WGS_or_WXS == "WGS"){
         var cmd = "mkdir -p scratch && mkdir results && python /d3b-bixu-data-assembly/scripts/copy_number_consensus_call/scripts/merged_to_individual_files.py --manta " + inputs.input_formatted_mantaSV[0].path + " --cnvkit " + inputs.input_formatted_cnvkit.path + " --freec " + inputs.input_formatted_controlfreeC.path  + " --snake ./scratch/config_snakemake.yaml --scratch ./scratch --uncalled ./results/uncalled_samples.tsv && snakemake -s /d3b-bixu-data-assembly/scripts/copy_number_consensus_call/Snakefile --configfile ./scratch/config_snakemake.yaml -j --restart-times 2 && cp ./results/data-cnv-consensus.seg.gz ." + ";"       
        }
        else{
         var cmd = "mkdir -p scratch && mkdir results && python /d3b-bixu-data-assembly/scripts/copy_number_consensus_call/scripts/merged_to_individual_files.py --cnvkit " + inputs.input_formatted_cnvkit.path + " --freec " +  inputs.input_formatted_controlfreeC.path + " --snake  ./scratch/config_snakemake.yaml --scratch ./scratch --uncalled ./results/uncalled_samples.tsv && snakemake -s /d3b-bixu-data-assembly/scripts/copy_number_consensus_call/Snakefile_WXS --configfile ./scratch/config_snakemake.yaml -j --restart-times 2 && cp ./results/data-cnv-consensus.seg.gz ." + ";"
        }
        return cmd;
      }
inputs:
  input_formatted_cnvkit: File
  input_formatted_controlfreeC: File
  input_formatted_mantaSV: File[]?
  run_WGS_or_WXS: string

outputs:
  output_consensus_seg:
    type: File
    outputBinding:
      glob: '*consensus.seg.gz'
