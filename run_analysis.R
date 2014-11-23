# Code: run_analysis.R
# Author: ESB
# Date: 11/23/2014
# This project is for the Coursera "Getting and Cleaning Data" course. It is 
# based on the **Human Activity Recognition Using Smartphones Dataset** 

#The objective of this exercise is to download and clean up the data (e.g. 
#combining the training and test sets, subsetting the data, using descriptive 
#activity and variable names, and transforming the data).
# 1. Merges the training and the test sets to create one data set. 
# 2. Extracts only the measurements on the mean and standard deviation for each
#    measurement.
# 3. Uses descriptive activity names to name the activities in the data set 
# 4. Appropriately labels the data set with descriptive variable names. 
# 5. From the data set in step 4, creates a second, independent tidy data set 
#    with the average of each variable for each activity and each subject.

# Data description:
# http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 
# Data:
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 


#First time when downloading data and unzipping into working directory
# url<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
# zipfile<-"dataset.zip"
# download.file(url,zipfile)
# unzip(zipfile)

# check assumption about working directory etc.


# 1. Read in the test and training sets (X_, y_, subject_) and merges the 
# training and the test sets to create one data set. 
# setwd("~/") #Goes to root folder first-- for when re-running on my computer
folder<-"UCI HAR Dataset"
setwd(folder)
X_test<-read.table("test/X_test.txt") #2947 x 561 variables - measurements
y_test<-read.table("test/y_test.txt") #2947 x 1 variable - activities
X_train<-read.table("train/X_train.txt") # 7352 x 561 variables - measurements
y_train<-read.table("train/y_train.txt") # 7352 x  1 variable - activities
subject_train<-read.table("train/subject_train.txt")# 2497 x 1 var- subjects
subject_test<-read.table("test/subject_test.txt")#7352 x 1 var - subjects

#Create a train set and a test set (with column binding) and add a variable:
#partition="test" or "train" (depending on what set it is)
train<-cbind(subject_train,"train",y_train,X_train)
colnames(train)[1:3]<-c("subject","partition","activity")
test<-cbind(subject_test,"test",y_test,X_test)
colnames(test)[1:3]<-c("subject","partition","activity")

#Use rbind to combine the train and the test sets
data<-rbind(train,test) #10299 obs of 564 variables (561+1+1+new partition var)

# 2. Extracts only the measurements on the mean and standard deviation for each
#    measurement.
# Read in the features file for the X measurement names
features<-read.table("features.txt") #561 variables
# Check for duplicate names; see that there are 84 duplicates
features_duplicates<-length(features$V2)-length(unique(features$V2))
features$vnames<-make.unique(as.character(features$V2)) #see 477 levels, but 561 
#observations so duplicates in names
#will append .1, .2 in seq for 2nd and 3rd repeats respectively
#Look at names for observations that include mean or std. dev for measurements
#--need to use escape character so looks for mean() exactly.
mean_var_names<-grep('mean\\(\\)',features$vnames,value=TRUE)
# -- mean_var does not including meanFreq() and not including angular mean
std_var_names<-grep('std\\(\\)',features$vnames,value=TRUE)
#Get indices for the mean and std variables (REMEMBER this is in reference to
#just the X data that has 561 columns)
mean_var<-grep('mean\\(\\)',features$vnames)
std_var<-grep('std\\(\\)',features$vnames)
subset_index<-sort(c(mean_var,std_var)) #sort so when combine, they are in the 
#     order of the columns
offset<-3 #need to do an offset of 3 because data= subj,partition,y,(561 X) and
#include the first three columns
data_sub<-data[c(1,2,3,subset_index+offset)]
colnames(data_sub) #double check that right columns are subset

# 3. Uses descriptive activity names to name the activities in the data set 
activity_labels<-read.table("activity_labels.txt")
# Rename the activity numbers with the labels to create a table with a variable
# of the full activity names. The descriptive activity names then replace the
# numeric activity column
data_sub$activity <- factor(data$activity, labels = activity_labels$V2)


# 4. Appropriately labels the data set with descriptive variable names. 
# Rename all of the X subset measurement names based on the features$vnames and 
# the index used to extract the mean and std. dev variables
# Removes () and replaces - with .
vnames<-make.names(features$vnames[subset_index])
#Replace "t" at beginning with "time", "f" with frequency
#Replace ".." with ""
#Example: "tBodyAcc-mean()-X"  goes to "timeBodyAccMeanX" 
vnames<-gsub("^t","time",gsub("^f","freq",gsub("\\.\\.","",vnames)))
#Replace BodyBody repeat with just Body (issue with last six)
vnames<-gsub("BodyBody","Body",vnames)
#Replace "." with "-" since not supposed to have dots, white spaces, etc.
vnames<-gsub("mean","Mean",gsub("std","Std",vnames))
vnames<-gsub("\\.","",vnames)
#Overwrite the colnames for the features 
colnames(data_sub)[-(1:3)]<-vnames


# 5. From the data set in step 4, creates a second, independent tidy data set 
#    with the average of each variable for each activity and each subject.
# subj - partition - activity - v1, v2, v3
#  1       test        Laying - 0.3, etc.
# Test to see that unique for subject_train and subject_test (so that for this
# column can just select the first observation for the subject_activity pair)
intersect(subject_train,subject_test) #no overlaps in train and test subjects
# Create a function that outputs the mean if numeric and if not, then the first 
# value (all obs. will be the same for the subject-activity pair for the activity
# and for the partition)
func_mean<-function(x) {
        if(is.numeric(x)){
                mean(x,na.rm=TRUE)
        }else{
                x[1]
        }
}
agg<-aggregate(data_sub,by=list(data_sub$activity, data_sub$subject),FUN=func_mean)
data.output<-agg[,-c(1,2)]
#Don't need to sort data since already arranged by subject and then activity
#(with activity in order of 1:6 as was first given)
write.table(data.output,"smartphonedata.txt",row.name=FALSE)

##EXTRA CODE FOR HELPING WITH DOCUMENTATION
##For text in codebook
# for(i in 1:69){
#         print(col[i])
# }

##DOUBLECHECKING
#Double check on number of activities per subject
#table(train[,c(1,3)])
#Double check some values to see if they are correct
# > mean(data_sub[data_sub$subject==2,4])
# [1] 0.2731131
# > head(agg[,1:4])
# subject partition           activity tBodyAcc-mean()-X
# 1       1     train           STANDING         0.2656969
# 2       2      test WALKING_DOWNSTAIRS         0.2731131
# 3       3     train           STANDING         0.2734287
# 4       4      test WALKING_DOWNSTAIRS         0.2741831
# 5       5     train           STANDING         0.2791780
# 6       6     train           STANDING         0.2723766
