# -*- coding: utf-8 -*-
"""
Created on Mon Dec 11 13:40:16 2023

@author: sclynn
"""
## This is the code script for heat/cold day

# heat/cold day definition
# -- using data from 1990-2019
# Heat Day: max temperature >= 90th quantile of daily max temp from 1990-2019
# Cold Day: min temperature <= 10th quantile of daily min temp from 1990-2019

import imdlib as imd
#import matplotlib.pyplot as plt
import xarray as xr
import pandas as pd


######################### Heat Day - Determine the historical 90th quantile threshold ###############################
# read in and transform the data into xarray 
start_yr = 1990
end_yr = 2019
variable = 'tmax' # other options are ('tmin'/ 'tmax'/ 'rainfall')
file_dir = (r'IMD Gridded/MaxT') #Path to save the files
data = imd.open_data(variable, start_yr, end_yr,'yearwise', file_dir)

ds = data.get_xarray()
ds 

# first filter the grids that have non-sense temperature to represent NA
mask = ds['tmax'] > 90
ds_filter = ds.where(~ mask, drop = True)

ds = None

# Calculate the mean temperature over all locations
# .mean(dim=('lat', 'lon')) gets the daily mean temperature over all locations
# .mean(dim=('lat', 'lon', 'time')) gets the  mean temperature of the year over all location
mean_temperature = ds_filter['tmax'].mean(dim=('lat', 'lon'))
mean_temperature

ds_filter = None

# Calculate the 90th quantile
quantile_90 = mean_temperature.quantile(0.9)
# for years 1990 - 2019, 90th is at 36.103, 95th is at 37.053

# Print the result
print("90th quantile:", quantile_90)


# Use an ifelse function to turn days with average temperature over 90th quantile to 1
#binary_vector = (mean_temperature >= quantile_90).astype(int)

######################### A function to write and store extreme heat event counts #######################

# modify the calc_tmax function (with additional input of quantile_vals)
# 1. slice into month-specific
# 2. take mean over (lat, long) - get daily avg. max temp
# 3. turn into binary vector of 0, 1
# 4. take sum over (time) - get number of extreme heat event counts 

def Calc_extreme_heat(file_dir, file_year, hist_90qnt): 
    
    """
    Read a year's file, calculate the daily mean of Summer (April, May, June, July) tmax
    i.e the mean over (lat, long) - get daily avg. max temp
    and store the mean values in an array. 
    Then turn into binary vector of 0 and 1 when daily tmax >= qnt_90_hist
    Then take sum over (time) - get number of extreme heat event counts 

    Parameters:
    - file_dir (string): The path where you store all the tmax files EX. (r'fill in your path')
    - file_years (numeric): The year to be read in.
    - hist_90qnt (numeric): The historic (1990-2019) 90th quantile of tmax temperature

    Returns:
    - result_array (list): A list containing the calculated counts of heat days
    """
    
    # Step 1: read in the file using imdlib
    start_yr = file_year
    end_yr = file_year
    variable = 'tmax' 
    file_dir = file_dir #Path to save the files
    data = imd.open_data(variable, start_yr, end_yr,'yearwise', file_dir)

    ds = data.get_xarray()
    data = None # close the file in each step (to benefit the memory)
    
    # Step 2: drop the masked data points
    mask = ds['tmax'] > 90
    ds = ds.where(~ mask, drop = True)
    
    # Step 4: slice up the needed data (the Summer months)
    file_year = str(file_year)
    summer_start = file_year + "-04-01"
    summer_end = file_year + "-07-31"
    
    # Step 5: Calculate the mean daily temperature over all locations (for each month)
    summer_tmax = ds.sel(time=slice(summer_start, summer_end))['tmax'].mean(dim=('lat', 'lon'))
    ds = None # clean up for better memory usage
    
    # Step 6: convert the mean daily temperature over all locations into indicator of extreme heat event or not (T/F)
    binary_vector = (summer_tmax >= hist_90qnt).astype(int)
    binary_vector = binary_vector.sum() #.values.item()

    extreme_heat_cnt = {
        'extreme_heat_cnt': binary_vector
    }
    
    return extreme_heat_cnt

