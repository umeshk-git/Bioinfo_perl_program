#!/usr/bin/perl
use warnings;
use strict;
use feature qw(say);
use Data::Dumper;

# Modules for command line option
use Pod::Usage;
use Getopt::Long;

####################################################################################
# 
# File   :  codingTask.pl 
# History:  21-February-2016 (Umesh) wrote the program
#           22-February-2016 (Umesh) commenting & formatting 
#           
####################################################################################
#
# This program is about to filter out fasta sequences based on different conditions 
# and calculate the score based on different preferences. It first open the fasta 
# file, access the sequence line by line and with the help of hash, pass the sequence 
# from below mentioned criteria to filter out unwanted sequence. Then calculate the 
# score of the filtered sequence based on below mentioned 3 preferences and score 
# the sequence out of 300 (100 per preference). 
#
####################################################################################

# declare file handler
my $fileInOne;

# to get command line option
my $usage = "\n$0 [options]\n\n
Options:-

    -file	open the fasta file (coadingTaskSequence.fa)
    -help	Show this message

\n";

GetOptions(
	"file=s"	=> \$fileInOne,
	"h"			=> sub {pod2usage($usage);},
) or pod2usage(2);

unless ($fileInOne) {
    die "\nDying...Make sure to give an appripriate file name\n" , $usage;
}

# command line option code over

# declare global variable
my $pam;
my $target;
my %seqHash;
my @wholeSeq;

# Open a file
unless (open(FILE,"<", $fileInOne)) {
	die "can't open $fileInOne file", $!;
}

while (my $seq = <FILE>) {
	chomp $seq;
	# remove the white spaces if any
	$seq =~ s/^\s+|\s+$//g;
	# push into an array (for further use)
	push @wholeSeq, $seq;
	# regex to remove first line and get ony sequence ending with NGG
	if ($seq =~ m/^A|T|G|C/ && $seq =~ /[ATGC]GG$/) {
		$pam = substr($seq,-3);
		$target = substr($seq,0,-3);
		# give the target sequence as a key and PAM sequence as its value
		$seqHash{$target} = $pam;
	}
}

####################################################################################
# 			To filter out based on below criteria
####################################################################################
#
# 1) Targets that are not between 20%-80% GC content
# 2) Targets with an ATG motifs
# 3) Targets with homopolymers of more than 4 in a row
#
####################################################################################

# define global variable
my $gcContent;
my %filteredHash;
my %gcContentHash;
 
foreach my $line (keys %seqHash) {
	# to calculate GC content
	my $seqLength = length $line;
	my $gcCount = $line =~ tr/GC//;
	$gcContent = ($gcCount / $seqLength) * 100;
	
	# to satisfy first condition
	if ($gcContent > 20 && $gcContent < 80) {
		# to satisfy second condition
		if ($line !~ /ATG/g) {
			# to satisfy third condition
			unless ($line =~ m/A{5}|T{5}|G{5}|C{5}/) {
				# store the filtered sequence
				$filteredHash{$line} = $seqHash{$line};
				$gcContentHash{$line} = $gcContent;
			}	
		}
	}
}

####################################################################################
# 				To calculate score
####################################################################################
# I have calculated the score out of 300 (100 per criteria)
# 
# 1) Preference given to targets that have a PAM with a G or C as its first nucleotide
# 2) Preference for targets closest to 45% GC content.
# 3) Preference given to targets with high 'specificity' for their 'seed region' 
#    (nucleotides 13-20, 1-based numbering)
#
####################################################################################

# define global variable
my $score1;
my $score2;
my $score3;
my $seed;
my $found = 0;

# print out the heading
print "\n",'-' x 77;
printf "\n%-51s   %-13s   %5s\n","Target Sequence","PAM Sequence","Score";
print '-' x 77,"\n";

while (my ($targetKey,$pamStart) = each %filteredHash) {
	# score for first preference
	if($pamStart =~ /^G|C/) {
		$score1 = 100;
	}
	else {
		$score1 = 0;
	}
	
	# score for second preference (I have considered 45 GC content as 100 score)
	my $score2 = ($gcContentHash{$targetKey} * 100) / 45;
	if ($score2 > 100) {
		$score2 = 100 - ($score2 - 100);
	}
	
	# score for third preference
	$found = 0;
	$seed = substr $targetKey, 12, 8;
	for (my $j=0; $j < scalar(@wholeSeq); $j++) {
		if (index($wholeSeq[$j], $seed) != -1) {
		$found = $found + 1;
		}
	}
	if ($found == 1) {
		$score3 = 100;
	}
	else {
		$score3 = 0
	}
	
	# to get the total score out of 300
	my $score = ($score1 + $score2 + $score3);
	
	# print out the result on terminal
	printf "%-51s   %-13s   %.2f\n\n",$targetKey,$pamStart,$score;
}
