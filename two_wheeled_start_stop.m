twwalker1 = csvread('two-wheels\walker-1.csv', 1);
twwalker2 = csvread('two-wheels\walker-2.csv', 1);
twwalker3 = csvread('two-wheels\walker-3.csv', 1);

twwalker1_start_to_stop =  twwalker1(120:300, :);

AccelerometerAnalysis(twwalker1_start_to_stop);
