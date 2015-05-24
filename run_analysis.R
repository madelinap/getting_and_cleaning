#download file
if(!file.exists("./data_cleaning/project")){dir.create("./data_cleaning/project")}
fileUrl <- "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data_cleaning/project/Dataset.zip")
#unzip files
unzip(zipfile="./data_cleaning/project/Dataset.zip",exdir="./data_cleaning/project")
path_rf <- file.path("./data_cleaning/project" , "UCI HAR Dataset")
#load data frames
#activity files
dataActivityTrain <- read.table(file.path(path_rf, "train", "Y_train.txt"),header = FALSE)
dataActivityTest  <- read.table(file.path(path_rf, "test" , "Y_test.txt" ),header = FALSE)
#subject files
dataSubjectTrain <- read.table(file.path(path_rf, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(path_rf, "test" , "subject_test.txt"),header = FALSE)
#feature files
dataFeatureTrain <- read.table(file.path(path_rf, "train", "X_train.txt"),header = FALSE)
dataFeatureTest  <- read.table(file.path(path_rf, "test" , "X_test.txt"),header = FALSE)
#merge vertically the datasets: test, train
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeatureTrain, dataFeatureTest)
#assign name to the columns in the dataframefs
names(dataSubject)<-c("subject")
names(dataActivity)<-c("activity")
dataFeatureNames <- read.table(file.path(path_rf, "features.txt"),head=FALSE)
names(dataFeatures)<-dataFeatureNames$V2
#merge horizontally the datasets: subject, activity, features
allData1 <- cbind(dataSubject, dataActivity)
allData  <- cbind(allData1, dataFeatures)
#subset columns mean and std
subdataFeatureNames<-dataFeatureNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeatureNames$V2)]
selectedNames<-c(as.character(subdataFeatureNames), "subject", "activity" )
finalData <- subset(allData,  select=selectedNames)
#replace activity with name activity
activityLabels <- read.table(file.path(path_rf, "activity_labels.txt"),header = FALSE)
finalData$activity <- factor(finalData$activity, labels=activityLabels$V2)
#replace column names with appropriate values
names(finalData)<-gsub("^t", "time", names(finalData))
names(finalData)<-gsub("^f", "frequency", names(finalData))
names(finalData)<-gsub("Acc", "Accelerometer", names(finalData))
names(finalData)<-gsub("Gyro", "Gyroscope", names(finalData))
names(finalData)<-gsub("Mag", "Magnitude", names(finalData))
names(finalData)<-gsub("BodyBody", "Body", names(finalData))
#aggregate by subject and activity and average the variables
library(plyr);
finalData2<-aggregate(. ~subject + activity, finalData, mean)
finalData2<-finalData2[order(finalData2$subject,finalData2$activity),]
write.table(finalData2, file = "tidydata.txt",row.name=FALSE)











