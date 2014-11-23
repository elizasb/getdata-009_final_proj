---
title: "README"
author: "esb"
date: "Sunday, November 23, 2014"
output: html_document
---

README.md explains how all of the scripts work and how they are connected.

This project is for the Coursera "Getting and Cleaning Data" course. It is based on the **Human Activity Recognition Using Smartphones Dataset** which is available at:
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

The objective of this exercise is to download and clean up the data (e.g. combining the training and test sets, subsetting the data, using descriptive activity and variable names, and transforming the data).

#FILES:
1. README.md (this file)  
2. CodeBook.md (description of the variables, data, and transformations)  
3. run_analysis.R (script)  
4. smartphonedata.txt (output from script)

#Description of the Script
Script: **run_analysis.R**   
Overview:  
1. Merges the training and the test sets to create one data set.   
2. Extracts only the measurements on the mean and standard deviation for each measurement.  
3. Uses descriptive activity names to name the activities in the data set.  
4. Appropriately labels the data set with descriptive variable names.     
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject. This output table is called "agg"
   
Assumptions:   
1. Data has been downloaded and unzipped into your working directory and the
folder hasn't been renamed.



