
ground_truth = load('data/data_1/ground_truth_12_5_2021_5min_1_100ms.mat');
force = ground_truth.force';
time_signal = ground_truth.curr_time';

start_time = time_signal(1);
time_diff_signal = time_signal - start_time;
time_diff_signal = time_diff_signal;

% apply plomb only to a window of 10s
start_ix = 1;
next_step_found = false;
next_start_ix = 1;
window_ix = start_ix + 1; 

breathing_ground = [];
timestamps = [];

N = size(force, 1);
R_bound = [0.1 0.6];

while window_ix < N
    time_diff = time_diff_signal(window_ix) - time_diff_signal(start_ix);
    if (time_diff > 10)
        fprintf("%0.5f | %d | %d\n", time_diff, window_ix, start_ix);
        time_window = time_diff_signal(start_ix:window_ix);
        signal_window = force(start_ix:window_ix,:);
        [pxx, f] = plomb(signal_window, time_window);
        idx = find(f >= R_bound(1) & f <= R_bound(2));
        f = f(idx);
        pxx = pxx(idx);
        [freqPeak, loc] = max(pxx);
        
        breathing_ground = [breathing_ground; f(loc)];
        timestamps = [timestamps; [time_signal(start_ix) time_signal(window_ix)]];
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


breathing_ground = breathing_ground*60;
plot(breathing_ground)
save('data/data_1/breathing_ground.mat',"breathing_ground");
save('data/data_1/timestamps_ground.mat',"timestamps");