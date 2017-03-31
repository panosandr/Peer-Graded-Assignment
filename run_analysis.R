library(plyr)

# Download and unzip file

if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip",method="curl")

unzip(zipfile="./data/Dataset.zip",exdir="./data")

path <- file.path("./data","UCI HAR Dataset")

# Read Features, Subject, Activity files 

featuresTest <- read.table(file.path(path,"test","X_test.txt"))
featuresTrain <- read.table(file.path(path,"train","X_train.txt"))

subjectTest <- read.table(file.path(path,"test","subject_test.txt"))
subjectTrain  <- read.table(file.path(path,"train","subject_train.txt"))

activityTest  <- read.table(file.path(path,"test","Y_test.txt" ))
activityTrain <- read.table(file.path(path,"train","Y_train.txt"))

# Merge the training and the test sets to create one data set

features <- rbind(featuresTrain,featuresTest)
subject <- rbind(subjectTrain,subjectTest)
activity <- rbind(activityTrain,activityTest)

featuresNames <- read.table(file.path(path,"features.txt"))
names(features)<- featuresNames$V2
names(subject) <- c("subject")
names(activity) <- c("activity")

merged_data <- cbind(subject,activity)
my_data <- cbind(features,merged_data)

# Extract only the measurements on the mean and standard deviation 
# for each measurement

subNames <- featuresNames$V2[grep("mean\\(\\)|std\\(\\)",featuresNames$V2)]
selectedNames <- c(as.character(subNames),"subject","activity" )
my_data <- subset(my_data,select=selectedNames)

# Use descriptive activity names to name the activities in the data set

activityLabels <- read.table(file.path(path,"activity_labels.txt"))

# Appropriately label the data set with descriptive variable names

names(my_data) <- gsub("^t","time",names(my_data))
names(my_data) <- gsub("^f","frequency",names(my_data))
names(my_data) <- gsub("Acc","Accelerometer",names(my_data))
names(my_data) <- gsub("Gyro","Gyroscope",names(my_data))
names(my_data) <- gsub("Mag","Magnitude",names(my_data))
names(my_data) <- gsub("BodyBody","Body",names(my_data))

# From the data set in step 4, create a second, independent tidy data set 
# with the average of each variable for each activity and each subject

my_data_2 <- aggregate(. ~subject + activity,my_data,mean)
my_data_2 <- my_data_2[order(my_data_2$subject,my_data_2$activity),]
write.table(my_data_2,file = "tidydata.txt",row.name=FALSE)