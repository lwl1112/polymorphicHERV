modesearch <- function(p, W_final, M_final, Sigma_final, nk, tol) {
#  modes of k comp normal mixture 
#  nk is number of random starting points drawn from mixture
#  tol is toleranece on log pdf scale for ending mode search, e.g. <=.01
#  example call:
#     [mm,pm] = modesearch(p,J,pi,mu,Sigma,1000,0.0001);
#
  k <- length(W_final)
  w <- rep(0, k)#matrix(0, nrow = k, ncol = k)
  z <- rep(0, p)
  Z <- matrix(0, nrow = p, ncol = p)
  Om <- Sigma_final
  a <- M_final
  m <- NULL
  pm <- NULL
  
  for(j in 1:k){
    Om[,,j] <- solve(Sigma_final[,,j])
    a[,j] <- Om[,,j]%*%M_final[,j]
  }

  # start at randomly sampled points ... and centroids ...
  allx = t(cbind(M_final, mvnormixrnd(W_final,M_final,Sigma_final,nk)$y))
  nk <- nk + k
  #allx = t(M_final) 
  #nk <- k
  
  allpx=mvnormixpdf(allx,W_final,M_final,Sigma_final);
  
  for (js in 1:nk){
    x=allx[js,]; px=allpx[js]; 
    # take at most 20 steps from each draw 
    h=0; etol=exp(tol); eps=1+etol; 
    while (h<=30&&eps>etol){
    #while (eps>etol){
      y=z; Y=Z;
      for(j in 1:k){
        if(p == 1){
          w[j] = W_final[j]*dnorm(x,M_final[,j],Sigma_final[,,j])
        }else{
          w[j] = W_final[j]*dmvnorm(x,M_final[,j],Sigma_final[,,j])
        }
        
        Y <- Y + w[j]*Om[,,j]
        y <- y + w[j]*a[,j]
      }
      y <- solve(Y, y)
      py <- mvnormixpdf(t(as.vector(y)),W_final,M_final,Sigma_final)
      eps <- solve(py,px)
      x <- y
      px <-py
      h=h+1 
    }
    m=cbind(m, x)
    pm=c(pm, px)
  }
  #[u,i]=unique(round(100*log(pm/max(pm))));
  # check that we've found modes not antimodes or shoulders .... 
  im=length(pm)
  Ip=diag(p)
  imodes=NULL
  for ( i in 1:im){
    G <- Z
    for (j in 1:k){
      eij = m[,i] - M_final[,j]
      if(p==1){
        G = G + W_final[j]*dnorm(eij,z,Sigma_final[,,j])*
          Om[,,j]%*%(Ip-eij%*%t(eij)%*%Om[,,j])
      }else{
        G = G + W_final[j]*dmvnorm(eij,z,Sigma_final[,,j])*
          Om[,,j]%*%(Ip-eij%*%t(eij)%*%Om[,,j])
      }
    }
    if(det(G) > 0) {
      imodes <- c(imodes, 1)
    }else{
      imodes <- c(imodes, 0)
    }
  }
  return (list("m" = m,"pm" = pm, "imodes" = imodes))

}
  
  