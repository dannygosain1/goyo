function [ feature_vector ] = ExtractSignalFeatures( sample )
% ExtractSignalFeatures Returns a feature vector with characteristics of interest 
%   Given a Nx1 vector representing accelerometer data, this function will
%   return a feature vector of the form [mean, variance, max]

    sample_mean = mean(sample);
    sample_var = var(sample);
    sample_max = max(abs(sample));
    
    feature_vector = [sample_mean sample_var, sample_max];

end

