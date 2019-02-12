open(file, @ARGV[0]);
open(file1, ">$ARGV[1]");
$i=0;
do{
	chomp($line);
	if($line ne ''){
		if(substr($line,0,1) eq '>'){
			@arr = split /@/, $line;
			print file1 "$arr[0]\@$i\n"; 
			$i++;
		}else{
			print file1 "$line\n"; 
		}
	}
}while($line=<file>);
close file;
close file1;
 