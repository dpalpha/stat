

# Parametric Test

# 1-sample t

# H0:m=μ
observed    = c(0.52, 0.20, 0.59, 0.62, 0.60)
theoretical = 0
t.test(x= observed, mu = theoretical, alternative = "two.sided", conf.int=0.95)

# 2-sample t
# H0:mA=mB
observed <- c(38.9, 61.2, 73.3, 21.8, 63.4, 64.6, 48.4, 48.8, 48.5)
theoretical <- c(67.8, 60, 63.4, 76, 89.4, 73.3, 67.3, 61.3, 62.4) 
t.test(x=observed, y=theoretical, alternative = "two.sided", var.equal = FALSE)
# k-sample ANOVA

# one-way ANOVA test
observed <- c(38.9, 61.2, 73.3, 21.8, 63.4, 64.6, 48.4, 48.8, 48.5)
group <- c("r1", "r2", "r1", "r1", "r2", "r1", "r1", "r2", "r1") 
group <- ordered(group,levels = c("r1", "r2"))

res.aov <- aov(observed ~ group)
summary(res.aov)
# Tukey Honest Significant Differences
TukeyHSD(res.aov)

library(multcomp)
summary(glht(res.aov, linfct = mcp(group = "Tukey")))

pairwise.t.test(observed, group,
                p.adjust.method = "BH")

plot(res.aov, 2)

aov_residuals <- residuals(object = res.aov )

shapiro.test(x = aov_residuals )

# Pearson r


# Nonparametric Counterpart

# Wilcoxon signed-rank

# Wilcoxon 2-sample rank-sum

# Kruskal-Wallis

# Spearman ρ