base_dir = 'data/data_';
%{
for k = 7:9
    input_filePath = [base_dir num2str(k) '/csi_signal.mat'];
    csi_signal_mat = load(input_filePath, 'stream1');
    stream = csi_signal_mat.stream1;
    stream.pdSignal = []; stream.sysTimeBuff = []; stream.delayBuff = []; stream.timeBuff = []; 
    pd_signal = compute_phase_difference(stream);
    output_filePath = [base_dir num2str(k) '/new_pd_signal.mat'];
    save(output_filePath, 'pd_signal');
    fprintf("Completed generating pd signal for dataset:%d\n", k);
end
%}

fprintf("All PD Signals generated ..... \n");
fprintf("Generating breathing rate estimates ..... \n");
for k = 7:18
    input_filePath = [base_dir num2str(k) '/new_pd_signal.mat'];
    % load the phase difference data of all spatial streams
    pd_signal_mat = load(input_filePath, 'pd_signal');
    pd_signal = pd_signal_mat.pd_signal;
    time_signal = pd_signal(:,end);
    pd_signal = pd_signal(:,1:end-1);

    start_time = time_signal(1);
    time_diff_signal = time_signal - start_time;
    time_diff_signal = time_diff_signal * 0.001;
    N = time_diff_signal(end);

    % apply bandpass & plomb only to a window of 15s 
    % all time signals are in seconds
    step = 1; window = 15; start_ix = 0; finish_ix = start_ix + window; br_estimates = []; br_estimates_all = []; timestamps = [];
    % windowing
    while finish_ix <= N
        index = find(time_diff_signal >= start_ix & time_diff_signal <= finish_ix);
        if isempty(index)
            fprintf('dataset:%d | CSI | [%d %d] is empty\n', k, start_ix, finish_ix);
            start_ix = start_ix + step;
            finish_ix = start_ix + window;
            continue
        end
        window_time = time_signal(index) * 0.001;
        windowed_signal = pd_signal(index, :);
        % filter the breathing frequencies using bandpass filter
        %filtered_signal = bandpass(windowed_signal, [0.1 0.6], 40);
        %plot(window_time, filtered_signal);
        curr_window_br_estimate = get_respiration_rates(windowed_signal, window_time);
        if isempty(curr_window_br_estimate)
            fprintf('dataset:%d | CSI | [%d %d] [%.9f %.9f] br_estimates are empty\n', k, start_ix, finish_ix, window_time(1), window_time(end));
            start_ix = start_ix + step;
            finish_ix = start_ix + window;            
            continue        
        end
        br_estimates = [br_estimates; curr_window_br_estimate'];
        timestamps = [timestamps; [window_time(1)*1000 window_time(end)*1000]];
        fprintf('dataset:%d | CSI | [%d %d] [%.9f %.9f] is processed\n', k, start_ix, finish_ix, window_time(1), window_time(end));
        start_ix = start_ix + step;
        finish_ix = start_ix + window;
    end
    %output_filePath = [base_dir num2str(k) '/new_br_estimates_plomb.fig'];
    %saveas(gcf,output_filePath);
    output_filePath = [base_dir num2str(k) '/new_br_estimates_plomb.mat'];
    save(output_filePath,"br_estimates");
    output_filePath = [base_dir num2str(k) '/new_br_timestamps_plomb.mat'];
    save(output_filePath,"timestamps");

    num = 5;
    if (k >= 13)
        num = 11;
    end
    ground_truth_file = ['data/data_' num2str(k) '/ground_truth_12_' num2str(num) '_2021_5min_' num2str(k) '_100ms.mat'];
    ground_truth = load(ground_truth_file);
    force = ground_truth.force';
    veriner_estimates = ground_truth.RR_bpm;
    time_signal = ground_truth.curr_time';

    start_time = time_signal(1); 
    time_diff_signal = time_signal - start_time;
    N = time_diff_signal(end);

    % apply plomb only to a window of 10s
    start_ix = 0; finish_ix = start_ix + window; breathing_ground = []; timestamps_gt = []; R_bound = [0.1 0.6];
    % windowing
    while finish_ix <= N
        index = find(time_diff_signal >= start_ix & time_diff_signal <= finish_ix);
        if isempty(index)
            fprintf('dataset:%d | GT | [%d %d] is empty\n', k, start_ix, finish_ix);
            start_ix = start_ix + step;
            finish_ix = start_ix + window;
            continue
        end
        window_time = time_signal(index);
        windowed_signal = force(index);
        % filter the breathing frequencies using bandpass filter - force
        % readings are out every 100ms so frequency is 10Hz 
        %filtered_signal = bandpass(windowed_signal, [0.1 0.6], 10);
        curr_window_br_estimate = get_respiration_rates(windowed_signal, window_time);
        if isempty(curr_window_br_estimate)
            fprintf('dataset:%d | GT | [%d %d] [%.9f %.9f] br_estimates are empty\n', k, start_ix, finish_ix, window_time(1), window_time(end));
            start_ix = start_ix + step;
            finish_ix = start_ix + window;            
            continue        
        end
        breathing_ground = [breathing_ground; curr_window_br_estimate'];
        timestamps_gt = [timestamps_gt; [window_time(1) window_time(end)]];
        fprintf('dataset:%d | GT | [%d %d] [%.9f %.9f] is processed\n', k, start_ix, finish_ix, window_time(1), window_time(end));
        start_ix = start_ix + step;
        finish_ix = start_ix + window;
    end
    filename = ['data/data_' num2str(k) '/breathing_ground_ts.mat'];
    save(filename,"breathing_ground");
    filename = ['data/data_' num2str(k) '/timestamps_ground_ts.mat'];
    save(filename,"timestamps_gt");
    fprintf("Completed the processing of gt for dataset-%d\n",k);

    figure;
    plot(timestamps_gt(:,2)*1e3,breathing_ground,'DisplayName','vernier-estimates');
    hold on;
    plot(time_signal(1:100:end)*1e3, veriner_estimates(1:100:end),'DisplayName','vernier-rates');
    hold on;
    plot(timestamps(:,2),mean(br_estimates,2),'DisplayName','Predictions');
    hold off;
    legend;
end