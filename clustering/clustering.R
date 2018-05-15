#setwd("C:/Users/wul135/Downloads/DPGMM")#setwd("~/Desktop/coverage/DPGMM")
#setwd("~/Desktop/coverage/DPGMM")
rm(list = ls())
setwd("C:/Users/wul135-admin/Dropbox/paper/clustering_codes")
setwd("C:/Users/lwl11/Dropbox/paper/clustering_codes")
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
#site = 18 # 2 ### which site
#ratio <- read.table("matrix_Oct17/mat.1kg.50.oct17.dat")
ratio<-read.csv("../matrix/mat_1kg_nT.csv",header = TRUE, row.names = 1)#matrix_Oct17
coverage <- read.table("../matrix/coverage2565_1-28")
ratio2<-read.csv("../matrix/mat_nT_lgl_highcov.csv", header=TRUE, row.names=1)
DF2<-data.frame(ratio2[,1:89],coverage=ratio2[90])
site=38
names=colnames(ratio)[1:51]
names[site]
DF<-data.frame(ratio[1:51,1:89], coverage=ratio[90][1:51,1])#89

#################### 92:94 ####################
#male <- scan("male_no.dat", what="", sep="\n")[1:1244]
#ratio <- ratio[male, ]
#coverage <- coverage[male,]
#DF <- data.frame(ratio, coverage = coverage)
###
#ratio2<- read.table("matrix/mat.1kg_lgl.50.dat")
ratio_2 <- read.csv("matrix_Oct17/mat_nT_1kg_lgl.csv", header=TRUE, row.names = 1)
ratio2<-ratio_2[2536:2586,1:94]
cov2 <- read.table("matrix/coverage_1kg_lgl")
DF2<-data.frame(ratio2, coverage = cov2$V1[2536:2586])
df2 <- DF2[,c(site,95)]
df2[,2] <- log(df2[,2])  # log(coverage)
x2 = df2
X2 = scale(x2)
##
ratio3 <- read.table("matrix/mat.lgl.50.dat")
coverage3 <- read.table("matrix/coverage_LGL")
DF2<-data.frame(ratio3, coverage = coverage3$V1)
df2 <- DF2[,c(site,97)]
df2[,2] <- log(df2[,2])  # log(coverage)
x2 = df2
X2 = scale(x2)
#DF<-data.frame(ratio3, coverage = coverage3$V1)

########################################
DF <- data.frame(ratio[1:94], coverage = coverage$V1[1:2535])#94
n = nrow(DF)

p = 2 #final

