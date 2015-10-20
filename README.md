#misc_perl_scripts
some misc perl
### get.scaffold.per.chr.w7984.pl 
This is a script to take two files: 
  (1) fasta file of all genome wide scaffolds .... E.g. Chapman 2015 Genome Biology Build 
  (2) chr info of those scaffolds.
The program separates the contigs or scaffold sequences according to their chromosome origin and 
  output them into separate chr.specific fasta files. New line character within sequences were removed.

### pbs.blast.gen.pl
This is a driver script to generate text files to batch process multiple jobs. The program takes the 3 options.
  (1) --fasta  your source fasta file
  (2) --db_dir  your database path
  (3) --outdir your BLAST output path

### vcf.sum script
This program takes vcf and GFF files and count how many SNPs are within a gene model and if the SNP is a true SNP, or likely representing universal differences between the reference genome and the sequenced genome


