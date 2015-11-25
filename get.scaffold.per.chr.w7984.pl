#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use List::Util qw (sum);

if (@ARGV <2) {die "usage: please specify input chr_file and fasta_file"; };

my ($chr_file,$fasta_file);
GetOptions ("chr_file=s"=>\$chr_file, "fasta_file=s"=>\$fasta_file);

########### reading and taking information regarding chromosome position of scaffolds or contigs
my (%pos_scaff, %chr, %FH)=();
open (CHR_FILE, "< $chr_file");
<CHR_FILE>; #remove header
while (<CHR_FILE>){
	chomp; my @F=split "\t";
	my ($scaff,$chr,$pos)=@F[0,5,6];
	@{$pos_scaff{$scaff}}=($chr,$pos);
	$chr{$chr}=1;
}

################## openning file handles , ready to print to each chromosome
foreach my $key (sort keys %chr){
	my $file=$key . ".fa";
	open (my $fh, ">", $file);
	$FH{$key}=$fh;
}

open (OUT2, "> not.mapped.fa") or die "cannot open output file for not.mapped.fa";

################# This is the main program to separate single genome wide build into chromosome specific builds.
$/=">"; ## set the record separator to be ">"
open (FASTA, "< $fasta_file");
while (<FASTA>){
	$_=~s/>//g; 
	my @fields=split (/\n/, $_);
	if (@fields>0){
		my $id=shift @fields;
		my $seq=join('', @fields);
 		if (exists $pos_scaff{$id}) {
			my ($chr,$pos) = @{$pos_scaff{$id}}[0,1];
			my $fh = $FH{$chr};
			print $fh ">${id}_${chr}_${pos}\n$seq\n";
		}else {
			print OUT2 ">$id\n$seq\n"
		};
	}
}

