#! /usr/bin/python 

import volume 
import os
import scipy.io.wavfile as wav 
import numpy as np
import pylab 
import wave
import struct 

def plot_cochannel(s1,s2,s_cch):
    ## Plot co-channel signal
    pylab.figure()
    pylab.subplot(3,1,1)
    pylab.plot(s1,color='g')
    pylab.subplot(3,1,2)
    pylab.plot(s2,color='r')
    pylab.subplot(3,1,3)
    pylab.plot(s_cch,color='b',lw=2)
    pylab.plot(s1,color='g',lw=0.1,ls=':')
    pylab.plot(s2,color='r',lw=0.1,ls=':')
    pylab.show()

def mix_signals(s1,s2,orig_sir,target_sir):
    # mix (sum) two signals s1 and s2 to create cochannel audio.
    # orig_sir is 10log(P(s1)/P(s2)). And target_sir is the target 
    # signal to interference ratio. 
    alpha = np.exp(orig_sir/20.0)/np.exp(target_sir/20.0)
    return s1 + alpha*s2

def nistsre2008(filename, ch, target_sir):
    # first will have to convert to wav file. 
    #sph2pipe_cmd = '/home/nxs113020/kaldi-trunk/tools/sph2pipe_v2.5/sph2pipe'
    sph2pipe_cmd  = '/scratch2/share/nxs113020/tools/kaldi_dir/kaldi/tools/sph2pipe_v2.5/sph2pipe'
    wav_dir = '/erasable/nxs113020/tmp_dir/'
    basename = filename.split('/')[-1][:-4]
    #print "basename:",basename
    wavname = '%s/%s_%s.wav'
    sph2wav_format = '%s %s -p -c %s -f wav > %s'
    # Two channel maps to turn A/B to 1/2
    # In NIST data, sometimes the audio is single-channel
    channel_map = {'A':'1','B':'2','':'1'}
    invert_channel_map = {'A':'2','B':'1','':'1'}
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
    os.system('rm %s'%(wavname%(wav_dir,basename,'1')))
    os.system('rm %s'%(wavname%(wav_dir,basename,'2')))
    rms1,rms2 = volume.read_rms(filename)
    sph_sir = 20.*np.log10(rms1/rms2)
    s = mix_signals(sig1,sig2,sph_sir,target_sir)
    if ch=='':
        alpha = np.exp(sph_sir/20.0)/np.exp(target_sir/20.0)
        s = s/(1.+alpha)
    
    #plot_cochannel(sig1,sig2,s) 
    out_wav = wavname%(wav_dir,basename,target_channel+'_'+background_channel)
    data = np.array(s, dtype=np.int16)
    wav.write(out_wav,fs,data)
    return out_wav # name of output wav file.

   
def switchboard(filename,ch,target_sir):
    # We need to deal with each dataset separately. 
    # Switchboard data is in sph format. 
    
    # first will have to convert to wav file. 
    #sph2pipe_cmd = '/home/nxs113020/kaldi-trunk/tools/sph2pipe_v2.5/sph2pipe'
    sph2pipe_cmd  = '/scratch2/share/nxs113020/tools/kaldi_dir/kaldi/tools/sph2pipe_v2.5/sph2pipe'
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
    #plot_cochannel(sig1,sig2,s) 
    out_wav = wavname%(wav_dir,basename,target_channel+'_'+background_channel)
    data = float2pcm(s/(abs(max(s))+1e-4), 'int16')
    wav.write(out_wav,fs,data)
    return out_wav # name of output wav file.



if __name__=='__main__':
    #switchboard('/corpora/sre/SwitchBoard2/Phase2/DVD2/swb2_2/sw_22080.sph','A',0.)
    nistsre2008('/corpora/sre/SRE16/LDC2009E100/SRE08/sp08-11/train/data/short2/tfsri.sph', 'A', 100.)
    
