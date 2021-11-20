
from scipy.io import savemat
import time
from gdx import gdx
import matplotlib.pyplot as plt
import scipy.signal as signal
import numpy
import math

gdx = gdx.gdx()

force = list()
RR_bpm = list()
curr_time = list()

# gdx.open_ble("GDX-RB 0K2024N0")
gdx.open_usb()
gdx.select_sensors([1,2])
gdx.start(100)
for i in range(0,3000):
    current_time = time.time()
    measurements = gdx.read()
    force.append(measurements[0])
    RR_bpm.append(measurements[1])
    curr_time.append(current_time)

    if measurements == None:
        break
    print(measurements)
    # f.write(str(measurements[0]) + '    ' + str(measurements[1]) + '\n')
savemat(r"ground_truth_11_19_2021_5min_100ms.mat", mdict={'force': force, 'RR_bpm': RR_bpm, 'curr_time': curr_time})
gdx.stop()
gdx.close()
