csv_data = csvread('two-wheels\data_force_4_axis_test2.csv', 1, 1);
outside = csv_data(:,3);
top = csv_data(:,4);

sampling_rate = 10;
dt = 1/sampling_rate;
t = (0:dt:length(outside)/10 - 0.1)';
N = length(t);
dF = sampling_rate/N;
f = -sampling_rate/2:dF:sampling_rate/2-dF;

out_no_gain = detrend(outside);

out_freq = fftshift(fft(out_no_gain));
top_freq = fftshift(fft(csv_data(:,4)));

peak = 78;

filt = ones(length(out_freq));
filt_sup = zeros(21, 1);
filt(peak-10:peak+10) = filt_sup;

filtered_out = filt*out_freq;

figure
% subplot(2,1,1)
stem(f, abs(out_freq));
xlabel('Frequency');
title('Magnitude Response of outside sensor - No Gain');

highpass = designfilt('highpassfir', 'StopbandFrequency', 0.71, 'PassbandFrequency', 0.85, 'StopbandAttenuation', 60, 'PassbandRipple', 1, 'SampleRate', 10);
highpass2 = designfilt('highpassfir', 'StopbandFrequency', .75, 'PassbandFrequency', .81, 'StopbandAttenuation', 60, 'PassbandRipple', 1, 'SampleRate', 10);
highpass3 = designfilt('highpassfir', 'StopbandFrequency', .76, 'PassbandFrequency', .8, 'StopbandAttenuation', 60, 'PassbandRipple', 1, 'SampleRate', 10);
highpass4 = designfilt('highpassfir', 'StopbandFrequency', .77, 'PassbandFrequency', 0.79, 'StopbandAttenuation', 60, 'PassbandRipple', 1, 'SampleRate', 10);

lowpass1 = designfilt('lowpassfir', 'PassbandFrequency', 0.2, 'StopbandFrequency', 0.25, 'PassbandRipple', 1, 'StopbandAttenuation', 60, 'SampleRate', 10);

target_filt = lowpass1;

figure
subplot(2,1,1)
plot(filter(target_filt, outside))
title('High pass filtered outside sensor')
subplot(2,1,2)
plot(filter(target_filt, top))
title('High pass filtered top sensor')

% subplot(2,1,2);
% plot(ifft(out_freq));
% xlabel('Time');
% title('Time domain data - No Gain');
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