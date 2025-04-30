# intersection.pl 

command to run the program from command line
~~~
perl intersection.pl -file1 "file1 name" -file2 "file2 name"
~~~
as an example with the provided files.
~~~
perl intersection.pl -file1 chr21_genes.txt -file2 HUGO_genes.txt
~~~

## Description
It takes the common occuring gene symbol from both file1 and file2 and print it out into "intersectionOutput.txt" in alphabetical order. a subroutine will split the file first by enter and then by tab and store the gene symbol into an array. that subroutine call on both file1 and file2. then it will take the common gene symbol from both respective arrays with the help of hash. sort them in alphabetical order and print it out into output file.  

It takes two arguments from command line
-file1 chr21_genes.txt (having the gene symbol, description and category)  
-file2 HUGO_genes.txt (having the gene symbol & description)

## Ouput
in intersectionOutput.txt you will find 
a list of common gene symbol from file1 and file2 in alphabetical order.

