# setwd('/Users/michaelhsu/code/mini_project')
setup_data = read.csv('data/ldpa30_train use.csv')

# split data
bin_list =  paste("bin", 1:10, sep = "")
for( i in 1:length(bin_list)){
	## Assign a value to a name in an environment.
	assign(bin_list[i], subset(setup_data, new_index > (i-1)*1110 & new_index <= i*1110 ) )
}

# input:9 bins of [training data], return [params w, w0]
model_train <- function(bin_train){
	bin_train_class1 = subset(bin_train, class == 1)
	bin_train_class0 = subset(bin_train, class == 0)
	N1 = nrow(bin_train_class1)
	N0 = nrow(bin_train_class0)

	pi = matrix(c(N1/(N1+N0),N0/(N1+N0)),ncol=2)
	dimnames(pi) = list('pi',c('class1','class0'))

	mean = matrix(c(rep(0,10)),ncol=5, nrow=2)
	dimnames(mean) = list(c("class1",'class0'), c('alpha','beta_mkt','beta_hml','beta_smb','sigma'))

	mean["class1","alpha"]    = mean(bin_train_class1$alpha)
	mean["class1","beta_mkt"] = mean(bin_train_class1$beta_mkt)
	mean["class1","beta_hml"] = mean(bin_train_class1$beta_hml)
	mean["class1","beta_smb"] = mean(bin_train_class1$beta_smb)
	mean["class1","sigma"]    = mean(bin_train_class1$sigma)

	mean["class0","alpha"]    = mean(bin_train_class0$alpha)
	mean["class0","beta_mkt"] = mean(bin_train_class0$beta_mkt)
	mean["class0","beta_hml"] = mean(bin_train_class0$beta_hml)
	mean["class0","beta_smb"] = mean(bin_train_class0$beta_smb)
	mean["class0","sigma"]    = mean(bin_train_class0$sigma)

	bin_train_class1$class = NULL
	bin_train_class1$new_index = NULL
	bin_train_class0$class = NULL
	bin_train_class0$new_index = NULL

	# ?
	cov = (N1*cov(bin_train_class1) + N0*cov(bin_train_class0)) / (N1+N0)
	w  = solve(cov) %*% (mean["class1",] - mean["class0",])
	w0_value = ((-0.5) * t(mean["class1",]) %*% solve(cov) %*% mean["class1",]) + (0.5 * t(mean["class0",]) %*% solve(cov) %*% mean["class0",]) + log(pi["pi", "class1"] / pi["pi", "class0"])

	list(w=w, w0_value=w0_value)
}

logistic_sigmoid <- function(a){
	result = 1/(1+exp(-a))
	result
}

# input:remaining bin of [validation data, params w, w0], return [predict class]
model_predict <- function(bin_validation, w, w0_value){
	w0 = matrix(rep(model_train_param$w0_value),nrow(bin_validation))
	
	bin_validation_class = bin_validation$class
	bin_validation$class = NULL
	bin_validation_new_index = bin_validation$new_index
	bin_validation$new_index = NULL

	probility_of_predict_class1 = logistic_sigmoid(t(w) %*% t(bin_validation) + t(w0))
	bin_validation$probility = t(probility_of_predict_class1)
	bin_validation$class = bin_validation_class
	bin_validation$class_validation = matrix(rep(0),nrow(bin_validation))
	bin_validation
}

# input:remaining bin of [which bin, and validation data], return [preformance]
model_evaluate <- function(bin_validation_list, bin_validation){
	# confusion_matrix
	confusion_matrix = matrix(rep(0),ncol=2, nrow=2)
	dimnames(confusion_matrix) = list(c("known_class1",'known_class0'), c("prediction_class1",'prediction_class0'))

	for (n in 1:nrow(bin_validation)){
		if(bin_validation[n,"probility"] >= 0.5){
			bin_validation[n,"class_validation"] = 1
			if(bin_validation[n,"class"] == 1){
				confusion_matrix["known_class1", "prediction_class1"] = confusion_matrix["known_class1", "prediction_class1"] + 1
			}
			else{
				confusion_matrix["known_class0", "prediction_class1"] = confusion_matrix["known_class0", "prediction_class1"] + 1
			}
		}
		else{
			if(bin_validation[n,"class"] == 1){
				confusion_matrix["known_class1", "prediction_class0"] = confusion_matrix["known_class1", "prediction_class0"] + 1
			}
			else{
				confusion_matrix["known_class0", "prediction_class0"] = confusion_matrix["known_class0", "prediction_class0"] + 1
			}		
		}
	}

	# performance
	performance_matrix = matrix(rep(0),ncol=4, nrow=1)
	dimnames(performance_matrix) = list(bin_validation_list, c("accuracy",'precision', 'recall', 'F-measure'))

	tp = confusion_matrix["known_class1", "prediction_class1"]
	fp = confusion_matrix["known_class0", "prediction_class1"]
	fn = confusion_matrix["known_class1", "prediction_class0"]
	tn = confusion_matrix["known_class0", "prediction_class0"]
	performance_matrix[, "precision"] = tp / (tp+fp)
	performance_matrix[, "recall"]    = tp / (tp+fn)
	performance_matrix[, "accuracy"]  = (tp+tn) / (tp+tn+fp+fn)
	performance_matrix[, "F-measure"] = 2 * performance_matrix[, "precision"] * performance_matrix[, "recall"] / (performance_matrix[, "precision"]+performance_matrix[, "recall"])
	performance_matrix
}

### training data combine # pick bin10 as validation
ten_fold_evaluate = NULL

# pick one as validation data (10 loop)
for( i in 1:length(bin_list)){
	bin_validation_list = bin_list[i]
	bin_train_list      = bin_list[-i]

	bin_validation = get(bin_validation_list)
	bin_train = NULL
	for(b in bin_train_list){
		bin_train = rbind(bin_train, get(b))
	}

	# train / test / evaluate 
	model_train_param = model_train(bin_train)
	bin_validation    = model_predict(bin_validation, model_train_param$w, model_train_param$w0_value)
	evaluate          = model_evaluate(bin_validation_list, bin_validation)
	ten_fold_evaluate = rbind(ten_fold_evaluate, evaluate)
}

print(ten_fold_evaluate)

## calculate mean, sd
performance_summary_matrix = matrix(rep(0),ncol=4, nrow=2)
dimnames(performance_summary_matrix) = list(c("mean", "sd"), c("accuracy",'precision', 'recall', 'F-measure'))

for(c in colnames(ten_fold_evaluate)){
	performance_summary_matrix["mean", c] = mean(ten_fold_evaluate[, c])
	performance_summary_matrix["sd", c] = sd(ten_fold_evaluate[, c])
}
print(performance_summary_matrix)