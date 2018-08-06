open(file, @ARGV[0]);#   $  population 
open(file1, ">$ARGV[1]");  # population.json
print file1 "\{\n";
 
do{
	chomp($line);
	$line =~ s/\r|\n//g;
	if($line ne ''){
		@arr = split ( /\s+/, $line); 
		#"HG00096": "GBR",
		print file1 "\"$arr[0]\": \"$arr[1]\",\n";
	}
}while($line=<file>);
close file;
print file1 "\}\n";
close file1;