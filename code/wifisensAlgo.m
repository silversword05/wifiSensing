classdef wifisensAlgo
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        pktThreshold
        initTime
        numCSIPkt4Anlysis
        
        selectedSC
        prevRoundCSISet;
        AGC_threshold;
        
        BPassFilterCoeff;
        LPassFilterCoeff
        avgSigPower;
        avgNoisePower;
        WindLen;
        
        M
        I
        
        Fs;
    end
    
    methods
        function obj = wifisensAlgo()
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            obj.pktThreshold = 1000;
            obj.numCSIPkt4Anlysis = 100;
            obj.AGC_threshold = 0.01;
        end
        
        function [CSIOut] = agcCompensation(obj,csiBuff,curCSI)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            
            if isempty(csiBuff)
                CSIOut = curCSI;
            else
                AGC_threshold = 0.1;
                now = curCSI ./ csiBuff(end,:);
                if mean(now)>(1+AGC_threshold) || mean(now)<(1-AGC_threshold)
                    CSIOut = curCSI / mean(now);
                else
                    CSIOut = curCSI;
                end
            end
            
            
        end
        
        function [curCSI, csiBuff]=ucsdagcCompensition(obj,csiBuff,curCSI,agcLast)
             if (isempty(csiBuff))
                 csiBuff = curCSI;
             else
                 csiBuff = [csiBuff; curCSI];
                 now =  curCSI(obj.selectedSC)./ agcLast(obj.selectedSC);
                 if ((median(now) < 1 - obj.AGC_threshold) || (median(now) > 1 + obj.AGC_threshold))
                     curCSI(obj.selectedSC) = curCSI(obj.selectedSC) ./ median(now);
                 end
             end
        end
        
        
        function anomFlag=anomalyRemove(obj,curCSI,scalingFactor)
            anomFlag = 0;
%             if curDelay >5 
%                 anomFlag = 1;
%             end
            dataLen = length(curCSI);
            noiseIdx = setdiff(1:dataLen,obj.selectedSC);
            avgNoise = abs(mean(curCSI(noiseIdx)));
            if avgNoise > scalingFactor*obj.avgNoisePower
                anomFlag = 1;
            end
        end
        
        
        function [agcBuff, timeBuff_s, timeBuff_ref, anomTimeFlag,pdpBuff] = anomTimeRemove(obj,agcBuff, curTime, timeBuff_s, timeBuff_ref,pdpBuff)
            anomTimeFlag = 0;
            if(isempty(timeBuff_s))
                timeBuff_s = curTime;
                timeBuff_ref = 0;
            else
                if(curTime - timeBuff_s(end) == 0)
                    % looks if curr_time - last_time = 0, then update last
                    % csi as the mean of last and curent csi, and drop
                    % the current packet
                    agcBuff(end - 1,:) = mean(agcBuff(end-1:end,:),1);
                    agcBuff(end,:) = [];
                    pdpBuff(end - 1,:) = mean(pdpBuff(end-1:end,:),1);
                    pdpBuff(end,:) = [];
                    anomTimeFlag = 1;
                else
                    timeBuff_s = [timeBuff_s curTime];
                    timeBuff_ref = [timeBuff_ref (curTime - timeBuff_s(1))];
                end
            end
        end
        
        function [agcBuff, timeBuff_s, timeBuff_ref, anomTimeFlag,csiBuff] = anomTimeRemove_v2(obj,agcBuff, curTime, timeBuff_s, timeBuff_ref,csiBuff,firstTime)
            anomTimeFlag = 0;
            if(isempty(timeBuff_s))
                timeBuff_s = curTime;
                timeBuff_ref = 0;
            else
                if(curTime - timeBuff_s(end) == 0)
                    % looks if curr_time - last_time = 0, then update last
                    % csi as the mean of last and curent csi, and drop
                    % the current packet
                    agcBuff(end - 1,:) = mean(agcBuff(end-1:end,:),1);
                    agcBuff(end,:) = [];
                    anomTimeFlag = 1;
                    csiBuff(end - 1,:) = mean(csiBuff(end-1:end,:),1);
                    csiBuff(end,:) = [];
                else
                    timeBuff_s = [timeBuff_s curTime];
                    timeBuff_ref = [timeBuff_ref (curTime - firstTime)];
                end
            end
        end
        function [delay]=showDelay_org(obj,curTime)
            sec = floor(curTime/1000);
         msec = curTime-sec*1000;
         date = datetime(curTime/1000,'convertfrom','posixtime','TimeZone','America/Chicago');
         date2=datetime('now','TimeZone','America/Chicago','Format','dd-MMM-uuuu HH:mm:ss.SSS');
         delay=seconds(date2-date)-msec/1000;
