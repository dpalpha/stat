



cl <- tryCatch({ makeCluster(nCores) }, error = function(e) { NULL })
if (!is.null(cl)) { registerDoParallel(cl) }

metrics <- foreach(
  i = seq(1, nCores), 
  .combine = "c", .verbose = TRUE, .inorder=TRUE,
  .errorhandling = "stop", 
  .packages = c("h2o", "data.table", "MLmetrics"),
  .init = c()) %dopar% {
    set.seed(i)
    h2o.init()
    ret <- c()
    for (i in 1:nRepeatPerCore){
      trainIndexes <- sample(1:nrow(X), nrow(X), replace = TRUE)

      trainH2oSampled <- as.h2o(X[trainIndexes, ])
      testH2oSampled <- as.h2o(X[setdiff(1:nrow(X), trainIndexes), ])
      
      gbmSampled <- do.call(
        h2o.gbm,
        {
          p <- model@parameters
          p$model_id = NULL         
          p$training_frame = trainH2oSampled      
          p$validation_frame = NULL  
          p$nfolds = 0  
          p$stopping_rounds = 5
          p
        })  

      ret <- c(ret, myMetric(
        y_pred = as.vector(predict(gbmSampled, newdata = testH2oSampled)$predict), 
        y_true = as.vector(testH2oSampled[[response]])))
      
      h2o.rm(c(h2o.getId(testH2oSampled), h2o.getId(trainH2oSampled), gbmSampled))
    }
    return(ret)
  }

if (!is.null(cl)) { stopCluster(cl) }
rm(cl)

ci <- quantile(metrics, c(.05, .95)) 

ggplot(
  data.frame(myMetric = metrics), 
  aes(x = myMetric)) + 
  geom_histogram(binwidth = (max(metrics) - min(metrics)) / 100, alpha = 0.2, na.rm = TRUE, color = "blue", fill="blue") + 
  theme(legend.position="none") +
  geom_vline(aes(xintercept=mean(myMetric, na.rm = TRUE)),   
             color = "red", linetype = "dashed", size = 1) +
  geom_vline(aes(xintercept = ci[[1]]),   
             color = "green", linetype = "dashed", size = 1) +
  geom_vline(aes(xintercept = ci[[2]]),   
             color = "green", linetype = "dashed", size = 1)
