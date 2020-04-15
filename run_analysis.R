library(data.table)
path <- getwd()
labels <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt"), col.names = c("Labels", "Activity"))
features <- fread(file.path(path, "UCI HAR Dataset/features.txt"), col.names = c("Num", "Feature"))
mean_std <- grep("(mean|std)\\(\\)", features[, Feature])
calculate <- features[mean_std, Feature]
calculate <- gsub('[()]', '', calculate)

# calculate train 
trains <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[, mean_std, with = FALSE]
setnames(trains, colnames(trains), calculate)
Trains_act <- fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt"), col.names = c("Activity"))
Trains_sub <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt"), col.names = c("Num_sub"))
trains <- cbind(Trains_sub, Trains_act, trains)

# calculate test 
tests <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, mean_std, with = FALSE]
setnames(tests, colnames(tests), calculate)
Tests_act <- fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt"), col.names = c("Activity"))
Tests_sub <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt"), col.names = c("Num_sub"))
tests <- cbind(Tests_sub, Tests_act, tests)

# Merges the training and the test.
complete_data <- rbind(trains, tests)

# Convert labels. 
complete_data[["Activity"]] <- factor(complete_data[, Activity], levels = labels[["Labels"]], labels = labels[["Activity"]])
complete_data[["Num_sub"]] <- as.factor(complete_data[, Num_sub])

# reshape.
library(reshape2)
complete_data <- melt(complete_data, c("Num_sub", "Activity"))
complete_data <- dcast(complete_data, Num_sub + Activity ~ variable, fun.aggregate = mean)

# write txt result
fwrite(x = complete_data, file = "tidyData.txt", quote = FALSE)
