#!/usr/bin/perl -w
use strict;
use Data::Dumper::Simple;
use Getopt::Long;
use List::Util qw (sum);

if (@ARGV <6) {die "usage: please specify input --fasta --db_dir --outdir"; };

print "#!/bin/bash -l\n#PBS -l pmem=4gb,nodes=1:ppn=2,walltime=24:00:00\n#PBS -m abe\n\n\n";

my ($fasta,$db_dir,$outdir);
GetOptions ("fasta=s"=>\$fasta, "db_dir=s"=>\$db_dir, "outdir=s"=>\$outdir);

my $software = "/soft/ncbi_blast+/2.2.28/bin/blastn";

opendir (DH, $db_dir);
my @db_files=grep{/_db.nhr/}readdir(DH);

foreach my $db (sort @db_files){
	my $db_name=$db; $db_name=~s/_db\.nhr//;
	print "$software -db $db_dir/${db_name}_db -query $fasta -outfmt 6  -out $outdir/$db_name.blastout -perc_identity 95\n";
}
