csi_signal_mat = load('data/data_15/csi_signal.mat', 'stream1');
stream = csi_signal_mat.stream1;
stream.pdSignal = []; stream.sysTimeBuff = []; stream.delayBuff = []; stream.timeBuff = []; 
pd_signal = compute_phase_difference(stream);
save('data/data_15/new_pd_signal.mat', 'pd_signal');

% beacon frames sent out every few ms
beacon_interval = 25;

% load the phase difference data of all spatial streams
pd_signal_mat = load('data/data_15/new_pd_signal.mat', 'pd_signal');
pd_signal = pd_signal_mat.pd_signal;
time_signal = pd_signal(:,end);
pd_signal = pd_signal(:,1:end-1);

%plot(pd_signal(:,20));
%plot(time_signal);

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
        start_ix = start_ix + step;
        finish_ix = start_ix + window;
        continue        
    end
    br_estimates = [br_estimates; curr_window_br_estimate'];
    timestamps = [timestamps; [window_time(1) window_time(end)]];
    start_ix = start_ix + step;
    finish_ix = start_ix + window;
end
plot(mean(br_estimates,2));
saveas(gcf,'data/data_15/new_br_estimates_plomb.fig');
save('data/data_15/new_br_estimates_plomb.mat',"br_estimates");
save('data/data_15/new_br_timestamps_plomb.mat',"timestamps");