cwlVersion: v1.0
class: CommandLineTool 
id: gatekeeper
requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/ubuntu:18.04'
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
inputs:
  run_WGS: boolean
outputs:
  scatter_WGS:
    type: int
    outputBinding:
      outputEval:
        ${
          if (inputs.run_WGS) {return [1]}
          else {return []}
        }
