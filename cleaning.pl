# dirty = samples - clean
# Usage: perl cleaning.pl <samples.fasta> <cleandata> <clean.fasta>
open(file,@ARGV[0]);  #fasta file
$line = <file>;
open(cleanfile,@ARGV[1]);  # file
$cleanline = <cleanfile>;
open(file1,">$ARGV[2]"); # Write file
%clean=();
$header="";
do{
	chomp($cleanline);
	@array = split /\t/, $cleanline;
	$clean{@array[0]}++;
}while($cleanline=<cleanfile>);
close cleanfile;
 
do{
	chomp($line);
	if(substr($line,0,1) eq ">"){ 
		$header = $line;		 
	}
	else{
		if(exists($clean{$line})){ 
			print file1 "$header\n$line\n"; 
		}
	}
}while($line=<file>);
close file;

close file1;
