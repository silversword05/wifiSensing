algo = wifisensAlgo_v3();
load('DataLog0712_0People_50ms_03_sam.mat')
selectedSC = 1:52;
algo.selectedSC = selectedSC;
CSIAmpBuff = abs(csiBuff);
algo = algo.SNRCalc(CSIAmpBuff);
csi1 = csiBuff(1:2:end-1, :);
csi2 = csiBuff(2:2:end,:);


anom1 = [];
anom2 = [];
[csi1, anom1] = anomalyRemover(algo, anom1, csi1, 0);
[csi2, anom2] = anomalyRemover(algo, anom2, csi2,0);

mesh(abs(csi1(:, 1:52)));

   function [csiBuff, anom]=anomalyRemover(algo,anom, csiBuff,curDelay)
   scalingFactor = 2
    for idx = 1:size(csiBuff,1)
        sig = csiBuff(idx,:);
        anomFlag = algo.anomalyRemove(sig,scalingFactor);
      
       
        if(anomFlag == 1)
            anom(end +1) = idx;
            csiBuff(idx,1:52) = zeros(1,52);
        end
    end
   end