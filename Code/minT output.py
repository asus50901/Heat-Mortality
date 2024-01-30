# -*- coding: utf-8 -*-
"""
Created on Mon Nov 20 13:23:14 2023

@author: sclynn
"""
# This is the code script to first tidy the minT grid-lvl data
# to get the annual mean Summer heat for India

import imdlib as imd
import matplotlib.pyplot as plt
import xarray as xr
import pandas as pd


######################### A function to write and store mean values of a month #######################

    

def Calc_tmin_mean(file_dir, file_year): 
    
    """
    Read a year's file, calculate the mean of a March, April, May, June tmin,
    also Nov, Dec, Jan, and Feb tmin
    and store the mean values in an array.

    Parameters:
    - file_dir (string): The path where you store all the tmin files EX. (r'fill in your path')
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
    
    # Step 2: drop the masked data points
    mask = ds['tmin'] > 90
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
    jan_tmin = ds.sel(time=slice(jan_start, jan_end))['tmin'].mean(dim=('lat', 'lon', 'time'))
    feb_tmin = ds.sel(time=slice(feb_start, feb_end))['tmin'].mean(dim=('lat', 'lon', 'time'))
    mar_tmin = ds.sel(time=slice(mar_start, mar_end))['tmin'].mean(dim=('lat', 'lon', 'time'))
    apr_tmin = ds.sel(time=slice(apr_start, apr_end))['tmin'].mean(dim=('lat', 'lon', 'time'))
    may_tmin = ds.sel(time=slice(may_start, may_end))['tmin'].mean(dim=('lat', 'lon', 'time'))
    jun_tmin = ds.sel(time=slice(jun_start, jun_end))['tmin'].mean(dim=('lat', 'lon', 'time'))
    jul_tmin = ds.sel(time=slice(jul_start, jul_end))['tmin'].mean(dim=('lat', 'lon', 'time'))
    nov_tmin = ds.sel(time=slice(nov_start, nov_end))['tmin'].mean(dim=('lat', 'lon', 'time'))
    dec_tmin = ds.sel(time=slice(dec_start, dec_end))['tmin'].mean(dim=('lat', 'lon', 'time'))
    
    ds = None # clean up for better memory usage

    mean_values = {
        'jan_tmin': jan_tmin,
        'feb_tmin': feb_tmin,
        'mar_tmin': mar_tmin,
        'apr_tmin': apr_tmin,
        'may_tmin': may_tmin,
        'jun_tmin': jun_tmin,
        'jul_tmin': jul_tmin,
        'nov_tmin': nov_tmin,
        'dec_tmin': dec_tmin
    }
    
    return mean_values

## Test run 
file_dir = (r'IMD Gridded/MinT') #Path to save the files

tmp_store = Calc_tmin_mean(file_dir = file_dir, file_year = 1990)
tmp_store2 = Calc_tmin_mean(file_dir = file_dir, file_year = 1991)

# Testing to append dictionaries together
# Initialize an empty dictionary to store the result
result_dict = {}


# Perform the operation 2 times
test_year = [1990, 1991]
for i in range(len(test_year)):
    # Call the function to generate a dictionary
    current_dict = Calc_tmin_mean(file_dir = file_dir, file_year = test_year[i])

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

years_uWant = list(range(1990, 2020)) # we have data from 1951 to 2019
file_dir = (r'IMD Gridded/MinT')

# Initialize an empty dictionary to store the result
result_dict = {}


# Perform the operation over the years you want
for i in range(len(years_uWant)):
    # Call the function to generate a dictionary
    current_dict = Calc_tmin_mean(file_dir = file_dir, file_year = years_uWant[i])

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
combined_dataframe.to_csv("monthly tmin.csv")
