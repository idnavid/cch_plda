#! /usr/bin/python 

import volume 
import os
import scipy.io.wavfile as wav 
import numpy as np
import pylab 

def mix_signals(s1,s2,orig_sir,target_sir):
    # mix (sum) two signals s1 and s2 to create cochannel audio.
    # orig_sir is 10log(P(s1)/P(s2)). And target_sir is the target 
    # signal to interference ratio. 
    alpha = np.exp(orig_sir/20.0)/np.exp(target_sir/20.0)
    return s1 + alpha*s2


def switchboard(filename,ch,target_sir):
    # We need to deal with each dataset separately. 
    # Switchboard data is in sph format. 
    
    # first will have to convert to wav file. 
    sph2pipe_cmd = '/home/nxs113020/kaldi-trunk/tools/sph2pipe_v2.5/sph2pipe'
    wav_dir = '/home/nxs113020/tmp_dir/'
    basename = filename.split('/')[-1][:-4]
    #print "basename:",basename
    wavname = '%s/%s_%s.wav'
    sph2wav_format = '%s %s -p -c %s -f wav > %s'
    # Two channel maps to turn A/B to 1/2
    channel_map = {'A':'1','B':'2'}
    invert_channel_map = {'A':'2','B':'1'}
    target_channel = channel_map[ch] # target channel
    os.system(sph2wav_format%(sph2pipe_cmd,filename, 
                target_channel,wavname%(wav_dir,basename,target_channel)))
    #print "created", wavname%(wav_dir,basename,target_channel)
    
    background_channel = invert_channel_map[ch] # background channel
    os.system(sph2wav_format%(sph2pipe_cmd,filename,
                background_channel,wavname%(wav_dir,basename,background_channel)))
    #print "created", wavname%(wav_dir,basename,background_channel)
      
    # read wav files:
    (fs,sig1) = wav.read(wavname%(wav_dir,basename,target_channel))
    (fs,sig2) =  wav.read(wavname%(wav_dir,basename,background_channel))
    rms1,rms2 = volume.read_rms(filename)
    sph_sir = 20.*np.log10(rms1/rms2)
    s = mix_signals(sig1,sig2,sph_sir,target_sir)
    out_wav = wavname%(wav_dir,basename,target_channel+'_'+background_channel)
    wav.write(out_wav,fs,s/(abs(max(s))+1e-4))
    # return output wav name
    return out_wav



if __name__=='__main__':
    switchboard('/home/nxs113020/tmp.sph','A',100.)
    
    
