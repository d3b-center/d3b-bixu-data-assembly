class: CommandLineTool
cwlVersion: v1.0
id: merge_maf
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 1000
  - class: DockerRequirement
    dockerPull: 'xiaoyan0106/monthly-release:1.0'
  - class: InitialWorkDirRequirement
    listing:
      - entryname: input.sh
        entry: |-
          ${
              content = "cat "
              for(i=0;i<inputs.input_maf.length;i++){
                  content += inputs.input_maf[i].path + "\t"
              }
              return content
          }
        writable: false
  - class: InlineJavascriptRequirement
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
        name="${
          var base = "";
          base = inputs.input_maf[0].basename
          var parts = base.split(".");
          parts.shift();
          return (parts.join("."))
        }"
  
        sh input.sh | sed -e '2,\${/#version/d;}' -e '3,\${/Hugo_Symbol/d;}' | gzip  > $(inputs.output_basename).$name.gz
  
inputs:
  input_maf: 'File[]'
  output_basename: string
outputs:
  output_merged_maf:
    type: File
    outputBinding:
      glob: '*.gz'

