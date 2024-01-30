# This is the script to read in all the GBD pop est data and tidy


#################### Set up ########################

pkgs <- c("tidyverse", "foreign", "mice", "segmented", "bcp",
          "corrplot")
invisible(lapply(pkgs, library, character.only = T))



##################### Mortality Data Tidy ######################

# Loop to Read and Separate the Mortality Data
# file directory
year <- c(1960:2019)
file_dir <- paste0("GBD Data/GBD Population Est/IHME_GBD_2019_POP_", year, "_Y2020M10D15.CSV")

# some obj. to save the results
Fpop <- data.frame(); Mpop <- data.frame(); Bothpop <- data.frame()

for(i in 1:length(year)){
  df_tmp <- read_csv(file_dir[i])
  
  df_tmp <- df_tmp %>% filter(location_name == "India",
                               age_group_name == "All Ages") %>% 
    dplyr::select(c("year_id", "measure_name", "metric_name",
                    "sex_name", "age_group_name", "val")) %>% 
    dplyr::rename(year = year_id, measure = measure_name, metric = metric_name,
                  sex = sex_name, age = age_group_name, pop_cnt = val)
  
  Fpop <- rbind(Fpop, df_tmp[df_tmp$sex == "female", ])
  Mpop <- rbind(Mpop, df_tmp[df_tmp$sex == "male", ])
  Bothpop <- rbind(Bothpop, df_tmp[df_tmp$sex == "both", ])
}

# Fpop
# Mpop
# Bothpop

# write_csv(Fpop, "Female GBD Pop.csv")
# write_csv(Mpop, "Male GBD Pop.csv")
# write_csv(Bothpop, "Both Sex GBD Pop.csv")

##################### Manual Checking of Mortality rate ###########################

# Check the GBD mortality rates align with the 
# calculated mortality rate with the GBD pop est. and GBD mortality counts

# read in GBD population estimates
Fpop <- read_csv("GBD Data/GBD Population Est/Female GBD Pop.csv")
Mpop <- read_csv("GBD Data/GBD Population Est/Male GBD Pop.csv")
Bothpop <- read.csv("GBD Data/GBD Population Est/Both Sex GBD Pop.csv")
  
# tidy a data with mortality counts and GBD population estimates
# read in the GBD mortality counts 
# read in GBD data of mortality counts
df_gbd <- read_csv("GBD Data/IHME-GBD_2019_DATA-dee311ab-1.csv") # mortality counts
df_gbd <- df_gbd %>% dplyr::select(-ends_with("_id")) %>% 
  rename(measure = measure_name,
         sex = sex_name,
         cause = cause_name,
         metric = metric_name,
         Year = year, 
         mort_cnt = val) %>% 
  dplyr::select(-c("location_name", "age_name"))

#str(df_gbd)

a <- Bothpop %>% rename(Year = year) %>% dplyr::select(c("Year", "pop_cnt"))
gbd_both <- df_gbd %>% dplyr::filter(sex == "Both") %>% left_join(a, by = "Year")

a <- Mpop %>% rename(Year = year) %>% dplyr::select(c("Year", "pop_cnt"))
gbd_male <- df_gbd %>% dplyr::filter(sex == "Male") %>% left_join(a, by = "Year")

a <- Fpop %>% rename(Year = year) %>% dplyr::select(c("Year", "pop_cnt"))
gbd_female <- df_gbd %>% dplyr::filter(sex == "Female") %>% left_join(a, by = "Year")

## Manually calc the mortality rates 
#  def: deaths per 100,000 pop

gbd_both <- gbd_both %>% dplyr::mutate(mort_RT = (mort_cnt/pop_cnt)*(10^5)) %>% arrange(Year)
gbd_male <- gbd_male %>% dplyr::mutate(mort_RT = (mort_cnt/pop_cnt)*(10^5)) %>% arrange(Year)
gbd_female <- gbd_female %>% dplyr::mutate(mort_RT = (mort_cnt/pop_cnt)*(10^5)) %>% arrange(Year)