names <- scan("../matrix/sortedSites.oct17", what="", sep="\n")
names[site]
#### get data matrix of size n x 2
for(site in 93:94){ 
  df <- DF[,c(site,95)]#97### replace with bio transfrom
  #df[,1]<-log(df[,1])
  df[,2] <- log(df[,2])  # log(coverage)
  x = df
  X = scale(x) ## standardization
  
  DF<-data.frame(ratio=mydata$chr1_155596457_155605636, coverage=mydata$coverage, populations=mydata$population)
  AFR=which(DF$populations=="AFR")
  EUR=which(DF$populations=="EUR")
  
  df<-DF[EUR,1:2]
  n=nrow(df)
  df[,2] <- log(df[,2])  # log(coverage)
  x = df
  X = scale(x) 
  #### Initialization ####
  lambda <- 2#2 ## equivalent to t in the paper  ##### lwl
  phi<- 5#5 #samller phi, more # clusters?
  ## prior for Sigma_j is IW(delta, Phi), delta = k+2 (p+2 here), Phi = kK
  delta <- p-1+3 ##                            ##### lwl
  #Phi <- diag(10,p)
  Phi <- diag(phi,p)  # diag(x, nrow, ncol) constructs a diagonal matrix.        ##### lwl
  m <- rep(0, p)     #replicates the values # m: p-vector prior mean
  J = 15L; # upper bound for the number of normal components    ##### lwl: alpha_EM
  e = 10; f = 1; # alpha ~ G(e,f)
  #riwish(delta, Phi): IW (k+2,kK): p is k,  phi is K.
  TT = 5000
  #################################
  ######Initialize parameters for MCMC
  alpha <- rep(0, TT); alpha[1] <- 20
  nu <- array(0, dim = c(J-1, TT))
  nu[,1] <- rbeta(J-1,1,alpha[1]) # V_j | alpha ~ Beta(1,alpha)
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
    Sigma[[1]][,,j] <- riwish(delta, Phi) #generates a random draw from the inverse Wishart distribution.
    mu[, j, 1] <- mvrnorm(1, m, lambda*Sigma[[1]][,,j]) # u_j | Sigma_j ~ N(m, t Sigma_j): t is lambda here
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
  unique(cluster)
  ##########################
  namesLGL <- scan("names_LGL", what="", sep="\n")
  m<-matrix(0,51,1)
  alpha2 = classprobs_c(W_final, M_final, Sigma_final, X2, tmp$C) 
  cluster2 <- apply(alpha2, 1, which.max)
  DFres2 <- data.frame(DF2[,c(site,95)], "Z" = cluster2)
  clusterplot2 <- ggplot(DFres2,aes_string(colnames(DFres2)[1], colnames(DFres2)[2])) + geom_point(aes(colour = Z), size = 1, alpha = 0.5) +
    #guides(colour=FALSE) + 
    scale_color_gradientn(colours = rev(brewer.pal(10, "Spectral"))) +
    theme_bw() +
    xlab(expression(n/T)) + ylab("coverage")+xlim(0,1.25)
  clusterplot2
  for(i in 1:81){
    clusterplot2 <- clusterplot2 + annotate("text", x=DFres2[i, 1], y=DFres2[i, 2], label=row.names(df2)[i],size=5)
  }
  ###### plot #####
  DFres <- data.frame(DF[,c(site,95)], "Z" = cluster)#97#96(.oct17)
  DFres <- data.frame(DF[AFR,1:2],"Z"=cluster)
  DFres <- data.frame(DF[EUR,1:2],"Z"=cluster)
  DFres <- data.frame(DF, "Z" = cluster)
  clusterplot <- ggplot(DFres,aes_string(colnames(DFres)[1], colnames(DFres)[2])) + geom_point(aes(colour = (Z)), size = 1, alpha = 0.5) +
    #guides(colour=FALSE) + 
    scale_color_gradientn(colours =  rev(brewer.pal(10, "Spectral"))) +
    theme_bw()+ theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
    xlab(expression(n/T)) + ylab("coverage")+
    #xlim(0,1.25)+ 
    labs(title=names[site])+theme(plot.title = element_text(hjust = 0.5))
  clusterplot
  
  clusterplot <- ggplot(DFres,aes_string(colnames(DFres)[1], colnames(DFres)[2])) + geom_point(aes(colour = (Z)), size = 1, alpha = 0.5) +
    #guides(colour=FALSE) + 
    #scale_color_gradientn(colours =  rev(brewer.pal(10, "Spectral"))) +
    scale_color_gradientn(colours = c("#5E4FA2" ,"#3288BD", "#66C2A5" ,"#ABDDA4", "#E6F598" ,"#FEE08B" ,"#FDAE61", "#F46D43" ,"#D53E4F", "#9E0142")) +
    
    theme_bw()+ theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
    xlab(expression(n/T)) + ylab("coverage")+
    #xlim(0,1.25)+ 
    labs(title="chr12_55727215_55728183 (K=50)")+theme(plot.title = element_text(hjust = 0.5))
  clusterplot
  # c("#5E4FA2" ,"#3288BD", "#66C2A5" ,"#ABDDA4", "#E6F598" ,"#FEE08B" ,"#FDAE61", "#F46D43" ,"#D53E4F", "#9E0142")) +
  
  
  #1,3,4,5
  patientindex <- scan("../matrix/28_patients.index.txt", what='', sep='\n') 
  
    
 #######################
  # malepatient <- intersect(patientindex,male) 
  for (i in 1:28) { #28: 11 male #97#96
    #clusterplot <- clusterplot + annotate("text", x=DF[strtoi(patientindex[i]), site], y=DF[strtoi(patientindex[i]), 95], label=as.character(i),size=5)
    #clusterplot <- clusterplot + annotate("text", x=DF[malepatient[i], site], y=DF[malepatient[i], 97], label=as.character(which(malepatient[i]==patientindex)),size=5)
    #print(cluster[strtoi(patientindex[i])])
    clusterplot <- clusterplot + annotate("text", x=DF$chr12_55727215_55728183[strtoi(patientindex[i])], y=DF$coverage[strtoi(patientindex[i])], label=as.character(i),size=4, col='black')
    clusterplot <- clusterplot + annotate("text", x=DF$chr12_55727215_55728183[2535+i], y=DF$coverage[2535+i], label=as.character(i),size=4, col='red')
    }
  clusterplot

  
  ggsave(paste(c('clusterplot50/', names[site],'_lambda=', lambda, '_phi=', phi, '.png'), collapse=""))
  save.image(file=paste(c('clustering50/', names[site],'_lambda=', lambda, '_phi=', phi, '.updated.RData'), collapse=""))
}


