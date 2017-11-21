walkcorner_raw = csvread('feature-vectors\walk5corner_raw.csv');
walktop_raw = csvread('feature-vectors\walk5top_raw.csv');
walkside_raw = csvread('feature-vectors\walk5side_raw.csv');
walkfront_raw = csvread('feature-vectors\walk5front_raw.csv');

%all the classifications are the same for all of them

classifications = walkcorner_raw(:,1);

standard_corner = StandardizeFeatures(walkcorner_raw(:,2:12));
standard_top = StandardizeFeatures(walktop_raw(:,2:12));
standard_side = StandardizeFeatures(walkside_raw(:,2:12));
standard_front = StandardizeFeatures(walkcorner_raw(:,2:12));


csvwrite('feature-vectors\walk5corner_standard.csv', horzcat(classifications, standard_corner))
csvwrite('feature-vectors\walk5top_standard.csv', horzcat(classifications, standard_top))
csvwrite('feature-vectors\walk5side_standard.csv', horzcat(classifications, standard_side))
csvwrite('feature-vectors\walk5front_standard.csv', horzcat(classifications, standard_front))