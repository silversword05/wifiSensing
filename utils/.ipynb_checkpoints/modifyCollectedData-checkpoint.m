clear all; clc; close all;

load('data/csi_signal.mat');

totalRowCount = size(stream1.antenna1.csiBuff, 1) + size(stream1.antenna2.csiBuff, 1);
totalRowCount = totalRowCount + size(stream2.antenna1.csiBuff, 1) + size(stream2.antenna2.csiBuff, 1);
totalRowCount = totalRowCount + size(stream3.antenna1.csiBuff, 1) + size(stream3.antenna2.csiBuff, 1);

% total channel count + 3 time stamp + core & stream info + real/imaginary
columCount = size(stream1.antenna1.csiBuff, 2) + 3 + 2 + 1;
% row count is twice because there is real and imaginary
finalMatrix = -1*ones(totalRowCount*2, columCount);

% stream 1 antenna 1 real
offset = 0;
stream1Ant1Size = size(stream1.antenna1.csiBuff);
finalMatrix = fillFinalMatrix(finalMatrix, offset, stream1Ant1Size, stream1.antenna1, 1, 1, 0);
% stream 1 antenna 1 imag
offset = offset + stream1Ant1Size(1);
finalMatrix = fillFinalMatrix(finalMatrix, offset, stream1Ant1Size, stream1.antenna1, 1, 1, 1);

% stream 1 antenna 2 real
offset = offset + stream1Ant1Size(1);
stream1Ant2Size = size(stream1.antenna2.csiBuff);
finalMatrix = fillFinalMatrix(finalMatrix, offset, stream1Ant2Size, stream1.antenna2, 1, 2, 0);
% stream 1 antenna 2 imag
offset = offset + stream1Ant2Size(1);
finalMatrix = fillFinalMatrix(finalMatrix, offset, stream1Ant2Size, stream1.antenna2, 1, 2, 1);

% stream 2 antenna 1 real
offset = offset + stream1Ant2Size(1);
stream2Ant1Size = size(stream2.antenna1.csiBuff);
finalMatrix = fillFinalMatrix(finalMatrix, offset, stream2Ant1Size, stream2.antenna1, 2, 1, 0);
% stream 2 antenna 1 imag
offset = offset + stream2Ant1Size(1);
finalMatrix = fillFinalMatrix(finalMatrix, offset, stream2Ant1Size, stream2.antenna1, 2, 1, 1);

% stream 2 antenna 2 real
offset = offset + stream2Ant1Size(1);
stream2Ant2Size = size(stream2.antenna2.csiBuff);
finalMatrix = fillFinalMatrix(finalMatrix, offset, stream2Ant2Size, stream2.antenna2, 2, 2, 0);
% stream 2 antenna 2 imag
offset = offset + stream2Ant2Size(1);
finalMatrix = fillFinalMatrix(finalMatrix, offset, stream2Ant2Size, stream2.antenna2, 2, 2, 1);

% stream 3 antenna 1 real
offset = offset + stream2Ant2Size(1);
stream3Ant1Size = size(stream3.antenna1.csiBuff);
finalMatrix = fillFinalMatrix(finalMatrix, offset, stream3Ant1Size, stream3.antenna1, 3, 1, 0);
% stream 3 antenna 1 imag
offset = offset + stream3Ant1Size(1);
finalMatrix = fillFinalMatrix(finalMatrix, offset, stream3Ant1Size, stream3.antenna1, 3, 1, 1);

% stream 3 antenna 2 real
offset = offset + stream3Ant1Size(1);
stream3Ant2Size = size(stream3.antenna2.csiBuff);
finalMatrix = fillFinalMatrix(finalMatrix, offset, stream3Ant2Size, stream3.antenna2, 3, 2, 0);
% stream 3 antenna 1 imag
offset = offset + stream3Ant2Size(1);
finalMatrix = fillFinalMatrix(finalMatrix, offset, stream3Ant2Size, stream3.antenna2, 3, 2, 1);

writematrix(finalMatrix,'data/stream-antenna-data.csv')

function finalMatrix = fillFinalMatrix(finalMatrix, offset, sizeTuple, antennaObj, streamNum, antennaNum, realImagCoeff)
    if realImagCoeff == 0
        finalMatrix(offset+1: offset + sizeTuple(1), 1:sizeTuple(2)) = real(antennaObj.csiBuff);
    else 
        finalMatrix(offset+1: offset + sizeTuple(1), 1:sizeTuple(2)) = imag(antennaObj.csiBuff);
    end
    finalMatrix(offset+1: offset + sizeTuple(1), sizeTuple(2)+1) = antennaObj.timeBuff';
    finalMatrix(offset+1: offset + sizeTuple(1), sizeTuple(2)+2) = antennaObj.sysTimeBuff';
    finalMatrix(offset+1: offset + sizeTuple(1), sizeTuple(2)+3) = antennaObj.delayBuff';
    finalMatrix(offset+1: offset + sizeTuple(1), sizeTuple(2)+4) = streamNum*ones(sizeTuple(1), 1)';
    finalMatrix(offset+1: offset + sizeTuple(1), sizeTuple(2)+5) = antennaNum*ones(sizeTuple(1),1)';
    finalMatrix(offset+1: offset + sizeTuple(1), sizeTuple(2)+6) = realImagCoeff*ones(sizeTuple(1),1)';
end

