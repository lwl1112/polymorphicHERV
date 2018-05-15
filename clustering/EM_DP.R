ltol <- 0.001
maxiter <- 10000

###Initialize W, M, V,L from Gibbs
W <- W_Gibbs
M <- M_Gibbs
Sig <- Sig_Gibbs
alpha_EM = alpha_Gibbs
Lp = -6.1110e+005;
Lpo = 2*Lp;

mvnormixpdf <- function(X,w,mu,Sigma){
  # x  = n.p array of n values of p-dim MV normal mixture 
  # w = column k vector probs
  # mu = p.k matrix of component means 
  # Sigma = p.p.k array of variance matrice 
  # pdf = n vector of pdf values
  #
  n <- nrow(X); J <- length(w) 
  pdf <- rep(0,n)
  for(j in 1:J){
    if(p==1){
      pdf <- pdf + w[j]*dnorm(X, mu[,j], sqrt(Sigma[,,j]))
    }else{
      pdf <- pdf + w[j]*dmvnorm(X, mu[,j], Sigma[,,j])
    }
  }
  return(pdf)
}

##### EM algorithm #####
niter = 0;
V = rep(0,J);
pi_t = array(0, dim = c(n,J)); 
veps = 1e-9;
partialsum = rep(0, J);
while ((Lp-Lpo)>log(1+ltol) & (niter<=maxiter)){
  mixpdf = mvnormixpdf(X,W,M,Sig)
  for(j in 1:J){
    if(p == 1){
      pdf_j <- W[j]*dnorm(X, M[,j], sqrt(Sig[,,j]))
    }else{
      pdf_j <- W[j]*dmvnorm(X, M[,j], Sig[,,j])
    }
    pi_t[,j] <- pdf_j/mixpdf
  }
  # for (i in 1:n){
  #   for(j in 1:J){
  #     if(p == 1){
  #       pdf_ij <- dnorm(X[i,], M[,j], sqrt(Sig[,,j]))
  #     }else{
  #       pdf_ij <- dmvnorm(X[i,],M[,j],Sig[,,j])
  #     }
  #     pi_t[i,j] <- W[j]*pdf_ij/mixpdf[i]
  #   }
  # }
  totalsum <- sum(sum(pi_t))
  ww <- 1
  sumlog <- 0
  
  partialsum[1] <- totalsum
  for (j in 2:J){
    partialsum[j] <- partialsum[j-1]-sum(pi_t[,(j-1)])
  }
  
  for(r in 1:10){  # find alpha and V
    for(j in 1:(J-1)){
      sumi_pi_ij <- sum(pi_t[,j])
      V[j] <- sumi_pi_ij/(partialsum[j]+alpha_EM-1) #update V_j    
      V[j]= max(veps,min(1-veps, V[j]));
    }
    V[J] <- 1
    VV <- V[1:(J-1)]
    alpha_EM <- (J+e-2)/ (f-sum(log(1-VV))) #undate alpha
  }  
  for(j in 1:(J-1)){
    W[j] <- ww*V[j]
    ww <- ww*(1-V[j])
    xbar_j <- (t(pi_t[,j])%*%X)/sum(pi_t[,j]) # xbar_j (1,d)
    M[,j] = (m/lambda + t(xbar_j)%*%sum(pi_t[,j]))/(1/lambda + sum(pi_t[,j]));   #updata mu_j
    tmpp <- X - matrix(rep(xbar_j,n),n,p, byrow = T)
    pptm <- apply(tmpp,2, function(x) x*sqrt(pi_t[,j]))
    mat <- t(pptm)%*%pptm
    #mat <- matrix(0, nrow =p, ncol = p)
    #for(k in 1:n){
    #  mat= mat + pi_t[k,j]*t(X[k,]-xbar_j)%*%(X[k,]-xbar_j)
    #}
    Sig[,,j] = (Phi + mat + (sum(pi_t[,j])/(1+lambda*sum(pi_t[,j])))*t(xbar_j-m)%*%
                    (xbar_j-m))/(sum(pi_t[,j])+delta+p+2) #updata Sigma_j
  }
  
  # for J
  W[J] = ww  #set V[J] = 1
  xbar_j = (t(pi_t[,J])%*%X)/sum(pi_t[,J])  # xbar_j (1,d)
  M[,J] = (m/lambda + t(xbar_j)%*%sum(pi_t[,J]))/(1/lambda + sum(pi_t[,J]))   #updata mu_j
  tmpp <- X - matrix(rep(xbar_j,n),n,p, byrow = T)
  pptm <- apply(tmpp,2, function(x) x*sqrt(pi_t[,J]))
  mat <- t(pptm)%*%pptm
  #mat <- matrix(0, nrow =p, ncol = p)
  #for(k in 1:n){
  #  mat = mat+pi_t[k,J]*t(X[k,]-xbar_j)%*%(X[k,]-xbar_j)
  #}
  Sig[,,J] = (Phi + mat + (sum(pi_t[,J])/(1+lambda*sum(pi_t[,J])))*t(xbar_j-m)%*%(xbar_j-m))/
    (sum(pi_t[,J])+delta+p+2); #updata Sigma_j
  Lpo = Lp;
  Ln = sum(log((mvnormixpdf(X,W,M,Sig)))); 
  if(p == 1){
    Lmu <- sum((dnorm(M,m,sqrt(lambda*Sig), log = TRUE)))
  }else{
    Lmu <- 0
    for(k in 1:J){
      Lmu <- Lmu + dmvnorm(M[,k],m,lambda*Sig[,,k], log = TRUE)
    }
  }
  LIW <- sum(apply(Sig,3, function(x) log(diwish(x, delta,Phi))))
  LBeta = sum((dbeta(V[1:J-1],1,alpha_EM, log = TRUE)))
  LGamma = dgamma(alpha_EM,e, rate = f, log = TRUE)
  Lp = Lmu+LIW+LBeta+LGamma+Ln
  niter = niter + 1;
  cat("alpha_EM = ", alpha_EM ,"\n")
}

Ln = sum(log((mvnormixpdf(X,W,M,Sig)))); 
if(p == 1){
  Lmu <- sum((dnorm(M,m,sqrt(lambda*Sig), log = TRUE)))
}else{
  Lmu <- 0
  for(k in 1:J){
    Lmu <- Lmu + dmvnorm(M[,k],m,lambda*Sig[,,k], log = TRUE)
  }
}
LIW <- sum(apply(Sig,3, function(x) log(diwish(x, delta,Phi))))
LBeta = sum((dbeta(V[1:J-1],1,alpha_EM, log = TRUE)))
LGamma = dgamma(alpha_EM,e, rate = f, log = TRUE)
Lp = Lmu+LIW+LBeta+LGamma+Ln
