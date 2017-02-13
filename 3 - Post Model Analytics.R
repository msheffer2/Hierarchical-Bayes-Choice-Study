# Set working directory
################################################################################
setwd("C:\\repos\\Hierarchical-Bayes-Choice-Study")

# Load libraries
################################################################################
library(tidyverse)
library(stringr)
#explicitly called:  scales, car

################################################################################
# Technical Model Results
################################################################################

#Data Prep
load("./output/mod1_coefs.Rdata")

scr <- select(mod1_coefs, X1, X2) %>%
  mutate(l1 = -1 * X1 + -1 * X2,
         l2 = X1,
         l3 = X2) %>%
  select(-(starts_with("X"))) %>%
  gather(lev, lo) %>%
  mutate(or = round(exp(lo), digits=2),
         pco = or - 1) %>%
  mutate(lev = as.numeric(str_replace(lev, "l", ""))) %>%
  mutate(var= ifelse(lev==1, 1, 0)) %>%
  select(var, lev, lo, or, pco)

ram <- select(mod1_coefs, X3, X4) %>%
  mutate(l4 = -1 * X3 + -1 * X4,
         l5 = X3,
         l6 = X4) %>%
  select(-(starts_with("X"))) %>%
  gather(lev, lo) %>%
  mutate(or = round(exp(lo), digits=2),
         pco = or - 1) %>%
  mutate(lev = as.numeric(str_replace(lev, "l", ""))) %>%
  mutate(var= ifelse(lev==4, 2, 0)) %>%
  select(var, lev, lo, or, pco)

pro <- select(mod1_coefs, X5, X6) %>%
  mutate(l7 = -1 * X5 + -1 * X6,
         l8 = X5,
         l9 = X6) %>%
  select(-(starts_with("X"))) %>%
  gather(lev, lo) %>%
  mutate(or = round(exp(lo), digits=2),
         pco = or - 1) %>%
  mutate(lev = as.numeric(str_replace(lev, "l", ""))) %>%
  mutate(var= ifelse(lev==7, 3, 0)) %>%
  select(var, lev, lo, or, pco)

pri <- select(mod1_coefs, X7, X8) %>%
  mutate(l10 = -1 * X7 + -1 * X8,
         l11 = X7,
         l12 = X8) %>%
  select(-(starts_with("X"))) %>%
  gather(lev, lo) %>%
  mutate(or = round(exp(lo), digits=2),
         pco = or - 1) %>%
  mutate(lev = as.numeric(str_replace(lev, "l", ""))) %>%
  mutate(var= ifelse(lev==10, 4, 0)) %>%
  select(var, lev, lo, or, pco)

bra <- select(mod1_coefs, X9, X10, X11) %>%
  mutate(l13 = -1 * X9 + -1 * X10 + -1 * X11,
         l14 = X9,
         l15 = X10,
         l16 = X11) %>%
  select(-(starts_with("X"))) %>%
  gather(lev, lo) %>%
  mutate(or = round(exp(lo), digits=2),
         pco = or - 1) %>%
  mutate(lev = as.numeric(str_replace(lev, "l", ""))) %>%
  mutate(var= ifelse(lev==13, 5, 0)) %>%
  select(var, lev, lo, or, pco)

bxp <- select(mod1_coefs, X12, X13, X14) %>%
  mutate(l17 = -1 * X12 + -1 * X13 + -1 * X14,
         l18 = X12,
         l19 = X13,
         l20 = X14) %>%
  select(-(starts_with("X"))) %>%
  gather(lev, lo) %>%
  mutate(or = round(exp(lo), digits=2),
         pco = or - 1) %>%
  mutate(lev = as.numeric(str_replace(lev, "l", ""))) %>%
  mutate(var= ifelse(lev==17, 6, 0)) %>%
  select(var, lev, lo, or, pco)

