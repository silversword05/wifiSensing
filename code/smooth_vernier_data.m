base_dir = 'data/data_';

for k = 10:18
    num = 5;
    if (k >= 13)
        num = 11;
    end
    ground_truth_file = [base_dir num2str(k) '/ground_truth_12_' num2str(num) '_2021_5min_' num2str(k) '_100ms.mat'];
    ground_truth = load(ground_truth_file);
    force = ground_truth.force';
    veriner_estimates = ground_truth.RR_bpm';
    time_signal = ground_truth.curr_time';

    time_signal = time_signal(1:100:end)*1e3;
    veriner_estimates = veriner_estimates(1:100:end);

    input_br_estimate = [base_dir num2str(k) '/new_br_estimates_plomb.mat'];
    br_estimate_mat = load(input_br_estimate);
    br_estimates = br_estimate_mat.br_estimates;

    input_br_time = [base_dir num2str(k) '/new_br_timestamps_plomb.mat'];
    timestamps_mat = load(input_br_time);
    timestamps = timestamps_mat.timestamps;
    
    timestamps_mean = mean(timestamps,2);
    time_start = min(timestamps_mean(1), time_signal(1));

    time_signal = time_signal - time_start;
    time_diff_mean = timestamps_mean - time_start;

    breathing_gt_estimates = spline(time_signal,veriner_estimates,time_diff_mean);
    
    time_diff_mean_from_zero = time_diff_mean - time_diff_mean(1);
    time_diff_mean_from_zero = time_diff_mean_from_zero * 1e-3;
    sub_carrier_cnt = size(br_estimates, 2);
    finalMatrix = -1*ones(size(time_diff_mean, 1), sub_carrier_cnt + 2);

    finalMatrix(:, 1:sub_carrier_cnt) = br_estimates;
    finalMatrix(:, sub_carrier_cnt+1, :) = time_diff_mean_from_zero';
    finalMatrix(:, sub_carrier_cnt+2) = breathing_gt_estimates';

%     figure;
%     plot(time_diff_mean, breathing_gt_estimates, ...
%         'DisplayName','gt-estimates');
%     hold on;
%     plot(time_diff_gt_mean, veriner_estimates, ...
%         'DisplayName','gt-actual');
%     hold off;
%     legend;

    filename = ['data/data_' num2str(k) '/final_dataset2.csv'];
    writematrix(finalMatrix,filename);
end