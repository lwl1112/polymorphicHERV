open(file,@ARGV[0]);  # labels.fa
open(file1,">$ARGV[1]"); # unique.fa

$sum = 0;
do{
	chomp($line);
	$line=~ s/^\s+|\s+$//g;
	if($line ne ""){
		if(substr($line,0,1) eq ">"){
			@array = split /;/, $line; 
			$size = @array;
			if($size==1){
				$header = $line;
			}else{
				$header = "";
			}
			foreach $v (@array){
				@arr = split /,/, $v;
				$asize = @arr;				
				$sum += $size;
			}
			
		}else{
			if($header ne ""){
				print file1 "$header\n$line\n";
			}
		}
	}
}while($line=<file>);
close file; 
close file1;
#print "$sum\n";