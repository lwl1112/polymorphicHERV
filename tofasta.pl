# generate samples with length $L
# Usage: perl generatedataset.pl <rawfile> <LengthofSample:50> <outputfile>
open(file,@ARGV[0]);  # text file
open(file1,">$ARGV[1]"); # fasta file
$i=1;
do{
	chomp($line);
	$line=~ s/^\s+|\s+$//g;
	if($line ne ""){
		print file1 ">$i\n";
		@array = split /\s+/, $line; 
		print file1 "$array[0]\n";
		$i++;
	}
}while($line=<file>);
close file; 

close file1;

              