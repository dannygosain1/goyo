csv_data = csvread('two-wheels\data_force_4_axis_test2.csv', 1, 1);
outside = csv_data(:,3);

% figure
% subplot(4,1,1)
% plot(csv_data(:,1));
% title('inside sensor');
% 
% subplot(4,1,2)
% plot(csv_data(:,2));
% title('bottom sensor');
% 
% subplot(4,1,3)
% plot(csv_data(:,3));
% title('outside sensor');
% 
% subplot(4,1,4)
% plot(csv_data(:,4));
% title('top sensor');

out_no_gain = detrend(outside);

out_freq = fftshift(fft(out_no_gain));
top_freq = fftshift(fft(csv_data(:,4)));

peak = 78;

filt = ones(length(out_freq));
filt_sup = zeros(21, 1);
filt(peak-10:peak+10) = filt_sup;

filtered_out = filt*out_freq;

figure
subplot(2,1,1)
plot(abs(out_freq));
xlabel('Frequency');
title('Magnitude Response of outside sensor - No Gain');

subplot(2,1,2);
plot(ifft(out_freq));
xlabel('Time');
title('Time domain data - No Gain');
% subplot(2,1,2)
% plot(abs(filtered_out));
% xlabel('Frequency');
% title('Filtered outside sensor');

% subplot(2,1,2);
% plot(out_no_gain);
% title('Time domain - No gain');


% subplot(2,1,2)
% plot(abs(top_freq));
% xlabel('Frequency');
% title('Magnitude Response of top sensor');