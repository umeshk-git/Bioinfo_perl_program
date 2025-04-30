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
# File   :  chr21GeneNames.pl 
# History:  19-October-2015 (Umesh) wrote the program
#           23-October-2015 (Umesh) commenting 
#           
########################################################################
#
# On command line, It will ask the user to provide the gene symbol. 
# it will retrieve the gene symbol, description of that gene from the 
# given file. it will not stop to ask user for gene symbol until user
# enter quit word. it splits the file data by tab, and put it into a  
# hash key and value pair. with the help of subroutine, it will keep 
# prompting user until get quit from user. with every existing gene 
# symbol (in file),it will find the description and display.
#
########################################################################

#declare file handler
my $fileIn;

# command line option code start
my $usage = "\n$0 [options]\n\n
Options:-

    -file   open the chromosome 21 gene data (chr21_genes.txt)
    -help   Show this message

\n";

GetOptions(
	"file=s"	=>\$fileIn,
	"h"			=> sub {pod2usage($usage);},
) or pod2usage(2);

unless($fileIn){
    die "\nDying...Make sure to give a file name\n" , $usage;
}
# command line option code over

# declare a Hash
my %fileHash = ();

#read the file from file handler
my $file = getFh('<',$fileIn);

#split the file from tab and denote the key and value of hash
while ( my $line = <$file>) {
	chomp ($line);
	my ($key, $discription, $NULL) = split("\t", $line);
	$fileHash{$key} = $discription;
}

# call the subroutine for prompt
while(defined(my $geneSymbol = userPrompt("\nEnter gene name of interest. Type quit to exit: "))) { 
	# it will continue to prompt until quit word
	last if $geneSymbol eq "quit";
	# check that user input symbol exist or not in data
	# if yes then print the description and if no then print error message
	if (exists $fileHash{$geneSymbol}) {
		say "\n$geneSymbol found! Here is the description:";
		say $fileHash{$geneSymbol};	
	}
	else {
		say "\nThe given gene symbole does not exist";
	}
}

#------------------------------------------------------------------------------------------------
# scalar context: my $geneSymbol = userPrompt("\nEnter gene name of interest. Type quit to exit: ")
#------------------------------------------------------------------------------------------------
#
# It will take the prompt message and print it. chomp the user input gene symbol and return it.
#
#------------------------------------------------------------------------------------------------

sub userPrompt {
  my ($prompt) = @_;
  local $| = 1;		# set autoflush;
  print $prompt;
  chomp(my $geneSymbol = <STDIN> // return undef);
  return $geneSymbol;
}