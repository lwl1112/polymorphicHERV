##Gibbs sampling for Dirichlet Process Gaussian mixture model using stick-breaking representation
#########MCMC###########
Z <- array(0,dim=c(n,TT))
prob <- rep(0, J)
for(tt in 2:TT){
  ###update Z
#   for(i in 1:n){
#     for(j in 1:J){
#       if(p == 1){
#         prob[j] = log(pp[j,tt-1]) + dnorm(X[i,], mu[,j,tt-1], sqrt(Sigma[[tt-1]][,,j]), log = TRUE)
#       }else{
#         prob[j] = log(pp[j,tt-1]) + dmvnorm(X[i,], mu[,j,tt-1], Sigma[[tt-1]][,,j], log = TRUE)
#       }
#     }
#     mmax <- max(prob)
#     deno <- mmax + log(sum(exp(prob - mmax)))
#     Z[i,tt] <- sample(J, 1, replace = FALSE, prob = (exp(prob - deno)))
#   }

  if(p == 1){
    helpa <- log(pp[,tt-1])
    helpb <- mu[,,tt-1]
    helpc <- sqrt(as.vector(Sigma[[tt-1]]))
    Z[,tt] <- .loopexp_scalar(helpa, helpb, helpc, as.vector(X), J, n);
  }else{
    helpa <- log(pp[,tt-1])
    helpb <- mu[,,tt-1]
    helpc <- Sigma[[tt-1]]
    Z[,tt] <- .loopexp(helpa, helpb, helpc, X, J, n, p);
  }
  
  # Z[,tt] <- components
  ### update nu
  for(j in 1:(J-1)){
    aj <- sum(Z[,tt] == j)
    as <- sum(Z[,tt] >j)
    nu[j,tt] <- rbeta(1, aj + 1, alpha[tt-1] + as)
  }
  
  pp[1,tt] <- nu[1,tt]
  tmp <- 1-nu[1,tt]
  for(jj in 2:(J-1)){
    pp[jj,tt] = tmp * nu[jj,tt]
    tmp <- tmp * (1-nu[jj,tt])
  }
  pp[J,tt] <- tmp
  # pp[1:Jstar,tt] <- 1/Jstar
  ### update alpha
  alpha[tt] <- rgamma(1,J+e-1, rate = f- sum(log(1-nu[,tt]))) # alpha ~ G(e,f)
  
  ## update mu and Sigma
  Sigma[[tt]]<- array(0, dim=c(p,p,J))
  for(j in 1:J){
    aj = sum(Z[,tt]==j)
    if(aj == 0){
      mu[,j,tt] <-mvrnorm(1, m, lambda * Sigma[[tt-1]][,,j]) 
      Sigma[[tt]][,,j] <- riwish(delta + 1, Phi + (mu[,j,tt] - m)%*%t(mu[,j,tt] - m)/lambda)
    }else if(aj == 1){
      Cj <- lambda/(1+lambda*aj)
      mu_bar <- Cj*(m/lambda + (X[which(Z[,tt]==j),]))
      mu[,j,tt] <-mvrnorm(1, mu_bar, Cj * Sigma[[tt-1]][,,j]) 
      
      Phi_bar <- (mu[,j,tt] - m)%*%t(mu[,j,tt] - m)/lambda + 
        (X[which(Z[,tt] == j),] - mu[,j,tt])%*%t(X[which(Z[,tt] == j),] - mu[,j,tt])
      Sigma[[tt]][,,j] <- riwish(delta +aj + 1, Phi + Phi_bar)
      
    }else{
      Cj <- lambda/(1+lambda*aj)
      if(p == 1){
        mu_bar <- Cj*(m/lambda + sum(X[which(Z[,tt]==j),]))
      }else{
        mu_bar <- Cj*(m/lambda + colSums(X[which(Z[,tt]==j),]))
      }
      mu[,j,tt] <-mvrnorm(1, mu_bar, Cj * Sigma[[tt-1]][,,j]) 
      
      tmp <- as.matrix(X[which(Z[,tt] == j),] - mu[,j,tt],nrow = aj)
      tmpsum <- matrix(0, nrow = p, ncol = p)
      for(s  in 1:aj){
        tmpsum = tmpsum + tmp[s,]%*%t(tmp[s,])
      }
      Phi_bar <- (mu[,j,tt] - m)%*%t(mu[,j,tt] - m)/lambda + tmpsum
      Sigma[[tt]][,,j] <- riwish(delta +aj + 1, Phi + Phi_bar)
    }
  }
#   mu[,1:Jstar,tt] <- mus
#   #Sigma[[tt]]<- array(1, dim=c(p,p,J))
#   Sigma[[tt]] <- array(0, dim=c(p,p,J))
#   for(j in 1:J){
#     Sigma[[tt]][,,j] = diag(p)
#   }
  if (tt %% 1000 == 0 ){
    cat("tt = ", tt, "\n")
  }
}