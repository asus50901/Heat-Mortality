# -*- coding: utf-8 -*-
"""
Created on Mon Nov 20 13:23:14 2023

@author: sclynn
"""
# This is the code script to first tidy the meanT grid-lvl data
# to get the annual mean Summer heat for India

import imdlib as imd
import matplotlib.pyplot as plt
import xarray as xr
import pandas as pd

# There is no variable type for mean T
# we can read it in as tmin (since it has the same dimension)
# This will however, result in the varaible name 'tmin' instead of "tmean"
# We can fix that later

start_yr = 1951
end_yr = 1951
variable = 'tmin' # other options are ('tmin'/ 'tmax')
file_dir = (r'IMD Gridded/MeanT') #Path to save the files
data = imd.open_data(variable, start_yr, end_yr,'yearwise', file_dir)
data


ds = data.get_xarray()
ds 

ds_rename = ds.rename({'tmin': 'tmean'})
ds_rename['tmean'].attrs['long_name'] = 'Mean Temperature'

# Slice up the Summer time data only 
# By meteorological definitions of IMD, Pre-monsoon (Summer) is March, April, May
summer_start = '1951-03-01'
summer_end = '1951-05-31'

# Use the sel method to select the desired time range
subset_data = ds_rename.sel(time=slice(summer_start, summer_end))

# Print the information about the subsetted dataset
print(subset_data.info())


# testing plot of the mean temperature in grid level
# first filter the grids that have non-sense temperature to represent NA
mask = subset_data['tmean'] > 90
subset_data_filter = subset_data.where(~ mask, drop = True)

# Calculate the mean temperature over all locations
# .mean(dim=('lat', 'lon')) gets the daily mean temperature over each location
# .mean(dim=('lat', 'lon', 'time')) gets the summer mean temperature of the year over each location
mean_temperature = subset_data_filter['tmean'].mean(dim=('lat', 'lon', 'time'))
mean_temperature


######################### A function to write and store mean values of a month #######################

    

def Calc_tmean_mean(file_dir, file_year): 
    
    """
    Read a year's file, calculate the mean of a March, April, May, June tmean,
    also Nov, Dec, Jan, and Feb tmean
    and store the mean values in an array.

    Parameters:
    - file_dir (string): The path where you store all the tmean files EX. (r'fill in your path')
    - file_years (numeric): The year to be read in.

    Returns:
    - result_array (list): A list containing the calculated means.
    """
    
    # Step 1: read in the file using imdlib
    start_yr = file_year
    end_yr = file_year
    variable = 'tmin' 
    file_dir = file_dir #Path to save the files
    data = imd.open_data(variable, start_yr, end_yr,'yearwise', file_dir)

    ds = data.get_xarray()
    data = None # close the file in each step 
    
    # Step 2: rename the names because tmean is not a default reading option
    ds = ds.rename({'tmin': 'tmean'})
    ds['tmean'].attrs['long_name'] = 'Mean Temperature'
    
    # Step 3: drop the masked data points
    mask = ds['tmean'] > 90
    ds = ds.where(~ mask, drop = True)
    
    # Step 4: slice up the needed data
    file_year = str(file_year)
    jan_start = file_year + "-01-01"
    jan_end = file_year + "-01-31"
    
    feb_start = file_year + "-02-01"
    feb_end = file_year + "-02-28"
    
    mar_start = file_year + "-03-01"
    mar_end = file_year + "-03-31"
    
    apr_start = file_year + "-04-01"
    apr_end = file_year + "-04-30"
    
    may_start = file_year + "-05-01"
    may_end = file_year + "-05-31"
    
    jun_start = file_year + "-06-01"
    jun_end = file_year + "-06-30"
    
    jul_start = file_year + "-07-01"
    jul_end = file_year + "-07-31"

    nov_start = file_year + "-11-01"
    nov_end = file_year + "-11-30"
    
    dec_start = file_year + "-12-01"
    dec_end = file_year + "-12-31"
    #summer_start = '1951-03-01'
    #summer_end = '1951-05-31'
    
    # Step 5: Calculate the mean temperature over all locations (for each month)
    jan_tmean = ds.sel(time=slice(jan_start, jan_end))['tmean'].mean(dim=('lat', 'lon', 'time'))
    feb_tmean = ds.sel(time=slice(feb_start, feb_end))['tmean'].mean(dim=('lat', 'lon', 'time'))
    mar_tmean = ds.sel(time=slice(mar_start, mar_end))['tmean'].mean(dim=('lat', 'lon', 'time'))
    apr_tmean = ds.sel(time=slice(apr_start, apr_end))['tmean'].mean(dim=('lat', 'lon', 'time'))
    may_tmean = ds.sel(time=slice(may_start, may_end))['tmean'].mean(dim=('lat', 'lon', 'time'))
    jun_tmean = ds.sel(time=slice(jun_start, jun_end))['tmean'].mean(dim=('lat', 'lon', 'time'))
    jul_tmean = ds.sel(time=slice(jul_start, jul_end))['tmean'].mean(dim=('lat', 'lon', 'time'))
    nov_tmean = ds.sel(time=slice(nov_start, nov_end))['tmean'].mean(dim=('lat', 'lon', 'time'))
    dec_tmean = ds.sel(time=slice(dec_start, dec_end))['tmean'].mean(dim=('lat', 'lon', 'time'))
    
    ds = None # clean up for better memory usage

    mean_values = {
        'jan_tmean': jan_tmean,
        'feb_tmean': feb_tmean,
        'mar_tmean': mar_tmean,
        'apr_tmean': apr_tmean,
        'may_tmean': may_tmean,
        'jun_tmean': jun_tmean,
        'jul_tmean': jul_tmean,
        'nov_tmean': nov_tmean,
        'dec_tmean': dec_tmean
    }
    
    return mean_values

## Test run 
file_dir = (r'IMD Gridded/MeanT') #Path to save the files
tmp_store = Calc_tmean_mean(file_dir = file_dir, file_year = 1990)
tmp_store2 = Calc_tmean_mean(file_dir = file_dir, file_year = 1991)

# Testing to append dictionaries together
# Initialize an empty dictionary to store the result
result_dict = {}


# Perform the operation 2 times
test_year = [1990, 1991]
for i in range(len(test_year)):
    # Call the function to generate a dictionary
    current_dict = Calc_tmean_mean(file_dir = file_dir, file_year = test_year[i])

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

######################## Build the csv file containing all the monthly mean tmeans over the years ##########################

years_uWant = list(range(1990, 2017)) # list(range(1990, 2020)) for the tmin and tmax
# # we have data from 1951 to 2016
# we could use imputation to fill in the last three years tmean once we finish this compiling in Python
file_dir = (r'IMD Gridded/MeanT') #Path to save the files

# Initialize an empty dictionary to store the result
result_dict = {}


# Perform the operation over the years you want
for i in range(len(years_uWant)):
    # Call the function to generate a dictionary
    current_dict = Calc_tmean_mean(file_dir = file_dir, file_year = years_uWant[i])

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

# save the monthly tmeans of years
combined_dataframe.to_csv("monthly tmean.csv")
