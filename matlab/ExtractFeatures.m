% Script that takes data and extracts all the signal features

twwalker1 = csvread('two-wheels\walker-2.csv', 1);
fsr1 = csvread('two-wheels\data_force_4_axis_test2.csv', 1, 1);

x_accel = twwalker1(:,1);
y_accel = twwalker1(:,2);
z_accel = twwalker1(:,3);
time_fsr = fsr1(:,1);
outside_fsr = fsr1(:,3);
top_fsr = fsr1(:,4);
% oops, matching this will be hard :(

num_features = 9;
rate = 10;          % Hz
window_size = 2;    % sec
window_overlap = 1; %sec

xwindows = WindowCreation(x_accel, rate, window_size, window_overlap);
ywindows = WindowCreation(y_accel, rate, window_size, window_overlap);
zwindows = WindowCreation(z_accel, rate, window_size, window_overlap);

feature_data = zeros(length(zwindows), num_features);

for k=1:length(zwindows)
    xcur_window = xwindows{k};
    ycur_window = ywindows{k};
    zcur_window = zwindows{k};
    
    feature_data(k,1:3) = ExtractSignalFeatures(xcur_window);
    feature_data(k,4:6) = ExtractSignalFeatures(ycur_window);
    feature_data(k,7:9) = ExtractSignalFeatures(zcur_window);
end