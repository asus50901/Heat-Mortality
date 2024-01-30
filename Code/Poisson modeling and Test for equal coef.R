# This is the code to perform testing of gender specific beta coefficients to be equal

########################### Set up #################################
pkgs <- c("tidyverse", "ggplot2", "xlsx", 
          "ggthemes", "patchwork", "splines", 
          "lmtest", "sandwich", "corrplot") 

invisible(lapply(pkgs, library, character.only = T))

## Read in the gbd datas
gbd_both <- read_csv("gbd_both.csv")
gbd_male <- read_csv("gbd_male.csv")
gbd_female <- read_csv("gbd_female.csv")



##################### Test with Dispersion ####################
set.seed(1211)

tmp_mod_male <- glm(data = gbd_male,
                    mort_cnt ~ Summer_mean_temp,
                    offset = log(pop_cnt),
                    family = poisson(), x = T)
AER::dispersiontest(tmp_mod_male) # there is overdispersion in male (p-value < 0.05)

tmp_mod_female <- glm(data = gbd_female,
                      mort_cnt ~ Summer_mean_temp,
                      offset = log(pop_cnt),
                      family = poisson(), x = T)
AER::dispersiontest(tmp_mod_female) # there is overdispersion in female (p-value < 0.05)

####################### Simple Poisson (Summer mean temp) #######################

set.seed(1211)

## Construct the poisson glms (Summer mean Temp)
mod_M_SMeanTonly <- glm(data = gbd_male,
                     mort_cnt ~ Summer_mean_temp,
                     offset = log(pop_cnt),
                     family = quasipoisson, x = T)
summary(mod_M_SMeanTonly)

confint(mod_M_SMeanTonly)
# Summer mean Temp is not significant for male

mod_F_SMeanTonly <- glm(data = gbd_female,
                     mort_cnt ~ Summer_mean_temp,
                     offset = log(pop_cnt),
                     family = quasipoisson(), x = T)
summary(mod_F_SMeanTonly)
# Summer mean Temp is not significant for female

#################### Testing of z-test statistics for Summer mean temp
# H0: B_m = B_f

# Test for Equivalence

M_infoSMeanT <- c(coef(mod_M_SMeanTonly)[2], # beta_M,
               summary(mod_M_SMeanTonly)$coefficients[2,2]) # se of beta_M
names(M_infoSMeanT) <- c("beta", "se_beta")

F_infoSMeanT <- c(coef(mod_F_SMeanTonly)[2], # beta_F
               summary(mod_F_SMeanTonly)$coefficients[2,2]) # se of beta_F
names(F_infoSMeanT) <- c("beta", "se_beta")

(z_score_SMeanT <- (M_infoSMeanT["beta"] - F_infoSMeanT["beta"])/sqrt(M_infoSMeanT["se_beta"]^2 + F_infoSMeanT["se_beta"]^2))

# Calc. the two-tailed p-value 
2 * (1 - pnorm(abs(z_score_SMeanT)))
# reject the null hypothesis, we conclude that B_m != B_f for Summer mean temperature

####################### Simple Poisson (Summer Max temp) #######################

## Construct the poisson glms (Summer_max_temp)
mod_M_SMaxTonly <- glm(data = gbd_male,
                       mort_cnt ~ Summer_max_temp,
                       offset = log(pop_cnt),
                       family = quasipoisson(), x = T)
summary(mod_M_SMaxTonly)
# Summer Max Temp is not significant for male

mod_F_SMaxTonly <- glm(data = gbd_female,
                       mort_cnt ~ Summer_max_temp,
                       offset = log(pop_cnt),
                       family = quasipoisson(), x = T)
summary(mod_F_SMaxTonly)
# Summer Max Temp is not significant for female

#################### Testing of z-test statistics for Summer Max temp
# H0: B_m = B_f

# Test for Equivalence

M_infoSMaxT <- c(coef(mod_M_SMaxTonly)[2], # beta_M,
                 summary(mod_M_SMaxTonly)$coefficients[2,2]) # se of beta_M
names(M_infoSMaxT) <- c("beta", "se_beta")

F_infoSMaxT <- c(coef(mod_F_SMaxTonly)[2], # beta_F
                 summary(mod_F_SMaxTonly)$coefficients[2,2]) # se of beta_F
names(F_infoSMaxT) <- c("beta", "se_beta")

(z_score_SMaxT <- (M_infoSMaxT["beta"] - F_infoSMaxT["beta"])/sqrt(M_infoSMaxT["se_beta"]^2 + F_infoSMaxT["se_beta"]^2))

# Calc. the two-tailed p-value 
2 * (1 - pnorm(abs(z_score_SMaxT)))
# reject the null hypothesis, we conclude that B_m != B_f for Summer Max temperature

####################### Simple Poisson (Winter Mean temp) #######################

