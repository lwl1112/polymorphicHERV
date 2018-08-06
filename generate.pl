my $directory = @ARGV[0];

$K = @ARGV[2];
opendir(DIR,$directory);
my @files = readdir(DIR);
closedir(DIR);

foreach $f (@files){
  if($f ne '.' && $f ne '..'){
  	generate($f, $directory, $ARGV[1]);    
  }
}


sub generate(){
	($infile, $indir, $outdir) = @_;
	$in = $indir.$infile;
	print "$in\n";
	$out = $outdir.$infile;
	print "$out\n";
	open(file,$indir.$infile);  #fasta file
	$L= $K;#@ARGV[1]; #sample length 
	$line = <file>;
	$name = "";
	$label="";
	open(file1, ">$outdir$infile"); # Write file
	@ai = split /\./, $infile;	
	$virus = $ai[0];
	print "$virus\n";
	do{
		chomp($line);
		$line=~ s/^\s+|\s+$//g;
		if(substr($line,0,1) eq ">"){ 
			$name = substr($line,1);	
			$find = " ";
			$replace = "";
			$find = quotemeta $find; # escape regex metachars if present
			$name =~ s/$find/$replace/g;
			print "$name\n";
		}else{
			$len = length($line);
			$line=uc($line); #capitalize
			if($len-$L >=0) {
				  $str="";
				  for($i=0;$i<$len-$L+1;$i++){
						print file1 ">$virus\@$name:$i\n";  
						$sample = substr($line,$i,$L);
						print file1 "$sample\n";  
				  }
			  }
		}
	}while($line=<file>);
	close file; 	
	close file1;
}
