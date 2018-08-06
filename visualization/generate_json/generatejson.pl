open(file, @ARGV[0]); # chr positions visualization/position.dat # ordered ##polypos.dat #poly
open(file1, @ARGV[1]); # visualization/mat01.dat 20%:0, 80%:1  91*2535 #polymat.dat: #poly * #individuals
open(file2, @ARGV[2]); # 1000/population 
#open(file3, ">$ARGV[3]"); # population.json 
open(file3, ">$ARGV[3]"); # matrix.json #polymat.json   # remove last ,
 
#%h=();
#print file3 "{\n";
#$i=0;
#do{
#	chomp($line);
#	$line =~ s/\r|\n//g;
#	if($line ne ''){
#		@arr = split /\s+/, $line;
#	 	if($i<2534){
#	 		print file3 "\"$arr[0]\": \"$arr[1]\",\n";
#	 	}else{
#	 		print file3 "\"$arr[0]\": \"$arr[1]\"\n";
#	 	}
#	 	$h{$arr[1]}++;
#	 	$i++;
#	}
#}while($line=<file2>);
#close file2;
#print file3 "}\n";
#close file3;
#for $k(sort keys %h){
#	print "$k\n";
#}

$c=0;
@individual=();
do{
	chomp($line);
	$line =~ s/\r|\n//g;
	if($line ne ''){
		@arr = split /\s+/, $line;
		$individual[$c++]=$arr[0];
	}
}while($line=<file2>);
close file2;

print file3 "{\n";
$c=0;
do{
	chomp($line);
	chomp($line1);
	$line =~ s/\r|\n//g;
	$line1 =~ s/\r|\n//g;
	if($line ne '' && $line1 ne ''){
		print "$line\n";
	 	 print file3 "\"$line\":[\n";
	 	 @arr = split /\s+/, $line1;
	 	 $len = @arr;
	 	 for($i=0; $i<$len; $i++){
	 	 	 print file3 "{\"id\":\"$individual[$i]\",\n";
	 	 	# print file3 "{\"pop\":$individual[$i]\",\n";
	 	 	 print file3 "\"count\": $arr[$i]\n\}";
	 	 	if($i!=$len-1){
	 	 		print file3 ",";
	 	 	}
	 	 	print file3 "\n";
	 	 	 
	 	 }
	 	 
	 	 if($c<90){
	 	 	 print file3 "],\n";
	 	 }else{
	 	 	  print file3 "]\n";
	 	 }
	 	 $c++;
	}
}while($line=<file> and $line1=<file1>);
close file;
close file1;
print file3 "}\n";
close file3;

 
# 1000/population
#[
#	
#	"chrX:.-.":{  #chr postions: chr1~chrY (by order)		
#		"HGXXXX": count, # matrix
#		"NAXXXX": count  # hash
#	},
#	"":{
#	}
#       
#]
#"HGXXXX":{
#		#	"count":X,   # mat01[i,j] // per line
#		#},
#			"population":"X" # 1000/population # hash #redundant info!


#ACB
#ASW
#BEB
#CDX
#CEU
#CHB
#CHS
#CLM
#ESN
#FIN
#GBR
#GIH
#GWD
#IBS
#ITU
#JPT
#KHV
#LWK
#MSL
#MXL
#PEL
#PJL
#PUR
#STU
#TSI
#YRI

# json
# {} //object
# [] //array

# reorder matrix
# 0/1
#for  i in range(0,88):
#	mat01[i,:][np.where(sortedmat[i,:]>=-np.sort(-sortedmat[i,:])[2535*0.8])]=1
#	mat01[i,:][np.where(sortedmat[i,:]<-np.sort(-sortedmat[i,:])[2535*0.8])]=0
#male=np.loadtxt('E:/bioResearch/data/march/male.dat',dtype='int')
#sortedmat[88,:][list(set(all)-set(male))] #female
#for  i in range(88,91):
#	mat01[i,:][np.where(sortedmat[i,:][male]>=-np.sort(-sortedmat[i,:][male])[995])]=1 #1244*0.8
#check
#for  i in range(88,91):
#	print(np.where(mat01[i,:]==1)[0].shape + np.where(mat01[i,:]==0)[0].shape)