## Construct the poisson glms (Winter_mean_temp)
mod_M_WmeanTonly <- glm(data = gbd_male,
                        mort_cnt ~ Winter_mean_temp,
                        offset = log(pop_cnt),
                        family = quasipoisson(), x = T)
summary(mod_M_WmeanTonly)
# Winter Mean temp is not significant for male

mod_F_WmeanTonly <- glm(data = gbd_female,
                        mort_cnt ~ Winter_mean_temp,
                        offset = log(pop_cnt),
                        family = quasipoisson(), x = T)
summary(mod_F_WmeanTonly)
# Winter Mean temp is not significant for female

#################### Testing of z-test statistics for Winter Mean temp
# H0: B_m = B_f

# Test for Equivalence

M_infoWmeanT <- c(coef(mod_M_WmeanTonly)[2], # beta_M,
                  summary(mod_M_WmeanTonly)$coefficients[2,2]) # se of beta_M
names(M_infoWmeanT) <- c("beta", "se_beta")

F_infoWmeanT <- c(coef(mod_F_WmeanTonly)[2], # beta_F
                  summary(mod_F_WmeanTonly)$coefficients[2,2]) # se of beta_F
names(F_infoWmeanT) <- c("beta", "se_beta")

(z_score_WmeanT <- (M_infoWmeanT["beta"] - F_infoWmeanT["beta"])/sqrt(M_infoWmeanT["se_beta"]^2 + F_infoWmeanT["se_beta"]^2))

# Calc. the two-tailed p-value 
2 * (1 - pnorm(abs(z_score_WmeanT)))
# cannot reject the null hypothesis, we cannot reject that B_m = B_f for Winter Mean temperature

####################### Simple Poisson (Winter Min temp) #######################

## Construct the poisson glms (Winter_min_temp)
mod_M_WMinTonly <- glm(data = gbd_male,
                       mort_cnt ~ Winter_min_temp,
                       offset = log(pop_cnt),
                       family = quasipoisson(), x = T)
summary(mod_M_WMinTonly)
# Winter Min temp is not significant for male

mod_F_WMinTonly <- glm(data = gbd_female,
                       mort_cnt ~ Winter_min_temp,
                       offset = log(pop_cnt),
                       family = quasipoisson(), x = T)
summary(mod_F_WMinTonly)
# Winter Min temp is not significant for female

#################### Testing of z-test statistics for Winter Min temp
# H0: B_m = B_f

# Test for Equivalence

M_infoWMinT <- c(coef(mod_M_WMinTonly)[2], # beta_M,
                 summary(mod_M_WMinTonly)$coefficients[2,2]) # se of beta_M
names(M_infoWMinT) <- c("beta", "se_beta")

F_infoWMinT <- c(coef(mod_F_WMinTonly)[2], # beta_F
                 summary(mod_F_WMinTonly)$coefficients[2,2]) # se of beta_F
names(F_infoWMinT) <- c("beta", "se_beta")

(z_score_WMinT <- (M_infoWMinT["beta"] - F_infoWMinT["beta"])/sqrt(M_infoWMinT["se_beta"]^2 + F_infoWMinT["se_beta"]^2))

# Calc. the two-tailed p-value 
2 * (1 - pnorm(abs(z_score_WMinT)))
# cannot reject the null hypothesis, we cannot reject that B_m = B_f for Winter Min temperature

####################### Simple Poisson (Heat Days Counts) #######################

## Construct the poisson glms (Heat Days Counts)
mod_M_ExHeatCnt <- glm(data = gbd_male,
                       mort_cnt ~ extreme_heat_cnt,
                       offset = log(pop_cnt),
                       family = quasipoisson, x = T)
summary(mod_M_ExHeatCnt)
# Heat Days Counts is significant for male

mod_F_ExHeatCnt <- glm(data = gbd_female,
                       mort_cnt ~ extreme_heat_cnt,
                       offset = log(pop_cnt),
                       family = quasipoisson(), x = T)
summary(mod_F_ExHeatCnt)
# Heat Days Counts is not significant for female

#################### Testing of z-test statistics for Heat Days Counts
# H0: B_m = B_f

# Test for Equivalence

M_infoExHeatCnt <- c(coef(mod_M_ExHeatCnt)[2], # beta_M,
                  summary(mod_M_ExHeatCnt)$coefficients[2,2]) # se of beta_M
names(M_infoExHeatCnt) <- c("beta", "se_beta")

F_infoExHeatCnt <- c(coef(mod_F_ExHeatCnt)[2], # beta_F
                  summary(mod_F_ExHeatCnt)$coefficients[2,2]) # se of beta_F
names(F_infoExHeatCnt) <- c("beta", "se_beta")

(z_score_ExHeatCnt <- (M_infoExHeatCnt["beta"] - F_infoExHeatCnt["beta"])/sqrt(M_infoExHeatCnt["se_beta"]^2 + F_infoExHeatCnt["se_beta"]^2))

