%**************************************************************************
%   function LL = calc_log_likelihood(model, data)
%
%   Calculate log-likelihood of the data for the PLDA model with integrated
%   out latent variables
%
%   Input:
%       model   - Learned PLDA model
%       data    - Dataset: N1Sample x NFeature
%       substract_mean - indicator whether to substract from the data a
%       mean value for PLDA model
%   Output:
%       LL      - Log-likelihood for the whole dataset
% Aleksandr Sizov, UEF 2014
%**************************************************************************
function LL = calc_log_likelihood(model, data, substract_mean)

if nargin < 3
    substract_mean = true;
end

if substract_mean
    data = bsxfun(@minus,data,model.mu);
end

N = size(data,1); % Number of data points
D = size(data,2); % Dimensionality of the data

% Check whether noise matrix has only diagonal elements
if size(model.Sigma) == size(model.Sigma')
    Sigma = model.Sigma; 
else
    Sigma = diag(model.Sigma); % expand diagonal
end

W = model.V*model.V' + model.U*model.U' + Sigma; % Total covariance matrix

% Calc log determinant
E = eig(W);
det = sum(log(E));

LL = - 0.5*(N*D*log(2*pi) + N*det + sum(sum(data*inv(W).*data,2))); 
end

