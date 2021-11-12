%% csireader.m
%
% read and plot CSI from UDPs created using the nexmon CSI extractor (nexmon.org/csi)
% modify the configuration section to your needs
% make sure you run >mex unpack_float.c before reading values from bcm4358 or bcm4366c0 for the first time
%
% the example.pcap file contains 4(core 0-1, nss 0-1) packets captured on a bcm4358
%
% Usage: [csi_time_stamp, csi_feature_buffer] = csi_feature(csi_filename);
% The BW should be 80 MHz in this implementation.

function [time_stamp_new, csi_buff_new, csi_buff_raw,frameOut] = frame2CSI(frame,BW,CHIP)

% Time stamp return the time of current packet
% csi_buff_new returns the csi without abnormal sub carriers
% csi_buff_raw returns the csi with all sub-carriers

%CHIP = '4339';          % wifi chip (possible values 4339, 4358, 43455c0, 4366c0)
if(BW ==20)             % list of valid sub-carriers for BW = 20
    nullCarrierIndex =[-32:-27,0,27:31]+33;
elseif BW==80
    nullCarrierIndex =[-128:-123, -1:1,123:127]+129;
end

%% Read Frame
HOFFSET = 16;           % header offset
NFFT = BW*3.2;          % fft size
THRESHOLD = 50;
csi_buff_raw = complex(zeros(1,NFFT),0);
time_stamp = [];
len_incl = [];

ts_sec = frame(1);              % get the time stamp
ts_usec = frame(2);             % get the micro-second time stamp
orig_len = frame(4);            % get the original length of payload

 
time_stamp = [time_stamp, double(ts_sec)*1000 + double(ts_usec)/1000.0];
len_incl = [len_incl, orig_len];
if orig_len-(HOFFSET-1)*4 ~= NFFT*4
    disp('skipped frame with incorrect size');
    return;
end
payload = frame(5:end);                     % Extract the payload
% get more info 
last2words = payload(HOFFSET-2);
last2bytes = typecast(last2words,'uint8');
strcoreByte = last2bytes(3);
frameOut.sstreamNum = bitshift(strcoreByte,-3);
frameOut.coreNum = bitand(strcoreByte,0b00000111);
last4words = payload(HOFFSET-4);
last4bytes = typecast(last4words,'uint8');
rssiByte = last4bytes(1);
frameOut.lastRssi = typecast(rssiByte,'int8');
frameOut.seqNum = typecast(last2bytes(1:2),'uint16');
frameOut.frameControl=typecast(last4bytes(2),'uint8');
%fprintf('a new frame:\n')
%typecast(payload(HOFFSET-5:HOFFSET-1),'uint8')

H = payload(HOFFSET:HOFFSET+NFFT-1);        % Extract the payload portion containing csi info
if (strcmp(CHIP,'4339') || strcmp(CHIP,'43455c0'))
    Hout = typecast(H, 'int16');
elseif (strcmp(CHIP,'4358'))
    Hout = unpack_float(int32(0), int32(NFFT), H);
elseif (strcmp(CHIP,'4366c0'))
    Hout = unpack_float(int32(1), int32(NFFT), H);
else
    disp('invalid CHIP');
    return;
end
Hout = reshape(Hout,2,[]).';
cmplx = double(Hout(1:NFFT,1))+1j*double(Hout(1:NFFT,2));               % get the complex value out it
csi_buff_raw = cmplx.';
%csi_buff_raw = fftshift(csi_buff_raw);                                  % shifts zero frequency component to the center of the spectrum

%% Extract the subcarriers that are valid
csi_buff_new = [];
time_stamp_new = [];
if(BW == 80)
    time_stamp_new = double(time_stamp);
    
    csi_buff_new=csi_buff_raw([7:32,34:59,71:96,98:123,135:160,162:187,199:224,226:251]);
    
elseif(BW == 20)
    csi_buff_new = csi_buff_raw;
    csi_buff_new(nullCarrierIndex)=[];
    time_stamp_new = double(time_stamp);
end

return

