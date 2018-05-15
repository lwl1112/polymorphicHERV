mvnormixrnd <- function(pi,mu,Sigma,n){
  # simulate a sample of size n from a p-dim normal mxiture
  # pi = column k vector probs
  # mu = p.k matrix of component means 
  # Sigma = p.p.k array of variance matrice 
  # n = sample size
  #
  p <- nrow(mu); k <- ncol(mu);
  y <- NULL
  z <- 1+colSums(outer(cumsum(pi),runif(n),'<=')) # sample n Mn draws 
  for(j in 1:k){
    zj <- which(z==j)
    nj <- length(zj)
    if(nj > 0){
      repmu <- matrix(rep(mu[,j],each=nj),nrow=nj)
      y <- cbind(y, t(repmu) + t(chol(Sigma[,,j]))%*%matrix(rnorm(p*nj), nrow = p))
    }
  }
  return (list("y" = y,"z" = z))
}

