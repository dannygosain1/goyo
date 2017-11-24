walkData = csvread('demo/raw.csv', 1);

num_features = 12;
rate = 24;          % Hz
window_size = 2;    % sec
window_overlap = 1; % sec
windows = WindowCreation(walkData, rate, window_size, window_overlap);

feature_data = zeros(length(windows), num_features);

for k=1:length(windows)
    cur_window = windows{k};
    feature_data(k,:) = ExtractSignalFeatures(cur_window);
end
csvwrite('demo/raw_features.csv', feature_data)
classifications = feature_data(:,1);
standardized_data = StandardizeFeatures(feature_data(:,2:12));
csvwrite('demo/standard_features.csv', horzcat(classifications, standardized_data))