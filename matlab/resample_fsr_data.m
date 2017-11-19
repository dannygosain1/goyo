%resamples acceleration data and writes it to different files
orig = csvread('two-wheels-second-data\FSR\data_walk6.csv', 1, 1);
resampled = resample(orig, 24, 10);
csvwrite('two-wheels-second-data\FSR\data_walk6_resampled.csv', resampled)