## test run
file_dir = (r'IMD Gridded/MaxT') #Path to save the files

tmp_store = Calc_extreme_heat(file_dir = file_dir, file_year = 1990, hist_90qnt=quantile_90)


####################### Run Here for Extreme Heat Event Counts over the Years ################################

years_uWant = list(range(1990, 2020)) # we have data from 1951 to 2019
file_dir = (r'IMD Gridded/MaxT') #Path to save the files

# Initialize an empty dictionary to store the result
result_dict = {}


# Perform the operation over the years you want
for i in range(len(years_uWant)):
    # Call the function to generate a dictionary
    current_dict = Calc_extreme_heat(file_dir = file_dir, file_year = years_uWant[i], hist_90qnt=quantile_90)

    # If it's the first iteration, directly assign the dictionary
    if not result_dict:
        result_dict = current_dict
    else:
        # Loop through the keys in the dictionaries
        for key in current_dict.keys():
            # Concatenate the xarrays along a new dimension  
            current_xarray = xr.concat([result_dict[key], current_dict[key]], dim='years')

            # Update the appended dictionary with the concatenated xarray
            result_dict[key] = current_xarray
            
# Print the result
print(result_dict)

# Convert the dictionary of xarrays to a dictionary of dataframes
dataframes_dict = {key: value.to_dataframe(name=key) for key, value in result_dict.items()}


# Save each dataframe to a separate CSV file
combined_dataframe = pd.concat(dataframes_dict.values(), axis=1)

# Change the row names (index)
combined_dataframe.index = years_uWant
# drop the unwanted quantile columns
combined_dataframe = combined_dataframe.drop('quantile', axis = 1)


######################### Cold Day Data - Determine the historical 10th quantile threshold ###############################
# read in and transform the data into xarray 
start_yr = 1990
end_yr = 2019
variable = 'tmin' # other options are ('tmin'/ 'tmax'/ 'rainfall')
file_dir = (r'IMD Gridded/MinT') #Path to save the files
data = imd.open_data(variable, start_yr, end_yr,'yearwise', file_dir)

ds = data.get_xarray()
ds 

# first filter the grids that have non-sense temperature to represent NA
mask = ds['tmin'] > 90
ds_filter = ds.where(~ mask, drop = True)

ds = None

# Calculate the mean temperature over all locations
# .mean(dim=('lat', 'lon')) gets the daily mean temperature over all locations
# .mean(dim=('lat', 'lon', 'time')) gets the  mean temperature of the year over all location
mean_temperature = ds_filter['tmin'].mean(dim=('lat', 'lon'))
mean_temperature

ds_filter = None

# Calculate the 10th quantile
quantile_10 = mean_temperature.quantile(0.1)
# for years 1990 - 2019, 10th is at 11.261, 5th is at 10.292

# Print the result
print("10th quantile:", quantile_10)


######################### A function to write and store Cold day counts #######################

# modify the calc_tmax function (with additional input of quantile_vals)
# 1. slice into month-specific
# 2. take mean over (lat, long) - get daily avg. min temp
# 3. turn into binary vector of 0, 1
# 4. take sum over (time) - get number of extreme cold event counts 

