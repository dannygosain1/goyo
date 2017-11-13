csv_data = csvread('two-wheels\data_force_4_axis_test2.csv', 1, 1);
outside = csv_data(:,3);
top = csv_data(:,4);

outside1 = outside(25:70);
outside2 = outside(80:145);
[c, l] = wavedec(outside,3,'db1');
[cd1,cd2,cd3] = detcoef(c,l,[1 2 3]);

figure;
subplot(2,2,1);
plot(outside1)
title('outside')

subplot(2,2,2);
plot(cd1)
title('cd1')

subplot(2,2,3);
plot(cd2)
title('cd2')

subplot(2,2,4);
plot(cd3)
title('cd3')


sampling_rate = 10;
dt = 1/sampling_rate;
t = (0:dt:length(outside1)/10 - 0.1)';
N = length(t);
dF = sampling_rate/N;
f = -sampling_rate/2:dF:sampling_rate/2-dF;

out1_no_gain = detrend(outside1);
out1_freq = fftshift(fft(out1_no_gain));


figure;
stem(f, abs(out1_freq));


