modesearchmerge <- function(m, pm, imodes,W_final,tol) {
  # this function needs the output of function modesearch, which is [m,pm,imodes]
  # and tol is the tolerance used for modesearch() function
  # output
  # C is the row vector indicating with cluster a componennt belongs to.
  if (length(which(imodes==1))<length(imodes)){
    cat("Converge to non-modes, Be careful.")
  }
  k=length(pm)
  C=rep(0, k)
  
  for(i in 1:k){
    if(C[i] == 0){
      distance <- pm-pm[i]
      index <- (abs(distance)<=2*tol)
      C[index] <- max(C)+1
      pm[index] <- mean(pm[index])
      m[1,index] <- mean(m[1,index])
      #m(2,index)=mean(m(2,index));
    }
  }
  n_cluster <- length(unique(C))
  w <- rep(0, n_cluster)
  for(i in 1:n_cluster){
    w[i]=sum(W_final[which(C==i)])
  }
  return (list("m" = m,"pm" = pm,"C" = C,"w" = w))
}
 