# read in the GBD data of mortality rates (Environmental heat and cold exposure deaths)
df_gbd_mortRT <- read_csv("GBD Data/GBD_EnvHeatColdMortRate.csv")

bothrate <- df_gbd_mortRT %>% 
  filter(sex == "Both") %>% 
  dplyr::select(c("year", "val")) %>% 
  dplyr::rename(Year = year, mort_RT = val) %>% 
  arrange(Year)

Mrate <- df_gbd_mortRT %>% 
  filter(sex == "Male") %>% 
  dplyr::select(c("year", "val")) %>% 
  dplyr::rename(Year = year, mort_RT = val)%>% 
  arrange(Year)

Frate <- df_gbd_mortRT %>% 
  filter(sex == "Female") %>% 
  dplyr::select(c("year", "val")) %>% 
  dplyr::rename(Year = year, mort_RT = val)%>% 
  arrange(Year)

# test if there is a difference
sum(abs(gbd_both$mort_RT - bothrate$mort_RT)) # for both
sum(abs(gbd_male$mort_RT - Mrate$mort_RT)) # for male 
sum(abs(gbd_female$mort_RT - Frate$mort_RT)) # for female


# There is am extremely small difference in the mortality rates
# proceed our analysis using the manually calculated numbers


## Visualization with the difference 
Mrate <- Mrate %>% dplyr::rename(GBD_mort_RT = mort_RT)
Frate <- Frate %>% dplyr::rename(GBD_mort_RT = mort_RT)

t_male <- gbd_male %>% 
  left_join(Mrate, by = "Year") %>% 
  dplyr::mutate(difference = mort_RT - GBD_mort_RT)

t_female <- gbd_female %>% 
  left_join(Frate, by = "Year") %>% 
  dplyr::mutate(difference = mort_RT - GBD_mort_RT)

