#pbs: perl findmatch.pl finalunique_withrc.fa file1 file100
#id \t label
# perl labelcount.pl hashlabels/HG00096.dat sortedSites  hashlabels/HG00096.label

#$start_run = time();
open(file, @ARGV[0]); # finalunique_withrc.fa
$fastadir = @ARGV[1]; # input dir: patient_fasta70/
$hashlabeldir = @ARGV[2]; # output dir: hashlabels/
$K = @ARGV[3];
%data=();
do{
	chomp($line);
	$line=~ s/^\s+|\s+$//g;
	if($line ne ""){
		if(substr($line,0,1) eq '>'){
			$header = substr($line,1);
		}else{
			$data{$line} = $header;
		}
	}
}while($line=<file>);
close file; 
#$end_run = time();
#$duration = $end_run - $start_run;
#print "$duration s\n";

for ($i=4; $i<$#ARGV + 1; $i++){
	getlabels($fastadir, $ARGV[$i], $hashlabeldir); # $ARGV[$i]: patient names -> files
}
#$end_run2 = time();
#$duration = $end_run2 - $end_run;
#print "$duration s \n";

sub getlabels(){
	($dir, $f, $outdir) = @_;
	open(file, $dir.$f.".$K.fa");
	open(file1, ">$outdir$f.dat");
	do{
		chomp($line);
		$line=~ s/^\s+|\s+$//g;
		if($line ne ""){
			if(substr($line,0,1) eq '>'){
				$header = substr($line,1);
			}else{
				if(exists($data{$line})){
					print file1 "$header\t$data{$line}\n";
				}
			}
		}
	}while($line=<file>);
	close file; 
	close file1;
}