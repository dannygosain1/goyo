function [ feature_vector ] = ExtractSignalFeatures( sample )
% ExtractSignalFeatures Returns a feature vector with characteristics of interest 
%   Given a Nx1 vector representing accelerometer data, this function will
%   return a feature vector of the form 
%   feature size: 12
% [is_walking, fsr_median (2), mean (3), variance (3), energy (3)]
    sample_mean = mean(sample(:,4:6));
    sample_var = var(sample(:, 4:6));
    sample_energy = bandpower(sample(:,4:6));
    is_walking = mode(sample(:,1));
    sample_fsr = median(sample(:,2:3));
    feature_vector = [is_walking, sample_fsr, sample_mean sample_var, sample_energy];
end