%          mod(curTime,10e3)
         
         fprintf('pkt delay is:%.3f \n',delay)
        end
        function [delay, curSysTime]=showDelay(obj,curTime)
            sec = floor(curTime/1000);
             msec = curTime-sec*1000;
             date = datetime(curTime/1000,'convertfrom','posixtime','TimeZone','America/Chicago');
             date2=datetime('now','TimeZone','America/Chicago','Format','dd-MMM-uuuu HH:mm:ss.SSS');
             msec2 = (posixtime(date2) - floor(posixtime(date2)))*1e3;
             curSysTime = floor(posixtime(date2))*1e3 + msec2;
             delay=seconds(date2-date)-msec/1000;
             fprintf('pkt delay is:%.3f \n',delay)
        end
        function obj=SNRCalc(obj,CSIAmpBuff)
            %dataLen = size(CSIAmpBuff,1);
            sig = mean(CSIAmpBuff(:,obj.selectedSC),2);
            nIdx = setdiff(1:size(CSIAmpBuff,2),obj.selectedSC);
            noise = mean(CSIAmpBuff(:,nIdx),2);
            obj.avgSigPower = median(sig);
            obj.avgNoisePower = median(noise);
        end
        function plotCSIBuff(obj,csiBuff,tsBuff,fignum)
            dataLen = size(csiBuff,1);
%             if dataLen >100
%                 idx = (dataLen-100):dataLen;
%             else
%                 idx = 1:dataLen;
%             end
            
%             csiBuff = csiBuff;%(idx,:);
%             tsBuff = tsBuff;%(idx);
            tsBuff= tsBuff - tsBuff(1);
            figure(fignum)
%             subplot(3,1,1)
            Y = tsBuff;
            X = [1:size(csiBuff,2)];
%             meshgrid(Y);
            mesh(X,Y,csiBuff)
            set(gca, 'Ydir', 'reverse')
            ylim([0 1.3*max(Y)])
            xlabel('subcarrier')
            ylabel('time - ms')
            zlabel('amplitude of csi')
        end
        function plotStatistics(obj,csi_new,fignum)
            varSet =[];
            for idx = 1:size(csi_new,1)
                sig = csi_new(idx,obj.selectedSC);
                varSet=[varSet;mean(sig),max(sig),min(sig),median(sig)];
            end
            figure(fignum)
            subplot(4,1,1)
            plot(varSet(:,1))
            title('mean amp')
            subplot(4,1,2)
            plot(varSet(:,2))
            title('max amp')
            subplot(4,1,3)
            plot(varSet(:,3))
            title('min amp')
            subplot(4,1,4)
            plot(varSet(:,4))
            title('median amp')
            
        end
        function plotFinal(obj,csiBuff,timeBuff,firstPCA,PtimeBuff,filtSig,frqSig,RRHz,...
                RRSet,RRTime,fignum,h_ann)
            figure(fignum);
            
            subplot(2,2,1)
            dataLen = size(csiBuff,1);
            if dataLen >100
                idx = (dataLen-100):dataLen;
            else
                idx = 1:dataLen;
            end
            csiBuff = csiBuff(idx,:);
            tsBuff = timeBuff(idx);
            Y = (tsBuff-tsBuff(1))/1e3;
            X = [1:size(csiBuff,2)];
            meshgrid(Y);
            mesh(X,Y,csiBuff)
            set(gca, 'Ydir', 'reverse')
             set(gca, 'Xdir', 'reverse')
            ylim([0 max(Y)])
            xlabel('Subcarrier')
            ylabel('time (s)')
            zlabel('Amplitude of csi')
            subplot(2,2,2)
           
            plot((PtimeBuff-PtimeBuff(1))/1e3,firstPCA)
            xlabel('time(s)')
            ylabel('Amplitude')
             title('Time domain Signal')
            subplot(2,2,3)
           
            plot(linspace(-obj.Fs*60/2,obj.Fs*60/2,length(frqSig)),fftshift(frqSig))
            xlabel('respiration spectrum (bpm)')
            ylabel('Amplitude')
             title('Frequency domain Signal')
            subplot(2,2,4)
            plot((RRTime-RRTime(1))/1e3,RRSet,'r*-')
            xlabel('Time (s)')
            ylabel('RR bpm')
            title('Respiration Rate Record')
            ylim([0 20])
             
            set(h_ann,'String',sprintf('Detected Respiration rate: %.2f bpm',RRHz*60))
            
        end
        function plotFinalGround(obj,csiBuff,timeBuff,firstPCA,PtimeBuff,filtSig,frqSig,RRHz,...
                RRSet,RRTime,fignum,h_ann,RR_bpm,curr_time)
            RR_bpm = RR_bpm(1:100:end);
            curr_time = curr_time(1:100:end);
            
            f = figure(fignum);
            f.WindowState = 'maximized';
