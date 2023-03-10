import argparse
import gzip

## Establish input arguments
parser = argparse.ArgumentParser()
parser.add_argument("-cns", help="Merged CNVkit cns file",required=True)
parser.add_argument("-seg", help="Merged CNVkit seg file",required=True)
parser.add_argument("-experiment", help="Experiment strategy",required=True)
parser.add_argument("-out", help="output prefix name",required=True)
args = parser.parse_args()

## Set up variables for the input arguments
cns_files = open(args.cns)
seg_files = open(args.seg)
outfile = gzip.open(args.out+'.'+args.experiment+'.cnvkit.gz','wt')
outfile.write("ID\tchrom\tloc.start\tloc.end\tnum.mark\tseg.mean\tcopy.num\n")
dct = {}
for file in cns_files:
    file = file.strip("\n")
    (bsid,chr,start,end,cn) = file.split('\t')
    key = bsid+'_'+chr+'_'+start+'_'+end
    dct[key] = cn

for seg in seg_files:
    seg = seg.strip('\n')
    (bsid,chr,start,end,num_mark,seg_mean) = seg.split('\t')
    if bsid == 'ID':
        continue
    nstart = int(start)-1
    newkey = bsid+'_'+chr+'_'+str(nstart)+'_'+end
    if newkey in dct.keys():
        outfile.write(seg + '\t'+dct[newkey]+'\n')