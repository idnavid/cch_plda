#! /usr/bin/python

# Find data file in switchboard files using basename. 

import sys
import subprocess
sys.path.append('/home/nxs113020/cch_plda/tools/')
import make_cochannel





if __name__=='__main__':
    """
    Reads list of switchboard sphfiles formatted as:
        filename, spkrid, channel  
    Generates co-channel wav data for a given SIR for the 
    input data list. 
    Returns corresponding wav.scp and utt2spk files. 
    input:
        1. input audio list in the format described above.
        2. signal-to-interference ratio (dB), sir
    outputs:
        1. data wav.scp 
        2. data utt2spk
    """
    swb_dir = '/home/nxs113020/Downloads/SwitchBoard2/Phase2'
    input_audio_list = sys.argv[1]
    sir = float(sys.argv[2])
    out_wavscp = sys.argv[3]
    out_utt2spk = sys.argv[4]
    
    file_dict = {}
    wavscp_list = []
    utt2spk_list = []
    for i in open(input_audio_list):
        basename_spkr_channel = i.split(',')
        basename = basename_spkr_channel[0].strip()
        spkr_id = basename_spkr_channel[1].strip()
        channel = basename_spkr_channel[2].strip()
        # search for basename in Switchboard directory
        if not(basename in file_dict):
            output = subprocess.check_output('find %s -name %s.sph'%(swb_dir,basename),shell=True)
            filepath = output.strip()
        else:
            filepath = file_dict[basename]
        print basename
        wavpath = make_cochannel.switchboard(filepath,channel,sir)
        uttid = spkr_id+'_'+basename+':'+channel
        wavscp_list.append(uttid+' '+wavpath+'\n')
        utt2spk_list.append(uttid+' '+spkr_id+'\n')
    
    wavscp_list = sorted(set(wavscp_list))
    utt2spk_list = sorted(set(utt2spk_list))
    
    
    wavscp = open(out_wavscp,'w')
    utt2spk = open(out_utt2spk,'w')
    for i in range(len(wavscp_list)):
        wavscp.write(wavscp_list[i])
        utt2spk.write(utt2spk_list[i])
    
    wavscp.close()
    utt2spk.close()

