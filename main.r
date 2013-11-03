setup_data_train = read.csv('data/ldpa30_train preprocess.csv')
setup_data_test  = read.csv('data/ldpa30_test_blind.csv')

# training
glm = glm(week_return1 ~ alpha+beta_mkt+beta_hml+beta_smb+sigma, data = setup_data_train)

# testing
newdata = setup_data_test
newdata$week_index = NULL
newdata$group = NULL
newdata$class = NULL
prediction_glm = predict(glm, newdata = newdata)
setup_data_test$week_return1 = prediction_glm

# loop find max，then mark flag = 1
for (i in 371:494) {
	week_block = subset(setup_data_test, week_index == i)
	max_offset = which.max( week_block$week_return1 )
	setup_data_test[(i-371)*30 + max_offset, "flag"] = 1
}

# fetch flag == 1
result = subset(setup_data_test, setup_data_test$flag ==1)

# output
write.csv(result[,1:2], file = "result.csv", row.names=FALSE, na="")