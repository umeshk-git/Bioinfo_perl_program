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
# File   :  intersection.pl 
# History:  20-October-2015 (Umesh) wrote the program
#           23-October-2015 (Umesh) commenting
#           
########################################################################
#
# It takes the common occuring gene symbol from both file1 and file2 and 
# print it out into "intersectionOutput.txt" in alphabetical order. 
# a subroutine will split the file first by enter and then by tab and 
# store the gene symbol into an array. that subroutine call on both file1 
# and file2. then it will take the common gene symbol from both respective 
# arrays with the help of hash. sort them in alphabetical order and print 
# it out into output file.
#
########################################################################


# declare file handlers
my $fileInOne;
my $fileInTwo;

# command line option code start
my $usage = "\n$0 [options]\n\n
Options:-

    -file1   open the chromosome 21 gene data (chr21_genes.txt)
    -file2   open the HUGO gene data (HUGO_genes.txt)
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
    die "\nDying...Make sure to give a file name having gene symbol and description\n" , $usage;
}
# command line option code over

# read OR create a file using getFh function from MyIO module
my $fileOne = getFh ('<',$fileInOne);
my $fileTwo = getFh ('<',$fileInTwo);
my $fileOut = getFh ('>','intersectionOutput.txt');

# getFileOneGeneSymbol subroutine call
my @fileOneGeneSymbol = getFileOneGeneSymbol ($fileOne);
my @fileTwoGeneSymbol = getFileOneGeneSymbol ($fileTwo);


#-----------------------------------------------------------------------
# scalar context: my @fileOneGeneSymbol = getFileOneGeneSymbol ($fileOne);
#				  my @fileTwoGeneSymbol = getFileOneGeneSymbol ($fileTwo);
#-----------------------------------------------------------------------
#
# It takes file handle as an argument. Then split the data from enter (\n)
# and then again split the resultant data from tab (\t). And then push the 
# gene symbol into the array. shit the array and return it.
#
#-----------------------------------------------------------------------

sub getFileOneGeneSymbol {
	(my $fileIn) = @_;
	my @geneSymbol;
	while (<$fileIn>) {
		chomp;
		my @line = split(/\n/,$_);
		my @tabWord = split(/\t/, $_); 
		push(@geneSymbol,shift @tabWord);
	}
	shift @geneSymbol;
	return @geneSymbol;
}

# take out the common gene symbol from the both array using map and grep function
my %commonArray = map {$_ => 1} @fileTwoGeneSymbol;
my @commonGeneSymbol = grep {$commonArray{$_}} @fileOneGeneSymbol;

# sort the common gene symbol in alphabetical order
my @sortCommonGeneSymbol = sort { (lc($a) cmp lc($b)) or ($a cmp $b) } @commonGeneSymbol;

# print the total number of common gene symbol on the terminal
say scalar @sortCommonGeneSymbol , " common gene symboles were found from \"chr21_genes.txt\" & \"HUGO_genes.txt\" files";

# print the common sorted gene symbol into the output file
say $fileOut join("\n", @sortCommonGeneSymbol);