# This is the R script to perform the visualizations of India All-cause  mortality Rate VS Temperature data

pkgs <- c("tidyverse", "dplyr", "ggplot2", "xlsx", 
          "ggthemes", "patchwork", "corrplot")
invisible(lapply(pkgs, library, character.only = T))

## Read in the data
gbd_both <- read_csv("gbd_both.csv") %>% as.data.frame()
gbd_male <- read_csv("gbd_male.csv") %>% as.data.frame()
gbd_female <- read_csv("gbd_female.csv") %>% as.data.frame()

df_allcause <- read_csv("GBD Data/IHME-GBD_AllcauseMortRT_India.csv") %>% 
  as.data.frame()


#################### Tidy the All Cause Mort RT ########################

df_allcause <- df_allcause %>% 
  dplyr::select(-c("measure", "location", "age", "cause",
                   "upper", "lower", "metric")) %>% 
  dplyr::rename(mort_RT = val, Year = year)

## Both
# tmp df for left joining the temperature data
tmp <- gbd_both %>% dplyr::select(-c("mort_cnt", "mort_RT"))
both_allcause <- df_allcause %>% 
  dplyr::filter(sex == "Both") %>% 
  dplyr::select(-c("sex")) %>% 
  left_join(tmp, by = "Year") %>% 
  dplyr::arrange(Year)

## Male
tmp <- gbd_male %>% dplyr::select(-c("mort_cnt", "mort_RT"))
male_allcause <- df_allcause %>% 
  dplyr::filter(sex == "Male") %>% 
  dplyr::select(-c("sex")) %>% 
  left_join(tmp, by = "Year") %>% 
  dplyr::arrange(Year)

## Female
tmp <- gbd_female %>% dplyr::select(-c("mort_cnt", "mort_RT"))
female_allcause <- df_allcause %>% 
  dplyr::filter(sex == "Female") %>% 
  dplyr::select(-c("sex")) %>% 
  left_join(tmp, by = "Year") %>% 
  dplyr::arrange(Year)

#################### Correlation plot for All-cause Mortality Data ############################
## Male
corrplot(corr = cor(male_allcause[, c(2, 4:7)],
                    use = "complete.obs",
                    method = "spearman"),
         method = "square", type = "lower",
         addCoef.col = "black", diag = F,
         tl.srt = 0, tl.col = "black", tl.offset = 0.9,
         title = "Spearman Correlation for GBD Male All Cause Data", mar=c(0,0,3,0))


## Female
corrplot(corr = cor(female_allcause[, c(2, 4:7)],
                    use = "complete.obs",
                    method = "spearman"),
         method = "square", type = "lower",
         addCoef.col = "black", diag = F,
         tl.srt = 0, tl.col = "black", tl.offset = 0.9,
         title = "Spearman Correlation for GBD Female All Cause Data", mar=c(0,0,3,0))

# We choose Spearman correlation, bcs it doesn't require normality assumption and is robust to outliers
# Pearson correlation assumes normality assumption

################### Time Smoothed Line ############################

## Male 
ggplot(data = male_allcause,
       aes(y = mort_RT, x = Year)) +
  geom_point() + geom_smooth(se = F) + 
  labs(x = "Winter Min Temperature",
       y = "Male All Cause Mortality Rate",
       title = "Male All Cause Mortality Rate Trend",
       subtitle = "Source: GBD Indian Male All Cause Mortality") + 
  theme_bw()
#ggsave("image/M_AllCause_Year.jpeg")

## female 
ggplot(data = female_allcause,
       aes(y = mort_RT, x = Year)) +
  geom_point() + geom_smooth(se = F) + 
  labs(x = "Winter Min Temperature",
       y = "Female All Cause Mortality Rate",
       title = "Female All Cause Mortality Rate Trend",
       subtitle = "Source: GBD Indian Female All Cause Mortality") + 
  theme_bw()
#ggsave("image/F_AllCause_Year.jpeg")

# Both gender on thhe same plot
ggplot(data = female_allcause, aes(x = Year, y = mort_RT))+
  geom_line(aes(color = "Female All Cause Mortality Rate"), linewidth = 1) +
  geom_line(data = male_allcause, 
            aes(y = mort_RT,
                color = "Male All Cause Mortality Rate"), linewidth = 1) +
  scale_y_continuous(sec.axis = sec_axis(~.,
                                         name="All Cause Mortality Rate")) +
  labs(x = "Year",
       y = "All Cause Mortality Rate",
       color = "") +
  scale_color_manual(values = c("Female All Cause Mortality Rate" = "tomato",
                                "Male All Cause Mortality Rate" = "cornflowerblue")) +
  theme_bw() +
  theme(
    axis.title.y = element_text(color = "gray30"),
    axis.title.y.right = element_text(color = "grey30"),
    legend.position = "top"
  ) 
