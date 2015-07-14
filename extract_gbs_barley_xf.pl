#!/usr/bin/perl -w 

use strict;

my $file=shift;


open (IN, "< $file"); 
my %hit_s;
while (<IN>){
	my $line=$_; $line=~s/[\r|\n]//;
	my @F= split (/\t/, $line);
	my ($ID, $len, $mis, $gap,$e,$s)=@F[0,3,4,5,10,11];
	if (!exists $hit_s{$ID} ) {
			print  "$line\n";	
			$hit_s{$ID}++;
	}elsif (exists $hit_s{$ID} && $hit_s{$ID} <= 1){
		print "$line\n";
		$hit_s{$ID}++;
	}
}