utils1_dat <- bind_rows(scr, ram, pro, pri, bra, bxp) %>%
  mutate(var = factor(var, levels=c(0:6), labels=c("", "Screen Size", "RAM", "Processor Speed", 
                                                   "Price", "Brand", "Brand * Price Interaction"))) %>%
  mutate(lev = factor(lev, levels=c(1:20), labels=c("5 Inches", "7 Inches", "10 Inches",
                                                      "8 Gb", "16 Gb", "32 Gb",
                                                      "1.5 GHz", "2 GHz", "2.5 GHz",
                                                      "$199", "$299", "$399",
                                                      "Brand A", "Brand B", "Brand C", "Brand D",
                                                      "Brand A * Price", "Brand B * Price", "Brand C * Price", "Brand D * Price")))
rm(scr, ram, pro, pri, bra, bxp)
names(utils1_dat) <- c("Attribute", "Level", "Log Odds Ratio", "Odds Ratio", "% Change in Odds")

#Plot
utils1_dat

save(utils1_dat, file="./output/utils1_dat.Rdata")

#Using the output structure in later table
hold <- select(utils1_dat, Attribute, Level) %>%
  filter(row_number() <= 16)
rm(utils1_dat)

################################################################################
# Preferred Model Results
################################################################################

#Data Prep
load("./data/apmatrix.Rdata")
allpos <- apmatrix[[2]]
apmatrix <- apmatrix[[1]]
apmatrix$scen <- c(1:nrow(apmatrix))

#Run all possible combinations
all <- data.frame(matrix(NA, nrow(mod1_coefs), nrow(apmatrix)))
for (i in seq(1:nrow(apmatrix))){
  test <- apmatrix[apmatrix$scen==i,]  
  all[i] <- 
    test$X1*mod1_coefs$X1+
    test$X2*mod1_coefs$X2+
    test$X3*mod1_coefs$X3+
    test$X4*mod1_coefs$X4+
    test$X5*mod1_coefs$X5+
    test$X6*mod1_coefs$X6+
    test$X7*mod1_coefs$X7+
    test$X8*mod1_coefs$X8+
    test$X9*mod1_coefs$X9+
    test$X10*mod1_coefs$X10+
    test$X11*mod1_coefs$X11+
    test$X12*mod1_coefs$X12+
    test$X13*mod1_coefs$X13+
    test$X14*mod1_coefs$X14
  rm(test)
}

#Convert to probability of being chosen
#Probability of being chosen: exp(x) / (exp(x) + # of Choices - 1)
all <- round(exp(all) / (exp(all) + 3 - 1), digits=3)

all <- summarize_each(all, funs(mean)) %>%
  t() %>%
  data.frame()

allpos <- bind_cols(allpos, all)
names(allpos)[6] <- c("p")
rm(all, i, apmatrix)

scr <- allpos %>%
  group_by(screen) %>%
  summarize(p=mean(p)) %>%
  select(p)

ram <- allpos %>%
  group_by(RAM) %>%
  summarize(p=mean(p)) %>%
  select(p)

pro <- allpos %>%
  group_by(processor) %>%
  summarize(p=mean(p)) %>%
  select(p)

pri <- allpos %>%
  group_by(price) %>%
  summarize(p=mean(p)) %>%
  select(p)

bra <- allpos %>%
  group_by(brand) %>%
  summarize(p=mean(p)) %>%
  select(p)

#Will use all possible combos later
save(allpos, file="./output/allpos.Rdata")

utils2_dat <- bind_rows(scr, ram, pro, pri, bra) %>%
  bind_cols(hold) %>%
  mutate(Probability=round(p, digits=3)) %>%
  mutate(Probability=scales::percent_format()(Probability)) %>%
  select(Attribute, Level, Probability)

#Plot
utils2_dat
save(utils2_dat, file="./output/utils2_dat.Rdata")
#rm(utils2_dat)

utils2_bxp <- allpos %>%
  mutate(bxp = brand*10 + price) %>%
  group_by(bxp) %>%
  select(bxp, brand, price, p) %>%
  summarize_each(funs(mean)) %>%
  mutate(brand = factor(brand, levels=c(1:4), labels=c("Brand A", "Brand B", "Brand C", "Brand D"))) %>%
  mutate(price = car::recode(price, "1=199;2=299;3=399")) %>%
  mutate(Probability=round(p, digits=3)) %>%
  select(brand, price, Probability) %>%
  rename(Brand = brand, Price = price)
