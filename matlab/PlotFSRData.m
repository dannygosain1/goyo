function [ ] = PlotFSRData( csv_data )
% Plots a figure with 4 subplots, one for each fsr
%   expected data format:
%       fsr0, fsr1, fsr2, fsr4

figure
subplot(4,1,1)
plot(csv_data(:,1));
title('inside sensor');

subplot(4,1,2)
plot(csv_data(:,2));
title('bottom sensor');

subplot(4,1,3)
plot(csv_data(:,3));
title('outside sensor');

subplot(4,1,4)
plot(csv_data(:,4));
title('top sensor');

end

