#! usr/bin/perl
use Getopt::Long;

sub usage {
        print STDERR << "USAGE";
usage: perl $0 [options]
options:
        -P_value|P:         *p.value.txt file from control_freeC
        -INFO|I:            *info.txt file from control_freeC
		-biospecimens_id|bs:   Tumor Biospecimens ID
        -help|h|?:          print help information

e.g.:
        perl $0
USAGE
        exit 0;
}

GetOptions(
        "P_value|P:s" => \$p_value,
        "INFO|I:s" => \$info,
		"biospecimens_id|bs:s" => \$bs,
        "help|h|?" => \$help,
);

die &usage() if (!defined $p_value || !defined $info || $help);


open IF,"$info";
while(<IF>){
	chomp;
	if (/^Output_Ploidy/){
		@ploidy_line=split(/\t/,$_);
		$ploidy=$ploidy_line[1];
	}
}
print "Kids_First_Biospecimen_ID\tchr\tstart\tend\tcopy number\tstatus\tgenotype\tuncertainty\tWilcoxonRankSumTestPvalue\tKolmogorovSmirnovPvalue\ttumor_ploidy\n";
open IN,"$p_value";
while(<IN>){
	chomp;
	if (/^chr/){
		next;
	}
	# print out bs_id and ploidy info
	print "$bs\t$_\t$ploidy\n";
}