save(utils2_bxp, file="./output/utils2_bxp.Rdata")

rm(scr, ram, pro, pri, bra, allpos, hold)

#Plot

ggplot(utils2_bxp, aes(x=Price, y=Probability, color=Brand)) + 
  geom_point(size=4) +
  geom_line(size=2) + 
  scale_y_continuous(limits=c(.05, .85), 
                     breaks=c(seq(0, 1, .1)), 
                     labels = scales::percent) +
  scale_x_continuous(limits=c(199, 399), 
                     breaks=c(199, 299, 399),
                     labels= scales::dollar) + 
  scale_colour_manual(values=c("red", "blue", "orange", "green")) + 
  theme(text = element_text(size=15), 
        panel.grid.minor=element_blank(),
        panel.grid.major=element_blank())

ggsave("./output/utils2_bxp.pdf")
rm(utils2_bxp)

################################################################################
# Attribute Importance
################################################################################

#Data Prep
imp_dat <- utils2_dat %>%
  mutate(Probability=as.numeric(sub("%", "", Probability))) %>%
  mutate(A2 = c(rep(1,3), rep(2,3), rep(3,3), rep(4,3), rep(5,4))) %>%
  group_by(A2) %>%
  summarize(maxp=max(Probability),
            minp=min(Probability)) %>%
  mutate(r=maxp - minp) %>%
  mutate(Importance = round(r / sum(r), digits=3)) %>%
  mutate(Attribute = factor(A2, levels=c(1:5), labels=c("Screen Size", "RAM", 
                                                        "Processor Speed", "Price",
                                                        "Brand"))) %>%
  select(Attribute, Importance) %>%
  #arrange(desc(Importance)) %>%
  mutate(Attribute = forcats::fct_reorder(Attribute, Importance, .desc=TRUE)) %>%
  mutate(label = scales::percent_format()(Importance))

save(imp_dat, file="./output/imp_dat.Rdata")

#Plot
colors <- c("red", "blue", "green", "purple", "orange")

ggplot(imp_dat, aes(x=Attribute, y=Importance)) + 
  geom_bar(stat="identity", color=colors, fill=colors) +
  geom_text(aes(label=label), vjust=-1.5, color="black") +
  scale_y_continuous(limits=c(0, .5), 
                     breaks=c(seq(0, 1, .1)), 
                     labels = scales::percent) +
  theme(text = element_text(size=15), 
        panel.grid.minor=element_blank(),
        panel.grid.major=element_blank())

ggsave("./output/imp.pdf")
rm(imp_dat, colors)

################################################################################
# Part-worths Plot
################################################################################

#Data Prep
pw_dat <- utils2_dat %>%
  mutate(Probability=as.numeric(sub("%", "", Probability))) %>%
  mutate(A2 = c(rep(1,3), rep(2,3), rep(3,3), rep(4,3), rep(5,4))) %>%
  group_by(A2) %>%
  mutate(PW = round((Probability - mean(Probability))/100, digits=2)) %>%
  ungroup() %>%
  mutate(A2 = factor(A2, levels=c(1:5), labels=c("Screen Size", "RAM", "Processor Speed", 
                                                   "Price", "Brand"))) %>%
  mutate(Attribute = paste0(A2, ": ", Level)) %>%
  select(Attribute, PW, A2) %>%
  mutate(c = factor(as.numeric(A2), levels=c(1:5), labels=c("purple", "green", "blue", "red", "orange"))) %>%
  mutate(c = as.character(c)) %>%
  arrange(desc(PW)) %>%
  select(-A2) %>%
  mutate(label = scales::percent_format()(PW)) %>%
  mutate(label_pos = ifelse(PW >= 0, PW + .02, PW - .04))

save(pw_dat, file="./output/pw_dat.Rdata")

#Plot
colors <- c(as.character(pw_dat[pw_dat$PW<0,]$c),
            as.character(pw_dat[pw_dat$PW>0,]$c))

