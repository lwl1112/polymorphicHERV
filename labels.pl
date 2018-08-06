open(file1, ">$ARGV[0]");
#$total = $#ARGV + 1;

%kmers = ();
#for ($i=1; $i<$total; $i++){
#	data(@ARGV[$i]);
#}

my $directory = @ARGV[1];
opendir(DIR,$directory);
my @files = readdir(DIR);
closedir(DIR);
foreach $f (@files){
  if($f ne '.' && $f ne '..'){
  	  data($directory.$f);
  }
}

  	  
sub reverse_complement {
        my $dna = shift;

	# reverse the DNA sequence
        my $revcomp = reverse($dna);

	# complement the reversed DNA sequence
        $revcomp =~ tr/ACGTacgt/TGCAtgca/;
        return $revcomp;
}


sub data(){ # , combine kmer within virus
	($infile) = @_;
	open(file, $infile);
	do{
		chomp($line);
		$line =~ s/\r|\n//g;
		
		if($line ne ""){
			if(substr($line,0,1) eq ">"){
				@arr = split /\@/, $line;
				$header = $arr[1];
				$virus = $arr[0];
			}else{
				# capital case
				$line = uc($line);
				# reverse complement
				$rc = reverse_complement($line);

				############
				if($line eq "ATATATATATATATATATATATATATATAT"){
					print $rc;
				}
				############
				if(exists($kmers{$line})){
					if(exists($kmers{$line}{$virus})){
						$kmers{$line}{$virus} = $kmers{$line}{$virus}.",".$header;
					}else{
						$kmers{$line}{$virus} = $header;
					}
				}elsif(exists($kmers{$rc})){
					if(exists($kmers{$rc}{$virus})){
						$kmers{$rc}{$virus} = $kmers{$rc}{$virus}.",".$header;
					}else{
						$kmers{$rc}{$virus} = $header;
					}
				}else{
					$kmers{$line}{$virus}=$header;
				}
			}
		}
	}while($line=<file>);
	close file; 
}

foreach $k ( keys%kmers){ # ; combine kmer between viruses #sort keys
	$header="";
	foreach $v (sort keys%{$kmers{$k}}){
		$header = $header.";".$v."@".$kmers{$k}{$v};
	}
	$header = substr($header,1);
	print file1 "$header\n$k\n";
}
close file1;