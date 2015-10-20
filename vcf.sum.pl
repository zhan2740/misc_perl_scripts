#!/usr/bin/perl -w
use strict;
use Data::Dumper::Simple;
use Getopt::Long;
use List::Util qw (sum);

if (@ARGV <1) {die "usage: please specify input --gff --vcfdir --outdir\n"};


my ($gff,$vcfdir,$outdir);
GetOptions ("gff=s"=>\$gff, "vcfdir=s"=>\$vcfdir, "outdir=s"=>\$outdir);

my ($hash_chr);

open (GFF, "<", $gff); ####### open GFF file to read gene, beg, end, positions for each gene model
while (<GFF>){
	chomp; my @F = split "\t";
	my ($chr,$type,$beg,$end,$id_gene)=@F[0,2,3,4,8];
	if ($type eq "gene"){
		$id_gene=~s/ID=|;//g;
		$hash_chr->{$chr}=[] if !exists $hash_chr->{$chr};
		push @{$hash_chr->{$chr}}, [$beg,$end,$id_gene];
	}
}

my (%count,%countAA, %countAB); #### Initialize counting...
my @vcf = `ls $vcfdir | grep flt.vcf`;

foreach my $vcf (@vcf){
	chomp ($vcf);
	open (IN, "<", "$vcfdir/$vcf");
	open (OT, ">", "$outdir/$vcf.sum.out");
	(%count,%countAA,%countAB)=();
	while (<IN>){
		chomp; 
		if (!/^\#/){
			my @F=split "\t";
			my ($chr,$pos,$type)=@F[0,1,9];
			my @type = split (/:/, $type);
			$type=$type[0];
			my $ary_ref =$hash_chr->{$chr};
			my @genes = grep {$_->[0] <= $pos && $_->[1]>=$pos }@{$hash_chr->{$chr}};
			########### getting each gene model; grep if the snp is within a gene
			if (@genes>0) {
				my $gene = $genes[0] -> [2]; 
				$count{$gene}++;
				if ($type eq "1/1"){
					$countAB{$gene}||=0; $countAA{$gene}++;
					########### count++ for 1/1, which represents universally different reference compared to sequenced
				}else {
					$countAA{$gene}||=0; $countAB{$gene}++;
					########### count++ for 1/0, which represents hybrid differences reference compared to sequenced
				}
			}
		}
	}
	foreach my $g (sort keys %count){
		print OT "$g\t$count{$g}\t$countAA{$g}\t$countAB{$g}\n";
	}
}






