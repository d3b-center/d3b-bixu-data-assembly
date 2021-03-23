#! usr/bin/perl
use Getopt::Long;

sub usage {
        print STDERR << "USAGE";
usage: perl $0 [options]
options:
        -call_cns|CNS:         *call.cns file from CNVkit
        -call_seg|SEG:         *call.seg file from CNVkit
        -help|h|?:             print help information

e.g.:
        perl $0
USAGE
        exit 0;
}

GetOptions(
        "call_cns|CNS:s" => \$cns,
        "call_seg|SEG:s" => \$seg,
        "help|h|?" => \$help,
);

die &usage() if (!defined $cns || !defined $seg || $help);


open IN,"$cns";
while(<IN>){
	chomp;
	@line=split(/\t/,$_);
        #get copy number from the column
	$hash{$line[1]}{$line[2]}=$line[6];
	}
print "ID\tchrom\tloc.start\tloc.end\tnum.mark\tseg.mean\tcopy.num\n";
open IN2,"$seg";
while(<IN2>){
	chomp;
	@seg_line=split(/\t/,$_);
        # -1 from the statr pos to match the cns file pos
        $start = $seg_line[2]-1;
	if (exists $hash{$start}{$seg_line[3]}){
		print "$_\t$hash{$start}{$seg_line[3]}\n";
		}
	}
