# polymorphicHERV
Mining mapped reads for accurately predicting polymorphic human endogenous retroviruses

Steps:

perl generatedataset.pl <rawfile> <LengthofSample> <outputfile>  -> samples.fasta  # len=50

perl filtering.pl <filename> <out>   -> cleandata (sample \t lable) // remove duplications, and multi-labels

perl cleaning.pl <samples.fasta> <cleandata> <clean.fasta>

bwa index clean.fasta

bwa mem (-T 40) clean.fasta read.fasta > out.sam

perl count.pl out.sam 


