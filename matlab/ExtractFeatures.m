% Script that takes data and extracts all the signal features

walkclassified = csvread('two-wheels-second-data\Combined Data\walk5_classified.csv', 1);

is_walking = walkclassified(:,1);
fsr_data = walkclassified(:,2:3);
top_data = walkclassified(:,4:6);
side_data = walkclassified(:,7:9);
corner_data = walkclassified(:,10:12);
front_data = walkclassified(:,13:15);

walktop = [is_walking fsr_data corner_data];
walkside = [is_walking fsr_data side_data];
walkcorner = [is_walking fsr_data corner_data];
walkfront = [is_walking fsr_data front_data];

num_features = 12;
rate = 24;          % Hz
window_size = 2;    % sec
window_overlap = 1; % sec
windows = WindowCreation(walktop, rate, window_size, window_overlap);

feature_data = zeros(length(windows), num_features);

for k=1:length(windows)
    cur_window = windows{k};
    feature_data(k,:) = ExtractSignalFeatures(cur_window);
end
csvwrite('feature-vectors\walk5top_raw.csv', feature_data)