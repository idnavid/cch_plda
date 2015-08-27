%**************************************************************************
%   function [model stats] = two_cov_initialize(data, matrixID)
%
%   Initialize the parameters for PLDA model, center training data and
%   compute statistics of the data.
%
%   Input:
%       data - NFeature  x NSample   Training data
%       matrixID - NSample   x nIdentity Identity matrix of training data
%       
%   Output:
%       model - two-covariance PLDA model with the following parameters
%           invB - NFeature x NFeature Between individual covariance matrix 
%           invW - NFeature x NFeature Within individual covariance matrix 
%           mu  - NFeature x 1  Mean vector of the data
%       stats - Statistics of the training data:
%           N - Zero-order statistic
%           f - First-order statistic
%           S - Second-order statistic
% 
% Aleksandr Sizov, UEF 2014
%**************************************************************************
function [model stats] = two_cov_initialize(data, matrixID)

model = []; stats = [];

% Center data after length normalization
mu = mean(data,2);

D = size(data, 1);      % Dimension of original space
K = size(matrixID,2);   % Number of individuals

N = size(data, 2); % Total number of samples - zero order moment
f = zeros(D,K); % First order moment

for i = 1:K
   f(:,i) = sum(data(:,matrixID(:,i)),2);
end

S = data * data'; % Global second order statistic

% Initialize the parameters
invB = S/(N);
invW = S/(N);

% Save statistics
stats.N = N;
stats.f = f;
stats.S = S;
    
% Save PLDA model
model.mu = mu;
model.invB = invB;
model.invW = invW;

