# -*- coding: utf-8 -*-
"""
Created on Sun Dec 31 04:07:42 2023

@author: sclynn
"""

## This is the code script to draw the Summer Max and Winter Min decade maps
# Also the Summer Mean and Winter Mean decade maps

# < STEPS >
# 1. make 1990-2000 Summer Max, 2000-2010 Summer Max, 2010-2019 Summer Max datasets
#     The datasets should have two columns, Year and Summer Max (Mean over time)
        # Write a function to do extract the datasets of the desired year
        
# 2. Draw the decade maps using the basic drawing procedure shown elsewhere

# 3. Repeat the process for Winter Min, Summer Mean and Winter Mean

############# Set up #################

# import the needed packages
import imdlib as imd
import matplotlib.pyplot as plt
import xarray as xr
import pandas as pd

start_yr = 1951
end_yr = 1951
variable = 'tmax' # other options are ('tmin'/ 'tmax')
file_dir = (r'IMD Gridded/MaxT') #Path to save the files
data = imd.open_data(variable, start_yr, end_yr,'yearwise', file_dir)
data


ds = data.get_xarray()
ds 

# Slice up the Summer time data only 
# By meteorological definitions of IMD, Pre-monsoon (Summer) is April, May, June, and July
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

# plot the grid level map 
subset_data_filter['tmean'].mean('time').plot()
plt.title("Summer month Min Temperature of India")
plt.xlabel('Longitude')
plt.ylabel('Latitude')

plt.show()

######################### Function - Prepare for Summer Max Temp Mapping #######################


def Map_Pre_SMaxT(file_dir, years):
    
    """
    Read a year's file, calculate the mean of Summer month tmax (March, April, May, June)
    and store the mean values in a list.
    Loop over the desired number of years, then combine the resulting summer month tmaxs into a DataArray object

    Parameters:
    - file_dir (string): The path where you store all the tmean files EX. (r'fill in your path')
    - years (numeric): The years to be read in.

    Returns:
    - result_array (DataArray): A DataArray object that have the desired years' Summer max temperature
    """
    
    # Initialize an empty list to store individual xarray objects
    summer_tmax_list = []

    for file_year in years:
        # Step 1: read in the file using imdlib
        start_yr = file_year
        end_yr = file_year
        variable = 'tmax'
        file_dir = file_dir  # Path to save the files
        data = imd.open_data(variable, start_yr, end_yr, 'yearwise', file_dir)

        ds = data.get_xarray()
        data = None  # Close the file in each step  

        # Step 2: drop the masked data points
        mask = ds['tmax'] > 90
        ds = ds.where(~mask, drop=True)

        # Step 3: slice up the needed data
        summer_start = f"{file_year}-04-01"
        summer_end = f"{file_year}-07-31"

        ds = ds.rename({'tmax': 'Summer Max Temp'})
        # Step 4: Select the summer max temperature for the specific year
        summer_tmax = ds.sel(time=slice(summer_start, summer_end))['Summer Max Temp'].mean(dim='time')

        # Append the result to the list
        summer_tmax_list.append(summer_tmax)

        ds = None  # Clean up for better memory usage

    # Concatenate the list of xarray objects along the time dimension
    combined_summer_tmax = xr.concat(summer_tmax_list, dim='time')

    return combined_summer_tmax

################ Test run of the function #########################

file_dir = (r'IMD Gridded/MaxT') #Path to save the files
years_list = list(range(1990, 1994)) # years 1990 to 1993
tmp = Map_Pre_SMaxT(file_dir, years_list)

# plot the grid level map 
tmp.mean(dim = 'time').plot() # This works!!
plt.title("Summer month Max Temperature of India")
plt.xlabel('Longitude')
plt.ylabel('Latitude')

plt.show()

######################## Create the maps for Summer Max Temp ##########################

file_dir = (r'IMD Gridded/MaxT') #Path to save the files

# The First Decade - Summer Max Temp
years_uWant = list(range(1990, 2001)) 
First_SMaxT_array = Map_Pre_SMaxT(file_dir, years_uWant)

# plot the grid level map 
First_SMaxT_array.mean(dim = 'time').plot(figsize = (6, 4)) 
plt.title("1990 to 2000 Decade Mean")
# Add gridlines to the background
plt.grid(color='grey', linestyle='-', linewidth=0.5)
plt.xlabel('Longitude')
plt.ylabel('Latitude')
plt.savefig("Maps/First_SMaxT_Map.jpeg",
            dpi=300)
plt.show()

# The Second Decade - Summer Max Temp
years_uWant = list(range(2000, 2011)) 
Second_SMaxT_array = Map_Pre_SMaxT(file_dir, years_uWant)

