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


def switchboard(filename):
    # We need to deal with each dataset separately. 
    # Switchboard data is in sph format. 
    
    # first will have to convert to wav file. 
    sph2pipe_cmd = '/home/nxs113020/kaldi-trunk/tools/sph2pipe_v2.5/sph2pipe'
    wav_dir = '../tmp_dir/'
    basename = filename.split('/')[-1][:-4]
    print "basename:",basename
    wavname = '%s/%s_%s.wav'
    sph2wav_format = '%s %s -p -c %s -f wav > %s'
    channel = '1'
    os.system(sph2wav_format%(sph2pipe_cmd,filename, 
                channel,wavname%(wav_dir,basename,channel)))
    print "created", wavname%(wav_dir,basename,channel)
    channel = '2'
    os.system(sph2wav_format%(sph2pipe_cmd,filename,
                channel,wavname%(wav_dir,basename,channel)))
    print "created", wavname%(wav_dir,basename,channel)
      
    # read wav files:
    channel = '1'
    (fs,sig1) = wav.read(wavname%(wav_dir,basename,channel))
    channel = '2'
    (fs,sig2) =  wav.read(wavname%(wav_dir,basename,channel))
    print "sampling rate:",fs
    rms1,rms2 = volume.read_rms(filename)
    print "rms1:",rms1, "\trms2:",rms2
    sph_sir = 20.*np.log10(rms1/rms2)
    print "original SIR:", sph_sir
    target_sir = 100.
    s = mix_signals(sig1,sig2,sph_sir,target_sir)
    pylab.plot(sig1)
    pylab.plot(sig2)
    pylab.figure()
    pylab.plot(s)
    pylab.show()
    wav.write(wavname%(wav_dir,basename,'_1_2'),fs,s)


if __name__=='__main__':
    switchboard('../tmp_dir/sw_20313.sph')
    
    
