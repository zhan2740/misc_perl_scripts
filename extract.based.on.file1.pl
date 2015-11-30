#/usr/bin/perl -w


if (@ARGV<2){die "please specify file1 file2"};

my $file1= shift;

open (IN1, "<", $file1);

my %id;
while (<IN1>){
	$_=~s/[\r|\n]//g;
	my @F=split "\t";
	$id{$F[0]}=1;
}

my $file2=shift;
open (IN2, "<", $file2);
my $header=<IN2>;
print $header; 

while (<IN2>){
	$_=~s/[\r|\n]//g;
	my $line=$_;
	my @F=split (/\t/,$line,2);
	my $tag=$F[0];
	if (exists $id{$tag}){
		print $line . "\n";
	}

}



