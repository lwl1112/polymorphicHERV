
<!--
```diff
+ green: input file/directory; 
- red: output file/directory.
```
-->
## Visualization tool 

Visualize distribution of HERV-K repeats in the 1000 genomes dataset at
http://personal.psu.edu/~wul135/visualization/

codes can be downloaded from ```visualization/``` folder.


## **K-mer base approach to mine patterns and leverage the repetitive nature of sequencing data**

Note: [i]: input; [o]: output. Remove "[i]", "[o]" when running scripts.

### -- generate n/T matrix --

### Step 1: Generate reference k-mers
(The final output file [unique.withrc.50.fa] can also be downloaded from https://www.dropbox.com/s/y991vnaja8s9x66/unique.withrc.50.fa?dl=0)

```
$ perl generate.pl [i]HERVK_alleles/  [o]kmer50pervirus/ 50  
$ perl labels.pl [o]total_withlabel_50.fa [i]kmer50pervirus/ 
$ perl unique.pl [i]total_withlabel_50.fa [o]unique.50.fa 
$ perl uniquewithrc.pl [i]unique.50.fa [o]unique.withrc.50.fa 
```
where kmer50pervirus/ is a temporary directory.

### Step 2: Calculate T
(The final output [T.50] is in the Github.)
``` 
$ perl t.pl HERVK_alleles/ [o]tscript.may.pbs 50 
```
where ```tscript.may.pbs``` is a pbs script can be run in a server.


### Step 3: Experiments: mapping to the k-mer references
3.1 download bam files from 1000 Genomes Project.

3.2 using the bed file to extract mapped reads based on the corresponding coordinates. 

   samtools view -b -L  *.bed  completed.bam > extracted.bam
   
the bed file can be downloaded in 'bed files/':

  HERVK_int.all.25oct2016.hg19.bed  (hg19 build)
  
  HERVK_hg38_sort_01apr2018.bed     (hg38 build)

3.3 convert bam files to fasta files, then kmerize to *.50.fa with k=50.

Example files [dataset_samples/] can be downloaded as follows:

https://www.dropbox.com/sh/z1uhuavavywjpz3/AADgbiJyN2zeBYOq1wlR2Tsoa?dl=0
```
$ perl findmatch.pl [i]unique.withrc.50.fa [i]dataset_samples/ [o]hashlabels_1000g_50/ 50 HG00096 HG00097 HG00099 HG00100  
$ perl labelcount.pl [i]hashlabels_1000g_50/HG00096.dat [i]sortedSites [o]hashlabels_1000g_50/HG00096.label
$ perl concate_tomatrix.pl [i]T.50 [i]peopleIDs_sample [i]hashlabels_1000g_50/ [o]mat.1kg.50.dat  
// peopleIDs is the full list for KGP dataset
```
where hashlabels_1000g_50/ is a temporary directory, and 
HG00096 HG00097 HG00099 HG00100 are sample names.

<!-- generate k-mer references --

1. perl generate.pl HERVK_alleles/ kmer50pervirus/ 50  (generate 50-mers per virus; input: kmer50pervirus/, k=50; output: kmer50pervirus/)
2. perl labels.pl total_withlabel_50.fa kmer50pervirus/ (labeling each k-mer. output: total_withlabel.fa)
3. perl unique.pl total_withlabel_50.fa unique.50.fa  (generate unique k-mers: unique.50.fa)
4. perl uniquewithrc.pl unique.50.fa unique.withrc.50.fa (generate references: unqiue k-mers with reverse complement. output: unique.withrc.50.fa)

k-mer references can be downloaded:
https://www.dropbox.com/s/y991vnaja8s9x66/unique.withrc.50.fa?dl=0

-- calculate T -- 

5. perl t.pl HERVK_alleles_may/ tscript.may.pbs 50 (Tscript())

// bwa: query name too long: rewrite header

// follow sortedSites order :  t.pl(Torder()) 

T.50 is the # of unique k-mers in each virus

-- calculate n : mapping dataset to the references -- 

// downloading bam files according to the coordinates, then converting into fasta files (with 50-mers: e.g, dsk is used)

6. perl findmatch.pl unique.withrc.50.fa dataset_samples/ hashlabels_1000g_50/ 50 HG00096 HG00097 HG00099 HG00100  (output: hashlabels_1000g_50/)
7. perl labelcount.pl hashlabels_1000g_50/HG00096.dat sortedSites hashlabels_1000g_50/HG00096.label
8. perl concate_tomatrix.pl T.50 peopleIDs hashlabels_1000g_50/ mat.1kg.50.dat (generate matrix of n/T ratio: mat.1kg.50.dat)

dataset_samples can be downloaded as follows:

https://www.dropbox.com/sh/z1uhuavavywjpz3/AADgbiJyN2zeBYOq1wlR2Tsoa?dl=0

peopleIDs_sample:

HG00096

HG00097

HG00099

HG00100
-->

###  -- mixture model for low coverage (depth) data --

clustering/analysis.R (credits to Dr. Lin Lin llin@psu.edu)

Note: only need to implement this step when the coverage (depth) of input sequence data is low. (i.e, <20).

R code examples for implementing a conversion of the n/T matrix to the 0,1,2 matrix after the biologists anaylzed the clustering diagrams.

```
unique(cluster) # list all cluster numbers
mat012= matrix(0,2535,1) # define and initialize a new matrix to store 0,1,2 values
mat012[which(cluster==clusterno)]= 1 # set the value for points in the cluster (ie., clusterno) to 1 when the virus is presence; 
#or 2 when solo-LTR exists.

```



<!-----------------------------------------------------------------------
Demo
1. raw data: short read DNA sequencing (100bps)

2. k-mer counting method

<img src="figures/outline.png" />

3. difficulties

<img src="figures/k=70_2.png" />

4. clustering results (from mixture models)
<img src="figures/chr12_557_k50.png" />

5. (Truncated) Dirichlet process Gaussian mixture model

(1) density function for GMM

<img src="figures/density_func.PNG" />

(2) model estimation: a latent indicator Z: P(Z=j) = \pi_j

(3) classic way to select the number of components: eg, BIC criterion

(4) dirichlet process prior for \theta [reference]: to represent the infinite mixure

Truncated Dirichlet process Gaussian mixture model: hyperparameters (M, e, f, m, t, d, S).

<img src="figures/Dirichlet Process.PNG" />

6. visualization of prevalence: D3.js map

http://personal.psu.edu/~wul135/visualization/

<img src="figures/map.png" />

---!>