# plot the grid level map 
Second_SMaxT_array.mean(dim = 'time').plot(figsize = (6, 4))
plt.title("2000 to 2010 Decade Mean")
plt.xlabel('Longitude')
plt.ylabel('Latitude')
plt.savefig("Maps/Second_SMaxT_Map.jpeg",
            dpi=300)

# The Third Decade - Summer Max Temp
years_uWant = list(range(2010, 2020)) 
Third_SMaxT_array = Map_Pre_SMaxT(file_dir, years_uWant)

Third_SMaxT_array.mean(dim = 'time').plot(figsize = (6, 4)) 

plt.title("2010 to 2019 Decade Mean")
plt.xlabel('Longitude')
plt.ylabel('Latitude')

plt.savefig("Maps/Third_SMaxT_Map.jpeg",
            dpi=300)

######################### Function - Prepare for Winter Min Temp Mapping #######################


def Map_Pre_WMinT(file_dir, years):
    
    """
    Read a year's file, calculate the mean of Winter month tmin (Dec, Jan, Feb)
    and store the mean values in a list.
    Loop over the desired number of years, then combine the resulting winter month tmins into a DataArray object

    Parameters:
    - file_dir (string): The path where you store all the tmin files EX. (r'fill in your path')
    - years (numeric): The years to be read in.

    Returns:
    - result_array (DataArray): A DataArray object that have the desired years' Winter min temperature
    """
    
    # Initialize an empty list to store individual xarray objects
    winter_tmin_list = []

    for file_year in years:
        # Step 1: read in the file using imdlib
        start_yr = file_year
        end_yr = file_year
        variable = 'tmin'
        file_dir = file_dir  # Path to save the files
        data = imd.open_data(variable, start_yr, end_yr, 'yearwise', file_dir)

        ds = data.get_xarray()
        data = None  # Close the file in each step 

        # Step 2: drop the masked data points
        mask = ds['tmin'] > 90
        ds = ds.where(~mask, drop=True)

        # Step 3: slice up the needed data
        period1_start = f"{file_year}-01-01"
        period1_end = f"{file_year}-02-28"
        
        period2_start = f"{file_year}-12-01"
        period2_end = f"{file_year}-12-31"
        
        ds = ds.rename({'tmin': 'Winter Min Temp'})

        # Step 4: Select the summer max temperature for the specific year
        period1_tmin = ds.sel(time=slice(period1_start, period1_end))['Winter Min Temp'].mean(dim='time')
        period2_tmin = ds.sel(time=slice(period2_start, period2_end))['Winter Min Temp'].mean(dim='time')
        
        # Concatenate along the time dimension
        winter_tmin = xr.concat([period1_tmin, period2_tmin], dim='time')

        # Append the result to the list
        winter_tmin_list.append(winter_tmin)

        ds = None  # Clean up for better memory usage

    # Concatenate the list of xarray objects along the time dimension
    combined_winter_tmin = xr.concat(winter_tmin_list, dim='time')

    return combined_winter_tmin

######################## Create the maps for Winter Min Temp ##########################

file_dir = (r'IMD Gridded/MinT') #Path to save the files

# The First Decade - Summer Max Temp
years_uWant = list(range(1990, 2001)) 
First_WMinT_array = Map_Pre_WMinT(file_dir, years_uWant)

# plot the grid level map 
First_WMinT_array.mean(dim = 'time').plot(figsize = (6, 4)) 
plt.title("1990 to 2000 Decade Mean")
plt.xlabel('Longitude')
plt.ylabel('Latitude')
plt.savefig("Maps/First_WMinT_Map.jpeg",
            dpi=300)

# The Second Decade - Winter Min Temp
years_uWant = list(range(2000, 2011)) 
Second_WMinT_array = Map_Pre_WMinT(file_dir, years_uWant)

# plot the grid level map 
Second_WMinT_array.mean(dim = 'time').plot(figsize = (6, 4)) 
plt.title("2000 to 2010 Decade Mean")
plt.xlabel('Longitude')
plt.ylabel('Latitude')
plt.savefig("Maps/Second_WMinT_Map.jpeg",
            dpi=300)

# The Third Decade - Winter Min Temp
years_uWant = list(range(2010, 2020)) 
Third_WMinT_array = Map_Pre_WMinT(file_dir, years_uWant)

# plot the grid level map 
Third_WMinT_array.mean(dim = 'time').plot(figsize = (6, 4)) 
plt.title("2010 to 2019 Decade Mean")
plt.xlabel('Longitude')
plt.ylabel('Latitude')
plt.savefig("Maps/Third_WMinT_Map.jpeg",
            dpi=300)


