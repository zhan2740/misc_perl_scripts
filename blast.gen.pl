#!/usr/bin/perl -w
use strict;
use Data::Dumper::Simple;
use Getopt::Long;
use List::Util qw (sum);

########### This program can be modified to suit batch processing of different software programs.

if (@ARGV <6) {die "usage: please specify input --fasta --db_dir --outdir"; };

############## This is the MSI HPC QSUB headers; institute specific information
################ 


my ($fasta,$db_dir,$outdir);
GetOptions ("fasta=s"=>\$fasta, "db_dir=s"=>\$db_dir, "outdir=s"=>\$outdir);

my $software = "/soft/ncbi_blast+/2.2.28/bin/blastn";

opendir (DH, $db_dir);
my @db_files=grep{/_db.nhr/}readdir(DH);

########### print command for each database or sample iteration. 
########### The databases here are chromosome specific, as wheat genome are so huge to be put into a single one
##################
foreach my $db (sort @db_files){
	my $db_name=$db; $db_name=~s/_db\.nhr//;
	print "$software -db $db_dir/${db_name}_db -query $fasta -outfmt 6  -out $outdir/$db_name.blastout -perc_identity 95\n";
}
