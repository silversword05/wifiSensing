clear all; clc; close all;

addpath('tcp_udp_ip');                          % Add path to folder containing tcp_udp_ip files
port = 11233;                                   % Local-Host Port to listen on to
% sock=pnet('tcpconnect','localhost',port);       % Creates tcp/ip connection to the specified 'hostname' and port
sock = tcpclient('localhost',port);
algo = wifisensAlgo();
BW = 80;        
CHIP = '4358';

acceptableDelay = 10;

sysTimeBuff = [];
stream1 = Stream(0);
stream2 = Stream(1);
stream3 = Stream(2);

if BW ==20
    pkt_len = 83;                                   % # of 32 bit chunks to extract for a packet
    len_field = 316;                                % Packet length included in Header
elseif BW == 80
    pkt_len = 275;                                   % # of 32 bit chunks to extract for a packet
    len_field = 1084;                                % Packet length included in Header
    selectedSC = 1:52;
    %53:104;%105:156;%53:104;%157:208; % for home; 157:208 for office
    %([7:32,34:59,71:96,98:123,135:160,162:187,199:224,226:251]);
end

algo.selectedSC = selectedSC;
algo.numCSIPkt4Anlysis = 100;


pktcnt = 1;
while(1)
    if(pktcnt == 1)
        data = read(sock,pkt_len+6,"uint32");%pnet(sock, 'read', pkt_len + 6, 'uint32', 'native');         %  data=pnet(con,'read' [,size] [,datatype] [,swapping] [,'view'] [,'noblock'])                                                                     % + 6 accounts for 6 chunks of 32bit Global Header that appears
        % once when starting to listen
    else
        data =  read(sock,pkt_len,"uint32");%pnet(sock, 'read', pkt_len, 'uint32', 'native');             %  data=pnet(con,'read' [,size] [,datatype] [,swapping] [,'view'] [,'noblock'])
    end    
    if(sum(data == len_field) == 2)                                         % look for 2 length fields (316) to sync to the Data frame
        
        frame_idx = find(data == len_field,1) - 2;                          % Find Index of the length field
        frame = data((frame_idx : frame_idx + pkt_len - 1));                % Extract Header + Payload
        [curTime, curCSI, csi_buff_raw,frameOut] = frame2CSI(frame,BW,CHIP);                 % Find the CSI of current Pkt
        
        
%         csiAbs = abs(curCSI);        
%         if sum(csiAbs(selectedSC))/sum(csiAbs)>0.6
%             pktcnt = pktcnt + 1;
%             continue
%         end
        
%         curCSI = abs(curCSI);
%         csiBuff=[csiBuff;curCSI];
%         rawCSIBuff = [rawCSIBuff; csi_buff_raw];
%         
%         [curDelay, curSysTime] = algo.showDelay(curTime);
%         timeBuff = [timeBuff curTime];
%         sysTimeBuff = [sysTimeBuff curSysTime];
%         delayBuff = [delayBuff curDelay];
        
        [curDelay, curSysTime] = algo.showDelay(curTime);
        sysTimeBuff = [sysTimeBuff curSysTime];
        disp(curSysTime);
%       Filtering on the basis of the antenna radio
        switch frameOut.sstreamNum
            case 0
                stream1 = stream1.process_data(frameOut.coreNum, curCSI, csi_buff_raw, curTime, curSysTime, curDelay);
            case 1
                stream2 = stream2.process_data(frameOut.coreNum, curCSI, csi_buff_raw, curTime, curSysTime, curDelay);
            case 2
                stream3 = stream3.process_data(frameOut.coreNum, curCSI, csi_buff_raw, curTime, curSysTime, curDelay);
        end
        % stop collecting data after 5 minutes
        if((sysTimeBuff(end) - sysTimeBuff(1))/1e3 > 30)
            stream1 = stream1.merge_buffers(acceptableDelay);
            stream2 = stream2.merge_buffers(acceptableDelay);
            stream3 = stream3.merge_buffers(acceptableDelay);
            
            N1 = size(stream1.pdSignal,1);
            N2 = size(stream2.pdSignal,1);
            N3 = size(stream3.pdSignal,1);

            N = min([N1 N2 N3]);

            pd_signal = cat(3, stream1.pdSignal(1:N,:), stream2.pdSignal(1:N,:), stream3.pdSignal(1:N,:));
            save('data/pd_signal.mat', 'pd_signal');
            save('data/csi_signal.mat',"stream1","stream2","stream3")
            keyboard
        end

%       if(mod(pktcnt,50) == 0)
%           algo.plotCSIBuff(abs(csiBuff(1:size(timeBuff,2),:)),timeBuff,1)
%       end

    end
    pktcnt = pktcnt+1;
end

%         if pktcnt >51
%             algo.plotCSIBuff(initCSIBuff,timeBuff_s,1)            
%         end
