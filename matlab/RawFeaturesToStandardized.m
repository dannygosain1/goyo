walk6corner_raw = csvread('feature-vectors\walk6corner_raw.csv', 1);
walk6top_raw = csvread('feature-vectors\walk6top_raw.csv', 1);
walk6side_raw = csvread('feature-vectors\walk6side_raw.csv', 1);
walk6front_raw = csvread('feature-vectors\walk6front_raw.csv', 1);

%all the classifications are the same for all of them

classifications = walk6corner_raw(:,1);

standard_corner = StandardizeFeatures(walk6corner_raw(:,2:12));
standard_top = StandardizeFeatures(walk6top_raw(:,2:12));
standard_side = StandardizeFeatures(walk6side_raw(:,2:12));
standard_front = StandardizeFeatures(walk6corner_raw(:,2:12));


csvwrite('feature-vectors\walk6corner_standard.csv', horzcat(classifications, standard_corner))
csvwrite('feature-vectors\walk6top_standard.csv', horzcat(classifications, standard_top))
csvwrite('feature-vectors\walk6side_standard.csv', horzcat(classifications, standard_side))
csvwrite('feature-vectors\walk6front_standard.csv', horzcat(classifications, standard_front))