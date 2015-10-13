#!/usr/bin/perl -w
use strict;
use Data::Dumper::Simple;
use Getopt::Long;
use List::Util qw (sum);

if (@ARGV <2) {die "usage: please specify input chr_file and fasta_file"; };

my ($chr_file,$fasta_file);
GetOptions ("chr_file=s"=>\$chr_file, "fasta_file=s"=>\$fasta_file);

my (%pos_scaff, %chr)=();
open (CHR_FILE, "< $chr_file");
<CHR_FILE>; #remove header
while (<CHR_FILE>){
	chomp; my @F=split "\t";
	my ($scaff,$chr,$pos)=@F[0,5,6];
	@{$pos_scaff{$scaff}}=($chr,$pos);
	$chr{$chr}=1;
}



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
			open (OUT, ">> ${chr}.txt") or die $!;
			print OUT ">${id}_${chr}_${pos}\n$seq\n";
		}else {
			open (OUT2, ">> not.mapped.fa") or die $!;
			print OUT2 ">$id\n$seq\n"
		};
	}
}

