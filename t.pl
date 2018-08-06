my $directory = @ARGV[0];
open(wf, ">$ARGV[1]");

$K = @ARGV[2];
opendir(DIR,$directory);
my @files = readdir(DIR);
closedir(DIR);

#####
print wf "#!/bin/sh\n#PBS -l nodes=1:ppn=1\n#PBS -l walltime=24:00:00\n#PBS -N t$K.pbs\ncd /gpfs/home/wul135/scratch/codes\n";
#####
# file names
#print wf "perl labels.pl 95labels.dat ";
foreach $f (@files){
  #print $_,"\n";
  if($f ne '.' && $f ne '..'){
  	  #@arr = split /\./, $f;
  	 # print wf "$arr[0]\n";# sortedSites.oct
  	 
  	 # print "$f\n";
  	  #rewrite($f, $directory); 
  	  
  	  # ~/bwa/bwa index rewritefile/chr1_13678850_13688242.fa
  	  #@a =  split /\./, $f;
  	  #$no = $a[0];
  	  #$outdir = "rewritefile/";
  	  #$name1 = $outdir.$no.".allele.fa";
  	  #$name2 = $outdir.$no.".fa";

	  #print "~/bwa/bwa index $name2\n";
	  #print "~/bwa/bwa mem $name2 $name1 > samfiles/$no.sam\n";
	 # print wf "./dsk -file  ../../bio/HERVK_alleles/$no.hk.allele.fa -kmer-size 50 -abundance-min 0\n";
	 # print wf "./dsk2ascii -file $no.hk.allele.h5 -out ../../bio/fall2016/$no.txt\n";
	 
	 #totalfa($f, $directory);
	 #getlength($f, $directory); #rewritefile2
	 #print wf "$f,"; #kmerbyvirus
	# $str = concanate($f, $directory);#kmerbyvirus
	# print wf "$str";
	#generate($f, $directory, $ARGV[1]);  # $dir=kmerbyvirus0.0/, $ARGV[1]: kmerbyvirus0.0
	#print wf "perl labels.pl $ARGV[2]$f $directory$f \n";
	#print wf "$directory$f\t";
	
	#largeref($f, $directory, "contigref/"); #"rewritefile2/"
	#	if ($f =~ /hk.allele.fa$/) { #end with
	#		@arr =  split /\./, $f;
	#		$faname = "contiginput/".$arr[0].".fa";
	#		$outname = "contigsam/".$arr[0].".sam";
	#		print wf "../software/bwa-0.7.12/bwa mem $directory$f $faname > $outname\n"; #contigref
	#	}
		
	#	open(file, $directory.$f);
	#	@arr = split /\./, $f;
	#	$name = $arr[0];
	#	do{
	#		chomp($line);
	#		$line =~ s/\r|\n//g;
	#		if($line ne ''){
	#			if(substr($line, 0, 1) eq '>'){
	#				$str = ">".$name."@".substr($line,1);
	#				print wf "$str\n";
	#			}else{
	#				print wf "$line\n";
	#			}
	#		}	
	#	}while($line=<file>);
	#	close file;
	

	Tscript($f,$directory,"processT.$K.2017may/",wf);
	#Torder($f, $directory); # perl t.pl HERVK_alleles_may/ 
	}
}
close wf;


