function [windows] = WindowCreation(data, rate, window_size, window_overlap)
    % Returns a set of windows of the data matrix
    % specify the sampling rate in hz, the window size (in s) and the
    % window overlap in s
    end_idx = window_size * rate;
    windows = {};
    count = 1;
    while(end_idx <= length(data))
        start_idx = end_idx - window_size*rate  + 1
        windows{count} = data(start_idx : end_idx, :);
        end_idx = end_idx + (window_size - window_overlap) * rate;
        if end_idx > length(data)
           windows{count} = data(start_idx : length(data), :);
        end
        count = count + 1;

    end
end
