function [ feature_vector ] = ExtractSignalFeatures( sample )
% ExtractSignalFeatures Returns a feature vector with characteristics of interest 
%   Given a Nx1 vector representing accelerometer data, this function will
%   return a feature vector of the form [mean, variance, energy]


    sample_fourier = fft(sample);
    
    sample_mean = mean(sample);
    sample_var = var(sample);
    sample_energy = sum(sample_fourier.*conj(sample_fourier));
    
    feature_vector = [sample_mean sample_var, sample_energy];

end
