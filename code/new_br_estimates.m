%{
base_dir = 'data/data_';
for k = 4:15
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
for k = 4:15
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
    step = 1; window = 15; % in seconds
    start_ix = 0; finish_ix = start_ix + window;
    br_estimates = []; br_estimates_all = []; timestamps = [];
    % windowing
    while finish_ix <= N
        index = find(time_diff_signal >= start_ix & time_diff_signal <= finish_ix);
        if isempty(index)
            fprintf('dataset:%d | [%d %d] is empty\n', k, start_ix, finish_ix);
            start_ix = start_ix + step;
            finish_ix = start_ix + window;
            continue
        end
        window_time = time_signal(index) * 0.001;
        windowed_signal = pd_signal(index, :);
        % filter the breathing frequencies using bandpass filter
        filtered_signal = bandpass(windowed_signal, [0.1 0.6], 40);
        %plot(filtered_signal(:,20));
        curr_window_br_estimate = get_respiration_rates(filtered_signal, window_time);
        if isempty(curr_window_br_estimate)
            fprintf('dataset:%d | [%d %d] [%.9f %.9f] br_estimates are empty\n', k, start_ix, finish_ix, window_time(1), window_time(end));
            start_ix = start_ix + step;
            finish_ix = start_ix + window;            
            continue        
        end
        br_estimates = [br_estimates; curr_window_br_estimate'];
        timestamps = [timestamps; [window_time(1)*1000 window_time(end)]*1000];
        fprintf('dataset:%d | [%d %d] [%.9f %.9f] is processed\n', k, start_ix, finish_ix, window_time(1), window_time(end));
        start_ix = start_ix + step;
        finish_ix = start_ix + window;
    end
    plot(mean(br_estimates,2));
    %output_filePath = [base_dir num2str(k) '/new_br_estimates_plomb.fig'];
    %saveas(gcf,output_filePath);
    output_filePath = [base_dir num2str(k) '/new_br_estimates_plomb.mat'];
    save(output_filePath,"br_estimates");
    output_filePath = [base_dir num2str(k) '/new_br_timestamps_plomb.mat'];
    save(output_filePath,"timestamps");
end