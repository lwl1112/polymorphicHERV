# filtering: 1. remove dupilication 2. remove multi-labels
# return sample with single-label
# AC008996	1
# AC244103	2
# AC213208	3
# AC231384	4
# chr* 		0
# Usage: perl filtering.pl <filename> <out>
open(file,@ARGV[0]);  #fasta file
$line = <file>;
open(file1,">$ARGV[1]"); # Write file
%tuple=();
$name="";
$class=-1;
sub reverse_complement {
        my $dna = shift;

	# reverse the DNA sequence
        my $revcomp = reverse($dna);

	# complement the reversed DNA sequence
        $revcomp =~ tr/ACGTacgt/TGCAtgca/;
        return $revcomp;
}

do{
	chomp($line);
	if(substr($line,0,1) eq ">"){ 
		@array = split /:/, $line;
		$name = @array[0];		 
	}
	else{
		if($name eq ">AC008996"){
			$class = 19;
		} elsif ($name eq ">AC244103"){
			$class = 1;
		} elsif ($name eq ">AC213208"){
			$class = 12;
		} elsif ($name eq ">AC231384"){
			$class = 10;
		} elsif (substr($name,0,4) eq ">chr"){
			$class = 0;
		} elsif (substr($name,0,5) eq ">K113"){
			$class = 113;
		} elsif (substr($name,0,5) eq ">K115"){
			$class = 115;
		} else {
			print "error\n";
			$class=-1;
		}
		
		$rc = reverse_complement($line);
		
		if(exists($tuple{$line})){
			if($class != $tuple{$line}){
				$tuple{$line} = -1;
			}
		}
		elsif(exists($tuple{$rc})){
			if($class != $tuple{$rc}){
				#$c = $tuple{$rc};
				#print "$c\t$class\n";
				$tuple{$rc} = -1;
			}
		}
		else{
			$tuple{$line} = $class;
		}
			
	}
}while($line=<file>);
close file;

# remove -1
for $sample (sort keys %tuple){
	if($tuple{$sample} != -1){
		print file1 "$sample\t$tuple{$sample}\n";
	}	
}
close file1;
