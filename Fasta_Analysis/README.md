## nucleotideStatisticsFromFasta.pl
~~~
perl nucleotideStatisticsFromFasta.pl -infile influenza.fasta -outfile influenza.stats.txt
~~~

Note - In order to use the file, please unzip the influenza.fasta.gz file

It takes two arguments from command line

-infile influenza.fasta (having fasta sequences)

-outfile influenza.stats.txt (will have the statistics data on FASTA sequences)

## Output

It will generate influenza.stats.txt file and, you will find below statistics in that

numbering, accession ID, each nucleotide occurance (A,T,G,C, & N(other than A,T,G,C)), Total sequence length, %GC content. 
