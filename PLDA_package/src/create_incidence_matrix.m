%**************************************************************************
%   function incidence_matrix  = create_incidence_matrix(data_labels)
%
%   Create an incidence matrix and infer total number of speakers given a
%   list of speaker labels for each file.
%
%   Input:
%       spk_labels          - NSample x 1   Speaker labels for each file.
%   Output:
%       incidence_matrix    - NSample x number_of_speakers
%       number_of_spks      - Total number of speakers   
%
% Aleksandr Sizov, UEF 2014
%**************************************************************************
function incidence_matrix = create_incidence_matrix(data_labels)

number_of_persons = length(unique(data_labels));
mult_Idx = repmat(data_labels, 1, number_of_persons);
z = repmat(unique(data_labels), 1, length(data_labels))';
if iscell(data_labels)
    incidence_matrix = strcmp(mult_Idx,z);
else
    incidence_matrix = (mult_Idx == z);
end
end

