
addpath(genpath(sprintf('%s/src', pwd))); % Add 'src' folder to path
addpath('/home/nxs113020/Downloads/kaldi_to_matlab_tools/');


% PLDA parameters
params.Vdim = 200; % Dimensionality of speaker latent variable   
params.Udim = 200;    % Dimensionality of channel latent variable
params.doMDstep = 0; % Indicator whether to do minimum-divergence step
params.PLDA_type = 'simp'; % 'std' for standard PLDA
                           % 'simp' for simplified PLDA and
                           % 'two-cov' for two-covariance model
numIter = 10;   % Number of training iterations
LDA_dim = 200; % Dimensionality for LDA. If it is 0 then do not apply LDA.
               % It should be less than the number of individuals in the
               % training set.
PCA_dim = 0; % Dimensionality for PCA. If it is 0 then do not apply PCA.

fprintf('Vdim: %d, Udim: %d LDA_dim: %d, PCA_dim: %d\n\n', params.Vdim, ...
        params.Udim,LDA_dim, PCA_dim);

exp_dir = '/home/nxs113020/cch_plda/sid_dir/exp/';
dev_ivectors = readkaldivectors([exp_dir 'sre08.iv/ivector.scp']);
trn_ivectors = readkaldivectors([exp_dir 'trn.iv.100dB/ivector.scp']);
tst_ivectors = readkaldivectors([exp_dir 'tst.iv.100dB/ivector.scp']);

[train_data,train_labels] = load_kaldi_ivecs(dev_ivectors);
[enrol_data,enrol_labels] = load_kaldi_ivecs(trn_ivectors);
[test_data,test_labels] = load_kaldi_ivecs(tst_ivectors);





% LDA
if LDA_dim > 0
    [eigvector, eigvalue] = LDA(train_labels, [], train_data);
    train_data = train_data*eigvector(:,1:LDA_dim);
    enrol_data = enrol_data * eigvector(:,1:LDA_dim);
    test_data = test_data*eigvector(:,1:LDA_dim);
end

% Centering
m     = mean(train_data);
train_data = bsxfun(@minus, train_data, m);
enrol_data = bsxfun(@minus, enrol_data, m);
test_data  = bsxfun(@minus, test_data, m);

% PCA
if PCA_dim > 0
   pca_coeff = princomp(train_data);
   train_data = train_data * pca_coeff(:,1:PCA_dim);
   enrol_data = enrol_data * pca_coeff(:,1:PCA_dim);
   test_data = test_data * pca_coeff(:,1:PCA_dim);
end

% Compute the mean and whitening transformation over training set only
m     = mean(train_data);
S     = cov(train_data);
[Q,D] = eig(S);
W     = diag(1./sqrt(diag(D)))*Q';

% Center and whiten all i-vectors
train_data = bsxfun(@minus, train_data, m) * W';
enrol_data = bsxfun(@minus, enrol_data, m) * W';
test_data  = bsxfun(@minus, test_data, m) * W';

% Project all i-vectors into unit sphere
train_data = bsxfun(@times, train_data, 1./sqrt(sum(train_data.^2,2))); 
enrol_data  = bsxfun(@times, enrol_data, 1./sqrt(sum(enrol_data.^2,2)));
test_data  = bsxfun(@times, test_data, 1./sqrt(sum(test_data.^2,2)));

% Average enrollment data
enrol_persons = unique(enrol_labels);
n = length(enrol_persons);
enrol_data_avr = zeros(n, size(enrol_data,2));
for i = 1:length(enrol_persons)
   spk_data = enrol_data(enrol_persons(i) == enrol_labels,:);
   enrol_data_avr(i,:) = mean(spk_data);
end
enrol_labels = enrol_persons; %#ok<NASGU%#ok<MSNU> >
    
matrixID = create_incidence_matrix(train_labels);

% Sort persons according to the number of samples
numSessions = sum(matrixID);
[junk,I] = sort(numSessions);
matrixID = matrixID(:,I);

%% PLDA
if strcmp(params.PLDA_type, 'two-cov')
    [model stats] = two_cov_initialize(train_data', matrixID);
    for i=1:numIter
        model = two_cov_em(matrixID, model, stats);
        scores = two_cov_verification(model, enrol_data_avr, test_data); 
        [EER DCF] = get_EER_matrix(scores, enrol_labels, test_labels, 'I4U');
        fprintf('Iter: %d \tEER: %f\tDCF: %f\n', i,EER, DCF);
    end 
else
    [train_data model stats] = em_initialize(train_data, matrixID, params);
    for i=1:numIter
        model = em_algorithm(matrixID, params, model, stats);
        scores = verification(model, enrol_data_avr, test_data); 
        [EER DCF] = get_EER_matrix(scores, enrol_labels, test_labels, 'I4U');
        LL_train = calc_log_likelihood(model, train_data', false);
        fprintf('Iter: %d \tEER: %f\tDCF: %f\tLL: %f\n', i,EER, DCF, LL_train);
    end  
end

