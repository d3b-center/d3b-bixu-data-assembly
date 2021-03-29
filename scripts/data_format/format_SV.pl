#! usr/bin/perl
use Getopt::Long;

sub usage {
        print STDERR << "USAGE";
usage: perl $0 [options]
options:
        -sv|S:                               Input SV file
        -participant_id|P:                   Participant ID 
        -biospecimen_id_normal|bs_n:         Normal Biospecimens ID
        -biospecimen_id_tumor|bs_t:          Tumor Biospecimens ID
        -help|h|?:                           print help information

e.g.:
        perl $0
USAGE
        exit 0;
}

GetOptions(
        "sv|S:s" => \$sv,
        "participant_id|P:s" => \$participant_id,
        "biospecimen_id_normal|bs_n:s" => \$biospecimen_id_normal,
        "biospecimen_id_tumor|bs_t:s" => \$biospecimen_id_tumor,
        "help|h|?" => \$help,
);

die &usage() if (!defined $sv || !defined $participant_id || $help);

open IN,"$sv";
while(<IN>){
	chomp;
	@line=split(/\t/,$_);
	if (/^AnnotSV/){
		$_=~s/ /\./g;
		print "$_\tKids.First.Participant.ID\tKids.First.Biospecimen.ID.Normal\tKids.First.Biospecimen.ID.Tumor\n";
		next;
		}
	print "$_\t$participant_id\t$biospecimen_id_normal\t$biospecimen_id_tumor\n";
	}
