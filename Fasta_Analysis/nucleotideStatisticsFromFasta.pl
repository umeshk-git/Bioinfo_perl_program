#!/usr/bin/perl
use warnings;
use strict;
use feature qw(say);

# Modules for command line option
use Pod::Usage;
use Getopt::Long;


########################################################################
# 
# File   :  nucleotideStatisticsFromFasta.pl 
# History:  05-October-2015 (Umesh) wrote the program with subroutines.
#           07-October-2015 (Umesh) added command line option and formating 
#           08-October-2015 (Umesh) addition in the comments
#           
########################################################################
#
# The purpose of this program is to take the fasta file having numbers of
# sequences and perform statistics on each of the fasta sequence entry
# into the file.
# statistics like number of each nucleotides in one sequence, length of
# sequence, %GC content. 
#
########################################################################


# declare a file handler
my $INFILE;
my $OUTFILE;


# command line option code start
my $usage = "\n$0 [options]\n\n
Options:-

       -infile   Give a the fasta sequence file name to do the stats on
       -outfile  Provide a output file to put the stats into
       -help     Show this message
\n";

GetOptions(
	"infile=s"	=>\$INFILE,
	"outfile=s" =>\$OUTFILE,
	"h"			=> sub {pod2usage($usage);},
) or pod2usage(2);

unless($INFILE){
    die "\nDying...Make sure to give a file name of a sequence in FASTA format\n" , $usage;
}
unless($OUTFILE){
    die "\nDying...Make sure to give an outfile name for the stats\n" , $usage;
}
# command line option code over


# Defining the global variables
my @arrNucleotide;
my $length;
my @allSeqLength;
my $gcPercentContent;
my $accession;
my $fileString;
my $i = 0;
my $number;


# getFh subroutine call for open a file and to write into a file
my $fhIn = getFh('<' , $INFILE);
my $fhOut = getFh('>' , $OUTFILE);


# getHeaderAndSequenceArrayRefs subroutine call
my ($refArrHeader, $refArrSeqs) = getHeaderAndSequenceArrayRefs($fhIn);


# dereference the array of header and sequence
my @deRefArrHeader = @$refArrHeader;
my @deRefArrSeqs = @$refArrSeqs;

# printSequenceStats subroutine call
printSequenceStats($refArrHeader, $refArrSeqs, $fhOut);


#-----------------------------------------------------------------------
# scalar context: my $fhIn = getFh('<' , $INFILE);
# 				my $fhOut = getFh('>' , $OUTFILE);
#-----------------------------------------------------------------------
#
# It opens the file to read or write base on the first argument sign (< or >)
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


#-----------------------------------------------------------------------
# void context: printSequenceStats($refArrHeader, $refArrSeqs, $fhOut);
#-----------------------------------------------------------------------
#
# It takes 3 arguments- reference to the header, reference to the sequence,
# and the file to write. It first dererence the both array and create a 
# filestring (header to print in file). foreach sequence in array, it print the 
# count number, length of the sequence & GC%. There is also 2 subroutine call
# (_getAccession and _getNtOccurance), and after that it print the accession 
# number (extracted from each header) and each nucleotide count. At last repeat
# the process to print out statistics for each sequence into the file name given
# by the user.
# 
#-----------------------------------------------------------------------

sub printSequenceStats {
	my ($refArrHead, $refArrSequence, $fhOutput) = @_;
	my @deRefHead = @$refArrHead;
	my @deRefSequence = @$refArrSequence;
	
	# the header line of the output file (separated by tab)		
	$fileString = "Number\tAccession\tA's\tT's\tG's\tC's\tN's\tLength\tGC%\n";
	
	foreach my $seqOne (@deRefSequence) {	
		# for numbering
		$number = $i + 1;
		$fileString .= "$number\t";
		
		# for accession number
		my $header = $deRefHead[$i];
		my $acc = _getAccession($header);
		$fileString .= "$acc\t";
		
		chomp $seqOne;
		
		#for nucleotide count
		my $A = _getNtOccurrence('A', \$seqOne);
		my $T = _getNtOccurrence('T', \$seqOne);
		my $G = _getNtOccurrence('G', \$seqOne);
		my $C = _getNtOccurrence('C', \$seqOne);
		my $N = _getNtOccurrence('N', \$seqOne);
		$fileString .= "$A\t$T\t$G\t$C\t$N\t";
	
		# for length count of the sequence
		$length = length($seqOne);
		$fileString .= "$length\t";
		
		# for GC% content count
		my $gcTotal = $G + $C;
		$gcPercentContent = sprintf "%.2f",(($gcTotal/$length) * 100); 
		$fileString .= "$gcPercentContent\n";
	
	$i++;
	
	}		
	# print into the given output file name
	say $fhOutput $fileString;
}


#-----------------------------------------------------------------------
# scalar context: my $acc = _getAccession($header);
#-----------------------------------------------------------------------
#
# It takes scalar argument that is the header to the sequence. Split the
# header by space and take out the first index (0th index) of array and
# return it. which is the accession number.
#
#-----------------------------------------------------------------------

sub _getAccession {
	my ($headOne) = @_;
	# split the header line by space
	my @splitHead = split / /, $headOne;
	$accession = $splitHead[0];
	return $accession;
}


#----------------------------------------------------------------------- 
# scalar context: my $A = _getNtOccurrence('A', \$seqOne);
#				my $T = _getNtOccurrence('T', \$seqOne);
#				my $G = _getNtOccurrence('G', \$seqOne);
#				my $C = _getNtOccurrence('C', \$seqOne);
#				my $N = _getNtOccurrence('N', \$seqOne);
#-----------------------------------------------------------------------
#
# It takes two argument, one is the nucleotide base and another is the 
# reference to the sequence data. Dereference the sequence and store
# each nucleotide base into an array and count given nucleotide occurance
# with the help of regular expression and return the count number.
# 
#-----------------------------------------------------------------------

sub _getNtOccurrence {
	my ($base,$refSequenceOne) = @_;
	my $deRefSequenceOne = $$refSequenceOne;
	# split by each nucleotide and store into an array 
	@arrNucleotide = split("", $deRefSequenceOne);
	my $count = 0;
	# for each nucleotide, do matching. and if match, count it
	foreach my $nucleotide (@arrNucleotide) { 
		if ($nucleotide =~ /$base/) {
			$count++;					
		}
		if ($base eq "N") {
			if ($nucleotide !~ /A|T|G|C/) {
				$count++;
			}
		}			
	}
	return $count; 
}
