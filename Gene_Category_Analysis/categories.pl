#!/usr/bin/perl
use warnings;
use strict;
use feature qw(say);
use MyIO qw(getFh);

# Modules for command line option
use Pod::Usage;
use Getopt::Long;

########################################################################
# 
# File   :  categories.pl 
# History:  19-October-2015 (Umesh) wrote the program
#           24-October-2015 (Umesh) commenting 
#           
########################################################################
#
# It counts the occurance of each category in file1 and print it into a 
# file named "categories.txt" with the category, occurance & defination 
# ( takes defination from the file2 ). form file1 it split data and take 
# the gene symbol as a key and category as a value and store in a hash. 
# from file2, it take the categoty as a key and description as a value 
# and store into another hash. find occurance of each category for every 
# gene symbol and print the category, occurance & defination into output 
# file in ascending order.
#
########################################################################


# declare file handler
my $fileInOne;
my $fileInTwo;

# command line option code start
my $usage = "\n$0 [options]\n\n
Options:-

    -file1   open the chromosome 21 gene data (chr21_genes.txt)
    -file2   open the chromosome 21 gene category data (chr21_genes_categories.txt)
    -help    Show this message

\n";

GetOptions(
	"file1=s"	=> \$fileInOne,
	"file2=s"	=> \$fileInTwo,
	"h"			=> sub {pod2usage($usage);},
) or pod2usage(2);

unless ($fileInOne) {
    die "\nDying...Make sure to give a file name having gene symbol, description & category\n" , $usage;
}

unless ($fileInTwo) {
    die "\nDying...Make sure to give a file name having gene category detail\n" , $usage;
}
# command line option code over

# declare the hashes
my %fileHashOne = ();
my %fileHashTwo = ();

# read OR create a file using getFh function from MyIO module
my $fileOne = getFh ('<',$fileInOne);
my $fileTwo = getFh ('<',$fileInTwo);
my $fileOut = getFh ('>','categories.txt');

# create a string (header of the output file)
my $fileString = "Category\tOccurance\tDefination\n";

# for file one,
while ( my $lineOne = <$fileOne> ) {
	chomp ($lineOne);
	# split the data from tab & denote the appropriate key and value to the file one hash 
	my ($key, $discription, $categoryNum) = split("\t", $lineOne);
	if ($key ne "Gene Symbol") {
	$fileHashOne{$key} = $categoryNum;
	}
}

# for file two,
while ( my $lineTwo = <$fileTwo> ) {
	chomp ($lineTwo);
	# split the data from tab & denote the appropriate key and value to the file two hash
	my ($keyNum, $categoryDisc) = split("\t", $lineTwo);
	$fileHashTwo{$keyNum} = $categoryDisc;
}

# declare the hash
my %count = ();
# count the frequency of the gene name
foreach my $geneName (values %fileHashOne) { 
	if ( exists $count{$geneName} ) {
		$count{$geneName}++;
	} 
	else {
		$count{$geneName} = 1;
	}
}

# sort the count frequency by ascending order and take the category, occurance and description  
foreach my $key ( sort{ $count{$a} <=> $count{$b} } keys %count ) {
	if ($key ne "") {
	$fileString .= "$key\t$count{$key}\t$fileHashTwo{$key}\n";
	}
}

#print it out into the output file
say $fileOut $fileString;