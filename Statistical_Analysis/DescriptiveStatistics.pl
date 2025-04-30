#!/usr/bin/perl
use strict;
use warnings;
use feature qw(say);
use Scalar::Util qw(looks_like_number);

########################################################################
# 
# File   :  DescriptiveStatistics.pl 
# History:  27-September-2015 (Umesh) wrote the program
#           29-September-2015 (Umesh) commenting & more documentation
#           
########################################################################
#
# The purpose of this program is to take out a column of data and produce
# descriptive statistics (like variance, std dev, median) on the column of 
# data. The data model will be an array, which is filled from data from an 
# infile.
#
#########################################################################

# command line argument
my $filename = $ARGV[0];

# open a file
open(my $FILE,"<",$filename)
or die "Can not open the $filename file $!\n";

# declare global variable
my @break;
my $columnToParse;
my @rawData;


while (<$FILE>) {
	chomp;
	@break = split("\t",$_);
	if ($ARGV[1] <= scalar(@break)) {
		$columnToParse = $break[$ARGV[1]];
		push (@rawData, $columnToParse);
	}
	else {
		die "The column number provided is excedded the actual columns in the file\n";
	}
}


my @data;
foreach my $expr (@rawData) {
	if ($expr eq "NaN" || $expr eq "inf") {
	}
	else {
		if (looks_like_number($expr)) {push (@data, $expr);
		}
	}
}

# subroutine call
my $avg = average(@data);
my $var = variance(@data);
my $med = median(@data); 

my $rawCount = scalar(@rawData);

my $count = scalar(@data);

my $max = (sort{$b <=> $a} @data)[0];

my $min = (sort{$a <=> $b} @data)[0];

#count standard deviation
my $stdDev = sqrt($var);

#Display
print "	Column : $ARGV[1]\n";
print "Count	 =	"; printf '%.3f',$rawCount; print"\n";
print "validNum =	"; printf '%.3f',$count; print"\n";
print "Average	 =	"; printf '%.3f',$avg; print"\n";
print "Maximun	 =	"; printf '%.3f',$max; print"\n";
print "Minimum	 =	"; printf '%.3f',$min; print"\n";
print "Variance =	"; printf '%.3f',$var; print"\n";
print "Std Dev	 =	"; printf '%.3f',$stdDev; print"\n";
print "Median	 =	"; printf '%.3f',$med; print"\n";

#subroutine to calculate average
sub average {
	my @array = @_;
	my $sum;
	foreach (@array) {
		$sum += $_;
	}
	if (scalar @array == 0) {
		die "To find the average, the denominator should be greater than 0.\n";
	}
	else {
		return $sum/(scalar @array);
	}
}

#subroutine to calculate variance
sub variance {
	my @array = @_;
	my $sqtotal;
	foreach (@array) {
		$sqtotal += ($_ - $avg)**2	
	}
	my $denom = (scalar(@array) - 1);
	if ($denom == 0) {
		die "To find the variance, the denominator should be greater than 0.\n";
	}
	else {		
		return $sqtotal/$denom;
	}
}


#subroutine to calculate median
sub median {
	my @array = @_;
	my $median;
	my $mid = int @array/2;
	my @order = sort {$a <=> $b} @array;
	if (@array % 2) {
		$median = $order[$mid];
	}
	else {
		$median = ($order[$mid -1] + $order[$mid])/2;
	} 
	return $median;
}
