# Set working directory
################################################################################
setwd("C:\\repos\\Hierarchical-Bayes-Choice-Study")

# Load libraries
################################################################################
library(tidyverse)
#Explicitly called:  dummies

# Load and prepare choice design data
################################################################################
choice_design <- read_delim("./data/choice_design.csv", delim="\t") %>%
  select(screen, RAM, processor, price, brand)

#Function to convert from design levels to Effects Coding
effcode <- function(attmat){
  effcode_sub <- function(xvec){
    att.mat <- dummies::dummy(xvec)
    ref.ndx <- att.mat[,1]
    att.mat <- att.mat[,-1]
    att.mat[ref.ndx==1,] <- -1
    return(att.mat)   
  }

  natts <- ncol(attmat)
  efmat <- matrix(data=NA, ncol=1, nrow=nrow(attmat))
  for (j in 1:natts){
    dummat <- effcode_sub(as.numeric(attmat[,j]))
    efmat <- cbind(efmat,dummat)
  }
  efmat <- efmat[,-1]
  dimnames(efmat) <- list(NULL,NULL)
  return(efmat)
}

xmatrix <- effcode(as.matrix(choice_design))

#Creating a price*brand interaction in the xmatrix
price <- choice_design$price - mean(choice_design$price)
brands <- xmatrix[,9:11]
pxb <- price * brands
xmatrix <- cbind(xmatrix, pxb)

#Since there isn't a hold-out card, I'm designating Card #20 as a hold-out
#and removing it from the model datasets
holdout_x <- xmatrix[58:60,]
xmatrix <- xmatrix[-(58:60),]

#Save file
save(xmatrix, file="./data/xmatrix.Rdata")
save(holdout_x, file="./data/holdout_x.Rdata")
rm(price, brands, pxb, choice_design, xmatrix, holdout_x)

# Load and prepare respondent data
################################################################################
load("./data/raw_data.Rdata")
ydata <- select(raw_data, starts_with("DCM"), -dcm1_timer)

#Since there isn't a hold-out card, I'm designating Card #20 as a hold-out
#and removing it from the model datasets

holdout_y <- select(ydata, DCM1_20)
ydata <- select(ydata, -DCM1_20) %>%
  as.matrix()

#Save file
save(ydata, file="./data/ydata.Rdata")
save(holdout_y, file="./data/holdout_y.Rdata")
rm(raw_data, ydata, holdout_y)

# Creating all possible combinations file to use during Post Model Analytics
################################################################################
allpos <- data.frame(expand.grid(screen=seq(1:3), RAM=seq(1:3), processor=seq(1:3), 
                                price=seq(1:3), brand=seq(1:4)))

apmatrix <- effcode(as.matrix(allpos))

#Creating a price*brand interaction in the xmatrix
price <- allpos$price - mean(allpos$price)
brands <- apmatrix[,9:11]
pxb <- price * brands
apmatrix <- data.frame(cbind(apmatrix, pxb))

#Listing allpos and apmatrix for saving
apmatrix <- list(apmatrix, allpos)

save(apmatrix, file="./data/apmatrix.Rdata")
rm(price, brands, pxb, allpos, apmatrix, effcode)

