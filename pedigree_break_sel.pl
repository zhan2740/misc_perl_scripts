#!/usr/bin/perl -w
use strict;   
use Getopt::Long;  
use List::Util qw (sum);  
use autodie qw (open close);

### Written by Liangliang Gao (U of Minnesota) 7/14/2015 for field F5 pedigree breakup, and sampling 

if (@ARGV <4){ die "usage: perl pedigree_break_sel.pl --field_book 2015_F5_field_book.txt --equiv_p equiv_parents.txt"};

my ($field_book,$equiv_p);
GetOptions ("field_book=s"=>\$field_book, "equiv_p=s"=>\$equiv_p);
######## Field book is field book. Equiv_p is a file with equivalent parents such as Rollag and MN05214-3

open (my $fbook, "< $field_book");
my $fb_pedigree_split = $field_book;
$fb_pedigree_split =~s/\.txt/\.pedigree_split\.txt/;
open (my $fb_ped, "> $fb_pedigree_split");  ### open a file handle for splitted pedigree

#1  This is a function or subroutine to convert equiv_p to a uniform parent name
sub convert_p {
	open (my $eqp, "< $equiv_p"); ## 1st col typo 2nd col standard ...
	my %hash_p;
	while (<$eqp>){$_=~s/[\r|\n]//g; my @F=split "\t"; if (@F ==2){$hash_p{$F[1]}=$F[0]}}; 
	my $input=$_[0]; my $output="";
	if (exists $hash_p{$input}){$output=$hash_p{$input}}else{$output=$input};
	$output=~s/[-|\s]Sr.*/-Sr/;  ### replacing Sr suffix of parent names
	return $output;
}

my %p_contr;



#2 break down pedigree 
while (<$fbook>){
	my $line =$_; $line=~s/[\r|\n]//; ##remove new line
	my @F = split ("\t",$line);
	my ($f5,$cross,$pedigree,$A6,$crk)=@F[0,1,2,9,15];
	my @parents=split (/\/+/, $pedigree);  ### splitting the pedigree to get founder parents info
	my @p_convert=@parents;
	foreach my $p (@p_convert) {$p=&convert_p($p)};
	############## @p_convert is a list of names converted 
				## -Sr42 etc were replaced with -Sr
				## SD3997 etc were converted to cultivar names Forefront etc.
	##############  
	########Now, we need to assign parental contribution to each parent in each F5 line
	if (@p_convert == 3) {
		my ($p1,$p2,$p3)=@p_convert[0..2];
		if ($p1 !~/\s/ && $p2 !~/\s/ && $p3 !~/\s/){
			print $fb_ped "$f5\t$cross\t$pedigree\t$A6\t$crk\t$p1\t0.25\t$p2\t0.25\t$p3\t0.5\n";
			$p_contr{$p1}+=0.25; $p_contr{$p2}+=0.25; $p_contr{$p3}+=0.5; 
		}else {
			print $fb_ped "$f5\t$cross\t$pedigree\t$A6\t$crk\tNA\t\tNA\tNA\tNA\tNA\tNA\n";
		}
		### This says that if this is a 3-way cross, and there are no extra spaces in each parent (@pS WITH extra spaces are not our targets)
		### Then parental contribution are 0.25 for first two, and 0.5 for last parent
	}elsif (@p_convert == 2){
		my ($p1,$p2)=@p_convert[0..1];
		if ($p1!~/\s/ && $p1 !~/CMS/ && $p2!~/\s/){
			print $fb_ped "$f5\t$cross\t$pedigree\t$A6\t$crk\t$p1\t0.5\t$p2\t0.5\tNA\tNA\n";
			$p_contr{$p1}+=0.5; $p_contr{$p2}+=0.5;
		}else {
			print $fb_ped "$f5\t$cross\t$pedigree\t$A6\t$crk\tNA\tNA\tNA\tNA\tNA\tNA\n";
		}
		### This says that if this is a 2-way simple cross, and there are no extra spaces and no CMS 
		### Parental contribution are 0.5 each;
	}else {
		print $fb_ped "$f5\t$cross\t$pedigree\t$A6\t$crk\tNA\tNA\tNA\tNA\tNA\tNA\n";
		### This says that if this has no cross, then it is not official F5 population, will be ignored and output NA
	}
}

######## Now finished splitting pedigree and assign parental contribution numbers for each F5 line

close $fbook;

open (my $fh2, "> parent.contr.txt");
foreach my $p  (sort keys %p_contr){
	print $fh2 "$p\t$p_contr{$p}\n";
}


###########

# After this step, you will get an output file named "2015_F5_field_book.pedigree_split.txt"
# Proceed with R for pedigree-based random sampling or training population design




