
library('dplyr')
library('lubridate')
library('ordinal')
library('ResourceSelection')
library('generalhoslem')



# Goodnes of Fit Tests for Logistic Regression Models
# hypothesis that the observed and expected proportions are the same across all doses is rejected
# H0: The models does not need interaction and non-linearity

library(reshape) # needed by logitgof
logitgof <- function (obs, exp, g = 10, ord = FALSE) {
  DNAME <- paste(deparse(substitute(obs)), deparse(substitute(exp)), sep = ", ")
  yhat <- exp
  if (is.null(ncol(yhat))) {
    mult <- FALSE
  } else {
    if (ncol(yhat) == 1) {
      mult <- FALSE
    } else mult <- TRUE
  }
  n <- ncol(yhat)
  if (mult) {
    if (!ord) {
      METHOD <- "Hosmer and Lemeshow test (multinomial model)"
    } else {
      METHOD <- "Hosmer and Lemeshow test (ordinal model)"
    }
    qq <- unique(quantile(1 - yhat[, 1], probs = seq(0, 1, 1/g)))
    cutyhats <- cut(1 - yhat[, 1], breaks = qq, include.lowest = TRUE)
    dfobs <- data.frame(obs, cutyhats)
    dfobsmelt <- melt(dfobs, id.vars = 2)
    observed <- cast(dfobsmelt, cutyhats ~ value, length)
    observed <- observed[order(c(1, names(observed[, 2:ncol(observed)])))]
    dfexp <- data.frame(yhat, cutyhats)
    dfexpmelt <- melt(dfexp, id.vars = ncol(dfexp))
    expected <- cast(dfexpmelt, cutyhats ~ variable, sum)
    expected <- expected[order(c(1, names(expected[, 2:ncol(expected)])))]
    stddiffs <- abs(observed[, 2:ncol(observed)] - expected[, 2:ncol(expected)]) / sqrt(expected[, 2:ncol(expected)])
    if (ncol(expected) != ncol(observed)) stop("Observed and expected tables have different number of columns. Check you entered the correct data.")
    chisq <- sum((observed[, 2:ncol(observed)] - expected[, 2:ncol(expected)])^2 / expected[, 2:ncol(expected)])
    if (!ord) {
      PARAMETER <- (nrow(expected) - 2) * (ncol(yhat) - 1) 
    } else {
      PARAMETER <- (nrow(expected) - 2) * (ncol(yhat) - 1) + ncol(yhat) - 2
    }
  } else {
    METHOD <- "Hosmer and Lemeshow test (binary model)"
    if (is.factor(obs)) {
      y <- as.numeric(obs) - 1
    } else {
      y <- obs
    }
    qq <- unique(quantile(yhat, probs = seq(0, 1, 1/g)))
    cutyhat <- cut(yhat, breaks = qq, include.lowest = TRUE)
    observed <- xtabs(cbind(y0 = 1 - y, y1 = y) ~ cutyhat)
    expected <- xtabs(cbind(yhat0 = 1 - yhat, yhat1 = yhat) ~ cutyhat)
    stddiffs <- abs(observed - expected) / sqrt(expected)
    chisq <- sum((observed - expected)^2/expected)
    PARAMETER <- nrow(expected) - 2
  }
  if (g != nrow(expected))
    warning(paste("Not possible to compute", g, "rows. There might be too few observations."))
  if (any(expected[, 2:ncol(expected)] < 1))
    warning("At least one cell in the expected frequencies table is < 1. Chi-square approximation may be incorrect.")
  PVAL <- 1 - pchisq(chisq, PARAMETER)
  names(chisq) <- "X-squared"
  names(PARAMETER) <- "df"
  structure(list(statistic = chisq, parameter = PARAMETER, 
                 p.value = PVAL, method = METHOD, data.name = DNAME, observed = observed, 
                 expected = expected, stddiffs = stddiffs), class = "htest")
}


dataset %>% 
  mutate(qater = floor_date(as.Date(APPLICATION_DATE, format =  "%d-%m-%Y"), "1 year")) %>% 
  group_by(qater) %>% 
  do(data.frame(
    pval = logitgof(.$DEFAULT, fitted(glm(.$DEFAULT~.$X1+
                                            .$X2+
                                            .$X3+
                                            .$X4+
                                            .$X5, family=binomial)),
                    g=10, ord = FALSE)$p.value
    
  ))



# generalhoslem::logitgof(dataset$DEFAULT,fitted(mod),g=10)

# hoslem.test(dataset$DEFAULT,fitted(mod),g=10)

pvalues <- array(0, 1000)

for (i in 1:1000) {
  n <- 100
  x <- rnorm(n)
  xb <- x
  pr <- exp(xb)/(1+exp(xb))
  y <- 1*(runif(n) < pr)
  mod <- glm(y~x, family=binomial)
  pvalues[i] <- logitgof(mod$y, fitted(mod), g=10, ord = FALSE)$p.value
  
}