def Calc_extreme_cold(file_dir, file_year, hist_10qnt): 
    
    """
    Read a year's file, calculate the daily mean of Winter (Dec, Jan, Feb) tmin
    i.e the mean over (lat, long) - get daily avg. min temp
    and store the mean values in an array. 
    Then turn into binary vector of 0 and 1 when daily tmin <= qnt_10_hist
    Then take sum over (time) - get number of extreme cold event counts 

    Parameters:
    - file_dir (string): The path where you store all the tmin files EX. (r'fill in your path')
    - file_years (numeric): The year to be read in.
    - hist_10qnt (numeric): The historic (1990-2019) 10th quantile of tmin temperature

    Returns:
    - result_array (list): A list containing the calculated counts of cold days.
    """
    
    # Step 1: read in the file using imdlib
    start_yr = file_year
    end_yr = file_year
    variable = 'tmin' 
    file_dir = file_dir #Path to save the files
    data = imd.open_data(variable, start_yr, end_yr,'yearwise', file_dir)

    ds = data.get_xarray()
    data = None # close the file in each step (to benefit the memory)
    
    # Step 2: drop the masked data points
    mask = ds['tmin'] > 90
    ds = ds.where(~ mask, drop = True)
    
    # Step 4: slice up the needed data (the Summer months)
    file_year = str(file_year)
    winter_pOne_start = file_year + "-01-01"
    winter_pOne_end = file_year + "-02-28"
    winter_pTwo_start = file_year + "-12-01"
    winter_pTwo_end = file_year + "-12-31"
    
    # Step 5: Calculate the mean daily temperature over all locations (for each month)
    df1_tmin = ds.sel(time=slice(winter_pOne_start, winter_pOne_end))['tmin'].mean(dim=('lat', 'lon'))
    df2_tmin = ds.sel(time=slice(winter_pTwo_start, winter_pTwo_end))['tmin'].mean(dim=('lat', 'lon'))
    df_tmin = xr.concat([df1_tmin, df2_tmin], dim = 'time')
    
    ds = None 
    df1_tmin = None
    df2_tmin = None# clean up for better memory usage
    
    # Step 6: convert the mean daily temperature over all locations into indicator of extreme heat event or not (T/F)
    binary_vector = (df_tmin <= hist_10qnt).astype(int)
    binary_vector = binary_vector.sum() #.values.item()

    extreme_cold_cnt = {
        'extreme_cold_cnt': binary_vector
    }
    
    return extreme_cold_cnt

####################### Run Here for Extreme Heat Event Counts over the Years ################################

years_uWant = list(range(1990, 2020)) # we have data from 1951 to 2019
file_dir = (r'C:/Users/sclynn/Desktop/Heat Related Mortality/Data Analysis/Data Repository/IMD Gridded/MinT') #Path to save the files

# Initialize an empty dictionary to store the result
result_dict = {}


# Perform the operation over the years you want
for i in range(len(years_uWant)):
    # Call the function to generate a dictionary
    current_dict = Calc_extreme_cold(file_dir = file_dir, file_year = years_uWant[i], hist_10qnt = quantile_10)

    # If it's the first iteration, directly assign the dictionary
    if not result_dict:
        result_dict = current_dict
    else:
        # Loop through the keys in the dictionaries
        for key in current_dict.keys():
            # Concatenate the xarrays along a new dimension (e.g., 'years')
            current_xarray = xr.concat([result_dict[key], current_dict[key]], dim='years')

            # Update the appended dictionary with the concatenated xarray
            result_dict[key] = current_xarray
            
# Print the result
print(result_dict)

# Convert the dictionary of xarrays to a dictionary of dataframes
dataframes_dict = {key: value.to_dataframe(name=key) for key, value in result_dict.items()}


# Save each dataframe to a separate CSV file
combined_dataframe2 = pd.concat(dataframes_dict.values(), axis=1)

# Change the row names (index)
combined_dataframe2.index = years_uWant
# drop the unwanted quantile columns
combined_dataframe2 = combined_dataframe2.drop('quantile', axis = 1)

combined_df_heatNcold = pd.concat([combined_dataframe, combined_dataframe2['extreme_cold_cnt']], axis=1)

# save the yearly counts of the heat/cold events
combined_df_heatNcold.to_csv("yearly extreme heatNcold count.csv")
