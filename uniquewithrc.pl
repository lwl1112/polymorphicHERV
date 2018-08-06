open(file, @ARGV[0]); # finalunique.fa
open(file1, ">$ARGV[1]"); # finalunique_withrc.fa

%data=();
%i=0;
do{
	chomp($line);
	$line=~ s/^\s+|\s+$//g;
	if($line ne ""){
		if(substr($line,0,1) eq '>'){
			$header = $line;
		}else{
			$rc = reverse_complement($line);
			if(exists($data{$line}) || exists($data{$rc})){
				print "error\n";
			}
			$data{$line}++;
			$data{$rc}++;
			# when $line == $rc
			print file1 "$header\n$line\n"; 
			if($line ne $rc){
				print file1 "$header\n$rc\n";
			}else{
				#print "-1\n";
			}
			$i++;
		}
	}
}while($line=<file>);
close file; 
close file1;

$size = keys%data;
#foreach $k (keys%data){
#	if($data{$k}>1){
#		print "$k\n";  # revserse complement
#	}
#}
#	print "$size\t$i\n";

sub reverse_complement {
        my $dna = shift;

	# reverse the DNA sequence
        my $revcomp = reverse($dna);

	# complement the reversed DNA sequence
        $revcomp =~ tr/ACGTacgt/TGCAtgca/;
        return $revcomp;
}