open(file0, @ARGV[0]); # T
@T = ();
$m=0;
do{
	$line0 =~ s/\r|\n//g;
	if($line0 ne ''){
		$T[$m++] = $line0;
	}
}while($line0=<file0>);
close file0;

open(file1, @ARGV[1]); # names
open(wf, ">$ARGV[3]");
$i=0;
do{
	chomp($line);
	$line =~ s/\r|\n//g;
	if($line ne ''){ 
		addfiles($line);
		$i++;
	}
}while($line=<file1>);
close file1;
close wf;

sub addfiles(){
   ($fname) = @_;
   $fname = @ARGV[2].$fname.".label"; #dir:../
   open(file, $fname);
   $i=0;
   do{
		chomp($line);
		$line =~ s/\r|\n//g;
		if($line ne ''){
			@arr = split /\s+/, $line;
			if($arr[1] ne ''){
			if($T[$i]==0){
				$ratio=0;
			}else{
				$ratio = $arr[1]*1.0/$T[$i];
			}			
			print wf "$ratio\t";
			$i++;
			}
		}
   }while($line=<file>);
   close file;
   print wf "\n";
   #print "$i\n";
}