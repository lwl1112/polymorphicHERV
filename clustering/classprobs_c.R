classprobs_c <- function(pi, mu, Sigma, x, comp) {
  # Compute posterior classification probabilities
  n = nrow(x)
  C = length(unique(comp)) 
  prob = array(0, dim=c(n, C))
  for(j in 1:C){
    compj = which(comp == j)
    a = 0
    for(ss in 1:length(compj))
    {
      a = a + 
        pi[compj[ss]]*dmvnorm(x, mu[,compj[ss]], Sigma[,,compj[ss]])
    }
    prob[,j] = (a)
  }
  alpha=apply(prob,1, function (x) {x/sum(x)})
              
  return (t(alpha))
}

