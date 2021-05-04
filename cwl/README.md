## Overview

- The goal here is to use the cwl workflow to run the new patient data assembly in cavatica

- cwl folder are including the tools and workflows for the data assembly 

## Structure

```
├── tools
│   ├── annoSV.cwl
│   ├── anno_fusion.cwl
│   ├── copy_number_consensus_call.cwl
│   ├── format_annoSV.cwl
│   ├── format_cnvkit_cnv.cwl
│   ├── format_controlfreeC_cnv.cwl
│   ├── format_fusion.cwl
│   ├── gatekeeper.cwl
│   ├── merge_fusion.cwl
│   ├── merge_maf.cwl
│   └── merge_rsem.cwl
└── workflow
    ├── data_assembly_DNA_wf.cwl
    └── data_assembly_RNA_wf.cwl
```

## Workflow and Inputs 

### data\_assembly\_DNA\_wf.cwl

- This workflow will 

  - merge the maf file to the monthly release

  - format the CNV output from CNVkit and controlfreeC  (run consensus call will add later)

  - run the annotSV and format the SV if WGS 

inputs | example
--- | --- 
input\_SV | eec4895c-9846-461e-9b01-876399f9c108.manta.somaticSV.reheadered.vcf.gz
input\_cnvkit\_call\_cns | eec4895c-9846-461e-9b01-876399f9c108.call.cns
input\_cnvkit\_call\_seg | eec4895c-9846-461e-9b01-876399f9c108.call.seg
input\_controlfreeC\_info | eec4895c-9846-461e-9b01-876399f9c108.controlfreec.info.txt
input\_controlfreeC\_p\_value | eec4895c-9846-461e-9b01-876399f9c108.controlfreec.CNVs.p.value.txt
input\_maf | f4376c77-1c23-460d-8520-bb6aa5730440.consensus\_somatic.vep.maf
input\_previous\_merged\_maf | pbta-merged-chop-method-consensus\_somatic.maf.gz
biospeimens\_id\_normal | BS\_Q07P48SY
biospeimens\_id\_tumor | BS\_1B00Q25Y
participant\_id | PT\_S7JCQ3TH
run\_WGS | False

### data\_assembly\_RNA\_wf.cwl 

- This workflow will

  - run the annotfusion and format the fusion results
  
  - merge the fusion results to the monthly release

  - merged the FPKM/TMP/readcounts to the monthly release

inputs | example
--- | ---
FusionGenome | GRCh38\_v27\_CTAT\_lib\_Feb092018.plug-n-play.tar.gz
arriba\_output\_file | f195c860-6f36-4921-8b1a-0cccdc1ecbd1.arriba.fusions.tsv
input\_rsem | f195c860-6f36-4921-8b1a-0cccdc1ecbd1.rsem.genes.results.gz
old\_arriba | pbta-fusion-arriba.tsv.gz
old\_rsem\_count | pbta-gene-counts-rsem-expected\_count.stranded.rds
old\_rsem\_fpkm | pbta-gene-expression-rsem-fpkm.stranded.rds
old\_rsem\_tpm | pbta-gene-expression-rsem-tpm.stranded.rds
old\_starfusion | pbta-fusion-starfusion.tsv.gz
star\_fusion\_output\_file | f195c860-6f36-4921-8b1a-0cccdc1ecbd1.STAR.fusion\_predictions.abridged.coding\_effect.tsv
biospecimens\_id\_RNA | BS\_PJC6FH4Y
library | stranded

## Cavatica tasks example:

- [data\_assembly\_DNA\_wf](https://cavatica.sbgenomics.com/u/zhangb1/data-assembly-dev/tasks/f76e7c83-360c-4fed-9373-b0af1939157a/)

- [data\_assembly\_RNA\_wf](https://cavatica.sbgenomics.com/u/zhangb1/data-assembly-dev/tasks/57258324-7898-4700-be56-e3ec4eab46c7/)