%             pause(0.00001)
            subplot(2,2,1)
            dataLen = size(csiBuff,1);
            if dataLen >100
                idx = (dataLen-100):dataLen;
            else
                idx = 1:dataLen;
            end
            csiBuff = csiBuff(idx,:);
            tsBuff = timeBuff(idx);
            Y = (tsBuff-tsBuff(1))/1e3;
            X = [1:size(csiBuff,2)];
            meshgrid(Y);
            mesh(X,Y,csiBuff)
            set(gca, 'Ydir', 'reverse')
             set(gca, 'Xdir', 'reverse')
            ylim([0 max(Y)])
            xlabel('Subcarrier')
            ylabel('time (s)')
            zlabel('Amplitude of csi')
            subplot(2,2,2)
           
            plot((PtimeBuff-PtimeBuff(1))/1e3,firstPCA)
            xlabel('time(s)')
            ylabel('Amplitude')
             title('Time domain Signal')
            subplot(2,2,3)
           
            plot(linspace(-obj.Fs*60/2,obj.Fs*60/2,length(frqSig)),fftshift(frqSig))
            xlabel('respiration spectrum (bpm)')
            ylabel('Amplitude')
             title('Frequency domain Signal')
            subplot(2,2,4)
            plot((RRTime-RRTime(1))/1e3,RRSet,'r*-')
            hold on
            if(curr_time(1) < RRTime(end)./1e3)
                plot(curr_time(find(curr_time < RRTime(end)./1e3)) - RRTime(1)/1e3,RR_bpm(find(curr_time < RRTime(end)./1e3)),'b*-')
                legend('CSI based Resp. Rate', 'Ground Truth')
            end
            xlabel('Time (s)')
            ylabel('RR bpm')
            title('Respiration Rate Record')
            ylim([0 20])
             
            set(h_ann,'String',sprintf('Detected Respiration rate: %.2f bpm',RRHz*60))
            
        end
        function plotFinalGround2(obj,RR_CSI, RRTimeCSI, fignum, offline, RRTimeVER, RR_VER)
            f = figure(fignum);
            clf(f)
%             f.WindowState = 'maximized';
%             pause(0.0001)
            plot(RRTimeCSI, RR_CSI,'bo-','LineWidth',1.5)
%             plot([1:length(RR_CSI)], RR_CSI,'bo-','LineWidth',1.5)
            hold on
            x = [floor(RRTimeCSI(1)):ceil(RRTimeCSI(end))];
            plot(x,25.*ones(1,length(x)),'r--','LineWidth',0.8)
            plot(x,5.*ones(1,length(x)),'k--','LineWidth',0.8)
            if(offline)
                plot(RRTimeVER, RR_VER,'r*-','LineWidth',1.5)
                set(gca,'FontSize',25)
                xlabel('time(s)','Fontsize',25)
                ylabel('Respiration Rate bpm','Fontsize',25)
                legend('Resp. Rate from CSI','Resp. Rate from Force','Fontsize',25)
                rmse = sqrt(sum((RR_CSI - RR_VER).^2)/length(RR_CSI));
                title(['RMSE = ' num2str(rmse)],'Fontsize',30)
                ylim([0 30])
            else
                set(gca,'FontSize',25)
                xlabel('time(s)','Fontsize',25)
                yyaxis left
                ylabel('Respiration Rate (bpm)','Fontsize',25)
                ylim([0 30])
                yyaxis right
                ylim([0 30])
                yticks([0 2.5 5 7.5 10 12.5 15 17.5 20 22.5 25 27.5 30])
                yticklabels({'','Lower Abnormal Rate','5','','','','','','','Higher Abnormal Rate','25'})
                st = ['Respiration Rate = ' num2str(round(RR_CSI(end),1)) ' bpm'];
                title(st,'Fontsize',35,'Color','b')
                legend('Resp. Rate from CSI','Fontsize',25)
            end
        end
    end
end