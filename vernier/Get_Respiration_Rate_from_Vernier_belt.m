function [respRate, pxx, f] = Get_Respiration_Rate_from_Vernier_belt(Force,time, isPlotDebug)
%GET_RESPIRATION_RATE_FROM_VERNIER_BELT Get respiration rate from a window
%of data from Vernier respiration belt
% Input:
%   - Force: Force data (in N)
%   - time: timestamp (in secs), must be monotonic increasing 
%   - isPlotDebug: is plotting results to debug or not
%   - debugPlotTitle: debug plot title
% Output:
%   - respRate: respiration rate (in bpm)
% calculate Lomb periodogram 
[pxx, f] = plomb(Force, time);
if isPlotDebug
    figure(isPlotDebug); 
	plot(f, pxx,'r*-','linewidth',1.5); 
    set(gca,'FontSize',25);
%     title(debugPlotTitle);
    xlabel('f (Hz)','FontSize',25);
    ylabel('Magnitude','FontSize',25);
    grid on; 
    xlim([0 2]);
    ylim([0 max(pxx)]);
end
detThres = 0; % detection threshold
% [maxval, loc] = max(pxx);
% peak_freq = 0; 
% if maxval > detThres && f(loc) >= 0.1
%     peak_freq = f(loc);
% end
% respRate = peak_freq * 60; 
R_bound = [0.15 0.5];
idx = find(f >= R_bound(1) & f <= R_bound(2));
f = f(idx);
pxx = pxx(idx);
[maxval, loc] = max(pxx);
peak_freq = 0; 
if maxval > detThres
    peak_freq = f(loc);
end
respRate = peak_freq * 60;
% if(respRate > 30)
%     keyboard
% end

end

