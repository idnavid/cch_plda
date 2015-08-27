%**************************************************************************
% function  [T, R, Y] = two_cov_E_step(model, matrixID, f)
%
%   E(Expectation ) - step of EM algorithm
%
%   Input:
%       model - two-covariance PLDA model with the following parameters
%           invB - NFeature x NFeature Between individual covariance matrix 
%           invW - NFeature x NFeature Within individual covariance matrix 
%           mu  - NFeature x 1  Mean vector of the data
%       matrixID - NSample x nIdentity  Identity matrix of training data
%       f - First-order statistic of the data
%
%   Output:
%       Please consult supplementary paper for details.
% 
% Aleksandr Sizov, UEF 2014
%**************************************************************************
function  [T, R, Y] = two_cov_E_step(model, matrixID, f)
B = inv(model.invB);
W = inv(model.invW);
mu = model.mu;

D = size(B,1); % dimensionality of visible data
K = size(matrixID,2);   % number of persons

% Set auxiliary matrices
T = zeros(D, D);
R = zeros(D, D);
Y = zeros(D, 1);

Bmu = B * mu;

n_old = 0;
for i = 1:K
    n = sum(double(matrixID(:,i))); % number of samples for i-th individual
    if n ~= n_old
       invL_i = inv(B + n*W);
       n_old = n;
    end
    gamma_i = Bmu + W*f(:,i);
    Ey_i = invL_i * gamma_i;
    T = T + Ey_i*f(:,i)';
    R = R + n*(invL_i + Ey_i*Ey_i');
    Y = Y + n*Ey_i;
end
end