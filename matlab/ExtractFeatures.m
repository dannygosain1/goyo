% Script that takes data and extracts all the signal features

twwalker1 = csvread('two-wheels\walker-1.csv', 1);
z_accel = twwalker1(:,3);

num_features = 3;
rate = 10;          % Hz
window_size = 2;    % sec
window_overlap = 1; %sec
windows = WindowCreation(z_accel, rate, window_size, window_overlap);

feature_data = zeros(length(windows), num_features);

for k=1:length(windows)
    cur_window = windows{k};
    feature_data(k,:) = ExtractSignalFeatures(cur_window);
end