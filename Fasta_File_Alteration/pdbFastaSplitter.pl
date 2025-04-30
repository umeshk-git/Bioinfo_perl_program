#!/usr/bin/perl
use warnings;
use strict;
use feature qw(say);

# Modules for command line option
use Pod::Usage;
use Getopt::Long;

########################################################################
# 
# File   :  pdbFastaSplitter.pl 
# History:  05-October-2015 (Umesh) wrote the program with subroutines.
#           06-October-2015 (Umesh) changes to subroutines to make it better 
#           08-October-2015 (Umesh) added command line option and formating
#           
########################################################################
#
# The purpose of this program is to take the fasta file with two different 
# information of protein. One is sequence and one is secondary structure and 
# this program will separate those sequences and make two output files
# pdbProtein.fasta having protein sequence & pdbSS.fasta having protein
# secondary structure sequence.
#
########################################################################


# declare a file handler
my $INFILE;


# command line option code start
my $usage = "\n$0 [options]\n\n
Options:-

    -infile   Give a the fasta sequence file name to do the splitting, this file contains
              Two entries for each sequence, one with the protein sequence data, and one with 
              the SS information
    -help     Show this message
\n";

GetOptions(
	"infile=s"	=>\$INFILE,
	"h"			=> sub {pod2usage($usage);},
) or pod2usage(2);

unless($INFILE){
    die "\nDying...Make sure to give a file name of a sequence in FASTA format\n" , $usage;
}
# command line option code over


# two output file name
my $OUTFILE_one = "pdbProtein.fasta";
my $OUTFILE_two = "pdbSS.fasta";


# getFh subroutine call for open a file and to write into a file
my $fhIn = getFh('<' , $INFILE);
my $fhOutOne = getFh('>' , $OUTFILE_one);
my $fhOutTwo = getFh('>', $OUTFILE_two);


# getHeaderAndSequenceArrayRefs subroutine call
my ($refArrHeader, $refArrSeqs) = getHeaderAndSequenceArrayRefs($fhIn);


# dereference the array of header and sequence
my @deRefArrHeader = @$refArrHeader;
my @deRefArrSeqs = @$refArrSeqs;


# match the header line and print it out in corresponding file with its sequence
my $i = 0;
foreach my $headerSeq (@deRefArrHeader) {
	if ($headerSeq =~ /sequence/g)   {
		# print into the file
		say $fhOutOne $headerSeq;
		say $fhOutOne $deRefArrSeqs[$i];
	}
	else {
		say $fhOutTwo $headerSeq;
		say $fhOutTwo $deRefArrSeqs[$i]; 
	}
	$i++;
}


#-----------------------------------------------------------------------
# scalar context: my $fhIn = getFh('<' , $INFILE);
#				my $fhOutOne = getFh('>' , $OUTFILE_one);
#				my $fhOutTwo = getFh('>', $OUTFILE_two);
#-----------------------------------------------------------------------
#
# It open the file to read or write base on the first argument sign (< or >)
# and as a second argument it take the file name either file name from read
# or file name to write.
# 
#-----------------------------------------------------------------------

sub getFh {
    my ($action , $fileName) = @_;
	my $file;
    if ($action eq "<" || ">") {
    open($file, $action , $fileName) or die "Can not open the $file file $!\n";
    return $file;
    }
    else {
        die;
    }
}


#-----------------------------------------------------------------------
# list context: my ($refArrHeader, $refArrSeqs) = getHeaderAndSequenceArrayRefs($fhIn);
#-----------------------------------------------------------------------
#
# It takes file as an argument, split the line from ">" sign. Take header
# into one array and sequence into another array. Return the both array
# reference.
# Inside the subroutine there is another subroutine "_checkSizeOfArrayRefs"
# call. which takes reference to the header and sequence as an argument.
#
#-----------------------------------------------------------------------

sub getHeaderAndSequenceArrayRefs {
    (my $rawFile) = @_; 
    my @lines;
    my @header;
    my @seq;
    # use > as a separator
    local $/ = ">";
    while(<$rawFile>) {
    	chomp;
		@lines= split(/\n/, $_);
		# push header into the header array and sequence into the seq array
		push(@header, shift @lines);
		push(@seq, join("\n", @lines));
	}
	shift @header;
	shift @seq;
	# subroutine call	
	_checkSizeOfArrayRefs(\@header, \@seq);
	return (\@header,\@seq);
}


#-----------------------------------------------------------------------
# void context: -_checkSizeOfArrayRefs(\@header, \@seq);
#-----------------------------------------------------------------------
#
# It takes reference to the header and sequence as an argument. Then
# dereference both and check whether the sizes of the arrays passed 
# into this argument are same. if different, then die with STDERR else return;
#
#-----------------------------------------------------------------------

sub _checkSizeOfArrayRefs {
	my ($refArrHeaderTwo, $refArrSeqsTwo) = @_;
	my $sizeArrHeader = @$refArrHeaderTwo;
	my $sizeArrSeqs = @$refArrSeqsTwo;
	if ($sizeArrHeader == $sizeArrSeqs) {
		return;
	}
	else {
		print STDERR "The size of the arrays passed into this argument are not the same\n";
		die; 
	}
}