########################### Short mapping tailored for the magazine style paper ###########################

# Summer max last decade
file_dir = (r'IMD Gridded/MaxT')
years_uWant = list(range(2010, 2020)) 
Third_SMaxT_array = Map_Pre_SMaxT(file_dir, years_uWant)

# The Third Decade - Winter Min Temp
file_dir = (r'IMD Gridded/MinT')
years_uWant = list(range(2010, 2020)) 
Third_WMinT_array = Map_Pre_WMinT(file_dir, years_uWant)

# Set the upper and lower bound for the colorbar of the map
Third_SMaxT_array.mean(dim = 'time').max()
Third_WMinT_array.mean(dim = 'time').min()

upperB = 40
lowerB = -5

# Summer max map
Third_SMaxT_array.mean(dim = 'time').plot(figsize = (6, 4), cmap = "coolwarm",
                                          vmin = lowerB, vmax  = upperB) 

plt.title("2010 to 2019 Decade Mean")
plt.xlabel('Longitude')
plt.ylabel('Latitude')

plt.savefig("Maps/Magazine_SMaxT_Map.jpeg",
            dpi=300)

# Winter min map
Third_WMinT_array.mean(dim = 'time').plot(figsize = (6, 4), cmap = "coolwarm",
                                          vmin = lowerB, vmax  = upperB) 
plt.title("2010 to 2019 Decade Mean")
plt.xlabel('Longitude')
plt.ylabel('Latitude')
plt.savefig("Maps/Magazine_WMinT_Map.jpeg",
            dpi=300)

######################### Function - Prepare for Summer Mean Temp Mapping #######################


def Map_Pre_SMeanT(file_dir, years):
    
    """
    Read a year's file, calculate the mean of Summer month tmean (March, April, May, June)
    and store the mean values in a list.
    Loop over the desired number of years, then combine the resulting summer month tmeans into a DataArray object

    Parameters:
    - file_dir (string): The path where you store all the tmean files EX. (r'fill in your path')
    - years (numeric): The years to be read in.

    Returns:
    - result_array (DataArray): A DataArray object that have the desired years' Summer mean temperature
    """
    
    # Initialize an empty list to store individual xarray objects
    summer_tmean_list = []

    for file_year in years:
        # Step 1: read in the file using imdlib
        start_yr = file_year
        end_yr = file_year
        variable = 'tmin'
        file_dir = file_dir  # Path to save the files
        data = imd.open_data(variable, start_yr, end_yr, 'yearwise', file_dir)

        ds = data.get_xarray()
        data = None  # Close the file in each step  
        
        # Step 2: rename the names because tmean is not a default reading option
        ds = ds.rename({'tmin': 'tmean'})
        ds['tmean'].attrs['long_name'] = 'Mean Temperature'

        # Step 3: drop the masked data points
        mask = ds['tmean'] > 90
        ds = ds.where(~mask, drop=True)

        # Step 4: slice up the needed data
        summer_start = f"{file_year}-04-01"
        summer_end = f"{file_year}-07-31"
        
        ds = ds.rename({'tmean': 'Summer Mean Temp'})

        # Step 5: Select the summer max temperature for the specific year
        summer_tmean = ds.sel(time=slice(summer_start, summer_end))['Summer Mean Temp'].mean(dim='time')

        # Append the result to the list
        summer_tmean_list.append(summer_tmean)

        ds = None  # Clean up for better memory usage

    # Concatenate the list of xarray objects along the time dimension
    combined_summer_tmean = xr.concat(summer_tmean_list, dim='time')

    return combined_summer_tmean


######################## Create the maps for Summer Mean Temp ##########################

file_dir = (r'IMD Gridded/MeanT') #Path to save the files

# The First Decade - Summer Max Temp
years_uWant = list(range(1990, 2001)) 
First_SMeanT_array = Map_Pre_SMeanT(file_dir, years_uWant)

# plot the grid level map 
First_SMeanT_array.mean(dim = 'time').plot(figsize = (6, 4)) 
plt.title("1990 to 2000 Decade Mean")
plt.xlabel('Longitude')
plt.ylabel('Latitude')
plt.savefig("Maps/First_SMeanT_Map.jpeg",
            dpi=300)
plt.show()

# The Second Decade - Summer Max Temp
years_uWant = list(range(2000, 2011)) 
Second_SMeanT_array = Map_Pre_SMeanT(file_dir, years_uWant)

# plot the grid level map 
Second_SMeanT_array.mean(dim = 'time').plot(figsize = (6, 4))
plt.title("2000 to 2010 Decade Mean")
plt.xlabel('Longitude')
plt.ylabel('Latitude')
plt.savefig("Maps/Second_SMeanT_Map.jpeg",
            dpi=300)

