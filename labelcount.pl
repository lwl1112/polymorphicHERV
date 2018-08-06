open(file,@ARGV[0]);  #nm file: hash label generated from findmathc.pl
open(file0, @ARGV[1]);#### follow sorted label: sortedSites.2017
open(file1,">$ARGV[2]"); # label freq
#375339	chr1:166574604-166580258@166578947
#375340	chr1:166574604-166580258@166578947;chr9:...
%labels=();
do{
	chomp($line);	
	if($line ne ''){ 
		if(index($line, ';')==-1){
			@arr = split /\t/, $line;
			@arr2 = split /@/, $arr[1]; # label @ pos
			$labels{$arr2[0]}{$arr2[1]}++;
		}
	}
}while($line=<file>);
close file;

####################
@sortedlabel=();
$i=0;
do{
	$line =~ s/\r|\n//g;
	
	chomp($line);	
	if($line ne ''){ 
		 $sortedlabel[$i++]=$line;
	}
}while($line=<file0>);
close file0;
########################
#$sum=0;
#foreach $l (sort keys%labels){
#	foreach $k (sort keys%{$labels{$l}}){
#		$sum+=$labels{$l}{$k};
#	}
#}
#print "$sum\n";

$zeros = 0;
foreach $l (@sortedlabel){
	if (exists($labels{$l})){
		$size = keys%{$labels{$l}};
		print file1 "$l\t$size\n";
	}else{
		print file1 "$l\t0\n";
		$zeros++;
	}
}

@k = keys%labels;
$s = @k;
if($s+$zeros!=94){
	print "$s\t$zeros\n";
}
close file1;