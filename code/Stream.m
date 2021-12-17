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
   end
end