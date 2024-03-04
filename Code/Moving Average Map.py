# -*- coding: utf-8 -*-
"""
Created on Sun Feb 25 17:44:17 2024

@author: sclynn
"""

######################### A function to write and store mean values of a month #######################

import imdlib as imd
import matplotlib.pyplot as plt
import xarray as xr
import pandas as pd
    

def Map_tmax_mean(file_dir, file_year, month=None): 
    
    """
    Read a year's file, calculate the mean of the specified month's tmax,
    and store the mean values in a dictionary.

    Parameters:
    - file_dir (string): The path where you store all the tmean files EX. (r'fill in your path')
    - file_year (numeric): The year to be read in.
    - month (string): The month for which to calculate the mean temperature (e.g., 'jan', 'feb', etc.). If None, returns mean values for all months.

    Returns:
    - mean_values (dict): A dictionary containing the calculated means.
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
    
    # Step 4: slice up the needed data
    file_year = str(file_year)
    months = {
        'jan': (file_year + "-01-01", file_year + "-01-31"),
        'feb': (file_year + "-02-01", file_year + "-02-28"),
        'mar': (file_year + "-03-01", file_year + "-03-31"),
        'apr': (file_year + "-04-01", file_year + "-04-30"),
        'may': (file_year + "-05-01", file_year + "-05-31"),
        'jun': (file_year + "-06-01", file_year + "-06-30"),
        'jul': (file_year + "-07-01", file_year + "-07-31"),
        'aug': (file_year + "-08-01", file_year + "-08-31"),
        'sep': (file_year + "-09-01", file_year + "-09-30"),
        'oct': (file_year + "-10-01", file_year + "-10-31"),
        'nov': (file_year + "-11-01", file_year + "-11-30"),
        'dec': (file_year + "-12-01", file_year + "-12-31")
    }
    
    # Check if month parameter is provided
    if month:
        start_date, end_date = months.get(month.lower(), (None, None))
        if start_date and end_date:
            tmax = ds.sel(time=slice(start_date, end_date))['tmax'].mean(dim=('time'))
            return tmax
        else:
            return None  # Return None if month is not found or invalid
    else:
        # Calculate mean temperature for all months
        mean_values = {}
        for month, (start_date, end_date) in months.items():
            tmax = ds.sel(time=slice(start_date, end_date))['tmax'].mean(dim=('time'))
            mean_values[f'{month}_tmax'] = tmax
        return mean_values



################### Get Data ###########################

years_uWant = list(range(1990, 2020)) # we have data from 1951 to 2019
file_dir = (r'C:/Users/sclynn/Desktop/Bhramar stuff/Heat Related Mortality/Data Analysis/Data Repository/IMD Gridded/MaxT') #Path to save the files

upperB = 45
lowerB = -5

SMaxT_array = Map_tmax_mean(file_dir, file_year = 2020, month='jan')

## January
SMaxT_array = Map_tmax_mean(file_dir, file_year = 2020, month='jan')
plt.figure(figsize=(6, 4.5), facecolor = 'white')
plt.axis('off') # no axis
SMaxT_array.plot(cmap = "coolwarm",
                 vmin = lowerB, vmax  = upperB,
                 cbar_kwargs={'orientation': 'horizontal',
                              'pad': -0.025, 'fraction': 0.02,
                              'aspect': 50})
plt.tight_layout()
plt.xlim([60.5, 101.5])  
plt.ylim([5.5, 38])  
plt.title("2019 January Average Daily Max")
plt.xlabel('Longitude')
plt.ylabel('Latitude')
plt.savefig("Maps/Reviewer/Jan_SMaxT.jpeg",
            dpi=600, bbox_inches='tight')

## February
SMaxT_array = Map_tmax_mean(file_dir, file_year = 2020, month='feb')
plt.figure(figsize=(6, 4.5), facecolor = 'white')
plt.axis('off') # no axis
SMaxT_array.plot(cmap = "coolwarm",
                 vmin = lowerB, vmax  = upperB,
                 cbar_kwargs={'orientation': 'horizontal',
                              'pad': -0.025, 'fraction': 0.02,
                              'aspect': 50})
plt.tight_layout()
plt.xlim([60.5, 101.5])  
plt.ylim([5.5, 38])  
plt.title("2019 February Average Daily Max")
plt.xlabel('Longitude')
plt.ylabel('Latitude')
plt.savefig("Maps/Reviewer/Feb_SMaxT.jpeg",
            dpi=600, bbox_inches='tight')

## March
SMaxT_array = Map_tmax_mean(file_dir, file_year = 2020, month='mar')
plt.figure(figsize=(6, 4.5), facecolor = 'white')
plt.axis('off') # no axis
SMaxT_array.plot(cmap = "coolwarm",
                 vmin = lowerB, vmax  = upperB,
                 cbar_kwargs={'orientation': 'horizontal',
                              'pad': -0.025, 'fraction': 0.02,
                              'aspect': 50})
plt.tight_layout()
plt.xlim([60.5, 101.5])  
plt.ylim([5.5, 38])  
plt.title("2019 March Average Daily Max")
plt.xlabel('Longitude')
plt.ylabel('Latitude')
plt.savefig("Maps/Reviewer/Mar_SMaxT.jpeg",
            dpi=600, bbox_inches='tight')

## April
SMaxT_array = Map_tmax_mean(file_dir, file_year = 2020, month='apr')
plt.figure(figsize=(6, 4.5), facecolor = 'white')
plt.axis('off') # no axis
SMaxT_array.plot(cmap = "coolwarm",
                 vmin = lowerB, vmax  = upperB,
                 cbar_kwargs={'orientation': 'horizontal',
                              'pad': -0.025, 'fraction': 0.02,
                              'aspect': 50})
plt.tight_layout()
plt.xlim([60.5, 101.5])  
plt.ylim([5.5, 38])  
plt.title("2019 April Average Daily Max")
plt.xlabel('Longitude')
plt.ylabel('Latitude')
plt.savefig("Maps/Reviewer/Apr_SMaxT.jpeg",
            dpi=600, bbox_inches='tight')

## May
SMaxT_array = Map_tmax_mean(file_dir, file_year = 2020, month='may')
plt.figure(figsize=(6, 4.5), facecolor = 'white')
plt.axis('off') # no axis
SMaxT_array.plot(cmap = "coolwarm",
                 vmin = lowerB, vmax  = upperB,
                 cbar_kwargs={'orientation': 'horizontal',
                              'pad': -0.025, 'fraction': 0.02,
                              'aspect': 50})
plt.tight_layout()
plt.xlim([60.5, 101.5])  
plt.ylim([5.5, 38])  
plt.title("2019 May Average Daily Max")
plt.xlabel('Longitude')
plt.ylabel('Latitude')
plt.savefig("Maps/Reviewer/May_SMaxT.jpeg",
            dpi=600, bbox_inches='tight')

## June
SMaxT_array = Map_tmax_mean(file_dir, file_year = 2020, month='jun')
plt.figure(figsize=(6, 4.5), facecolor = 'white')
plt.axis('off') # no axis
SMaxT_array.plot(cmap = "coolwarm",
                 vmin = lowerB, vmax  = upperB,
                 cbar_kwargs={'orientation': 'horizontal',
                              'pad': -0.025, 'fraction': 0.02,
                              'aspect': 50})
plt.tight_layout()
plt.xlim([60.5, 101.5])  
plt.ylim([5.5, 38])  
plt.title("2019 June Average Daily Max")
plt.xlabel('Longitude')
plt.ylabel('Latitude')
plt.savefig("Maps/Reviewer/Jun_SMaxT.jpeg",
            dpi=600, bbox_inches='tight')

## July
SMaxT_array = Map_tmax_mean(file_dir, file_year = 2020, month='jul')
plt.figure(figsize=(6, 4.5), facecolor = 'white')
plt.axis('off') # no axis
SMaxT_array.plot(cmap = "coolwarm",
                 vmin = lowerB, vmax  = upperB,
                 cbar_kwargs={'orientation': 'horizontal',
                              'pad': -0.025, 'fraction': 0.02,
                              'aspect': 50})
plt.tight_layout()
plt.xlim([60.5, 101.5])  
plt.ylim([5.5, 38])  
plt.title("2019 July Average Daily Max")
plt.xlabel('Longitude')
plt.ylabel('Latitude')
plt.savefig("Maps/Reviewer/Jul_SMaxT.jpeg",
            dpi=600, bbox_inches='tight')

## August
SMaxT_array = Map_tmax_mean(file_dir, file_year = 2020, month='aug')
plt.figure(figsize=(6, 4.5), facecolor = 'white')
plt.axis('off') # no axis
SMaxT_array.plot(cmap = "coolwarm",
                 vmin = lowerB, vmax  = upperB,
                 cbar_kwargs={'orientation': 'horizontal',
                              'pad': -0.025, 'fraction': 0.02,
                              'aspect': 50})
plt.tight_layout()
plt.xlim([60.5, 101.5])  
plt.ylim([5.5, 38])  
plt.title("2019 August Average Daily Max")
plt.xlabel('Longitude')
plt.ylabel('Latitude')
plt.savefig("Maps/Reviewer/Aug_SMaxT.jpeg",
            dpi=600, bbox_inches='tight')

## September
SMaxT_array = Map_tmax_mean(file_dir, file_year = 2020, month='sep')
plt.figure(figsize=(6, 4.5), facecolor = 'white')
plt.axis('off') # no axis
SMaxT_array.plot(cmap = "coolwarm",
                 vmin = lowerB, vmax  = upperB,
                 cbar_kwargs={'orientation': 'horizontal',
                              'pad': -0.025, 'fraction': 0.02,
                              'aspect': 50})
plt.tight_layout()
plt.xlim([60.5, 101.5])  
plt.ylim([5.5, 38])  
plt.title("2019 September Average Daily Max")
plt.xlabel('Longitude')
plt.ylabel('Latitude')
plt.savefig("Maps/Reviewer/Sep_SMaxT.jpeg",
            dpi=600, bbox_inches='tight')

## October
SMaxT_array = Map_tmax_mean(file_dir, file_year = 2020, month='oct')
plt.figure(figsize=(6, 4.5), facecolor = 'white')
plt.axis('off') # no axis
SMaxT_array.plot(cmap = "coolwarm",
                 vmin = lowerB, vmax  = upperB,
                 cbar_kwargs={'orientation': 'horizontal',
                              'pad': -0.025, 'fraction': 0.02,
                              'aspect': 50})
plt.tight_layout()
plt.xlim([60.5, 101.5])  
plt.ylim([5.5, 38])  
plt.title("2019 October Average Daily Max")
plt.xlabel('Longitude')
plt.ylabel('Latitude')
plt.savefig("Maps/Reviewer/Oct_SMaxT.jpeg",
            dpi=600, bbox_inches='tight')

## November
SMaxT_array = Map_tmax_mean(file_dir, file_year = 2020, month='nov')
plt.figure(figsize=(6, 4.5), facecolor = 'white')
plt.axis('off') # no axis
SMaxT_array.plot(cmap = "coolwarm",
                 vmin = lowerB, vmax  = upperB,
                 cbar_kwargs={'orientation': 'horizontal',
                              'pad': -0.025, 'fraction': 0.02,
                              'aspect': 50})
plt.tight_layout()
plt.xlim([60.5, 101.5])  
plt.ylim([5.5, 38])  
plt.title("2019 November Average Daily Max")
plt.xlabel('Longitude')
plt.ylabel('Latitude')
plt.savefig("Maps/Reviewer/Nov_SMaxT.jpeg",
            dpi=600, bbox_inches='tight')

## December
SMaxT_array = Map_tmax_mean(file_dir, file_year = 2020, month='dec')
plt.figure(figsize=(6, 4.5), facecolor = 'white')
plt.axis('off') # no axis
SMaxT_array.plot(cmap = "coolwarm",
                 vmin = lowerB, vmax  = upperB,
                 cbar_kwargs={'orientation': 'horizontal',
                              'pad': -0.025, 'fraction': 0.02,
                              'aspect': 50})
plt.tight_layout()
plt.xlim([60.5, 101.5])  
plt.ylim([5.5, 38])  
plt.title("2019 December Average Daily Max")
plt.xlabel('Longitude')
plt.ylabel('Latitude')
plt.savefig("Maps/Reviewer/Dec_SMaxT.jpeg",
            dpi=600, bbox_inches='tight')