ggplot(pw_dat, aes(x=reorder(Attribute, -PW), y=PW)) + 
  geom_bar(stat="identity", fill=colors) +
  geom_text(y=pw_dat$label_pos, aes(label=label), vjust=-1.5, color="black") +
  scale_y_continuous(limits=c(-.4, .4), 
                     breaks=c(seq(-1, 1, .1)), 
                     labels = scales::percent) +
  theme(text = element_text(size=15), 
        panel.grid.minor=element_blank(),
        panel.grid.major=element_blank(),
        axis.text.x = element_text(angle=90, hjust=1)) +
  xlab("Attribute/Level") + ylab("Part-Worth")

ggsave("./output/pw.pdf")
rm(pw_dat, colors, utils2_dat)

################################################################################
# Identyfing the Optimal Product Configuration
################################################################################

#Data Prep
load("./output/allpos.Rdata")
allpos <- allpos %>%
  mutate(screen = factor(screen, levels=c(1:3), labels=c("5 Inches", "7 Inches", "10 Inches"))) %>%
  mutate(RAM = factor(RAM, levels=c(1:3), labels=c("8 Gb", "16 Gb", "32 Gb"))) %>%
  mutate(processor = factor(processor, levels=c(1:3), labels=c("1.5 GHz", "2 GHz", "2.5 GHz"))) %>%
  mutate(price = factor(price, levels=c(1:3), labels=c("$199", "$299", "$399"))) %>%
  mutate(brand = factor(brand, levels=c(1:4), labels=c("Brand A", "Brand B", "Brand C", "Brand D"))) %>%
  rename(Screen=screen, Processor=processor, Price=price, Brand=brand) %>%
  mutate(Probability = scales::percent_format()(round(p, digits=3)))

top_ten <- arrange(allpos, desc(p)) %>%
  filter(row_number()<=10) %>%
  select(-p)

bot_ten <- arrange(allpos, p) %>%
  filter(row_number()<=10) %>%
  select(-p)

top_bot <- list(top_ten, bot_ten)

save(top_bot, file="./output/top_bot.Rdata")

#Plot
top_ten
bot_ten

rm(top_ten, bot_ten, top_bot, allpos)

################################################################################
# Predicting Preference Share for Market Scenarios
################################################################################

#Data Prep
extra <- read_csv("./data/extra_scenarios.csv")

xbeta <- as.matrix(extra) %*% t(mod1_coefs)
xbeta2 <- matrix(xbeta, ncol=3, byrow=TRUE)
expxbeta2 <- exp(xbeta2)
rsumvec <- rowSums(expxbeta2)
scenarios <- expxbeta2/rsumvec

scenarios <- data.frame(scenarios) %>%
  mutate(prod1=round(X1, digits=3),
         prod2=round(X2, digits=3),
         prod3=round(X3, digits=3)) %>%
  mutate(prod1=scales::percent_format()(prod1),
         prod2=scales::percent_format()(prod2),
         prod3=scales::percent_format()(prod3)) %>%
  select(prod1, prod2, prod3)

temp <- data.frame(matrix(nrow=6, ncol=4))
names(temp) <- c("Attribute", "Choice 1", "Choice 2", "Choice 3")
temp$Attribute <- c("Brand", "Screen", "RAM", "Processor", "Price", "Preference Share")

scen1 <- temp
scen1[2] <- c("B", "10 in.", "32 Gb", "2 GHz", "$199", ".")
scen1[3] <- c("A", "10 in.", "8 Gb", "2 GHz", "$199", ".")
scen1[4] <- c("C", "10 in.", "16 Gb", "2 GHz", "$199", ".")
scen1[6,2:4] <- scenarios[1,]

scen2 <- temp
scen2[2] <- c("B", "5 in.", "8 Gb", "1.5 GHz", "$199", ".")
scen2[3] <- c("A", "5 in.", "16 Gb", "1.5 GHz", "$199", ".")
scen2[4] <- c("C", "7 in.", "16 Gb", "1.5 GHz", "$399", ".")
scen2[6,2:4] <- scenarios[2,]

#Plot
scen1
scen2

scenarios <- list(scen1, scen2)
save(scenarios, file="./output/scenarios.Rdata")

rm(extra, xbeta, xbeta2, expxbeta2, rsumvec, scenarios, temp, mod1_coefs, scen1, scen2)