#ggsave("image/tmp/AllCause_rate.jpeg", width = 6, height = 4)

################### SMeanT Smoothed Line ############################

## Male 
ggplot(data = male_allcause,
       aes(y = mort_RT, x = Summer_mean_temp)) +
  geom_point() + geom_smooth(se = F) + 
  labs(x = "Summer Mean Temperature",
       y = "Male All Cause Mortality Rate",
       title = "Male All Cause Mortality Rate VS Summer Mean Temperature",
       subtitle = "Source: GBD Indian Male All Cause Mortality") + 
  theme_bw()
#ggsave("image/M_AllCause_SMeanT.jpeg")

## female 
ggplot(data = female_allcause,
       aes(y = mort_RT, x = Summer_mean_temp)) +
  geom_point() + geom_smooth(se = F) + 
  labs(x = "Summer Mean Temperature",
       y = "Female All Cause Mortality Rate",
       title = "Female All Cause Mortality Rate VS Summer Mean Temperature",
       subtitle = "Source: GBD Indian Female All Cause Mortality") + 
  theme_bw()
#ggsave("image/F_AllCause_SMeanT.jpeg")


################### SMaxT Smoothed Line ############################

## Male 
ggplot(data = male_allcause,
       aes(y = mort_RT, x = Summer_max_temp)) +
  geom_point() + geom_smooth(se = F) + 
  labs(x = "Summer Max Temperature",
       y = "Male All Cause Mortality Rate",
       title = "Male All Cause Mortality Rate VS Summer Max Temperature",
       subtitle = "Source: GBD Indian Male All Cause Mortality") + 
  theme_bw()
#ggsave("image/M_AllCause_SMaxT.jpeg")

## female 
ggplot(data = female_allcause,
       aes(y = mort_RT, x = Summer_max_temp)) +
  geom_point() + geom_smooth(se = F) + 
  labs(x = "Summer Max Temperature",
       y = "Female All Cause Mortality Rate",
       title = "Female All Cause Mortality Rate VS Summer Max Temperature",
       subtitle = "Source: GBD Indian Female All Cause Mortality") + 
  theme_bw()
#ggsave("image/F_AllCause_SMaxT.jpeg")

################### WMeanT Smoothed Line ############################

## Male 
ggplot(data = male_allcause,
       aes(y = mort_RT, x = Winter_mean_temp)) +
  geom_point() + geom_smooth(se = F) + 
  labs(x = "Winter Mean Temperature",
       y = "Male All Cause Mortality Rate",
       title = "Male All Cause Mortality Rate VS Winter Mean Temperature",
       subtitle = "Source: GBD Indian Male All Cause Mortality") + 
  theme_bw()
#ggsave("image/M_AllCause_WMeanT.jpeg")

## female 
ggplot(data = female_allcause,
       aes(y = mort_RT, x = Winter_mean_temp)) +
  geom_point() + geom_smooth(se = F) + 
  labs(x = "Winter Mean Temperature",
       y = "Female All Cause Mortality Rate",
       title = "Female All Cause Mortality Rate VS Winter Mean Temperature",
       subtitle = "Source: GBD Indian Female All Cause Mortality") + 
  theme_bw()
#ggsave("image/F_AllCause_WMeanT.jpeg")

################### WMinT Smoothed Line ############################

## Male 
ggplot(data = male_allcause,
       aes(y = mort_RT, x = Winter_min_temp)) +
  geom_point() + geom_smooth(se = F) + 
  labs(x = "Winter Min Temperature",
       y = "Male All Cause Mortality Rate",
       title = "Male All Cause Mortality Rate VS Winter Min Temperature",
       subtitle = "Source: GBD Indian Male All Cause Mortality") + 
  theme_bw()
#ggsave("image/M_AllCause_WMinT.jpeg")

## female 
ggplot(data = female_allcause,
       aes(y = mort_RT, x = Winter_min_temp)) +
  geom_point() + geom_smooth(se = F) + 
  labs(x = "Winter Min Temperature",
       y = "Female All Cause Mortality Rate",
       title = "Female All Cause Mortality Rate VS Winter Min Temperature",
       subtitle = "Source: GBD Indian Female All Cause Mortality") + 
  theme_bw()
#ggsave("image/F_AllCause_WMinT.jpeg")
