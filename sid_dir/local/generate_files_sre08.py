#! /usr/bin/python

# Find data file in switchboard files using basename. 

import sys
import subprocess
sys.path.append('../tools/')
import make_cochannel





if __name__=='__main__':
    """
    Reads list of nist sre08 formatted as:
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
    input_audio_list = sys.argv[1]
    sir = float(sys.argv[2])
    out_wavscp = sys.argv[3]
    out_utt2spk = sys.argv[4]
    
    file_dict = {}
    wavscp_list = []
    utt2spk_list = []
    for i in open(input_audio_list):
        filename_spkr_channel = i.split(',')
        filename = filename_spkr_channel[0].strip()
        basename = filename.split('/')[-1].split('.sph')[0]
        spkr_id = filename_spkr_channel[1].strip()
        channel = filename_spkr_channel[2].strip()
        filepath = filename
        print basename
        wavscp_format = "%s sox --ignore-length %s -t wav -b 16 - | "
        uttid = spkr_id+'_'+basename+':'+channel
        wavpath = make_cochannel.switchboard(filepath,channel,sir)
        wavscp_list.append(wavscp_format%(uttid,wavpath)+'\n')
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

