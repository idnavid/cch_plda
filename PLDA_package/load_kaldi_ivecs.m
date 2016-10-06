function [data,labels] = load_kaldi_ivecs(ivec_struct)
ivec_dim = length(ivec_struct.feature{1});
ivec_num = length(ivec_struct.feature);
data = zeros(ivec_num,ivec_dim);
labels = zeros(ivec_num,1);
for i = 1:ivec_num
    data(i,:) = ivec_struct.feature{i};
    uttid = ivec_struct.utt{i};
    if ~isempty(strfind(uttid,'_'))
        breakpoint = strfind(uttid,'_');
    else
        breakpoint = strfind(uttid,'-');
    end
    labels(i) = str2num(uttid(1:breakpoint(1)-1));
end

[tmp,idx] = sort(labels);
labels = tmp;
data = data(idx,:);