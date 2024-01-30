# -*- coding: utf-8 -*-
"""
Created on Mon Nov 20 16:28:46 2023

@author: sclynn
"""

# this is the code script to download the daily temperature data
# from IMD using the imdlib package

# import numpy as np
import imdlib as imd

start_yr = 1990
end_yr = 2019

# Download tmax
variable = 'tmax' # other options are ('rain'/ 'tmin')
download_data = imd.get_data(variable, start_yr, end_yr, fn_format='yearwise')

# Download tmin
variable = 'tmin' 
download_data = imd.get_data(variable, start_yr, end_yr, fn_format='yearwise')

