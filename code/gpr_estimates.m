% Assuming the final dataset is in a csv format with X and Y as the columns
% assuming dataset-format is <sc1 ..... sc208 elapsed-time/time-diff ground-truth>

base_dir = 'data/data_';

dataset = [];
train_beacons_set = [7 8 9];
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
    'Regularization',0.1, ...
    'OptimizeHyperparameters','auto', ...
    'HyperparameterOptimizationOptions', struct('AcquisitionFunctionName','expected-improvement-plus'));
% compute the avg loss on 0.25% of the train data
% avg_cv_loss = kfoldLoss(gpr_model);

R2_score = []; RMSE = [];
test_beacons_set = [16 17 18];
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

    RMSE = [RMSE; [0 test_beacons_set(i) sqrt(mean((scaled_pred - scaled_y_test).^2))]]; 
    fprintf("%.5f - Actual RMSE Loss for full dataset %d\n", RMSE, test_beacons_set(i));

    rss = sum((y_test - pred).^2);
    sss = sum((y_test - mean(y_test)).^2);
    R2_score = [R2_score; [0 test_beacons_set(i) (1 - (rss/sss))]]; 
    fprintf("%.5f - R2_score Loss for full dataset %d\n", R2_score, test_beacons_set(i));

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
    filename = ['data/images/gpr/new-user/gpr_result_beacons-dataset' num2str(test_beacons_set(i)) '.png'];
    saveas(gcf, filename);

end

dataset = [];
train_set = [7 8 9 10 11 12 16 17 18];
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
    'Regularization',0.1, ...
    'OptimizeHyperparameters','auto', ...
    'HyperparameterOptimizationOptions', struct('AcquisitionFunctionName','expected-improvement-plus'));
% compute the avg loss on 0.25% of the train data
% avg_cv_loss = kfoldLoss(gpr_model);

test_set = [13 14 15];
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

    RMSE = [RMSE; [1 test_set(i) sqrt(mean((scaled_pred - scaled_y_test).^2))]]; 
    fprintf("%.5f - RMSE Loss for full dataset - %d\n", RMSE, test_set(i));

    rss = sum((y_test - pred).^2);
    sss = sum((y_test - mean(y_test)).^2);
    R2_score = [R2_score; [1 test_set(i) (1 - (rss/sss))]]; 
    fprintf("%.5f - R2_score Loss for full dataset - %d\n", R2_score, test_set(i));

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
    filename = ['data/images/gpr/new-user/gpr_result_full-dataset' num2str(test_set(i)) '.png'];
    saveas(gcf, filename);
    close;
end

writematrix(RMSE,'data/images/gpr/metrics-x-subject-rmse-gpr.txt','Delimiter','tab','WriteMode','append');
writematrix(R2_score,'data/images/gpr/metrics-x-subject-r2-gpr.txt','Delimiter','tab','WriteMode','append');