import argparse
import gzip

## Establish input arguments
parser = argparse.ArgumentParser()
parser.add_argument("-info", help="Merged controlFreeC info file",required=True)
parser.add_argument("-pvalue", help="Merged controlFreeC p-value file",required=True)
parser.add_argument("-experiment", help="Experiment strategy",required=True)
parser.add_argument("-out", help="Manifest prefix name",required=True)
args = parser.parse_args()

## Set up variables for the input arguments
info_files = open(args.info)
pvalue_files = open(args.pvalue)
outfile = gzip.open(args.out+'.'+args.experiment+'.controlfreec.info.controlfreeC.gz','wt')
outfile.write("Kids_First_Biospecimen_ID\tchr\tstart\tend\tcopy number\tstatus\tgenotype\tuncertainty\tWilcoxonRankSumTestPvalue\tKolmogorovSmirnovPvalue\ttumor_ploidy\n")
dct = {}
for file in info_files:
    file = file.strip("\n")
    (bsid,tumor_ploidy) = file.split('\t')
    dct[bsid] = tumor_ploidy

for pvalue in pvalue_files:
    pvalue = pvalue.strip('\n')
    bsid = pvalue.split('\t')[-1]
    df = pvalue.rsplit("\t",1)[0]
    if bsid == 'Kids_First_Biospecimen_ID':
        continue
    if bsid in dct.keys():
        outfile.write(bsid + '\t' + df + '\t'+dct[bsid]+'\n')