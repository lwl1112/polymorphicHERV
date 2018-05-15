#setwd("C:/Users/wul135/Downloads/DPGMM")#setwd("~/Desktop/coverage/DPGMM")
#setwd("~/Desktop/coverage/DPGMM")
library(ggplot2)
library(cowplot)
library(RColorBrewer)
library(MASS)
library(MCMCpack)
library(mvtnorm)
library(Rcpp)
library(RcppArmadillo)
sourceCpp("express.cc", rebuild = TRUE, verbose = FALSE)
source("modesearch.R")
source("mvnormixrnd.R")
source("modesearchmerge.R")
source("classprobs_c.R")

## Get data
ratio <- read.table("matrix/mat.1kg.70.dat")
coverage <- read.table("matrix/coverage2565")
DF <- data.frame(ratio, coverage = coverage$V1[1:2535])
n = nrow(DF)
p = 2
names <- scan("sortedSites.2017", what="", sep="\n")

#### get data matrix of size n x 2
#site = 1# 2 ### which site
for (site in 1:1) #9#87
{
df <- DF[,c(site,97)]
#df[,1]<-log(df[,1])
df[,2] <- log(df[,2])  # log(coverage)
x = df
X = scale(x) ## standardization

#### Initialization ####
lambda <- 2 ## equivalent to t in the paper  ##### lwl
phi<-5#3
## prior for Sigma_j is IW(delta, Phi)
delta <- p-1+3 ##                            ##### lwl
#Phi <- diag(10,p)
Phi <- diag(phi,p)  # diag(x, nrow, ncol) constructs a diagonal matrix.        ##### lwl
m <- rep(0, p)     #replicates the values
J = 15L; # upper bound for the number of normal components    ##### lwl: alpha_EM
e = 20; f = 1; #alpha

TT = 5000
#################################
######Initialize parameters for MCMC
alpha <- rep(0, TT); alpha[1] <- 20
nu <- array(0, dim = c(J-1, TT))
nu[,1] <- rbeta(J-1,1,alpha[1])
pp <- array(0, dim = c(J, TT))
pp[1,1] <- nu[1,1]
tmp <- 1-nu[1,1]
for(jj in 2:(J-1)){
  pp[jj,1] = tmp * nu[jj,1]
  tmp <- tmp * (1-nu[jj,1])
}
pp[J,1] <- tmp
mu <- array(0, dim = c(p,J,TT))
Sigma <- vector("list", TT) 
Sigma[[1]]<- array(0, dim=c(p,p,J))
for(j in 1:J){
  Sigma[[1]][,,j] <- riwish(delta, Phi)
  mu[, j, 1] <- mvrnorm(1, m, lambda*Sigma[[1]][,,j])
}
source("Gibbs_DP.R")

LpEM = -6.1110e+005; 
for(rr in 1:10){ # Number of EM algorithms                    ##### lwl
  inter <- TT-(rr-1)*100 # Change the starting point for EM algorithms by using different MCMC samples. Make sure inter > 0.
  W_Gibbs <- pp[,inter]
  M_Gibbs <- array(unlist(mu[,,inter]),dim = c(p,J))
  Sig_Gibbs <- array(unlist(Sigma[[inter]]), dim = c(p, p, J))
  alpha_Gibbs <- alpha[inter]
  source("EM_DP.R")
  if(Lp > LpEM){
    W_final <- W # proportion
    M_final <- M # mean
    V_final <-V
    VV_final <- VV
    Sigma_final <- Sig # Covariance matrix
    alpha_final <- alpha_EM
    LpEM <- Lp
  }
}

## Mode search 
tol <- 0.0001
modes <- modesearch(p, W_final, M_final, Sigma_final,0,tol)
m <- modes$m
pm <- modes$pm
imodes <- modes$imodes

tmp <- modesearchmerge(m, pm, imodes,W_final,tol)

alpha = classprobs_c(W_final, M_final, Sigma_final, X, tmp$C)  # posterior probabilities for each patient to each cluster.
cluster <- apply(alpha, 1, which.max)

###### plot #####
patientindex <- read.table("28_28_patients.index.txt")#scan("28_28_patients.index.txt", what='', sep='\n') # start from 0
DFres <- data.frame(DF[,c(site,97)], "Z" = cluster)
clusterplot <- ggplot(DFres,aes_string(colnames(DFres)[1], colnames(DFres)[2])) + geom_point(aes(colour = (Z)), size = 1, alpha = 0.5) +
  #guides(colour=FALSE) + 
  scale_color_gradientn(colours = rev(brewer.pal(11, "Spectral"))) +
  theme_bw() +
  xlab(expression(n/T)) + ylab("coverage")+xlim(0,1.25)

for (i in 1:nrow(patientindex)) {
  if(i<=28){
    clusterplot <- clusterplot + annotate("text", x=DF[patientindex$V1[i]+1, site], y=DF[patientindex$V1[i]+1, 97], label=as.character(i) )
  }else{
    clusterplot <- clusterplot + annotate("text", x=DF[patientindex$V1[i]+1, site], y=DF[patientindex$V1[i]+1, 97], label=as.character(i-28), colour='red' )
  }
}
  
#plot(DFres[,1], DFres[,2], col=ifelse(DFres$Z==9, "red", "black"))
min(cluster)
max(cluster)
write(cluster, file=paste(c('clusters/', names[site]), collapse=""), sep='\n')
clusterplot
ggsave(paste(c('plots/', names[site], '.png'), collapse=""))
}
