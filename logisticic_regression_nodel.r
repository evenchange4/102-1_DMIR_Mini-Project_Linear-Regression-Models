setup_data = read.csv('data/ldpa30_train preprocess.csv')

bin_list =  paste("bin", 1:10, sep = "")
for( i in 1:length(bin_list)){
	assign(bin_list[i], subset(setup_data, new_index > (i-1)*1110 & new_index <= i*1110 ) )
}

bin_train = bin1
phi = matrix(c(bin_train$alpha, bin_train$beta_mkt, bin_train$beta_hml, bin_train$beta_smb, bin_train$sigma), ncol=5)

w_old = matrix(rep(0),5)
yn = logistic_sigmoid(phi %*% w_old)
R = yn %*% t(1 - yn)
w_new = solve(t(phi) %*% R %*% phi) %*% t(phi) %*% R

logistic_sigmoid <- function(a){
	result = 1/(1+exp(-a))
	result
}


mylogit = glm(class ~ alpha + beta_mkt + beta_hml + beta_smb + sigma, data = setup_data, family = "binomial")
bin1$pClass = predict(mylogit, newdata = bin1, type = "response")