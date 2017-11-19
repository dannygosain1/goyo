function [ standardized ] = StandardizeFeatures( raw_vectors )
%STANDARDIZEFEATURES converts the features to their z-score in a standard
%distribution. Do not give it the raw data directly, because the first
%column contains a 1 or 0 for its classification.
%   
mean_subtraction = bsxfun(@minus, raw_vectors, mean(raw_vectors));
standardized = bsxfun(@rdivide, mean_subtraction, std(raw_vectors));
end

