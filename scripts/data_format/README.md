# data format 

### Description

These perl scripts are used for the data format before the CNV consensus call data assembly step.

There are 3 major data format script.

```
CNVKit
Control-freeC
MantaSV
```

### Usage

#### CNVkit data format

```
usage: perl format_CNVkit.pl [options]
options:
        -call_cns|CNS:         *call.cns file from CNVkit
        -call_seg|SEG:         *call.seg file from CNVkit
        -help|h|?:             print help information

e.g.:
        perl format_CNVkit.pl -call_cns 106762e7-e100-405b-9ae9-bb80a186cdf9.call.cns  -call_seg 106762e7-e100-405b-9ae9-bb80a186cdf9.call.seg 
```

#### Control freeC data format

```
usage: perl format_control-freeC.pl [options]
options:
        -P_value|P:            *p.value.txt file from control_freeC
        -INFO|I:               *info.txt file from control_freeC
        -biospecimens_id|bs:   Tumor Biospecimens ID
        -help|h|?:             print help information

e.g.:
        perl format_control-freeC.pl -P_value 106762e7-e100-405b-9ae9-bb80a186cdf9.controlfreec.CNVs.p.value.txt -INFO 106762e7-e100-405b-9ae9-bb80a186cdf9.controlfreec.info.txt -biospecimens_id BS_13DJ6WHW
```

#### SV data format

```
usage: perl format_SV.pl [options]
options:
        -sv|S:                               Input SV file
        -participant_id|P:                   Participant ID
        -biospecimen_id_normal|bs_n:         Normal Biospecimens ID
        -biospecimen_id_tumor|bs_t:          Tumor Biospecimens ID
        -help|h|?:                           print help information

e.g.:
        perl format_SV.pl -sv 0940375a-83db-42e2-aa0b-f5f71e4aa466.manta.somaticSV.reheadered.annotated.tsv -participant_id PT_C9YDTZPA -biospecimen_id_normal BS_VKGSMV3F -biospecimen_id_tumor BS_CA4CRZKP
```