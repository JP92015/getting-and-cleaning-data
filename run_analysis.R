#Create one R script called run_analysis.R that does the following:
#1. Merges the training and the test sets to create one data set.
#2. Extracts only the measurements on the mean and standard deviation for each measurement.
#3. Uses descriptive activity names to name the activities in the data set
#4. Appropriately labels the data set with descriptive variable names.
#5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

#Downloading and unzipping data:
if(!file.exists('data')){dir.create('data')}
url <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
download.file(url, destfile = 'data/Dataset.zip', method = "curl")
unzip('data/Dataset.zip',exdir = 'data')

#Loading data into R
subjectTest <- read.table('./data/UCI HAR Dataset/test/subject_test.txt', header = FALSE)
subjectTrain <- read.table('./data/UCI HAR Dataset/train/subject_train.txt', header = FALSE)

xTest <- read.table('./data/UCI HAR Dataset/test/X_test.txt', header = FALSE)
xTrain <- read.table('./data/UCI HAR Dataset/train/X_train.txt', header = FALSE)

yTest <- read.table('./data/UCI HAR Dataset/test/y_test.txt', header = FALSE)
yTrain <- read.table('./data/UCI HAR Dataset/train/y_train.txt', header = FALSE)

#1. Merging test and train data sets to create one data set

SubjectData <- rbind(subjectTest,subjectTrain)
LabelesData <- rbind(yTest,yTrain)
FeaturesData <- rbind(xTest,xTrain)

#Adding col names

names(SubjectData) <- "subject"
names(LabelesData) <- "labels"

featurenames <- read.table('./data/UCI HAR Dataset/features.txt', header = FALSE)
names(FeaturesData) <- featurenames$V2
    
#Creating one data set for all measurments
Data <- cbind(SubjectData,LabelesData,FeaturesData)


#2. Extracting only the measurements on the mean and standard deviation for each measurement

mask <- grep("mean\\(\\)|std\\(\\)",names(Data))

filteredData <- subset(Data, select = c('subject','labels', names(Data[mask])))

#3. Use descriptive activity names to name the activities in the data set

activityLabels <- read.table('./data/UCI HAR Dataset/activity_labels.txt', header = FALSE)

#4. Appropriately labels the data set with descriptive variable names.

names(filteredData) <- gsub('^t','time',names(filteredData))
names(filteredData) <- gsub('^f','frequency',names(filteredData))
names(filteredData) <- gsub('Acc','Accelerometer',names(filteredData))
names(filteredData) <- gsub('Gyro','Giroscope',names(filteredData))
names(filteredData) <- gsub('BodyBody','Body',names(filteredData))
names(filteredData) <- gsub('Mag','Magnitude',names(filteredData))

#5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

install.packages("dplyr")
library(dplyr)

summirisedData <- summarise_each(group_by(filteredData,subject,labels),funs(mean))

