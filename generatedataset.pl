# generate samples with length $L
# Usage: perl generatedataset.pl <rawfile> <LengthofSample> <outputfile>
open(file,@ARGV[0]);  #fasta file
$L= @ARGV[1]; #sample length 
$line = <file>;
$name = "";
$start = -1;
$end = -1;
$allend = -1;
$allstart = -1;

open(file1,">$ARGV[2]"); # Write file
do{
	chomp($line);
	$line=~ s/^\s+|\s+$//g;
	if(substr($line,0,1) eq ">"){ 
		# header
		@array = split /:/, $line;
		$name = @array[0];
		@positions = split /-/, @array[1];
		$allstart = @positions[0];
		$allend = @positions[1];
	}else{
		if($allstart!=-1 && $allend!=-1){
		  $line=uc($line); #capitalize
		  if(length($line)-$L >=0) {
		  	  $str="";
		  	  for($i=0;$i<length($line)-$L+1;$i++){
		  	  	  $start = $allstart + $i;
		  	  	  $end = $start + $L-1;
		  	  	  if($end > $allend){
		  	  	  	  print $name.":".$start."-".$end."error!\n";
		  	  	  } else{
		  	  	  	 print file1 "$name:$start-$end\n"; #lwl 
		  	  	  	 $sample = substr($line,$i,$L);
		  	  	  	print file1 "$sample\n"; #lwl
		  	  	  	#$str=$str.$sample."\t"; #lwl
		  	  	  }
			  }
			  #$str =~ s/^\s+|\s+$//g; #lwl
			  #print file1 "$str\n"; #lwl
		  }
		}
	}
}while($line=<file>);
close file; 

close file1;

              