# Calc. the two-tailed p-value 
2 * (1 - pnorm(abs(z_score_ExHeatCnt)))
# reject the null hypothesis, we conclude that B_m != B_f for Heat Days Counts

####################### Simple Poisson (Cold Days Counts) #######################

## Construct the poisson glms (Cold Days Counts)
mod_M_ExColdCnt <- glm(data = gbd_male,
                       mort_cnt ~ extreme_cold_cnt,
                       offset = log(pop_cnt),
                       family = quasipoisson, x = T)
summary(mod_M_ExColdCnt)
# Cold Days is not significant for male

mod_F_ExColdCnt <- glm(data = gbd_female,
                       mort_cnt ~ extreme_cold_cnt,
                       offset = log(pop_cnt),
                       family = quasipoisson(), x = T)
summary(mod_F_ExColdCnt)
# Cold Days Counts is not significant for female

#################### Testing of z-test statistics for Cold Days Counts
# H0: B_m = B_f

# Test for Equivalence

M_infoExColdCnt <- c(coef(mod_M_ExColdCnt)[2], # beta_M,
                     summary(mod_M_ExColdCnt)$coefficients[2,2]) # se of beta_M
names(M_infoExColdCnt) <- c("beta", "se_beta")

F_infoExColdCnt <- c(coef(mod_F_ExColdCnt)[2], # beta_F
                     summary(mod_F_ExColdCnt)$coefficients[2,2]) # se of beta_F
names(F_infoExColdCnt) <- c("beta", "se_beta")

(z_score_ExColdCnt <- (M_infoExColdCnt["beta"] - F_infoExColdCnt["beta"])/sqrt(M_infoExColdCnt["se_beta"]^2 + F_infoExColdCnt["se_beta"]^2))

# Calc. the two-tailed p-value 
2 * (1 - pnorm(abs(z_score_ExColdCnt)))
# cannot reject the null hypothesis, we cannot reject that B_m = B_f for Cold Days Counts


############################# Joint Analysis - Summer Max Temp + Winter Min Temp ###########################

## Construct the poisson glms (Summer Temp + Winter Temp)
set.seed(1211)
mod_M_JntTemps <- glm(data = gbd_male,
                       mort_cnt ~ Summer_max_temp + Winter_min_temp,
                       offset = log(pop_cnt),
                       family = quasipoisson, x = T)
summary(mod_M_JntTemps)
# Summer max and Winter min are not significant for male
set.seed(1211)
mod_F_JntTemps <- glm(data = gbd_female,
                       mort_cnt ~ Summer_max_temp + Winter_min_temp, 
                       offset = log(pop_cnt),
                       family = quasipoisson(), x = T)
summary(mod_F_JntTemps)
# Summer max and Winter min are not significant for female

# Both not significant for male or female models, 
# but judging from the calculated t-statistics (larger abs value) and p-value (smaller value)
# The Summer max temperature is a better predictor for environmental heat and cold mortality rates
# for both male and female data.

#################### Testing of z-test statistics for Summer max + Winter min
# H0: B_m = B_f

# Test for Equivalence

(z_score_JntTemps <- (coef(mod_M_JntTemps)[-1] - coef(mod_F_JntTemps)[-1])/sqrt(summary(mod_M_JntTemps)$coefficients[-1, 2]^2 + summary(mod_F_JntTemps)$coefficients[-1, 2]^2))

# Calc. the two-tailed p-value 
2 * (1 - pnorm(abs(z_score_JntTemps)))
# # reject the null hypothesis, we conclude that B_m != B_f for Summer max temp
# # cannot reject the null hypothesis, we cannot reject that B_m = B_f for Winter min temp 

############################# Joint Analysis - Heat Days + Cold Days ###########################

## Construct the poisson glms (Heat Days + Cold Days)
set.seed(1211)
mod_M_JntExtevent <- glm(data = gbd_male,
                         mort_cnt ~ extreme_heat_cnt + extreme_cold_cnt,
                         offset = log(pop_cnt),
                         family = quasipoisson, x = T)
summary(mod_M_JntExtevent)
# Heat Days significant for male
set.seed(1211)
mod_F_JntExtevent <- glm(data = gbd_female,
                         mort_cnt ~ extreme_heat_cnt + extreme_cold_cnt, 
                         offset = log(pop_cnt),
                         family = quasipoisson(), x = T)
summary(mod_F_JntExtevent)
# Both not significant for female 

# Only Heat Days significant in the male model
# Both Heat Days and Cold Days are not significant in the female model.

#################### Testing of z-test statistics for Heat Days + Cold Days
# H0: B_m = B_f

# Test for Equivalence

