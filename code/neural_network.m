% Assuming the final dataset is in a csv format with X and Y as the columns
% assuming dataset-format is <sc1 ..... sc208 elapsed-time/time-diff ground-truth>

base_dir = 'data/data_';

% test_beacons_set = [17];
% train_beacons_set = [16 18];

test_set = [10 14];
train_set = [11 12 13 15 16 17 18];

train_dataset_beacons = [];
for i = 1:length(train_set)
    input_filePath = [base_dir num2str(train_set(i)) '/final_dataset.csv'];
    input_array = table2array(readtable(input_filePath));
    train_dataset_beacons = [train_dataset_beacons; input_array];
end

test_dataset_beacons = [];
for i = 1:length(test_set)
    input_filePath = [base_dir num2str(test_set(i)) '/final_dataset.csv'];
    input_array = table2array(readtable(input_filePath));
    test_dataset_beacons = [test_dataset_beacons; input_array];
end

% assuming dataset-format is <sc1 ..... sc208 elapsed-time/time-diff ground-truth>
x_train = train_dataset_beacons(:,1:end-2);
t_train = train_dataset_beacons(:,1:end-1);
y_train = train_dataset_beacons(:,end);

x_test = test_dataset_beacons(:,1:end-2);
t_test = test_dataset_beacons(:, end-1);
gt_test = test_dataset_beacons(:,end);

rng default;

Mdl = fitrnet(x_train,y_train,"Standardize",true, "LayerSizes",[80 50]);
testMSE = loss(Mdl,x_test,gt_test);

disp(testMSE);
testPredictions = predict(Mdl,x_test);

figure;
plot(testPredictions, 'DisplayName', 'estimate')
hold on;
plot(gt_test, 'DisplayName', 'actual')
%hold on;
%plot(mean(x_test, 2), 'DisplayName', 'mean')
hold off;

legend;
