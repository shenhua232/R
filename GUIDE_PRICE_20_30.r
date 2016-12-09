library(caret)
library(pROC)
library(gbm)

# 预测目标和预测变量
# 剔除热度CL,HR变量
outcomeName03 = "A_PRI"
predictorsNames03 = c("buy_months","years_between_out_pp" 
                      ,"is_same_year","BRAND","VENDOR"
                      ,"EMISSION_STANDARD","OUTPUT"
                      , "GUIDE_PRI" ,"IMP"
                      , "KM") 

# 拆分样本
set.seed(559)
file_car_03 = file_car_01[file_car_01$GUIDE_PRI>=20 & file_car_01$GUIDE_PRI< 30,]
index03 <- 1:nrow(file_car_03)
test_index03 <- sample(index03, trunc(length(index03)/5))
test_data_03 <- file_car_03[test_index03,]
train_data_03 <- file_car_03[-test_index03,]
dim(test_data_03);dim(train_data_03)


# 寻找最优参数
gbmGrid_03 <-  expand.grid(interaction.depth =  c(10,20,30),
                        n.trees = c(100,500),
                        shrinkage = c(0.05,0.01),
                        n.minobsinnode=c(10,20,30))

# 创建 caret trainControl 对象，用来控制交叉验证的参数
objControl_03 <- trainControl(method = 'cv', 
                           number = 3)

# run model
objModel_03 <- train(train_data_03[,predictorsNames03], 
                  train_data_03[,outcomeName03], 
                  method = 'gbm', 
                  trControl = objControl_03, 
                  tuneGrid = gbmGrid_03, 
                  verbose = TRUE)

# BEST MODEL
objModel_03$bestTune

# run model
fitControl_03 <- trainControl(method = "none")
objModel_03 <- train(file_car_03[,predictorsNames03], 
                    file_car_03[,outcomeName03], 
                    method = 'gbm', 
                    trControl = fitControl_03, 
                    tuneGrid = data.frame(interaction.depth =  5,
                                          n.trees = 500,
                                          shrinkage = 0.05 ,
                                          n.minobsinnode =  10), 
                    verbose = TRUE)



# 测试集上的结果
f.predict03 <- predict(objModel_03,test_data_03[,predictorsNames03])
test_rmse_03 = sum((test_data_03$A_PRI-f.predict03)^2)
print(paste0("TEST-RMSE:",round(test_rmse_03 ,2)))
test_data_result_03 = data.frame(predict_price = round(f.predict03,2),
                                 real_price = test_data_03$A_PRI,
                                 diff_price = round(f.predict03  - test_data_03$A_PRI,2),
                                 guide_price = test_data_03$GUIDE_PRI,
                                 buy_months =  round(test_data_03$buy_months/12))
print(head(test_data_result_03,20))


# 模型效果
table(cut(abs(test_data_result_03$diff_price),c(-Inf,-0.5,0,0.1,0.2,0.3,0.5,1,3,5,10,Inf)))

# 模型误判
test_data_result_03[abs(test_data_result_03$diff_price)>1,]

# 绘制图形
trellis.par.set(caretTheme())
plot(objModel_03)  
#ggplot(objModel) 


#####################################
#
# 总体效果评估
#
#####################################
f.predict.all.03 <- predict(objModel_03,file_car_03[,predictorsNames03])
total.rmse.03 = sum((file_car_03$A_PRI-f.predict.all.03)^2)
print(paste0("TOTAL-RMSE:",round(total.rmse ,2)))
all_data_result_03 = data.frame(predict_price = round(f.predict.all.03,2),
                             real_price = file_car_03$A_PRI,
                             diff_price = round(f.predict.all.03  - file_car_03$A_PRI,2),
                             guide_price = file_car_03$GUIDE_PRI,
                             buy_months =  round(file_car_03$buy_months/12))
print(head(all_data_result_03,20))

# 模型效果
all_data_result_tab_03 = table(cut(abs(all_data_result_03$diff_price),c(-Inf,-0.5,0,0.1,0.2,0.3,0.5,1,3,5,10,Inf)))
all_data_result_tab_03 = as.data.frame(all_data_result_tab_03)
names(all_data_result_tab_03) =c("预测价格和评估价格的差异绝对值","数量")
all_data_result_tab_03$比例 = round(all_data_result_tab_03$数量 / sum(all_data_result_tab_03$数量),2)
all_data_result_tab_03$累计比例 = cumsum(all_data_result_tab_03$比例)
all_data_result_tab_03


