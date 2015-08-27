%**************************************************************************
%   function [data model stats] = em_initialize(data, matrixID, params)
%
%   Initialize the parameters for PLDA model, center training data and
%   compute statistics of the data.
%
%   Input:
%       data - NFeature  x NSample   Training data
%       matrixID - NSample   x nIdentity Identity matrix of training data
%       params - Parameters for a PLDA learning:
%           Vdim - Number of columns for a matrix V
%           Udim - Number of columns for a matrix U
%           doMDstep - Indication whether to do a minimum-divergence step
%       
%   Output:
%       data - NFeature  x NSample   Centered training data
%       model - PLDA model with the following parameters
%           V        - NFeature x Vdim  Factor loading matrix
%           U        - NFeature x Udim  Factor loading matrix
%           Sigma    - NFeature x NFeature Covariance matrix
%           mu  - NFeature x 1 Mean vector of the training data
%       stats - Statistics of the training data:
%           N - Zero-order statistic
%           f - First-order statistic
%           S - Second-order statistic
% 
% Aleksandr Sizov, UEF 2014
%**************************************************************************

function [data model stats ] = em_initialize(data, matrixID, params)
model = []; stats = [];

% Center data after length normalization
model.mu = mean(data);
% transpose it for PLDA learning
data = bsxfun(@minus, data, model.mu)'; 

D = size(data, 1);      % Dimension of original space
K = size(matrixID,2);   % Number of individuals

N = size(data, 2); % Total number of samples - zero order moment
f = zeros(D,K); % First order moment

for i = 1:K
   f(:,i) = sum(data(:,matrixID(:,i)),2);
end

S = data * data'; % Global second order statistic

% Initialize the parameters randomly
V = randn(D, params.Vdim);
U = randn(D, params.Udim);

Sigma = S / N;    % noise covariance matrix
if strcmp(params.PLDA_type, 'std') % standard PLDA case
    Sigma = diag(diag(Sigma)); 
end

% Save statistics
stats.N = N;
stats.f = f;
stats.S = S;
    
% Save PLDA model
model.V = V;
model.U = U;
model.Sigma = Sigma;