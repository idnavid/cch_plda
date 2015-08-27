%**************************************************************************
%   function model = em_algorithm(matrixID, params, model, stats)
%
%   Learn a PLDA model given training Data using EM algorithm. PLDA, as a 
%   specific case of factor analysis doesn't have a unique solution.
%   Therefore, if you do not fix a seed for the random number generator you
%   will obtain a different set of parameters with each run.
%
%   Input:
%       matrixID - NSample x nIdentity  Identity matrix of training data
%       params - Parameters for a PLDA learning:
%           Vdim - Number of columns for a matrix V
%           Udim - Number of columns for a matrix U
%           doMDstep - Indication whether to do a minimum-divergence step
%       model - PLDA model with the following parameters
%           V        - NFeature x Vdim  Factor loading matrix
%           U        - NFeature x Udim  Factor loading matrix
%           Lambda    - NFeature x 1  Precision matrix
%           mu  - NFeature x 1 Mean vector of the training data
%       stats - Statistics of the training data:
%           N - Zero-order statistic
%           f - First-order statistic
%           S - Second-order statistic
%       
%   Output:
%       model - PLDA model with the following parameters
%           V        - NFeature x Vdim  Factor loading matrix
%           U        - NFeature x Udim  Factor loading matrix
%           Sigma    - NFeature x NFeature Covariance matrix
%           mu  - NFeature x 1 Mean vector of the training data
% 
% Aleksandr Sizov, UEF 2014
%**************************************************************************
function model = em_algorithm(matrixID, params, model, stats)

% E-step
[T_x, T_y, R_yy, R_yx, R_xx, Y_md] = get_expected_values(model, matrixID, stats);
R = [R_yy, R_yx; R_yx', R_xx];
T = [T_y;T_x];

% M-step
VU = T'/R;
V = VU(:, 1 : params.Vdim);
U = VU(:, params.Vdim + 1 : end);

Sigma = (stats.S - VU*T)/stats.N;
if strcmp(params.PLDA_type, 'std') % standard PLDA case
    Sigma = diag(diag(Sigma)); 
end

% MD-step
if params.doMDstep
    G = R_yx' / R_yy;
    X_md = (R_xx - G*R_yx)/stats.N;
    U = U * chol(X_md,'lower');
    V = V * chol(Y_md,'lower') + U*G;
end

% Store the trained PLDA model
model.V = V;
model.U = U;
model.Sigma = Sigma;