#include <RcppArmadilloExtensions/sample.h>
#include <iostream>

using namespace Rcpp ;

// [[Rcpp::depends(RcppArmadillo)]]

double find_max(Rcpp::NumericVector& z, int J){
  double t = z[0];
  int i;
  for (i = 1; i < J; i++)
  {
    if (z[i] > t)
      t = z[i];
  }
  return t;
}

double find_max_arma(arma::rowvec& z, int J){
  double t = z[0];
  int i;
  for (i = 1; i < J; i++)
  {
    if (z[i] > t)
      t = z[i];
  }
  return t;
}


const double log2pi = std::log(2.0 * M_PI);

// [[Rcpp::depends("RcppArmadillo")]]
// [[Rcpp::export]]
arma::vec Mahalanobis(arma::mat x, arma::rowvec center, arma::mat cov) {
  
  int n = x.n_rows;
  arma::mat x_cen;
  x_cen.copy_size(x);
  for (int i=0; i < n; i++) {
    x_cen.row(i) = x.row(i) - center;
  }
  return sum((x_cen * cov.i()) % x_cen, 1);    
}

// [[Rcpp::export]]
arma::vec dmvnorm_arma(arma::mat& x, arma::rowvec mean, arma::mat& sigma, bool log = false) { 
  
  arma::vec distval = Mahalanobis(x,  mean, sigma);
  
  double logdet = sum(arma::log(arma::eig_sym(sigma)));
  arma::vec logretval = -( (x.n_cols * log2pi + logdet + distval)/2  ) ;
  
  
  
  if (log) { 
    return(logretval);
  } else { 
    return(exp(logretval));
  }
}


// [[Rcpp::export(".loopexp")]]
Rcpp::NumericVector loopexp_out(const Rcpp::NumericVector& helpa, const arma::mat& helpb, 
                                NumericVector helpc, const arma::mat& X, 
                                int J, int n, int p)
{
  int i, j;
  RNGScope scope;
  arma::cube Sigma(helpc.begin(), p, p, J, false);   
  Rcpp::NumericVector Z(n);
  for (i = 1; i <= n; i++)
  {
    Rcpp::NumericVector prob(J);
    arma::rowvec x = X.row(i-1);
    for (j = 1; j <= J; j++)
    {
      arma::colvec mu = helpb.col(j-1);
      arma::mat Sig =Sigma.slice(j-1); 
      arma::vec result_t = dmvnorm_arma(x, mu.t(), Sig, 1); 
      Rcpp::NumericVector result(result_t.begin(), result_t.end());
      prob[j-1] = helpa[j-1] + result[0];
    }
    
    
    double mmax = find_max(prob, J);
    double deno = mmax + log(sum(exp(prob - mmax)));
    Rcpp::IntegerVector JJ = seq_len(J) ; // creates 1:15 vector
    
    Z[i-1] = RcppArmadillo::sample(JJ, 1, false, (exp(prob - deno)))[0];
  }
  
  return Z;
  //return ;
}


// [[Rcpp::export(".loopexp_prob")]]
arma::mat loopexp_out3(const Rcpp::NumericVector& helpa, const arma::mat& helpb, 
                       NumericVector helpc, const arma::mat& X, 
                       int J, int n, int p)
{
  int i, j;
  RNGScope scope;
  arma::cube Sigma(helpc.begin(), p, p, J, false);   
  arma::mat prob(n, J);
  for (i = 1; i <= n; i++)
  {
    arma::rowvec x = X.row(i-1);
    for (j = 1; j <= J; j++)
    {
      arma::colvec mu = helpb.col(j-1);
      arma::mat Sig =Sigma.slice(j-1); 
      arma::vec result_t = dmvnorm_arma(x, mu.t(), Sig, 1); 
      Rcpp::NumericVector result(result_t.begin(), result_t.end());
      prob(i-1,j-1) = helpa[j-1] + result[0];
    }
    arma::rowvec test = prob.row(i-1);
    
    double mmax = find_max_arma(test, J);
    double deno = mmax + log(sum(exp(prob.row(i-1) - mmax)));
    prob.row(i-1) = exp(prob.row(i-1) - deno);
  }
  
  return prob;
}

