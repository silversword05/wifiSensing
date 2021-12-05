classdef Antenna
   properties
      coreNum {mustBeNumeric}
      csiBuff=[]
      rawCSIBuff = [];
      timeBuff=[];
      sysTimeBuff = [];
      delayBuff = [];
   end
   methods
       function obj = Antenna(coreNum)
            obj.coreNum = coreNum;
        end
        function antenna = populate_buffer(antenna, curCSI, csi_buff_raw, curTime, curSysTime, curDelay)
            antenna.csiBuff=[antenna.csiBuff;curCSI];
            antenna.rawCSIBuff = [antenna.rawCSIBuff; csi_buff_raw];
            antenna.timeBuff = [antenna.timeBuff curTime];
            antenna.sysTimeBuff = [antenna.sysTimeBuff curSysTime];
            antenna.delayBuff = [antenna.delayBuff curDelay];
        end
   end
end