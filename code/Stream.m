classdef Stream
   properties
      spatialStream {mustBeNumeric}
      antenna1 = Antenna.empty;
      antenna2 = Antenna.empty; 
      pdSignal=[]
      timeBuff=[];
      sysTimeBuff = [];
      delayBuff = [];
   end
   methods
       function obj = Stream(spatialStream)
            obj.spatialStream = spatialStream;
            obj.antenna1 = Antenna(0);
            obj.antenna2 = Antenna(1); 
        end
        function stream = process_data(stream, coreNum, curCSI, csiBuffRaw, curTime, curSysTime, curDelay)
            if coreNum == 0
                stream.antenna1 = stream.antenna1.populate_buffer(curCSI, csiBuffRaw, curTime, curSysTime, curDelay);
            else
                stream.antenna2 = stream.antenna2.populate_buffer(curCSI, csiBuffRaw, curTime, curSysTime, curDelay);
            end
        end
        function stream = merge_buffers(stream, acceptableDelay)
            ix1 = 1; ix2 = 1;
            N1 = size(stream.antenna1.csiBuff, 1);
            N2 = size(stream.antenna2.csiBuff, 1);
            disp(N1);
            disp(N2);
            while (ix1 < N1) && (ix2 < N2)
                % compute the delay between the csi frames
                frameDelay = abs(stream.antenna1.sysTimeBuff(ix1) - stream.antenna2.sysTimeBuff(ix2));
                disp(frameDelay);
                if frameDelay < acceptableDelay
                    % phase difference of the csi from two antenna
                    phaseDifference = angle(stream.antenna1.csiBuff(ix1,:)) - angle(stream.antenna1.csiBuff(ix1,:));
                    stream.pdSignal = [stream.pdSignal; phaseDifference];
                    % store the timestamp, elapsed time, delay
                    stream.timeBuff = [stream.sysTimeBuff stream.antenna1.timeBuff(ix1)];
                    stream.delayBuff = [stream.sysTimeBuff stream.antenna1.delayBuff(ix1)];
                    stream.sysTimeBuff = [stream.sysTimeBuff stream.antenna1.sysTimeBuff(ix1)];
                    ix1 = ix1 + 1;
                    ix2 = ix2 + 1;
                elseif (stream.antenna1.sysTimeBuff(ix1) - stream.antenna2.sysTimeBuff(ix2)) < 0
                    % effectively drop the earlier frame
                    ix1 = ix1 + 1;
                else
                    ix2 = ix2 + 1;
                end
            end
            stream.pdSignal = [stream.pdSignal stream.sysTimeBuff' stream.timeBuff' stream.delayBuff'];
        end
   end
end