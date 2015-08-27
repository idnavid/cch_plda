%**************************************************************************
% function [EER minDCF thresh_EER thresh_DCF] = get_EER_matrix(scores, ...
%                                       enroll_labels, test_labels, DCF_type)
%
%   Calculate metrics 
%
%   Input:
%       scores - Two-dimensional array of scores between enrolment and test
%                files
%       enroll_labels - An array of labels for each enrolment file
%       test_labels - An array of labels for each test file
%       DCF_type - type of the DCF metric.
%
%   Output:
%       EER - Equal Error Rate.
%       minDCF - minimum of the Detection cost function
%       thresh_EER - Threshold to achive EER value
%       thresh_DCF - Threshold to achive minDCF value
% 
% Aleksandr Sizov, UEF 2014
%**************************************************************************
function [EER minDCF thresh_EER thresh_DCF] = get_EER_matrix(scores, ...
                                        enroll_labels, test_labels, DCF_type)

if nargin < 4
   DCF_type = 'I4U'; 
end

A1 = repmat(enroll_labels,1,length(test_labels));
A2 = repmat(test_labels',length(enroll_labels),1);
A = (A1 == A2);
target_scores = scores(A);
imposter_scores = scores(~A);

target_scores = target_scores(:)';
imposter_scores = imposter_scores(:)';
clear A1 A2 A scores

[ft, xt] = ecdf(target_scores);
[fi, xi] = ecdf(imposter_scores);
ft = ft(2:end);
xt = xt(2:end);
fi = fi(2:end);
xi = xi(2:end);
fi = 1 - fi;

x = sort(unique([xt; xi]));
yt = interp1(xt, ft, x);
yi = interp1(xi, fi, x);

[~, i] = min(abs(yt - yi));
EER = 100*yt(i);
thresh_EER = x(i);

switch DCF_type 
    case 'I4U'
        C_miss = 1; C_fa = 1; P_target = 1e-3;
        [minDCF, i] = min ( C_miss * yt * P_target + C_fa * yi * (1 - P_target));
        C_def = min(C_miss * P_target, C_fa * (1 - P_target));
        minDCF = minDCF / C_def;
    case 'iVC'
        C_miss = 1; C_fa = 100; P_target = 0.5;
        [minDCF, i] = min ( C_miss * yt * P_target + C_fa * yi * (1 - P_target));
        C_def = min(C_miss * P_target, C_fa * (1 - P_target));
        minDCF = minDCF / C_def;
end
thresh_DCF = x(i);    
end