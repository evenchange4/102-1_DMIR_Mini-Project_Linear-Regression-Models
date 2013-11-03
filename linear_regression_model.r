setup_data = read.csv('data/ldpa30_train preprocess.csv')

bin_list =  paste("bin", 1:10, sep = "")
for( i in 1:length(bin_list)){
	assign(bin_list[i], subset(setup_data, new_index > (i-1)*1110 & new_index <= i*1110 ) )
}
bin_train = bin1
bin_test  = rbind(bin2,bin3,bin4,bin5,bin6,bin7,bin8,bin9,bin10)


lm_function <- function(bin_train, bin_test){
	lm = lm(week_return1 ~ alpha+beta_mkt+beta_hml+beta_smb+sigma, data = bin_train)
	prediction_lm = predict(lm, newdata=bin_test)

	error = bin_test$week_return1 - prediction_lm
	rmse = sqrt(mean(error * error))
	rmse
}

glm_function <- function(bin_train, bin_test){
	glm = glm(week_return1 ~ alpha+beta_mkt+beta_hml+beta_smb+sigma+class, data = bin_train)
	prediction_glm = predict(glm, newdata=bin_test)

	error = bin_test$week_return1 - prediction_glm
	rmse = sqrt(mean(error * error))
	rmse
}

rmse_matrix = matrix(rep(0),ncol=10, nrow=2)
dimnames(rmse_matrix) = list(c("lm", "glm"))

for( i in 1:length(bin_list)){
	bin_validation_list = bin_list[i]
	bin_train_list      = bin_list[-i]

	bin_validation = get(bin_validation_list)
	bin_train = NULL
	for(b in bin_train_list){
		bin_train = rbind(bin_train, get(b))
	}

	# train / test / evaluate 
	rmse_matrix["lm",i] = lm_function(bin_train, bin_validation)
	rmse_matrix["glm",i] = glm_function(bin_train, bin_validation)
}

