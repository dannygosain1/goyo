nwwalker1 = csvread('no-wheels\walker-1.csv', 1);
nwwalker2 = csvread('no-wheels\walker-2.csv', 1);
nwwalker3 = csvread('no-wheels\walker-3.csv', 1);
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

z_accel = (nwwalker2(:,3));
x_accel = (nwwalker2(:,1));
y_accel = (nwwalker2(:,2));

sampling_rate = 10;
dt = 1/sampling_rate
t = (0:dt:length(z_accel)/10 - 0.1)'
N = length(t);

Z = fftshift(fft(z_accel));
X = fftshift(fft(x_accel));
Y = fftshift(fft(y_accel));
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
