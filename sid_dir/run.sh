#!/bin/bash

log_start(){
  echo "#####################################################################"
  echo "Spawning *** $1 *** on" `date` `hostname`
  echo ---------------------------------------------------------------------
}

log_end(){
  echo ---------------------------------------------------------------------
  echo "Done *** $1 *** on" `date` `hostname` 
  echo "#####################################################################"
}

. cmd.sh
. path.sh

set -e # exit on error

num_job=40
num_job_ubm=400
num_job_tv=24

SIR=0
mfccdir=/erasable/nxs113020/mfcc_${SIR}

generate_evaluation_data(){
    # generates co-channel trn and tst data for evaluation
    for x in tst; do
        python local/generate_files_swb.py data/${x}_list $SIR data/$x/wav.scp data/$x/utt2spk
        utils/utt2spk_to_spk2utt.pl data/$x/utt2spk > data/$x/spk2utt
    done
}
#generate_evaluation_data

run_mfcc(){
    if [ ! -d $mfccdir ]; then
        mkdir $mfccdir
    fi
    for x in sre08; do
      #steps/make_mfcc.sh --nj $num_job --cmd "$train_cmd" \
      #  data/$x exp/make_mfcc/$x $mfccdir
      #steps/compute_cmvn_stats.sh data/$x exp/make_mfcc/$x $mfccdir 
      utils/fix_data_dir_sid.sh data/$x
      sid/compute_vad_decision.sh --nj $num_job --cmd "$train_cmd" \
          data/$x exp/make_vad data/${x}_vad
    done
}
#run_mfcc

run_unsupervised_sad(){
    sad_tools="/home/nxs113020/speech_activity_detection/kaldi_setup/local/"
    for x in trn; do
       $sad_tools/compute_vad_decision.sh $num_job \"$train_cmd\" data/$x
    done
}
#run_unsupervised_sad

ubmdim=2048
ivdim=400

run_ubm(){
  
    sid/train_diag_ubm.sh --nj $num_job_ubm --cmd "$train_cmd" data/dev ${ubmdim} \
        exp/diag_ubm_${ubmdim}
    sid/train_full_ubm.sh --nj $num_job_ubm --cmd "$train_cmd" data/dev \
        exp/diag_ubm_${ubmdim} exp/full_ubm_${ubmdim}

}
#run_ubm

run_tv_train(){

    sid/train_ivector_extractor.sh --nj $num_job_tv --cmd "$train_cmd" \
        --ivector-dim $ivdim --num-iters 5 exp/full_ubm_${ubmdim}/final.ubm data/dev \
        exp/extractor_${ubmdim} || exit 1;

}
#run_tv_train

run_iv_extract(){

   for x in sre08; do
       sid/extract_ivectors.sh --cmd "$train_cmd" --nj $num_job \
           exp/extractor_${ubmdim}_both_genders data/$x exp/${x}.iv || exit 1;
   done

}
run_iv_extract

generate_trials(){
    trials=data/trials/trials.txt
    trials_key=${trials}.key
    python local/make_trials.py data/trn/utt2spk data/tst/utt2spk $trials 
}
#generate_trials


run_cds_score(){
    cat $trials | awk '{print $1, $2}' | \
    ivector-compute-dot-products - \
          scp:exp/trn.iv.0dB/ivector.scp \
          scp:exp/tst.iv.0dB/ivector.scp \
          score/cds.output 2> score/cds.log
    awk '{print $3}' score/cds.output > score/cds.score
    paste score/cds.score $trials_key > score/cds.score.key           
    echo "CDS EER : `compute-eer score/cds.score.key 2> score/cds_EER`"
    echo "CDS EER and MINDCF: `src/bin/compute-verification-errors score/cds.score.key 10 1 0.001 2> score/cds_minDCF`"
}
#run_cds_score

run_lda_plda(){
    mkdir -p exp/ivector_plda; rm -rf exp/ivector_plda/*
    ivector-compute-lda --dim=200 --total-covariance-factor=0.1 \
        'ark:ivector-normalize-length scp:exp/sre08.iv.0dB/ivector.scp ark:- |' \
        ark:data/sre08.0dB/utt2spk \
        exp/sre08.iv.0dB/lda_transform.mat 2> exp/sre08.iv.0dB/lda.log

    ivector-compute-plda ark:data/sre08.0dB/spk2utt \
          'ark:ivector-transform exp/sre08.iv.0dB/lda_transform.mat scp:exp/sre08.iv.0dB/ivector.scp ark:- | ivector-normalize-length ark:-  ark:- |' \
            exp/ivector_plda/plda 2>exp/ivector_plda/plda.log
    
    ivector-plda-scoring  \
           "ivector-copy-plda --smoothing=0.0 exp/ivector_plda/plda - |" \
           "ark:ivector-transform exp/sre08.iv.0dB/lda_transform.mat scp:exp/trn.iv.100dB/ivector.scp ark:- | ivector-subtract-global-mean ark:- ark:- |" \
           "ark:ivector-transform exp/sre08.iv.0dB/lda_transform.mat scp:exp/tst.iv.100dB/ivector.scp ark:- | ivector-subtract-global-mean ark:- ark:- |" \
           "cat '$trials' | awk '{print \$1, \$2}' |" score/plda.output 2> score/plda.log
    
    awk '{print $3}' score/plda.output > score/plda.score
    paste score/plda.score $trials_key > score/plda.score.key           
    echo "PLDA EER : `compute-eer score/plda.score.key 2> score/plda_EER`"
    echo "PLDA EER and MINDCF: `src/bin/compute-verification-errors score/plda.score.key 10 1 0.001 2> score/plda_minDCF`"
}
#run_lda_plda

