
% plot(nwwalker1(:,1));
% title('x-accel');
% 
% figure;
% plot(nwwalker1(:,2));
% title('y-accel');
% 
% figure
% plot(nwwalker1(:,3));
% title('z-accel');
% 
twwalker1 = csvread('two-wheels\walker-1.csv', 1);
twwalker2 = csvread('two-wheels\walker-2.csv', 1);
twwalker3 = csvread('two-wheels\walker-3.csv', 1);
twwalker4 = csvread('two-wheels\walker-3.csv', 1);
% plot(twwalker1(:,1));
% title('x-accel');
% 
% figure;
% plot(twwalker1(:,2));
% title('y-accel');
% 
% figure
% plot(twwalker1(:,3));
% title('z-accel');

z_accel = (twwalker1(:,3));
x_accel = (twwalker1(:,1));
y_accel = (twwalker1(:,2));
mean(twwalker2(:,3));

sampling_rate = 10;
dt = 1/sampling_rate
t = (0:dt:length(z_accel)/10 - 0.1)'
N = length(t);

Z = fftshift(fft(z_accel));
X = fftshift(fft(x_accel));
dF = sampling_rate/N;
f = -sampling_rate/2:dF:sampling_rate/2-dF;
%% Plot the spectrum:
figure;
stem(f,abs(Z));
xlabel('Frequency)');
title('Magnitude Response of Z');
figure
plot(z_accel);
title('Z Acceleration')
figure;
stem(f,abs(X));
xlabel('Frequency (in hertz)');
title('Magnitude Response of X');
figure;