(z_score_JntExtevent <- (coef(mod_M_JntExtevent)[-1] - coef(mod_F_JntExtevent)[-1])/sqrt(summary(mod_M_JntExtevent)$coefficients[-1, 2]^2 + summary(mod_F_JntExtevent)$coefficients[-1, 2]^2))

# Calc. the two-tailed p-value 
2 * (1 - pnorm(abs(z_score_JntExtevent)))
# # reject the null hypothesis, we conclude that B_m != B_f for Heat Days
# # cannot reject the null hypothesis, we cannot reject that B_m = B_f for Cold Days

############################# Joint Analysis - Summer Max Temp +  Heat Days ###########################

## Construct the poisson glms (Summer Temp + Heat Days)
set.seed(1211)
mod_M_JntHeatVar <- glm(data = gbd_male,
                        mort_cnt ~ Summer_max_temp + extreme_heat_cnt,
                        offset = log(pop_cnt),
                        family = quasipoisson, x = T)
summary(mod_M_JntHeatVar)
# All not significant for male (possible due to multicollinearity)
set.seed(1211)
mod_F_JntHeatVar <- glm(data = gbd_female,
                        mort_cnt ~ Summer_max_temp + extreme_heat_cnt, 
                        offset = log(pop_cnt),
                        family = quasipoisson(), x = T)
summary(mod_F_JntHeatVar)
# both Summer max temp and Heat Days significant for female (possible effected by multicollinearity)

# Both Summer max temperature and Heat Days count significant in the female model
# All the coefficients are not significant in the male model.
# This is possibly due to the issue of multicollinearity between the temperature data and extreme event counts
# but judging from the calculated t-statistics (larger abs value) and p-value (smaller value)
# The Extreme heat event counts is a better predictor for Male environmental heat and cold mortality rates
# As for the female data, we observe that the environmental heat and cold mortality rates are most influenced by heat-related covariates
# Indicating the vulnerability of Indian female to heat-related threats.

#################### Testing of z-test statistics for Summer max + Heat Days
# H0: B_m = B_f

# Test for Equivalence

(z_score_JntHeatVar <- (coef(mod_M_JntHeatVar)[-1] - coef(mod_F_JntHeatVar)[-1])/sqrt(summary(mod_M_JntHeatVar)$coefficients[-1, 2]^2 + summary(mod_F_JntHeatVar)$coefficients[-1, 2]^2))

# Calc. the two-tailed p-value 
2 * (1 - pnorm(abs(z_score_JntHeatVar)))
# # cannot reject the null hypothesis, we cannot reject that B_m = B_f for (Summer max temp and Heat Days count) 

############################# Joint Analysis - Summer Max Temp + Winter Min Temp + Heat Days + Cold Days ###########################

## Construct the poisson glms (Summer Temp + Winter Temp + Heat Days + Cold Days)
set.seed(1211)
mod_M_JntTempExtevent <- glm(data = gbd_male,
                             mort_cnt ~ Summer_max_temp + Winter_min_temp +
                               extreme_heat_cnt + extreme_cold_cnt,
                             offset = log(pop_cnt),
                             family = quasipoisson, x = T)
summary(mod_M_JntTempExtevent)
# All not significant for male (possible due to multicollinearity)
set.seed(1211)
mod_F_JntTempExtevent <- glm(data = gbd_female,
                             mort_cnt ~ Summer_max_temp + Winter_min_temp+
                               extreme_heat_cnt + extreme_cold_cnt, 
                             offset = log(pop_cnt),
                             family = quasipoisson(), x = T)
summary(mod_F_JntTempExtevent)
# Only Summer max temp and Heat Days significant for female (possible due to multicollinearity)

# Only Summer max temperature and Heat Days count significant in the female model
# All the coefficients are not significant in the male model.
# This is possibly due to the issue of multicollinearity between the temperature data and extreme event counts
# but judging from the calculated t-statistics (larger abs value) and p-value (smaller value)
# The Extreme event counts (heat and cold) are better predictors for Male environmental heat and cold mortality rates
# As for the female data, we observe that the environmental heat and cold mortality rates are most influenced by heat-related covariates
# Indicating the vulnerability of Indian female to heat-related threats.

#################### Testing of z-test statistics for Summer max + Winter min + Heat Days + Cold Days
# H0: B_m = B_f

# Test for Equivalence

(z_score_JntTempExtevent <- (coef(mod_M_JntTempExtevent)[-1] - coef(mod_F_JntTempExtevent)[-1])/sqrt(summary(mod_M_JntTempExtevent)$coefficients[-1, 2]^2 + summary(mod_F_JntTempExtevent)$coefficients[-1, 2]^2))

# Calc. the two-tailed p-value 
2 * (1 - pnorm(abs(z_score_JntTempExtevent)))
# # cannot reject the null hypothesis, we cannot reject that B_m = B_f for All 
# (Summer max temp, Winter min temp, Heat day count, Cold day Count) 

