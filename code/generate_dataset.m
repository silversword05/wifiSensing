base_dir = 'data/data_';

for k = 12:12
    input_gt_data = [base_dir num2str(k) '/breathing_ground_ts.mat'];
    breathing_ground_mat = load(input_gt_data, 'breathing_ground');
    breathing_ground = breathing_ground_mat.breathing_ground;

    input_ground_time = [base_dir num2str(k) '/timestamps_ground_ts.mat'];
    timestamps_gt_mat = load(input_ground_time, 'timestamps_gt');
    timestamps_gt = timestamps_gt_mat.timestamps_gt;

    input_br_estimate = [base_dir num2str(k) '/new_br_estimates_plomb.mat'];
    br_estimate_mat = load(input_br_estimate);
    br_estimates = br_estimate_mat.br_estimates;

    input_br_time = [base_dir num2str(k) '/new_br_timestamps_plomb.mat'];
    timestamps_mat = load(input_br_time);
    timestamps = timestamps_mat.timestamps * 1e-3;

    % NOTE  --- ALL TIME STAMPS ARE NOW IN SECONDS ---

    timestamps_gt_mean = mean(timestamps_gt, 2);
    timestamps_mean = mean(timestamps,2);

    timestamps_gt_start = timestamps_gt_mean(1);

    time_diff_gt_mean = timestamps_gt_mean - timestamps_gt_start;
    time_diff_mean = timestamps_mean - timestamps_gt_start;

    breathing_gt_estimates = spline(time_diff_gt_mean,breathing_ground,time_diff_mean);
    time_diff_mean_from_zero = time_diff_mean - time_diff_mean(1);

    sub_carrier_cnt = size(br_estimates, 2);
    finalMatrix = -1*ones(size(time_diff_mean, 1), sub_carrier_cnt + 2);

    finalMatrix(:, 1:sub_carrier_cnt) = br_estimates;
    finalMatrix(:, sub_carrier_cnt+1, :) = time_diff_mean_from_zero';
    finalMatrix(:, sub_carrier_cnt+2) = breathing_gt_estimates';

    figure;
    plot(time_diff_mean, breathing_gt_estimates, ...
        'DisplayName','gt-estimates');
    hold on;
    plot(time_diff_gt_mean, breathing_ground, ...
        'DisplayName','gt-actual');
    hold on;
    plot(time_diff_mean, mean(br_estimates,2), ...
        'DisplayName','csi-estimate');
    hold off;
    legend;

    filename = ['data/data_' num2str(k) '/final_dataset.csv'];
    writematrix(finalMatrix,filename);

    % find average of the time stamps of ground truth
    % substract all from the start  of the averages of timestamps of gt
    % apply spline on ground truth; output is a polynomial
    % substract the average timestamps of CSI from average start of the gt
    % get data for the timestamps of the CSI from spline polynomial
    % dump everything from then to csv
    % dataset-format is <sc1 ..... sc208 elapsed-time/time-diff ground-truth>
end
