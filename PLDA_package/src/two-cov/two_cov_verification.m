%**************************************************************************
%   function LLR = two_cov_verification(model, data1, data2)
%
%   Calculate the ratio of loglikelihood of the model that each pair of 
%   vectors from data1 and data2 has the same identity or different
%   identities.
% 
%   LogLikeRatio = Loglike_Same / Loglike_Different
%
%   Input:
%       model   - Learned PLDA model
%       data1   - Dataset 1: N1Sample x NFeature
%       data2   - Dataset 2: N2Sample x NFeature
%       
%   Output:
%       LLR - N1Sample x N2Sample Array of scores
% 
% Aleksandr Sizov, UEF 2014
%**************************************************************************
function LLR = two_cov_verification(model, data1, data2)

data1 = bsxfun(@minus,data1,model.mu');
data2 = bsxfun(@minus,data2,model.mu');


% Auxilary matrices
Sigma_wc = model.invW;
Sigma_ac = model.invB;
Sigma_tot = Sigma_wc + Sigma_ac;

Lambda_tot = -inv(Sigma_wc + 2*Sigma_ac) + inv(Sigma_wc);
Gamma = -inv(Sigma_wc + 2*Sigma_ac) - inv(Sigma_wc) + 2*inv(Sigma_tot); %#ok<*MINV>

Gamma11 = sum(data1*Gamma.*data1,2); % phi1' * Gamma * phi1
Gamma22 = sum(data2*Gamma.*data2,2)'; % phi2' * Gamma * phi2

LLR = 2*data1*Lambda_tot*data2'; % That's 2*phi1 * Lambda * phi2
LLR = bsxfun(@plus, LLR, Gamma11);
LLR = bsxfun(@plus, LLR, Gamma22);
end