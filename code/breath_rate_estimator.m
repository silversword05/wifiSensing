% beacon frames sent out every few ms
beacon_interval = 25;

% load the spatial stream objects containing the csi buffers
ss1_ant1 = load('data/csi-signal.mat', 'antenna1');
ss1_ant2 = load('data/csi-signal.mat', 'antenna2');

% compute the phase difference of the two antennas of a spatial stream
ss1 = ss1_ant1.csi_buff .* conj(ss1_ant2.csi_buff);
pd_signal = angle(ss1);
% filter the breathing frequencies using bandpass filter
filtered_signal = bandpass(pd_signal, [0.1 0.6], 40);
% apply fft to filtered signal to get the response of frequency domain
N = size(filtered_signal,1);
% apply fft only to a window of 200 samples (5s) with step size of 1s
step_size = 40;
window_size = 200; 
sampling_freq = 1000/beacon_interval;
% windowing
for ix = 1:40:N
    signal_t = filtered_signal(ix:ix+window_size,:);
    signal_f = fft(signal_t);
    p2 = abs(signal_f/window_size);
    p1 = p2(1:window_size/2+1);
    p1(2:end-1) = 2*p1(2:end-1);
    freq = sampling_freq*(0:(window_size/2))/window_size;
end
