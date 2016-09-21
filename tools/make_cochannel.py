#! /usr/bin/python 


def mix_signals(s1,s2,orig_sir,target_sir):
    # mix (sum) two signals s1 and s2 to create cochannel audio.
    # orig_sir is 10log(P(s1)/P(s2)). And target_sir is the target 
    # signal to interference ratio. 
    alpha = np.exp(orig_sir/20.0)/np.exp(target_sir/20.0)
    return s1 + alpha*s2


    
