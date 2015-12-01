#!/usr/bin/perl -w
use strict;
use Getopt::Long;

my $lsd_ii=shift;

open (LSDII, "<", $lsd_ii);
my $header=<LSDII> ; ## REMOVE HEADER
$header=~s/[\r|\n]//g;
$header="$header\tcode";
print $header . "\n";

while (<LSDII>){
	my $code=1;
	###### below scripts set code to be 0 if no diff; set to 2 if barley < wheat; unchanged 1 if barley > wheat; 3 if barley=wheat (buffer)
	my $line=$_; $line=~s/[\r|\n]//g;
	my @F= split "\t";
	my ($sev_b,$sev_w,$code1,$code2)=@F[3,7,11,12];
	########## Tke severity barley and wheat, code barley and wheat values
	my @code1=split(//,$code1);
	my %barleyC;
	foreach (@code1){$barleyC{$_}=1}
	my @code2=split(//,$code2);
	foreach my $c (@code2){
		if (exists $barleyC{$c}){
		$code=0;
		}
	};
	if ($code eq 1){
		if ($sev_b<$sev_w){
		$code =2;
		}elsif ($sev_b eq $sev_w){
		$code =3;
		}
	}
	print "$line\t$code\n";
}


