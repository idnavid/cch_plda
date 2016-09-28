#! /usr/bin/python 


import sys

def read_list(utt2spk_file):
    """
    convert utt2spk to dictionary, {utt_id:spkr_id}
    """
    fin = open(utt2spk_file)
    utt_dict = {}
    for i in fin:
        utt_id = i.strip().split(' ')[0]
        spkr_id = i.strip().split(' ')[-1]
        utt_dict[utt_id.strip()] = spkr_id.strip()
    fin.close()
    return utt_dict


if __name__=='__main__':
    """
    Takes train and test utt2spk files and returns a list of trials and a 
    corresponding key file.
    inputs: 
        1. train utt2spk, 
        2. test utt2spk, 
        3. output trial filename
    outputs: 
        1. output trial
        1. output keys ==> name will be [trial_filename.key]
    """
    
    trn_utt2spk = sys.argv[1]
    tst_utt2spk = sys.argv[2]
    trials_filename = sys.argv[3]
    trn_utt = read_list(trn_utt2spk)
    tst_utt = read_list(tst_utt2spk)
    
    ftrials = open(trials_filename,'w')
    fkey = open(trials_filename+'.key','w')
    for i in tst_utt:
        tst_spkr = tst_utt[i]
        for j in trn_utt:
            trn_spkr = trn_utt[j]
            key_val = 'nontarget'
            if (trn_spkr == tst_spkr):
                key_val = 'target'
            ftrials.write(j+'\t'+i+'\t'+key_val+'\n')
            fkey.write(key_val+'\n')
    ftrials.close()
    fkey.close()

