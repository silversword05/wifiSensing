function br_estimates = get_respiration_rates(filtered_signal, time_signal)
    br_estimates = [];
    [psd, freq] = plomb(filtered_signal, time_signal);
    idx = find(freq >= 0.1 & freq <= 0.6);
    if isempty(idx) || (size(idx, 1) <= 1)
        return
    end
    freq_bins = freq(idx);
    psd_filtered = psd(idx,:);    
    [magnitude, loc] = max(psd_filtered);
    br_estimates = freq_bins(loc) * 60;
end