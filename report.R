## ----setup, include=FALSE-----------------------------------------------
knitr::opts_chunk$set(echo = TRUE)


## ----import, warning=FALSE----------------------------------------------
rm(list=ls())
data = read.csv('./data/cleaned_data.csv')
attach(data)
head(data)


## ---- echo=FALSE--------------------------------------------------------
hist(Steps, breaks=20)


## ---- echo=FALSE--------------------------------------------------------
hist(log(Steps), breaks=20)


## -----------------------------------------------------------------------
n=length(Steps)
x=log(Steps)


## -----------------------------------------------------------------------
log_likelihood <- function(x, k, lam) {
  return (sum(log(dweibull(x,shape=k,scale=lam))))
}


## -----------------------------------------------------------------------
log_prior <- function(k, lam) {
  mu_k <- 0.5
  sigma_k <- 1
  mu_lambda <- 0.5
  sigma_lambda <- 1
  log_prior_k <- -0.5 * ((log(k) - mu_k)^2 / sigma_k^2) - log(k * sigma_k * sqrt(2 * pi))
  log_prior_lambda <- -0.5 * ((log(lam) - mu_lambda)^2 / sigma_lambda^2) - log(lam * sigma_lambda * sqrt(2 * pi))
  return(log_prior_k + log_prior_lambda)
}


## -----------------------------------------------------------------------
burnin = 2000
iters = 40000
toiter=burnin+iters


## -----------------------------------------------------------------------
k=rep(0,toiter)
lam=rep(0,toiter)

k[1] <- 7
lam[1] <- 70

pac.k = 0
pac.lam = 0


## -----------------------------------------------------------------------
for (i in 2:toiter) {
  # Update k
  kc <- rlnorm(1, meanlog = log(k[i-1]), sdlog = 0.1)  
  log_alpha_k <- log_likelihood(x, kc, lam[i-1]) + log_prior(kc, lam[i-1]) -
                  log_likelihood(x, k[i-1], lam[i-1]) - log_prior(k[i-1], lam[i-1])
  
  if (log(runif(1)) < log_alpha_k) {
    k[i] <- kc; if (i>burnin){pac.k=pac.k+1}
  }
  else{
    k[i] <- k[i-1]
  }
    
  # Update lambda
  lamc <- rlnorm(1, meanlog = log(lam[i-1]), sdlog = 0.02) 
  log_alpha_lam <- log_likelihood(x, k[i], lamc) + log_prior(k[i], lamc) -
                    log_likelihood(x, k[i], lam[i-1]) - log_prior(k[i], lam[i-1])
  
  if (log(runif(1)) < log_alpha_lam) {
    lam[i] <- lamc; if (i>burnin){pac.lam=pac.lam+1}
  }
  else{
    lam[i] <- lam[i-1]
  }
}



## -----------------------------------------------------------------------
pac.k = pac.k/iters
pac.lam = pac.lam/iters
c(pac.k, pac.lam)


## -----------------------------------------------------------------------
thin <- 1
k.post=k[seq(burnin+1,iters,by=thin)]
lam.post=lam[seq(burnin+1,iters,by=thin)]

plot.ts(k.post)
plot.ts(lam.post)


## -----------------------------------------------------------------------
acf(k.post)
acf(lam.post)


## -----------------------------------------------------------------------
thin <- 5
k.post=k[seq(burnin+1,iters,by=thin)]
lam.post=lam[seq(burnin+1,iters,by=thin)]


acf(k.post)
acf(lam.post)


## -----------------------------------------------------------------------
hist(k.post)
mean(k.post)


## -----------------------------------------------------------------------
hist(lam.post)
mean(lam.post)


## -----------------------------------------------------------------------
quantile(k.post,c(0.025,0.975))
quantile(lam.post,c(0.025,0.975))


## -----------------------------------------------------------------------
M=100000
disc.pred=rweibull(M,shape=k.post, scale=lam.post)
hist(disc.pred)


## -----------------------------------------------------------------------
hist(x,freq=F, breaks=15)
lines(density(disc.pred))


## -----------------------------------------------------------------------
mean(disc.pred>log(7000))

