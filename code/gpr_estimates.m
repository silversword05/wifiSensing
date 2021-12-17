% Assuming the final dataset is in a csv format with X and Y as the columns

base_dir = 'data/data_';

test_beacons_set = [17];
train_beacons_set = [16 18];
train_dataset_beacons = [];
for i = 1:length(train_beacons_set)
    input_filePath = [base_dir num2str(i) '/final_dataset.csv'];
    input_array = table2array(readtable(input_filePath));
    train_dataset_beacons = [train_dataset_beacons; input_array];
end

test_dataset_beacons = [];
for i = 1:length(test_beacons_set)
    input_filePath = [base_dir num2str(i) '/final_dataset.csv'];
    input_array = table2array(readtable(input_filePath));
    test_dataset_beacons = [test_dataset_beacons; input_array];
end

% assuming dataset-format is <sc1 ..... sc208 elapsed-time/time-diff ground-truth>
x_train = train_dataset_beacons(:,1:end-1);
y_train = train_dataset_beacons(:,end);
x_test = test_dataset_beacons(:,1:end-1);
gt_test = test_dataset_beacons(:,end);

rng default;
gpr_model = fitrgp(x_train,y_train,'FitMethod','exact','PredictMethod','exact',...
    'KernelFunction','squaredexponential',...
    'OptimizeHyperparameters','auto','HyperparameterOptimizationOptions',...
    struct('AcquisitionFunctionName','expected-improvement-plus'));
% compute the avg loss on 0.25% of the train data
% avg_cv_loss = kfoldLoss(gpr_model);
[pred,~,pred_intervals] = predict(gpr_model, x_test);
RMSE = sqrt(mean((pred - gt_test).^2)); 
fprintf("%.5f - RMSE Loss for full dataset", RMSE);


test_set = [10 14 18];
train_set = [11 12 13 15 16 17];
train_dataset = [];
for i = 1:length(train_set)
    input_filePath = [base_dir num2str(i) '/final_dataset.csv'];
    input_array = table2array(readtable(input_filePath));
    train_dataset = [train_dataset; input_array];
end
test_dataset = [];
for i = 1:length(test_set)
    input_filePath = [base_dir num2str(i) '/final_dataset.csv'];
    input_array = table2array(readtable(input_filePath));
    test_dataset = [test_dataset; input_array];
end
% assuming dataset-format is <sc1 ..... sc208 elapsed-time/time-diff ground-truth>
x_train = train_dataset(:,1:end-1);
y_train = train_dataset(:,end);
x_test = test_dataset(:,1:end-1);
gt_test = test_dataset(:,end);

rng default;
gpr_model = fitrgp(x_train,y_train,'FitMethod','exact','PredictMethod','exact',...
    'KernelFunction','squaredexponential',...
    'OptimizeHyperparameters','auto','HyperparameterOptimizationOptions',...
    struct('AcquisitionFunctionName','expected-improvement-plus'));
% compute the avg loss on 0.25% of the train data
% avg_cv_loss = kfoldLoss(gpr_model);
[pred,~,pred_intervals] = predict(gpr_model, x_test);
RMSE = sqrt(mean((pred - gt_test).^2)); 
fprintf("%.5f - RMSE Loss for full dataset", RMSE);