%csi_signal_mat = load('data/data_4/csi_signal.mat', 'stream1');
%stream1 = csi_signal_mat.stream1;
%stream1.pdSignal = []; stream1.sysTimeBuff = []; stream1.delayBuff = []; stream1.timeBuff = []; 
%stream1 = stream1.merge_buffers(10);
%pd_signal = stream1.pdSignal;
%save('data/pd_signal1.mat', 'pd_signal');

% beacon frames sent out every few ms
beacon_interval = 25;

% load the phase difference data of all spatial streams
pd_signal_mat = load('data/data_13/pd_signal1.mat', 'pd_signal');
pd_signal = pd_signal_mat.pd_signal;
time_signal = pd_signal(:,end-2);
pd_signal = pd_signal(:,1:end-3);

start_time = time_signal(1);
time_diff_signal = time_signal - start_time;
time_diff_signal = time_diff_signal * 0.001;

% filter the breathing frequencies using bandpass filter
filtered_signal = bandpass(pd_signal, [0.1 0.6], 40);
N = size(filtered_signal,1);
% apply plomb only to a window of 10s
start_ix = 1;
next_step_found = false;
next_start_ix = 1;
window_ix = start_ix + 1; 
br_estimates = [];
br_estimates_all = [];
timestamps = [];
% windowing
while window_ix < N
    time_diff = time_diff_signal(window_ix) - time_diff_signal(start_ix);
    if (time_diff > 10)
        fprintf("%0.5f | %d | %d\n", time_diff, window_ix, start_ix);
        time_window = time_diff_signal(start_ix:window_ix);
        signal_window = filtered_signal(start_ix:window_ix,:);
        [magnitude, freq] = plomb(signal_window, time_window);
        [M,I] = max(magnitude);
        br_estimates = [br_estimates; median(freq(I))];
        br_estimates_all = [br_estimates_all; freq(I)'];
        timestamps = [timestamps; [time_signal(start_ix) time_signal(window_ix)]];
        %plot(freq, magnitude(:,20));
        %drawnow
        if (next_step_found)
            start_ix = next_start_ix;
            window_ix = start_ix + 1;
            next_step_found = false;
        else
            start_ix = window_ix;
            window_ix = start_ix + 1;            
        end
    elseif (time_diff > 1 && not(next_step_found))
        fprintf("%0.5f | %d | %d\n", time_diff, next_start_ix, start_ix);
        next_start_ix = window_ix;
        next_step_found = true;
    else
        window_ix = window_ix +1;
    end
end
br_estimates = br_estimates * 60;
br_estimates_all = br_estimates_all * 60;
disp(sum(br_estimates > 10 & br_estimates < 20));
plot(br_estimates);
saveas(gcf,'data/data_13/br_estimates_plomb.fig');
save('data/data_13/br_estimates_plomb.mat',"br_estimates");
save('data/data_13/br_estimates_plomb_all.mat',"br_estimates_all");
save('data/data_13/timestamps_plomb.mat',"timestamps");
