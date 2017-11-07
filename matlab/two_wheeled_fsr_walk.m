fsr2 = csvread('two-wheels\data_force_4_axis_test2.csv', 1, 1);
fsr3 = csvread('two-wheels\data_force_4_axis_test3.csv', 1, 1);
fsr4 = csvread('two-wheels\data_force_4_axis_test4.csv', 1, 1);

PlotFSRData(fsr2, 1, 0)
PlotFSRData(fsr3, 1, 0)
PlotFSRData(fsr4, 1, 0)
