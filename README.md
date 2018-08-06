<bold> K-mer base approach to mine patterns and leverage the repetitive nature of sequencing data </bold>

Instructions:

-- generate k-mer references --

1. perl generate.pl HERVK_alleles/ kmer50pervirus/ 50  (generate 50-mers per virus; input: kmer50pervirus/, k=50; output: kmer50pervirus/)
2. perl labels.pl total_withlabel_50.fa kmer50pervirus/ (labeling each k-mer. output: total_withlabel.fa)
3. perl unique.pl total_withlabel_50.fa unique.50.fa  (generate unique k-mers: unique.50.fa)
4. perl uniquewithrc.pl unique.50.fa unique.withrc.50.fa (generate references: unqiue k-mers with reverse complement. output: unique.withrc.50.fa)

-- calculate T -- 

5. perl t.pl HERVK_alleles_may/ tscript.may.pbs 50 (Tscript())

// bwa: query name too long: rewrite header

// follow sortedSites order :  t.pl(Torder()) 

-- calculate n : mapping dataset to the references -- 

// downloading bam files according to the coordinates, then converting into fasta files (with 50-mers: e.g, dsk is used)

6. perl findmatch.pl unique.withrc.50.fa dataset_samples/ hashlabels_1000g_50/ 50 HG00096 HG00097 HG00099 HG00100  (output: hashlabels_1000g_50/)
7. perl labelcount.pl hashlabels_1000g_50/HG00096.dat sortedSites hashlabels_1000g_50/HG00096.label
8. perl concate_tomatrix.pl T.50 peopleIDs hashlabels_1000g_50/ mat.1kg.50.dat (generate matrix of n/T ratio: mat.1kg.50.dat)



===================================================================

-- mixture model for low coverage data --

clustering/analysis.R

====================================================================

-- Visualization tool --

visualization/index.html

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
