#! usr/bin/perl
use Getopt::Long;

sub usage {
        print STDERR << "USAGE";
usage: perl $0 [options]
options:
        -gainloss|G:          *gailoss file
        -biospecimen_id|bs:   Tumor Biospecimens ID
        -help|h|?:             print help information

e.g.:
        perl $0
USAGE
        exit 0;
}

GetOptions(
        "gainloss|P:s" => \$gainloss,
	"biospecimen_id|bs:s" => \$bs,
        "help|h|?" => \$help,
);

die &usage() if (!defined $gainloss || $help);


#print "Kids_First_Biospecimen_ID\tchr\tstart\tend\tcopy number\tstatus\tgenotype\tuncertainty\tWilcoxonRankSumTestPvalue\tKolmogorovSmirnovPvalue\ttumor_ploidy\n";
print "BS_ID\tgene\tchromosome\tstart\tend\tlog2\tdepth\tweight\tn_bins\n";
open IN,"$gainloss";
while(<IN>){
	chomp;
	if (/^chr/){
		next;
	}
	print "$bs\t$_\n";
}
