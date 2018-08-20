# credit to Dr. Lin Lin (llin@psu.edu)
# Dirchlet Process Gaussian Mixture Model
# input: matrix of n/T ratio, depth
# parameters tuning


#setwd("~/DPGMM")
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
matrix <- read.csv("mat.csv",header=TRUE, row.names = 1)
ratio <- matrix[,1:94]
depth <- matrix$depth
sitenames <- colnames(matrix)[1:94]
DF <- data.frame(ratio, depth)
n = nrow(DF)
p = 2   ## equivalent to d in the paper 

#### get data matrix of size n x 2 : ratio & depth
site = 55 ### which site #sitenames[site]
df <- DF[,c(site,95)]
df[,2] <- log(df[,2]) 
x = df
X = scale(x) ## standardization

#### Initialization ####
lambda <- 2 ## equivalent to t in the paper  
phi<-5 # equivalent to S in the paper # parameter tuning
## prior for Sigma_j is IW(delta, Phi)
delta <- p-1+3 ##                             
Phi <- diag(phi,p)  # diag(x, nrow, ncol) constructs a diagonal matrix.         
m <- rep(0, p)     #replicates the values
J = 15L; # upper bound for the number of normal components    
e = 20; f = 1; #alpha
  
TT = 10000 #5000
set.seed(123)##
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
for(rr in 1:10){ # Number of EM algorithms                    
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
DFres <- data.frame(DF[,c(site,95)], "Z" = cluster)
ggplot(DFres,aes_string(colnames(DFres)[1], colnames(DFres)[2])) + geom_point(aes(colour = (Z)), size = 0.5, alpha = 0.5) +
  #guides(colour=FALSE) + 
  scale_color_gradientn(colours = rev(brewer.pal(11, "Spectral"))) +
  theme_bw() +
  xlab(expression(n/T)) + ylab("depth")+ggtitle(sitenames[site])



