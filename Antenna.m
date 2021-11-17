classdef Antenna
   properties
      Value {mustBeNumeric}
      csiBuff=[]
      rawCSIBuff = [];
      timeBuff=[];
      sysTimeBuff = [];
      delayBuff = [];
   end
   methods
        function obj = Antenna(val)
            if(val == 0)
                obj.Value = 1;
            else
                obj.Value = 2;
            end
        end
        function antenna = populateBuffers(antenna, curCSI, csi_buff_raw, curTime, curSysTime, curDelay)
            antenna.csiBuff=[antenna.csiBuff;curCSI];
            antenna.rawCSIBuff = [antenna.rawCSIBuff; csi_buff_raw];
            antenna.timeBuff = [antenna.timeBuff curTime];
            antenna.sysTimeBuff = [antenna.sysTimeBuff curSysTime];
            antenna.delayBuff = [antenna.delayBuff curDelay];
        end
   end
end