## male
ggplot(data = t_male, aes(x = Year, y = difference))+
  geom_point() + 
  geom_hline(yintercept = 0, color = "royalblue",
                            linetype = 2, linewidth = 1) +
  labs(y = "Difference", 
       title = "Difference of Manual Calculated Mortality Rates - GBD Provided Mortality Rates",
       subtitle = "GBD Indian Male Environmental Heat and Cold Exposure Mortality Rates (Unit: Deaths per 100,000 people)
       Reference line at 0") +
  theme_bw()
#ggsave("image/male_calcDiff.jpeg")

## female
ggplot(data = t_female, aes(x = Year, y = difference))+
  geom_point() + 
  geom_hline(yintercept = 0, color = "royalblue",
             linetype = 2, linewidth = 1) +
  labs(y = "Difference", 
       title = "Difference of Manual Calculated Mortality Rates - GBD Provided Mortality Rates",
       subtitle = "GBD Indian Female Environmental Heat and Cold Exposure Mortality Rates (Unit: Deaths per 100,000 people)
       Reference line at 0") +
  theme_bw()
#ggsave("image/female_calcDiff.jpeg")

####################### Mortality Data EDA  #############################

# Step 1. Draw sex-specific mortality counts, respectively (keep raw units)
# Step 2. Draw standardized sex-specific mortality counts on the same plot

# Step 3. Draw sex-specific mortality rates, respectively (keep raw units)
# Step 4. Draw standardized sex-specific mortality rates on the same plot

## Step 1. Draw sex-specific mortality counts, respectively (keep raw units)

# Male
ggplot(data = gbd_male, aes(x = Year, y = mort_cnt))+
  geom_line(color = "cornflowerblue", linewidth = 1) +
  labs(y = "Male Env. Heat and Cold Exposure Mortality Counts",
       title = "Indian Male Environmental Heat and Cold Exposure Mortality Counts",
       subtitle = "Source: Global Burden of Disease") + theme_bw()
#ggsave("image/Male_Mort_Cnt (Raw).jpeg")

# Female
ggplot(data = gbd_female, aes(x = Year, y = mort_cnt))+
  geom_line(color = "tomato", linewidth = 1) +
  labs(y = "Female Env. Heat and Cold Exposure Mortality Counts",
       title = "Indian Female Environmental Heat and Cold Exposure Mortality Counts",
       subtitle = "Source: Global Burden of Disease") + theme_bw()
#ggsave("image/Female_Mort_Cnt (Raw).jpeg")

# Male and female mrotality counts on the same plot (raw units)
ggplot(data = gbd_female, aes(x = Year, y = mort_cnt))+
  geom_line(aes(color = "Female Mortality Count"), linewidth = 1) +
  geom_line(data = gbd_male, 
            aes(y = mort_cnt,
                color = "Male Mortality Count"), linewidth = 1) +
  scale_y_continuous(sec.axis = sec_axis(~.,
                                         name="Environmetal Heat and Cold Exposure Mortality Counts")) +
  labs(x = "Year",
       y = "Environmetal Heat and Cold Exposure Mortality Counts",
       color = "",
       title = "Female Mortality Counts VS Male Mortality Counts",
       subtitle = "1990 - 2019 GBD Indian Environmetal Heat and Cold Exposure Mortality Data") +
  scale_color_manual(values = c("Female Mortality Count" = "tomato",
                                "Male Mortality Count" = "cornflowerblue")) +
  theme_bw() +
  theme(
    axis.title.y = element_text(color = "gray30"),
    axis.title.y.right = element_text(color = "grey30"),
    legend.position = "top"
  ) 
#ggsave("image/Mort_Cnt (Raw).jpeg")


# Step 2. Draw standardized sex-specific mortality counts on the same plot
male_scale <- gbd_male %>% 
  mutate_if(is.numeric, ~(scale(., scale = T))) %>% 
  dplyr::mutate(Year = c(1990:2019))


female_scale <- gbd_female %>% 
  mutate_if(is.numeric, ~(scale(., scale = T)))%>% 
  dplyr::mutate(Year = c(1990:2019))


ggplot(data = female_scale, aes(x = Year, y = mort_cnt))+
  geom_line(aes(color = "Female Mortality Count"), linewidth = 1) +
  geom_line(data = male_scale, 
            aes(y = mort_cnt,
                color = "Male Mortality Count"), linewidth = 1) +
  scale_y_continuous(sec.axis = sec_axis(~.,
                        name="Male Environmetal Heat and Cold Exposure Mortality Counts (Standardized)")) +
  labs(x = "Year",
       y = "Female Environmetal Heat and Cold Exposure Mortality Counts (Standardized)",
       color = "",
       title = "Female Mortality Counts VS Male Mortality Counts",
       subtitle = "1990 - 2019 GBD Indian Environmetal Heat and Cold Exposure Mortality Data") +
  scale_color_manual(values = c("Female Mortality Count" = "tomato",
                                "Male Mortality Count" = "cornflowerblue")) +
  theme_bw() +
  theme(
    axis.title.y = element_text(color = "gray30"),
    axis.title.y.right = element_text(color = "grey30"),
    legend.position = "top"
  ) 
#ggsave("image/Mort_Cnt (standardized).jpeg")

## Step 3. Draw sex-specific mortality rates, respectively (keep raw units)

# Male Rates
ggplot(data = gbd_male, aes(x = Year, y = mort_RT))+
  geom_line(color = "cornflowerblue", linewidth = 1) +
  labs(y = "Male Environmental Heat and Cold Exposure Mortality Rate",
       title = "Indian Male Environmental Heat and Cold Exposure Mortality Rate",
       subtitle = "Source: Global Burden of Disease (Units: Deaths per 100,000 people)") + theme_bw()
#ggsave("image/Male_Mort_RT (Raw).jpeg")

# Female Rates
ggplot(data = gbd_female, aes(x = Year, y = mort_RT))+
  geom_line(color = "tomato", linewidth = 1)  +
  labs(y = "Female Env. Heat and Cold Exposure Mortality Rate",
       title = "Indian Female Environmental Heat and Cold Exposure Mortality Rate",
       subtitle = "Source: Global Burden of Disease (Units: Deaths per 100,000 people)") + theme_bw()
#ggsave("image/Female_Mort_RT (Raw).jpeg")

# Male and female mortality rates on the same plot (raw units)
ggplot(data = gbd_female, aes(x = Year, y = mort_RT))+
  geom_line(aes(color = "Female Mortality Rate"), linewidth = 1) +
  geom_line(data = gbd_male, 
            aes(y = mort_RT,
                color = "Male Mortality Rate"), linewidth = 1) +
  scale_y_continuous(sec.axis = sec_axis(~.,
                                         name="Environmental Heat and Cold Exposure Mortality Rate")) +
  labs(x = "Year",
       y = "Environmental Heat and Cold Exposure Mortality Rate",
       color = "",
       title = "Female Mortality Rate VS Male Mortality Rate (Units: Deaths per 100,000 people)",
       subtitle = "1990 - 2019 GBD Indian Environmetal Heat and Cold Exposure Mortality Data") +
  scale_color_manual(values = c("Female Mortality Rate" = "tomato",
                                "Male Mortality Rate" = "cornflowerblue")) +
  theme_bw() +
  theme(
    axis.title.y = element_text(color = "gray30"),
    axis.title.y.right = element_text(color = "grey30"),
    legend.position = "top"
  ) 
#ggsave("image/Mort_RT (Raw).jpeg")

# Step 4. Draw standardized sex-specific mortality counts on the same plot
male_scale <- gbd_male %>% 
  mutate_if(is.numeric, ~(scale(., scale = T))) %>% 
  dplyr::mutate(Year = c(1990:2019))


female_scale <- gbd_female %>% 
  mutate_if(is.numeric, ~(scale(., scale = T)))%>% 
  dplyr::mutate(Year = c(1990:2019))


ggplot(data = female_scale, aes(x = Year, y = mort_RT))+
  geom_line(aes(color = "Female Mortality Rate"), linewidth = 1) +
  geom_line(data = male_scale, 
            aes(y = mort_RT,
                color = "Male Mortality Rate"), linewidth = 1) +
  scale_y_continuous(sec.axis = sec_axis(~.,
                                         name="Male Environmetal Heat and Cold Exposure Mortality Rate (Standardized)")) +
  labs(x = "Year",
       y = "Female Environmetal Heat and Cold Exposure Mortality Rate (Standardized)",
       color = "",
       title = "Female Mortality Rate VS Male Mortality Rate",
       subtitle = "1990 - 2019 GBD Indian Environmetal Heat and Cold Exposure Mortality Data") +
  scale_color_manual(values = c("Female Mortality Rate" = "tomato",
                                "Male Mortality Rate" = "cornflowerblue")) +
  theme_bw() +
  theme(
    axis.title.y = element_text(color = "gray30"),
    axis.title.y.right = element_text(color = "grey30"),
    legend.position = "top"
  ) 
#ggsave("image/Mort_RT (standardized).jpeg")

# Quite concerning that the mortality rate of male keeps going down 
# but the female mortality rates are fluctuating within 0.55 to 0.75, with a sudden surge after 2004

###################################### Temperature Data Tidy ######################################

# read in the monthly tmax, tmin, tmean
df_tmax <- read_csv("monthly tmax.csv") %>% rename(Year = `...1`)
df_tmin <- read_csv("monthly tmin.csv") %>% rename(Year = `...1`)
df_tmean <- read_csv("monthly tmean.csv") %>% rename(Year = `...1`)

# Determine the best months for summer, best months for winter,'
# and also perform imputation for the missing tmean values for the year 2017 - 2019 (mice pkg)

# step 1. best months of Summer (a. Path plot of mar apr may jun tmean) (b. Path plot of mar apr may jun tmax)

## 3,4,5,6, 7 tmean
tmp_tmean <- df_tmean %>%
  dplyr::select(c(1, 4:8)) %>% 
  gather(key = "Month", value = "Mean T", 2:6) %>% 
  dplyr::mutate(Month = case_when(grepl("mar_", Month) ~ "March",
                                  grepl("apr_", Month) ~ "April",
                                  grepl("may_", Month) ~ "May",
                                  grepl("jul_", Month) ~ "July",
                                  T ~ "June"))
# tmax dataset
tmp_tmax <- df_tmax %>%
  dplyr::select(c(1, 4:8)) %>% 
  gather(key = "Month", value = "Max T", 2:6) %>% 
  dplyr::mutate(Month = case_when(grepl("mar_", Month) ~ "March",
                                  grepl("apr_", Month) ~ "April",
                                  grepl("may_", Month) ~ "May",
                                  grepl("jul_", Month) ~ "July",
                                  T ~ "June"))

ggplot(data = tmp_tmean, aes(x = Year, y = `Mean T`, color = Month))+
  geom_line(linewidth = 1) + 
  labs(y = "Monthly Mean Temperature",
       title = "Summer Monthly Mean Temperature Across 1990 to 2016",
       subtitle = "Source: IMD Grid-level Data") +
  scale_y_continuous(limits = c(min(tmp_tmean$`Mean T`) - 0.5, max(tmp_tmax$`Max T`) + 0.5)) + 
  theme_bw() +
  scale_color_brewer(palette = "Set2")
#ggsave("image/Determine Summer (Mean Temp).jpeg")

# March mean temperature is far from the other four months (4,5,6, 7)
# Note that July has the similar mean temperature trend as April

## 3, 4, 5, 6, 7 tmax
ggplot(data = tmp_tmax, aes(x = Year, y = `Max T`, color = Month))+
  geom_line(linewidth = 1) + 
  labs(y = "Monthly Max Temperature",
       title = "Summer Monthly Max Temperature Across 1990 to 2019",
       subtitle = "Source: IMD Grid-level Data") +
  theme_bw() +
  scale_y_continuous(limits = c(min(tmp_tmean$`Mean T`) - 0.5, max(tmp_tmax$`Max T`) + 0.5)) + 
  scale_color_brewer(palette = "Set2")
#ggsave("image/Determine Summer (Max Temp).jpeg")

# March max temperature is far from the other three months (4,5,6)
# However, the max temperature trend of March and July is not too different.

# In further analysis, the Summer mean temperature and max temperature should be calculated using the months (April, May, June, and July)
# We will still include July in the Summer months, because IMD climate reports claim to have heatwave days occur in July as well

#### step 2. best months of Winter 
# (a. Path plot of nov dec jan feb tmean) 
# (b. Path plot of nov dec jan feb tmin)

## 1, 2, 11, 12 tmean
tmp_tmean <- df_tmean %>%
  dplyr::select(c(1:3, 9, 10)) %>% 
  gather(key = "Month", value = "Mean T", 2:5) %>% 
  dplyr::mutate(Month = case_when(grepl("jan_", Month) ~ "January",
                                  grepl("feb_", Month) ~ "February",
                                  grepl("nov_", Month) ~ "November",
                                  T ~ "December"))

tmp_tmin <- df_tmin %>%
  dplyr::select(c(1:3, 9, 10)) %>% 
  gather(key = "Month", value = "Min T", 2:5) %>% 
  dplyr::mutate(Month = case_when(grepl("jan_", Month) ~ "January",
                                  grepl("feb_", Month) ~ "February",
                                  grepl("nov_", Month) ~ "November",
                                  T ~ "December"))

ggplot(data = tmp_tmean, aes(x = Year, y = `Mean T`, color = Month))+
  geom_line(linewidth = 1) + 
  labs(y = "Monthly Mean Temperature",
       title = "Winter Monthly Mean Temperature Across 1990 to 2016",
       subtitle = "Source: IMD Grid-level Data") +
  scale_y_continuous(limits = c(min(tmp_tmin$`Min T`) - 0.5, max(tmp_tmean$`Mean T`) + 0.5)) + 
  theme_bw() +
  scale_color_brewer(palette = "Set2")
#ggsave("image/Determine Winter (Mean Temp).jpeg")

# November mean temperature is far higher than the other three months (12, 1, 2)

##  1, 2, 11, 12 t min

ggplot(data = tmp_tmin, aes(x = Year, y = `Min T`, color = Month))+
  geom_line(linewidth = 1) + 
  labs(y = "Monthly Min Temperature",
       title = "Monthly Min Temperature Across 1990 to 2019",
       subtitle = "Source: IMD Grid-level Data") +
  scale_y_continuous(limits = c(min(tmp_tmin$`Min T`) - 0.5, max(tmp_tmean$`Mean T`) + 0.5)) + 
  theme_bw() +
  scale_color_brewer(palette = "Set2")
#ggsave("image/Determine Winter (Min Temp).jpeg")

# November min temperature is also far higher than the other three months (12, 1, 2)
# In further analysis, the Winter mean temperature and min temperature should be calculated using the months (December, January, and February)

########### Step 3. imputation for the missing tmean values for the year 2017 - 2019 (mice pkg)

# first build a big data set with all the mean, min, and max temperature
df_temp <- df_tmean %>% right_join(df_tmin, by = "Year") %>% left_join(df_tmax, by = "Year")

set.seed(1211)
df_imputed <- complete(mice(df_temp, m = 5, method = "rf"))
# df_imputed is the completed dataset with the missing values all imputed via the "Random Forest" method



############ Step 4. Calculate Summer mean (max) Temp, Winter mean (min) Temp

# For now, the Summer months are defined as months 4, 5, 6, 7 (discard march)
# For now, the Winter months are defined as months 12, 1, 2 (dsicard nov)

# calculation for max min and mean temperatures
df_temp_final <- df_imputed %>% 
  dplyr::select(-starts_with("mar_")) %>% 
  dplyr::select(-starts_with("nov_")) #%>% 
  # dplyr::rowwise() %>% 
  # dplyr::mutate(Summer_max_temp = max(c_across(starts_with(c("apr", "may", "jun", "jul")))),
  #               Winter_min_temp = min(c_across(starts_with(c("dec", "jan", "feb"))))) 
df_temp_final$Summer_max_temp <- rowMeans(dplyr::select(df_temp_final, apr_tmax, may_tmax, jun_tmax, jul_tmax))
df_temp_final$Winter_min_temp <- rowMeans(dplyr::select(df_temp_final, dec_tmin, jan_tmin, feb_tmin))

df_temp_final$Summer_mean_temp <- rowMeans(dplyr::select(df_temp_final, apr_tmean, may_tmean, jun_tmean, jul_tmean))
df_temp_final$Winter_mean_temp <- rowMeans(dplyr::select(df_temp_final, dec_tmean, jan_tmean, feb_tmean))

# delete the other uwanted columns
df_temp_final <- df_temp_final %>% 
  dplyr::select(starts_with(c("Year", "Summer", "Winter"))) %>% 
  as.data.frame()

# combine with the gbd mortality rate data
gbd_both <- gbd_both %>% 
  dplyr::select(c("Year", "mort_cnt", "pop_cnt", "mort_RT")) %>% 
  left_join(df_temp_final, by = "Year")%>% 
  as.data.frame()

gbd_male <- gbd_male %>% 
  dplyr::select(c("Year", "mort_cnt", "pop_cnt", "mort_RT")) %>% 
  left_join(df_temp_final, by = "Year")%>% 
  as.data.frame()

gbd_female <- gbd_female %>% 
  dplyr::select(c("Year", "mort_cnt", "pop_cnt", "mort_RT")) %>% 
  left_join(df_temp_final, by = "Year")%>% 
  as.data.frame()

############ Step 5. Read in the extreme heat and cold days counts and Create final analyzing dataset

df_hcDays <- read_csv("yearly extreme heatNcold count.csv") %>% 
  dplyr::rename(Year = `...1`) %>% as.data.frame()

gbd_both <- gbd_both %>% 
  left_join(df_hcDays, by = "Year") %>% 
  as.data.frame()

gbd_male <- gbd_male %>% 
  left_join(df_hcDays, by = "Year") %>% 
  as.data.frame()

gbd_female <- gbd_female %>% 
  left_join(df_hcDays, by = "Year") %>% 
  as.data.frame()

# Write CSV for the analytic datasets
write_csv(gbd_both, "gbd_both.csv")
write_csv(gbd_male, "gbd_male.csv")
write_csv(gbd_female, "gbd_female.csv")


############################## Temperature EDA - time series plot ###################################

# Summer Max Temp
ggplot(data = gbd_female, aes(x = Year, y = Summer_max_temp))+
  geom_line(color = "tomato", linewidth = 1) +
  labs(x = "Year",
       y = "Average Summer Months Max Temperatures",
       color = "") +
  theme_bw() +
  theme(
    axis.title.y = element_text(color = "gray30"),
    axis.title.y.right = element_text(color = "grey30"),
    legend.position = "top"
  ) 
#ggsave("image/tmp/S1/timeSeries_SmaxT.jpeg", width = 6, height = 4)

# Summer Mean Temp

ggplot(data = gbd_female, aes(x = Year, y = Summer_mean_temp))+
  geom_line(color = "orange", linewidth = 1) +
  labs(x = "Year",
       y = "Average Summer Months Mean Temperatures",
       color = "") +
  theme_bw() +
  theme(
    axis.title.y = element_text(color = "gray30"),
    axis.title.y.right = element_text(color = "grey30"),
    legend.position = "top"
  ) 
#ggsave("image/tmp/S1/timeSeries_SmeanT.jpeg", width = 6, height = 4)

# Winter Min Temp

ggplot(data = gbd_female, aes(x = Year, y = Winter_min_temp))+
  geom_line(color = "cornflowerblue", linewidth = 1) +
  labs(x = "Year",
       y = "Average Winter Month Min Temperatures",
       color = "") +
  theme_bw() +
  theme(
    axis.title.y = element_text(color = "gray30"),
    axis.title.y.right = element_text(color = "grey30"),
    legend.position = "top"
  ) 
#ggsave("image/tmp/S1/timeSeries_WMinT.jpeg", width = 6, height = 4)

# Winter Mean Temp

ggplot(data = gbd_female, aes(x = Year, y = Winter_mean_temp))+
  geom_line(color = "dodgerblue", linewidth = 1) +
  labs(x = "Year",
       y = "Average Winter Month Mean Temperatures",
       color = "") +
  theme_bw() +
  theme(
    axis.title.y = element_text(color = "gray30"),
    axis.title.y.right = element_text(color = "grey30"),
    legend.position = "top"
  ) 
#ggsave("image/tmp/S1/timeSeries_WMeanT.jpeg", width = 6, height = 4)

# Heat Days Counts
 
ggplot(data = gbd_female, aes(x = Year, y = extreme_heat_cnt))+
  geom_line(color = "red", linewidth = 1) +
  labs(x = "Year",
       y = "Average Heat Days Counts",
       color = "") +
  theme_bw() +
  theme(
    axis.title.y = element_text(color = "gray30"),
    axis.title.y.right = element_text(color = "grey30"),
    legend.position = "top"
  ) 
#ggsave("image/tmp/S1/timeSeries_HeatDaysCnt.jpeg", width = 6, height = 4)

# Cold Days Counts
 
ggplot(data = gbd_female, aes(x = Year, y = extreme_cold_cnt))+
  geom_line(color = "royalblue", linewidth = 1) +
  labs(x = "Year",
       y = "Average Cold Days Counts",
       color = "") +
  theme_bw() +
  theme(
    axis.title.y = element_text(color = "gray30"),
    axis.title.y.right = element_text(color = "grey30"),
    legend.position = "top"
  ) 
#ggsave("image/tmp/S1/timeSeries_ColdDaysCnt.jpeg", width = 6, height = 4)

############################################# Correlation Plots #######################

# before you model the data
# Correlation plot

# We choose Spearman correlation, bcs it doesn't require normality assumption and is robust to outliers
# Pearson correlation assumes normality assumption

## Male
tmp <- gbd_male[, c(4:10)] %>% 
  dplyr::rename(`Mortality Rate` = mort_RT,
                `Summer Max Temp` = Summer_max_temp,
                `Summer Mean Temp` = Summer_mean_temp,
                `Winter Min Temp` = Winter_min_temp,
                `Winter Mean Temp` = Winter_mean_temp,
                `Heat Days Cnt` = extreme_heat_cnt,
                `Cold Days Cnt` = extreme_cold_cnt)

corrplot(corr = cor(tmp,
                    use = "complete.obs",
                    method = "spearman"),
         method = "square", type = "lower",
         addCoef.col = "black", diag = F, cl.pos = "n",
         tl.srt = 0.005, tl.col = "black", tl.offset = 0.9, tl.cex = 1,
         title = "Spearman Correlation for GBD Male Data", mar=c(0,0,3,0))



## Female
tmp_female <- gbd_female[, c(4:10)] %>% 
  dplyr::rename(`Mortality Rate` = mort_RT,
                `Summer Max Temp` = Summer_max_temp,
                `Summer Mean Temp` = Summer_mean_temp,
                `Winter Min Temp` = Winter_min_temp,
                `Winter Mean Temp` = Winter_mean_temp,
                `Heat Days Cnt` = extreme_heat_cnt,
                `Cold Days Cnt` = extreme_cold_cnt)

corrplot(corr = cor(tmp_female,
                    use = "complete.obs",
                    method = "spearman"),
         method = "square", type = "lower",
         addCoef.col = "black", diag = F, cl.pos = "n",
         tl.srt = 0.0005, tl.col = "black", tl.offset = 0.9,
         title = "Spearman Correlation for GBD Female Data", mar=c(0,0,3,0))



##################### All Variable Relative Change Calculation ##########################

# mortality rate

df_relative_changes <- data.frame(Year = 1990:2019)

# Calculations
df_relative_changes$male_mort_RT <- c(diff(gbd_male$mort_RT)/lag(gbd_male$mort_RT) * 100)
df_relative_changes$female_mort_RT <- c(diff(gbd_female$mort_RT)/lag(gbd_female$mort_RT) * 100)
df_relative_changes$Summer_max_temp <- c(diff(gbd_male$Summer_max_temp)/lag(gbd_male$Summer_max_temp) * 100)
df_relative_changes$Summer_mean_temp <- c(diff(gbd_male$Summer_mean_temp)/lag(gbd_male$Summer_mean_temp) * 100)
df_relative_changes$Winter_min_temp <- c(diff(gbd_male$Winter_min_temp)/lag(gbd_male$Winter_min_temp) * 100)
df_relative_changes$Winter_mean_temp <- c(diff(gbd_male$Winter_mean_temp)/lag(gbd_male$Winter_mean_temp) * 100)
df_relative_changes$extreme_heat_cnt <- c(diff(gbd_male$extreme_heat_cnt)/lag(gbd_male$extreme_heat_cnt) * 100)
df_relative_changes$extreme_cold_cnt <- c(diff(gbd_male$extreme_cold_cnt)/lag(gbd_male$extreme_cold_cnt) * 100)


# Create a new column for decade
df_relative_changes <- df_relative_changes %>%
  mutate(decade = cut(Year, breaks = seq(1990, 2020, by = 10),
                      labels = FALSE, right = FALSE))

# Group by decade and calculate the mean relative change
relChange_group <- df_relative_changes %>%
  group_by(decade) %>%
  summarize(mean_M_mort_RT = mean(male_mort_RT, na.rm = TRUE),
            mean_F_mort_RT = mean(female_mort_RT, na.rm = TRUE),
            mean_SMaxT = mean(Summer_max_temp, na.rm = TRUE),
            mean_SMeanT = mean(Summer_mean_temp, na.rm = TRUE),
            mean_WMinT = mean(Winter_min_temp, na.rm = TRUE),
            mean_WMeanT = mean(Winter_mean_temp, na.rm = TRUE),
            mean_heatDays = mean(extreme_heat_cnt, na.rm = T),
            mean_coldDays = mean(extreme_cold_cnt, na.rm = T))

relChange_group <- relChange_group %>% 
  dplyr::mutate(decade = case_when(decade == 1 ~ "1990 - 2000",
                                   decade == 2 ~ "2000 - 2010",
                                   T ~ "2010 - 2019"))
