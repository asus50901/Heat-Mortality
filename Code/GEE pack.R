# GEE pack 
pkgs <- c("tidyverse", 
          "ggthemes", "patchwork",
          "nlme", "geepack")

invisible(lapply(pkgs, library, character.only = T))


################### Fit the models of AR(1) error structure #######################

# <step 1> Calculate the log(mort_cnt/pop_cnt)
# <step 2> construct the models formulas 
# <step 3> fit all the models with ar 1 error structure
# <step 4> calculate all the QAIC values
# <step 5> extract all the coefficient values, the 95% CI and the hypothesis testing for gender equality
# <step 6> Draw all the observed VS Fitted plots

## <step 1> create the lag 1 term of mortality rate
gbd_male_AR1 <- gbd_male %>% 
  dplyr::mutate(log_mort_RT = log((mort_cnt/pop_cnt))) 

gbd_female_AR1 <- gbd_female %>% 
  dplyr::mutate(log_mort_RT = log((mort_cnt/pop_cnt))) 

## <step 2> construct the models formulas with the offset and the lag 1 term

variable_list <- names(gbd_male)[5:10]
# Create an empty list to store the formula objects
formula_list <- list()

# Iterate over the variables in variable_list
for (variable in variable_list) {
  # Create a formula object for each variable
  formula_list[[variable]] <- as.formula(paste0("mort_cnt ~ ", variable, "+ offset(log(pop_cnt))"))
}

names(formula_list)[5:6] <- c("Heat Day Counts", "Cold Day Counts")

##  <step 3> fit all the models

AR1_model_results <- list()

# Loop over the list of formulas
for (i in seq_along(formula_list)) {
  set.seed(1211)
  
  # Fit a glm model for each formula
  M_model <- geepack::geeglm(formula_list[[i]],
                             data = gbd_male_AR1,
                             id = Year,
                             corstr = "ar1",
                             family = poisson)
  
  F_model <- geepack::geeglm(formula_list[[i]],
                             data = gbd_female_AR1,
                             id = Year,
                             corstr = "ar1",
                             family = poisson)
  
  # Store the model results in the list
  AR1_model_results[["Male Models"]][[i]] <- M_model
  AR1_model_results[["Female Models"]][[i]] <- F_model
}

names(AR1_model_results[[1]]) <- names(formula_list)
names(AR1_model_results[[2]]) <- names(formula_list)

# Calculate the equal gender differences z-score and p-value
male_coef_store <- data.frame()
female_coef_store <- data.frame()
z_score_store <- c()
pvalue_store <- c()

for(i in seq_along(formula_list)){
  aa <- summary(AR1_model_results[["Male Models"]][[i]])$coefficients %>% 
    as.data.frame()
  
  lower_CI <- summary(AR1_model_results[["Male Models"]][[i]])$coefficients[2, 1] - 
    1.96*summary(AR1_model_results[["Male Models"]][[i]])$coefficients[2, 2] %>% 
    as.data.frame()
  
  upper_CI <- summary(AR1_model_results[["Male Models"]][[i]])$coefficients[2, 1] + 
    1.96*summary(AR1_model_results[["Male Models"]][[i]])$coefficients[2, 2] %>% 
    as.data.frame()
  
  tt <- cbind(aa[-1, ], lower_CI, upper_CI) # Male model coefficients
  
  aa <- summary(AR1_model_results[["Female Models"]][[i]])$coefficients %>% 
    as.data.frame()
  lower_CI_F <- summary(AR1_model_results[["Female Models"]][[i]])$coefficients[2, 1] - 
    1.96*summary(AR1_model_results[["Female Models"]][[i]])$coefficients[2, 2] %>% 
    as.data.frame()
  
  upper_CI_F <- summary(AR1_model_results[["Female Models"]][[i]])$coefficients[2, 1] + 
    1.96*summary(AR1_model_results[["Female Models"]][[i]])$coefficients[2, 2] %>% 
    as.data.frame()
  
  zz <- cbind(aa[-1, ], lower_CI_F, upper_CI_F) # Female model coefficients
  
  male_coef_store <- rbind(male_coef_store, tt)
  female_coef_store <- rbind(female_coef_store, zz)
  
  tmp_zscore <- (coef(AR1_model_results[["Male Models"]][[i]])[-1] - coef(AR1_model_results[["Female Models"]][[i]])[-1])/sqrt(summary(AR1_model_results[["Male Models"]][[i]])$coefficients[-1, 2]^2 + summary(AR1_model_results[["Female Models"]][[i]])$coefficients[-1, 2]^2)
  
  z_score_store[i] <- tmp_zscore
  
  # Calc. the two-tailed p-value 
  tmp_pvalue <- 2 * (1 - pnorm(abs(tmp_zscore)))
  pvalue_store[i] <- tmp_pvalue
}

# store the coefficients
AR1_model_results[["Coefficients"]][["Male"]] <- male_coef_store
AR1_model_results[["Coefficients"]][["Female"]] <- female_coef_store

colnames(AR1_model_results[["Coefficients"]][["Male"]])[5:6] <- c("Lower CI", "Upper CI")
colnames(AR1_model_results[["Coefficients"]][["Female"]])[5:6] <- c("Lower CI", "Upper CI")

# Store the hypothesis testing results
AR1_model_results[["Test for Equal Gender-Difference"]] <- data.frame(z_score = z_score_store,
                                                                      p_value = pvalue_store)
rownames(AR1_model_results[["Test for Equal Gender-Difference"]]) <- names(formula_list)


# Calculate the QIC # something specific for the GEE models
get_QIC <- function(model){
  QIC <- geepack::QIC(model)
  tmp <- QIC[1]
  return(tmp)
}