sub Tscript(){
	($file,$dir,$out,$wf) = @_;
	## Map to the references alleles of chr1_735:
	#bwa index chr1_73594980_73595948.hk.allele.fa
	#bwa mem -a chr1_73594980_73595948.hk.allele.fa chr1_73594980_73595948.fa | samtools view -Sbh > chr1_73594980_73595948.bam
	#samtools sort chr1_73594980_73595948.bam > chr1_73594980_73595948.sorted.bam
	#samtools index chr1_73594980_73595948.sorted.bam
	## group the k-mers that share the same mapping location on one of the alleles.
	#samtools view chr1_73594980_73595948.sorted.bam |\ perl -lane 'BEGIN {$"="\t"} $KMERS{"@F[2..3]"}=$KMERS{"@F[2..3]"}.";;;".$_; END { foreach $key (keys %KMERS) {$KMERS{$key}=~s/^;;;//; print "$KMERS{$key}"}}' > chr1_73594980_73595948.kmerge.nhsam
	## count of uniq k-mers:
	#cat chr1_73594980_73595948.kmerge.nhsam |\ perl -lane '@H=split/\;\;\;/; @S0=\"\"; @S1=split/\t/,$H[0]; @S2=split/\t/,$H[1]; push @S0,$S1[0]; push @S0,$S2[0]; @sort=sort{$a<=>$b} @S0; print \"$sort[0]\t$sort[1]\"' | sort -u | wc\n";
	
 
	@arr = split /\./, $file;
	$name = $arr[0];
	print "$name\n";  ##### add to Tscript.pbs.o*
	print $wf "~/bwa/bwa index $dir$file\n";
	print $wf "perl rewriteheader.pl finalunique$K\_may/$name.fa finalunique$K\_may/$name.short.fa\n";
	print $wf "~/bwa/bwa mem -a $dir$file finalunique$K\_may/$name.short.fa | ~/samtools/samtools view -Sbh > $out$name.bam\n";
	print $wf "~/samtools/samtools sort $out$name.bam > $out$name.sorted.bam\n";
	print $wf "~/samtools/samtools index $out$name.sorted.bam\n";
	print $wf "~/samtools/samtools view $out$name.sorted.bam | perl -lane'  \n";
	print $wf "BEGIN {\$\"=\"\\t\"} \n";
	print $wf "\$KMERS{\"\@F[2..3]\"}=\$KMERS{\"\@F[2..3]\"}\.\";;;\"\.\$_; \n";
	print $wf "END { \n";
	print $wf "foreach \$key (keys %KMERS) {\$KMERS{\$key}=~s/^;;;//; print \"\$KMERS{\$key}\"}} \n";
	print $wf "' > $out$name.kmerge.nhsam\n";
	
	print $wf "cat $out$name.kmerge.nhsam | perl -lane '\@H=split/\\;\\;\\;/; \n";
	print $wf "\@S0=\"\"; \n";
	print $wf "\@S1=split/\\t/,\$H[0]; \n";
	print $wf "\@S2=split/\\t/,\$H[1];  \n";
	print $wf "push \@S0,\$S1[0]; \n";
	print $wf "push \@S0,\$S2[0]; \n";
	print $wf "\@sort=sort{\$a<=>\$b} \@S0; \n";
	print $wf "print \"\$sort[0]\\t\$sort[1]\"' | sort -u | wc -l\n";
	
}

sub Torder(){
	($file,$dir) = @_;
	## Map to the references alleles of chr1_735:
	#bwa index chr1_73594980_73595948.hk.allele.fa
	#bwa mem -a chr1_73594980_73595948.hk.allele.fa chr1_73594980_73595948.fa | samtools view -Sbh > chr1_73594980_73595948.bam
	#samtools sort chr1_73594980_73595948.bam > chr1_73594980_73595948.sorted.bam
	#samtools index chr1_73594980_73595948.sorted.bam
	## group the k-mers that share the same mapping location on one of the alleles.
	#samtools view chr1_73594980_73595948.sorted.bam |\ perl -lane 'BEGIN {$"="\t"} $KMERS{"@F[2..3]"}=$KMERS{"@F[2..3]"}.";;;".$_; END { foreach $key (keys %KMERS) {$KMERS{$key}=~s/^;;;//; print "$KMERS{$key}"}}' > chr1_73594980_73595948.kmerge.nhsam
	## count of uniq k-mers:
	#cat chr1_73594980_73595948.kmerge.nhsam |\ perl -lane '@H=split/\;\;\;/; @S0=\"\"; @S1=split/\t/,$H[0]; @S2=split/\t/,$H[1]; push @S0,$S1[0]; push @S0,$S2[0]; @sort=sort{$a<=>$b} @S0; print \"$sort[0]\t$sort[1]\"' | sort -u | wc\n";
	
 
	@arr = split /\./, $file;
	$name = $arr[0];
	print "$name\n";  ##### add to Tscript.pbs.o*
}