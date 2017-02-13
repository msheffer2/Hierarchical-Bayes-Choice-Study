# Set working directory
################################################################################
setwd("C:\\repos\\Hierarchical-Bayes-Choice-Study")

# Load libraries
################################################################################
library(bayesm)
library(tidyverse)
library(caret)
library(pROC)

# Load matrices and create listed data required for bayesm
################################################################################
load("./data/xmatrix.Rdata")
load("./data/ydata.Rdata")

lgtdata <- NULL
for (i in 1:nrow(ydata)) { 
  lgtdata[[i]]=list(y=ydata[i,],
                    X=xmatrix)}
rm(xmatrix, ydata, i)

# Run model
# p = 3 choices per card, R = 50000 iteractions, keep = keep every 5th run
################################################################################
set.seed(3456)
fit <- rhierMnlDP(Data=list(p=3, lgtdata=lgtdata), 
                  Mcmc=list(R=50000, keep=5))
save(fit, file="./output/mod1.fit.xz", compress="xz")
rm(lgtdata)

# Pull out betas and look for stable region to pull
################################################################################
betadraw <- fit$betadraw

par(mfrow = c(2, 2))
for (i in 1:dim(betadraw)[2]){
  plot(apply(betadraw[,i,], 2, function(x){mean(na.omit(x))}) )  
}
par(mfrow = c(1, 1))
rm(i)

#Pulling data for a few coeficients to use in repository document only
s1 <- apply(betadraw[,1,], 2, function(x){mean(na.omit(x))})
s2 <- apply(betadraw[,2,], 2, function(x){mean(na.omit(x))})
s3 <- apply(betadraw[,3,], 2, function(x){mean(na.omit(x))})
s4 <- apply(betadraw[,4,], 2, function(x){mean(na.omit(x))})
stable_dat <- list(s1=s1, s2=s2, s3=s3, s4=s4)
save(stable_dat, file="./output/stable_dat.Rdata")
rm(s1, s2, s3, s4, stable_dat)

# Pull out stable betas, evaluate beta densities, create coefficieint dataset
################################################################################
betadraw <- betadraw[,,4001:8000]

par(mfrow = c(2, 2))
for (i in 1:dim(betadraw)[2]){
  plot(density(betadraw[,i,],width=2))
}
par(mfrow = c(1, 1))
rm(i)

#Pulling data for a few coeficients to use in repository document only
d1 <- density(betadraw[,1,],width=2)
d2 <- density(betadraw[,2,],width=2)
d3 <- density(betadraw[,3,],width=2)
d4 <- density(betadraw[,4,],width=2)
density_dat <- list(d1=d1, d2=d2, d3=d3, d4=d4)
save(density_dat, file="./output/density_dat.Rdata")
rm(d1, d2, d3, d4, density_dat)

#betameans <- data.frame(apply(betadraw[,,],c(1,2),mean))
betameans <- apply(betadraw[,,],c(2),mean)
tempbetas <- apply(betadraw[,,],c(1,2),mean)
rm(fit, betadraw)

# Validate the model with the holdout card
################################################################################
load("./data/holdout_x.Rdata")
load("./data/holdout_y.Rdata")

#Matrix math
xbeta <- holdout_x %*% t(tempbetas)
xbeta2 <- matrix(xbeta, ncol=3, byrow=TRUE)
expxbeta2 <- exp(xbeta2)
rsumvec <- rowSums(expxbeta2)
pchoicemat <- expxbeta2/rsumvec
predict <- max.col(pchoicemat)
actual <- as.vector(t(holdout_y))
holdout_dat <- data.frame(cbind(predict, actual))
names(holdout_dat) <- c("predict", "actual")
rm(xbeta, xbeta2, expxbeta2, rsumvec, pchoicemat, predict, actual, holdout_x, holdout_y)

confusionMatrix(holdout_dat$actual, holdout_dat$predict)
#Predictive Accuracy of All Cards = 85.4%
auc(multiclass.roc(holdout_dat$actual, holdout_dat$predict, plot=FALSE))
#Area under the curve = 77.8%

#Pulling hold out validation data to use in repository document only
save(holdout_dat, file="./output/holdout_dat.Rdata")
rm(holdout_dat)

# Validate the model across all the cards
################################################################################
load("./data/xmatrix.Rdata")
load("./data/ydata.Rdata")

#Matrix math
xbeta <- xmatrix %*% t(tempbetas)
xbeta2 <- matrix(xbeta, ncol=3, byrow=TRUE)
expxbeta2 <- exp(xbeta2)
rsumvec <- rowSums(expxbeta2)
pchoicemat <- expxbeta2/rsumvec
predict <- max.col(pchoicemat)
actual <- as.vector(t(ydata))
valid_dat <- data.frame(cbind(predict, actual))
names(valid_dat) <- c("predict", "actual")
rm(xbeta, xbeta2, expxbeta2, rsumvec, pchoicemat, predict, actual, xmatrix, ydata)

confusionMatrix(valid_dat$actual, valid_dat$predict)
#Predictive Accuracy of All Cards = 87.2%
auc(multiclass.roc(valid_dat$actual, valid_dat$predict, plot=FALSE))
#Area under the curve = 89.8%

#Pulling hold out validation data to use in repository document only
save(valid_dat, file="./output/valid_dat.Rdata")
rm(valid_dat)

# Save coefficients
################################################################################
mod1_coefs <- data.frame(t(round(betameans, digits=2)))
save(mod1_coefs, file="./output/mod1_coefs.Rdata")
rm(tempbetas, betameans, mod1_coefs)