AR1_model_results[["QIC"]] <- cbind(lapply(AR1_model_results[["Male Models"]], get_QIC) %>% unlist, 
                                     lapply(AR1_model_results[["Female Models"]], get_QIC) %>% unlist)
colnames(AR1_model_results[["QIC"]]) <- c("Male", "Female")

################################# AR(1) Observed VS Fitted Graph #################################

# a function to do the plotting 
plot_obsVsFitted_gee <- function(model, data, male){
  # Create data frame for plotting
  plot_data <- data.frame(
    Observed = data$mort_cnt, # (data$mort_cnt/data$pop_cnt)*10^5,
    Fitted = model$fitted.values # (model$fitted.values/data$pop_cnt)*10^5
  )
  
  # Create ggplot
  if(male == T){
    ggplot(plot_data, aes(y = Fitted, x = Observed)) +
      geom_point() +
      geom_abline(slope = 1, intercept = 0, color = "red", linetype = "dashed") +
      labs(y = "Fitted values", x = "Observed values",
           title = "Observed vs. Fitted Plot") + 
      scale_y_continuous(limits = c(6000, 10000)) + 
      scale_x_continuous(limits = c(6000, 10000)) +
      theme_bw() +
      theme(panel.grid = element_blank(),
            axis.line = element_blank(),
            title = element_text(size = 12, face = "bold"),
            axis.title.y = element_text(size = 12, face = "bold"),
            axis.ticks = element_blank(),
            axis.text.x = element_text(size = 12, face = "bold"),
            axis.text.y = element_text(size = 12, face = "bold"))
  } else{
    ggplot(plot_data, aes(y = Fitted, x = Observed)) +
      geom_point() +
      geom_abline(slope = 1, intercept = 0, color = "red", linetype = "dashed") +
      labs(y = "Fitted values", x = "Observed values",
           title = "Observed vs. Fitted Plot") + 
      scale_y_continuous(limits =c(2000, 5000)) + 
      scale_x_continuous(limits = c(2000, 5000)) +
      theme_bw() +
      theme(panel.grid = element_blank(),
            axis.line = element_blank(),
            title = element_text(size = 12, face = "bold"),
            axis.title.y = element_text(size = 12, face = "bold"),
            axis.ticks = element_blank(),
            axis.text.x = element_text(size = 12, face = "bold"),
            axis.text.y = element_text(size = 12, face = "bold"))
  }
  
}

####### Save the plots
# SmaxT
plot_obsVsFitted_gee(model = AR1_model_results[["Male Models"]][[1]],
                     data = gbd_male_AR1, male = T) 
ggsave("Image/Reviewer/ObsFitted/GEE_M_AR1_SMaxT.jpeg")


plot_obsVsFitted_gee(model = AR1_model_results[["Female Models"]][[1]],
                     data = gbd_female_AR1, male = F)
ggsave("Image/Reviewer/ObsFitted/GEE_F_AR1_SMaxT.jpeg")


# SMeanT
plot_obsVsFitted_gee(model = AR1_model_results[["Male Models"]][[2]],
                     data = gbd_male_AR1, male = T)
ggsave("Image/Reviewer/ObsFitted/GEE_M_AR1_SMeanT.jpeg")


plot_obsVsFitted_gee(model = AR1_model_results[["Female Models"]][[2]],
                     data = gbd_female_AR1, male = F)
ggsave("Image/Reviewer/ObsFitted/GEE_F_AR1_SMeanT.jpeg")


# WMinT
plot_obsVsFitted_gee(model = AR1_model_results[["Male Models"]][[3]],
                     data = gbd_male_AR1, male = T)
ggsave("Image/Reviewer/ObsFitted/GEE_M_AR1_WMinT.jpeg")


plot_obsVsFitted_gee(model = AR1_model_results[["Female Models"]][[3]],
                     data = gbd_female_AR1, male = F)
ggsave("Image/Reviewer/ObsFitted/GEE_F_AR1_WMinT.jpeg")


# WMeanT
plot_obsVsFitted_gee(model = AR1_model_results[["Male Models"]][[4]],
                     data = gbd_male_AR1, male = T)
ggsave("Image/Reviewer/ObsFitted/GEE_M_AR1_WMeanT.jpeg")


plot_obsVsFitted_gee(model = AR1_model_results[["Female Models"]][[4]],
                     data = gbd_female_AR1, male = F)
ggsave("Image/Reviewer/ObsFitted/GEE_F_AR1_WMeanT.jpeg")


# Heat Day
plot_obsVsFitted_gee(model = AR1_model_results[["Male Models"]][[5]],
                     data = gbd_male_AR1, male = T)
ggsave("Image/Reviewer/ObsFitted/GEE_M_AR1_ExHeatCnt.jpeg")



plot_obsVsFitted_gee(model = AR1_model_results[["Female Models"]][[5]],
                     data = gbd_female_AR1, male = F)
ggsave("Image/Reviewer/ObsFitted/GEE_F_AR1_ExHeatCnt.jpeg")


# ExColdCnt
plot_obsVsFitted_gee(model = AR1_model_results[["Male Models"]][[6]],
                     data = gbd_male_AR1, male = T)
ggsave("Image/Reviewer/ObsFitted/GEE_M_AR1_ExColdCnt.jpeg")


plot_obsVsFitted_gee(model = AR1_model_results[["Female Models"]][[6]],
                     data = gbd_female_AR1, male = F)
ggsave("Image/Reviewer/ObsFitted/GEE_F_AR1_ExColdCnt.jpeg")

