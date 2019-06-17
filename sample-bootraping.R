v = faithful$waiting
median_cl_boot <- function(x){
reP = 1000
a = median
quantile(apply(matrix(sample(x,reP, 10^4*length(x)), nrow=10^4),1, a), c(0.025, 0.975))
}
median_cl_boot <- function(x){
  gM <- median(x)
  bootNums <- 1000
  m = replicate(bootNums, gM - median(sample(x, replace = T)))
  gM + quantile(m, c(.025,.975))
}

x = matrix(rnorm(40*400), ncol=4)
system.time({
    mx<- rep(NA, nrow(x))
    for(i in 1:nrow(x)) mx[i]<- max(x[i])
})
system.time(mx2<- apply(x, 1, max))

slope_cl_boot <- function(x,y){
    x.mean = mean(x)
    y.mean = mean(y)
    b = 1000
    x.boot = numeric(b)
    y.boot = numeric(b)
    for (i in 1:b){
        x.boot[i] = mean(sample(x, size = length(x), replace = TRUE))
        y.boot[i] = mean(sample(y, size = length(y), replace = TRUE))
    }
    boot.st = x.boot - y.boot
    print(quantile(boot.st, c(.025,.975)))
}
slope_cl_boot(mtcars$qsec, mtcars$drat)

require(Lock5Data)
data(ImmuneTea)

tea = with(ImmuneTea, InterferonGamma[Drink=="Tea"])
coffee = with(ImmuneTea, InterferonGamma[Drink=="Coffee"])
tea.mean = mean(tea)
coffee.mean = mean(coffee)
tea.n = length(tea)
coffee.n = length(coffee)
B = 100000
# create empty arrays for the means of each sample
tea.boot = numeric(B)
coffee.boot = numeric(B)
# Use a for loop to take the samples
for ( i in 1:B ) {
tea.boot[i] = mean(sample(tea,size=tea.n,replace=TRUE))
coffee.boot[i] = mean(sample(coffee,size=coffee.n,replace=TRUE))
}

boot.stat = tea.boot - coffee.boot
# Find endpoints for 90%, 95%, and 99% bootstrap confidence intervals using percentiles.
quantile(boot.stat,c(0.05,0.95))
