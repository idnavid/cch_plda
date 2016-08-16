#! /usr/bin/python 
import audioop
import math

import commands

def calculate_volume(sphfile,leftch,rightch,SIR):
  # compute volume level from sph header. 
  # Useful to compute the signal-to-interference
  # level of stereo sph files. 
  with open(sphfile) as s:
    bytes = s.read()
  s1_bytes1 = audioop.tomono(bytes,2,leftch,rightch)
  s2_bytes1 = audioop.tomono(bytes,2,rightch,leftch)
  s1_bytes = s1_bytes1[1024:]
  s2_bytes = s2_bytes1[1024:]
  
  e1 = audioop.rms(s1_bytes,2)*1.0 # make float by multiplying by 1.0
  e2 = audioop.rms(s2_bytes,2)*1.0
  print e1,e2
  vol = math.exp(-1.0*float(SIR)/10)*e1/e2
  return vol


def read_rms(sphfile):
  # Uses sox to read the RMS of each channel in a sph file.
  tmp = commands.getoutput('sox %s -n stats'%sphfile)
  out_list = tmp.split('\n')
  items = out_list[5].split(' ')
  rms2 = float(items[-1])
  rms1 = float(items[-5])
  print rms1,rms2
  
  
       
  
if __name__=='__main__':
    calculate_volume('tmp_wavs/tlgqm.sph',1,0,'10.0')
    read_rms('tmp_wavs/tlgqm.sph',1,0)

