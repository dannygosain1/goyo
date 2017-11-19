% Script that takes data and extracts all the signal features

twwalker1 = csvread('two-wheels\walker-2.csv', 1);
fsr1 = csvread('two-wheels\data_force_4_axis_test2.csv', 1, 1);

time_fsr = fsr1(:,1);
outside_fsr = fsr1(:,3);
top_fsr = fsr1(:,4);
% oops, matching this will be hard :(

num_features = 12;
rate = 24;          % Hz
window_size = 2;    % sec
window_overlap = 1; %sec
windows = WindowCreation(walk6corner, rate, window_size, window_overlap);

feature_data = zeros(length(windows), num_features);

for k=1:length(windows)
    cur_window = windows{k};
    feature_data(k,:) = ExtractSignalFeatures(cur_window);
end