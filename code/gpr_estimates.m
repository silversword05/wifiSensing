% Assuming the final dataset is in a csv format with X and Y as the columns
% assuming dataset-format is <sc1 ..... sc208 elapsed-time/time-diff ground-truth>

base_dir = 'data/data_';

dataset = [];
train_beacons_set = [16 18];
for i = 1:length(train_beacons_set)
    input_filePath = [base_dir num2str(train_beacons_set(i)) '/final_dataset.csv'];
    input_array = table2array(readtable(input_filePath));
    dataset = [dataset; input_array];
end
t_train = dataset(:,1:end-1);

% assuming dataset-format is <sc1 ..... sc208 elapsed-time/time-diff ground-truth>
[train_dataset_beacons, ~, ~] = normalize([dataset(:,1:end-2) dataset(:,end)]);
x_train = train_dataset_beacons(:,1:end-1);
%[~,x_train] = pcares(x_train_full, 10);
y_train = train_dataset_beacons(:,end);

rng default;
gpr_model = fitrgp(x_train,y_train, ...
    'FitMethod','exact','BasisFunction','linear','KernelFunction','squaredexponential', ...
    'Regularization',0.2, ...
    'OptimizeHyperparameters','auto', ...
    'HyperparameterOptimizationOptions', struct('AcquisitionFunctionName','expected-improvement-plus'));
% compute the avg loss on 0.25% of the train data
% avg_cv_loss = kfoldLoss(gpr_model);

test_beacons_set = [17];
for i = 1:length(test_beacons_set)
    input_filePath = [base_dir num2str(test_beacons_set(i)) '/final_dataset.csv'];
    dataset = table2array(readtable(input_filePath));
    t_test = dataset(:, end-1);

    [test_dataset_beacons, C, S] = normalize([dataset(:,1:end-2) dataset(:,end)]);
    x_test = test_dataset_beacons(:,1:end-1);
    y_test = test_dataset_beacons(:,end); 
    scaled_y_test = (y_test .* S(end)) + C(end);

    [pred, ~, pred_intervals] = predict(gpr_model, x_test);
    scaled_pred = (pred .* S(end)) + C(end);
    scaled_pred_intervals = (pred_intervals .* S(end)) + C(end);

    RMSE = sqrt(mean((scaled_pred - scaled_y_test).^2)); 
    fprintf("%.5f - RMSE Loss for full dataset", RMSE);

    figure;
    plot(t_test, scaled_pred, 'b-','DisplayName', 'predicitions-gpr');
    hold on;
    plot(t_test, mean(dataset(:,1:end-2),2), 'g-','DisplayName', 'predicitions - mean');    
    hold on;
    %plot(t_test, scaled_pred_intervals(:,1), 'k--', 'DisplayName', 'predicition-interval');
    hold on;
    %plot(t_test, scaled_pred_intervals(:,2), 'k--', 'DisplayName', 'predicition-interval');
    hold on;
    plot(t_test, scaled_y_test, 'r-', 'DisplayName', 'ground-truth');
    hold off;
    legend('Location','best');
    titlename = ['GPR - beacons only - Dataset' num2str(test_beacons_set(i))];
    title(titlename);

end

dataset = [];
train_set = [11 12 13 15 16 17 18];
for i = 1:length(train_set)
    input_filePath = [base_dir num2str(train_set(i)) '/final_dataset.csv'];
    input_array = table2array(readtable(input_filePath));
    dataset = [dataset; input_array];
end
t_train = dataset(:,1:end-1);

% assuming dataset-format is <sc1 ..... sc208 elapsed-time/time-diff ground-truth>
[train_dataset, ~, ~] = normalize([dataset(:,1:end-2) dataset(:,end)]);
x_train = train_dataset(:,1:end-1);
y_train = train_dataset(:,end);

rng default;
gpr_model = fitrgp(x_train,y_train, ...
    'FitMethod','exact','BasisFunction','linear','KernelFunction','squaredexponential', ...
    'Regularization',0.2, ...
    'OptimizeHyperparameters','auto', ...
    'HyperparameterOptimizationOptions', struct('AcquisitionFunctionName','expected-improvement-plus'));
% compute the avg loss on 0.25% of the train data
% avg_cv_loss = kfoldLoss(gpr_model);

test_set = [10 14];
for i = 1:length(test_set)
    input_filePath = [base_dir num2str(test_set(i)) '/final_dataset.csv'];
    dataset = table2array(readtable(input_filePath));
    t_test = dataset(:, end-1);

    [test_dataset_beacons, C, S] = normalize([dataset(:,1:end-2) dataset(:,end)]);
    x_test = test_dataset_beacons(:,1:end-1);
    y_test = test_dataset_beacons(:,end); 
    scaled_y_test = (y_test .* S(end)) + C(end);

    [pred, ~, pred_intervals] = predict(gpr_model, x_test);
    scaled_pred = (pred .* S(end)) + C(end);
    scaled_pred_intervals = (pred_intervals .* S(end)) + C(end);

    RMSE = sqrt(mean((scaled_pred - scaled_y_test).^2)); 
    fprintf("%.5f - RMSE Loss for full dataset", RMSE);

    figure;
    plot(t_test, scaled_pred, 'b-','DisplayName', 'predicitions - gpr');
    hold on;
    plot(t_test, mean(dataset(:,1:end-2),2), 'g-','DisplayName', 'predicitions - mean');
    hold on;
   % plot(t_test, scaled_pred_intervals(:,1), 'k..', 'DisplayName', 'predicition-interval');
    hold on;
   % plot(t_test, scaled_pred_intervals(:,2), 'k..', 'DisplayName', 'predicition-interval');
    hold on;
    plot(t_test, scaled_y_test, 'r-', 'DisplayName', 'ground-truth');
    hold off;
    legend('Location','best');
    titlename = ['GPR - Dataset' num2str(test_set(i))];
    title(titlename);
end