# The Third Decade - Summer Max Temp
years_uWant = list(range(2010, 2017)) 
Third_SMeanT_array = Map_Pre_SMeanT(file_dir, years_uWant)

Third_SMeanT_array.mean(dim = 'time').plot(figsize = (6, 4)) 
plt.title("2010 to 2016 Mean")
plt.xlabel('Longitude')
plt.ylabel('Latitude')
plt.savefig("Maps/Third_SMeanT_Map.jpeg",
            dpi=300)

######################### Function - Prepare for Winter Mean Temp Mapping #######################


def Map_Pre_WMeanT(file_dir, years):
    
    """
    Read a year's file, calculate the mean of Winter month tmean (Dec, Jan, Feb)
    and store the mean values in a list.
    Loop over the desired number of years, then combine the resulting Winter months mean into a DataArray object

    Parameters:
    - file_dir (string): The path where you store all the tmin files EX. (r'fill in your path')
    - years (numeric): The years to be read in.

    Returns:
    - result_array (DataArray): A DataArray object that have the desired years' Winter mean temperature
    """
    
    # Initialize an empty list to store individual xarray objects
    winter_tmean_list = []

    for file_year in years:
        # Step 1: read in the file using imdlib
        start_yr = file_year
        end_yr = file_year
        variable = 'tmin'
        file_dir = file_dir  # Path to save the files
        data = imd.open_data(variable, start_yr, end_yr, 'yearwise', file_dir)

        ds = data.get_xarray()
        data = None  # Close the file in each step  
        
        # Step 2: rename the names because tmean is not a default reading option
        ds = ds.rename({'tmin': 'tmean'})
        ds['tmean'].attrs['long_name'] = 'Mean Temperature'

        # Step 2: drop the masked data points
        mask = ds['tmean'] > 90
        ds = ds.where(~mask, drop=True)

        # Step 3: slice up the needed data
        period1_start = f"{file_year}-01-01"
        period1_end = f"{file_year}-02-28"
        
        period2_start = f"{file_year}-12-01"
        period2_end = f"{file_year}-12-31"

        ds = ds.rename({'tmean': 'Winter Mean Temp'})
        # Step 4: Select the summer max temperature for the specific year
        period1_tmean = ds.sel(time=slice(period1_start, period1_end))['Winter Mean Temp'].mean(dim='time')
        period2_tmean = ds.sel(time=slice(period2_start, period2_end))['Winter Mean Temp'].mean(dim='time')
        
        # Concatenate along the time dimension
        winter_tmean = xr.concat([period1_tmean, period2_tmean], dim='time')

        # Append the result to the list
        winter_tmean_list.append(winter_tmean)

        ds = None  # Clean up for better memory usage

    # Concatenate the list of xarray objects along the time dimension
    combined_winter_tmean = xr.concat(winter_tmean_list, dim='time')

    return combined_winter_tmean

######################## Create the maps for Winter Mean Temp ##########################

file_dir = (r'IMD Gridded/MeanT') #Path to save the files

# The First Decade - Winter Mean Temp
years_uWant = list(range(1990, 2001)) 
First_WMeanT_array = Map_Pre_WMeanT(file_dir, years_uWant)

# plot the grid level map 
First_WMeanT_array.mean(dim = 'time').plot(figsize = (6, 4)) 
plt.title("1990 to 2000 Decade Mean")
plt.xlabel('Longitude')
plt.ylabel('Latitude')
plt.savefig("Maps/First_WMeanT_Map.jpeg",
            dpi=300)
plt.show()

# The Second Decade - Winter Mean Temp
years_uWant = list(range(2000, 2011)) 
Second_WMeanT_array = Map_Pre_WMeanT(file_dir, years_uWant)

# plot the grid level map 
Second_WMeanT_array.mean(dim = 'time').plot(figsize = (6, 4))
plt.title("2000 to 2010 Decade Mean")
plt.xlabel('Longitude')
plt.ylabel('Latitude')
plt.savefig("Maps/Second_WMeanT_Map.jpeg",
            dpi=300)

# The Third Decade - Winter Mean Temp
years_uWant = list(range(2010, 2017)) 
Third_WMeanT_array = Map_Pre_WMeanT(file_dir, years_uWant)

Third_WMeanT_array.mean(dim = 'time').plot(figsize = (6, 4)) 
plt.title("2010 to 2016 Mean")
plt.xlabel('Longitude')
plt.ylabel('Latitude')
plt.savefig("Maps/Third_WMeanT_Map.jpeg",
            dpi=300)