%**************************************************************************
%   function model = two_cov_em(matrixID, model, stats)
%
%   Learn a two-covariance PLDA model given training data using EM 
%   algorithm.
%
%   Input:
%       matrixID - NSample x nIdentity  Identity matrix of training data
%       model - two-covariance PLDA model with the following parameters
%           invB - NFeature x NFeature Between individual covariance matrix 
%           invW - NFeature x NFeature Within individual covariance matrix 
%           mu  - NFeature x 1  Mean vector of the data
%       stats - Statistics of the training data:
%           N - Zero-order statistic
%           f - First-order statistic
%           S - Second-order statistic
%       
%   Output:
%       model - two-covariance PLDA model with the following parameters
%           invB - NFeature x NFeature Between individual covariance matrix 
%           invW - NFeature x NFeature Within individual covariance matrix 
%           mu  - NFeature x 1  Mean vector of the data
% 
% Aleksandr Sizov, UEF 2014
%**************************************************************************
function model = two_cov_em(matrixID, model, stats)
N = stats.N;
S = stats.S;

% E-step
[T R Y] = two_cov_E_step(model, matrixID, stats.f);

% M-step
mu = Y / N;
invB = (R - mu*Y' - Y*mu')/N + mu*mu';
invW = (S - T - T' + R)/N;

% Store the trained PLDA model
model.invB = invB;
model.invW = invW;
model.mu = mu;