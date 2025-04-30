# chr21GeneNames.pl

command to run the program from command line
~~~
perl chr21GeneNames.pl -file "file name"
~~~

as an example with the provided files.
~~~
perl chr21GeneNames.pl -file chr21_genes.txt
~~~

## Description
On command line, It will ask the user to provide the gene symbol. it will retrieve the gene symbol, description of that gene from the given file. it will not stop to ask user for gene symbol until user enter quit word. it splits the file data by tab, and put it into a hash key and value pair. with the help of subroutine, it will keep prompting user until get quit from user. with every existing gene symbol (in file), it will find the description and display.

It takes 1 argument from command line 
-file chr21_genes.txt (having the gene symbol, description and category)

