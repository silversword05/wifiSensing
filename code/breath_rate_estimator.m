% beacon frames sent out every few ms
beacon_interval = 25;

% load the phase difference data of all spatial streams
pd_signal_mat = load('data/pd_signal1.mat', 'pd_signal');
pd_signal = pd_signal_mat.pd_signal;
pd_signal = pd_signal(:,1:end-3);
% filter the breathing frequencies using bandpass filter
filtered_signal = bandpass(pd_signal, [0.1 0.6], 40);
% apply fft to filtered signal to get the response of frequency domain
N = size(filtered_signal,1);
% apply fft only to a window of 200 samples (5s) with step size of 1s
step_size = 40;
window_size = 400; 
sampling_freq = 1000/beacon_interval;
breathing_rates = [];
% windowing
for ix = 1:40:(N-window_size)
    signal_t = filtered_signal(ix:ix+window_size,:);
    signal_f = fft(signal_t);
    p2 = abs(signal_f/window_size);
    p1 = p2(1:window_size/2+1,:);
    p1(2:end-1,:) = 2*p1(2:end-1,:);
    freq = sampling_freq*(0:(window_size/2))/window_size;
    [magnitude, freq_bins] = max(p1);
    br = freq(freq_bins);
    breathing_rates = [breathing_rates; br];
    fig = figure('visible','off');
    plot(freq, p1(:,20));
    filename = 'data/images/br_20_' + string(ix) + '.pdf';
    saveas(fig, filename);
end

save('data/br_estimates.mat', 'breathing_rates');