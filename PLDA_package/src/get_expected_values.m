%**************************************************************************
% function  [T_x, T_y, R_yy, R_yx, R_xx, Y_md] = get_expected_values(model,
%                                                      matrixID,stats)
%
%   E(Expectation ) - step of EM algorithm
%
%   Input:
%       model - PLDA model with the following parameters
%           V        - NFeature x Vdim  Factor loading matrix
%           U        - NFeature x Udim  Factor loading matrix
%           Sigma    - NFeature x NFeature  Covariance noise matrix
%           mu  - NFeature x 1  Mean vector of the training data
%       matrixID - NSample x nIdentity  Identity matrix of training data
%       stats - Statistics of the training data:
%           N - Zero-order statistic
%           f - First-order statistic
%           S - Second-order statistic
%
%   Output:
%       Please consult supplementary paper for details.
% 
% Aleksandr Sizov, UEF 2014
%**************************************************************************
function  [T_x, T_y, R_yy, R_yx, R_xx, Y_md] = get_expected_values(model,...
                                                            matrixID,stats)
V = model.V;
U = model.U;
Lambda = inv(model.Sigma); 

N = stats.N;
f = stats.f;
S = stats.S;

Vdim = size(V, 2);
Udim = size(U, 2);

D = size(V,1); % dimensionality of visible data
K = size(matrixID,2);   % number of persons

% Set auxiliary matrices
T       = zeros(Vdim+Udim, D);
R_yy    = zeros(Vdim,Vdim);
Ey      = zeros(Vdim,K);
Y_md    = zeros(Vdim,Vdim);

Q = inv(U'*Lambda*U + eye(Udim)); %#ok<*NASGU>
J = U'*Lambda*V;
H = V - U*Q*J;
LH = Lambda*H;
VLH = V'*LH;

n_old = 0;
for i = 1:K
    n = sum(double(matrixID(:,i))); % number of samples for i-th individual
    if n ~= n_old
       M = inv(n*VLH + eye(Vdim));
       n_old = n;
    end
    Ey(:,i) = M*(LH'*f(:,i)); %#ok Ey(:,i) = M*H'*Lambda*f(:,i);
    Eyy = Ey(:,i) * Ey(:,i)';
    Y_md = Y_md + (M + Eyy); % it's for the minimum-divergence step
    R_yy = R_yy + n*(M + Eyy);
end
Y_md = Y_md / K;

T_y = Ey * f';
T_x = Q * (U'*Lambda*S - J*T_y); %#ok

R_yx = (T_y*Lambda*U - R_yy*J')*Q;
% 2 auxiliary matrices
W1 = Lambda*U;
W2 = J*T_y;
R_xx = Q*(W1'*S*W1 - W1'*W2' - W2*W1 + J*R_yy*J')*Q + N*Q; %#ok
end