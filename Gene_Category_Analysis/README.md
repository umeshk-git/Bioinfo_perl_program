# categories.pl 

command to run the program from command line
~~~
perl categories.pl -file1 "file1 name" -file2 "file2 name"
~~~
as an example with the provided files.
~~~
perl categories.pl -file1 chr21_genes.txt -file2 chr21_genes_categories.txt
~~~

## Description
It counts the occurance of each category in file1 and print it into a file named "categories.txt" with the category, occurance & defination ( takes defination from the file2 ). form file1 it split data and take the gene symbol as a key and category as a value and store in a hash. from file2, it take the categoty as a key and description as a value and store into another hash. find occurance of each category for every gene symbol and print the category, occurance & defination into output file in ascending order.

It takes two arguments from command line
-file1 chr21_genes.txt (having the gene symbol, description and category)  
-file2 chr21_genes_categories.txt (having the category & description)

## Output
in categories.txt you will find

Category, Occurance and Description of each category in ascending order (of occurance).

