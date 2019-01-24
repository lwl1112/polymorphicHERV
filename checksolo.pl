
$loc = @ARGV[2]; # chr11_101565794_101575259
$length = length($loc);
$out = @ARGV[5];

%ref = ();
open(file1, @ARGV[1]); #unique.withrc
do{
	chomp($line);
	$line=~ s/^\s+|\s+$//g;
	if($line ne ""){
		if(substr($line,0,1) eq ">"){ 
			$header = substr($line,1);
		}else{
			$ref{$line} = $header;
		}
	}

}while($line=<file1>);
close file1; 

open(file, @ARGV[0]);
do{
	chomp($name);
	$name=~ s/^\s+|\s+$//g;
	if($name ne ""){
  	 
  	 open(wf, ">$out/$name.fa");#write
  	 %patientkmers = ();
  	 open(patientfile, "$ARGV[3]/$name.50.fa");
  	 #print "$directory$name.50.fa\n";
  	 do{
  	 	chomp($line);
		$line=~ s/^\s+|\s+$//g;
		if($line ne ""){
			if(substr($line,0,1) eq ">"){ 
			$header = substr($line,1);
			}else{
				$patientkmers{$header} = $line;
			}
		}
  	 }while($line=<patientfile>);
	close patientfile; 
	$size = keys%patientkmers;
	#print "$size\n";

	$nn=0;
  	 open(resfile, "$ARGV[4]/$name.dat");
  	 #print "$directory$f\n";
  	 do{
  	 	chomp($line);
		$line=~ s/^\s+|\s+$//g;
		if($line ne ""){
			@arr2 = split /\s+/, $line;
			$str = substr($arr2[1],0,22);
			#print "$str\n";
			if(substr($arr2[1],0, $length) eq $loc){
				#print "$line\n";
				$nn++;
				$kmer = $patientkmers{$arr2[0]};
				if($ref{$kmer} ne $arr2[1]){
					print "$ref{$kmer}\t\t$arr2[1]\n";
				}else{
					print wf ">$arr2[1]\n$kmer\n";
				}
			}
		}
  	 }while($line=<resfile>);
	close resfile; 
	close wf;
	print "$name\t$nn\n";
  }
}while($name=<file>);
close file; 
