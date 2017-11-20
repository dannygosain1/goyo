walkcorner_raw = csvread('feature-vectors\walk3corner_raw.csv', 1);
walktop_raw = csvread('feature-vectors\walk3top_raw.csv', 1);
walkside_raw = csvread('feature-vectors\walk3side_raw.csv', 1);
walkfront_raw = csvread('feature-vectors\walk3front_raw.csv', 1);

%all the classifications are the same for all of them

classifications = walkcorner_raw(:,1);

standard_corner = StandardizeFeatures(walkcorner_raw(:,2:12));
standard_top = StandardizeFeatures(walktop_raw(:,2:12));
standard_side = StandardizeFeatures(walkside_raw(:,2:12));
standard_front = StandardizeFeatures(walkcorner_raw(:,2:12));


csvwrite('feature-vectors\walk6corner_standard.csv', horzcat(classifications, standard_corner))
csvwrite('feature-vectors\walk6top_standard.csv', horzcat(classifications, standard_top))
csvwrite('feature-vectors\walk6side_standard.csv', horzcat(classifications, standard_side))
csvwrite('feature-vectors\walk6front_standard.csv', horzcat(classifications, standard_front))