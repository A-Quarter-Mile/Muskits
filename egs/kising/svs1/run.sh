#!/usr/bin/env bash
# Set bash to 'debug' mode, it will exit on :
# -e 'error', -u 'undefined variable', -o ... 'error in pipeline', -x 'print commands',
set -e
set -u
set -o pipefail

# spectrogram-related arguments
fs=24000
fmin=80
fmax=7600
n_fft=2048
n_shift=300
win_length=1200

score_feats_extract=frame_score_feats   # frame_score_feats | syllable_score_feats
expdir=exp/xiaoice_nodp_opencpop

opts=
if [ "${fs}" -eq 48000 ]; then
    # To suppress recreation, specify wav format
    opts="--audio_format wav "
else
    opts="--audio_format wav "
fi

train_set=tr_no_dev
valid_set=dev
test_sets="dev eval"

train_config=conf/tuning/train_xiaoice_noDP.yaml
# train_config=conf/train.yaml
inference_config=conf/decode.yaml

# text related processing arguments
g2p=none
cleaner=none

#     --pretrained_model /home/exx/jiatong/projects/svs/Muskits/egs/multilingual_four/svs1/exp/svs_train_xiaoice_noDP_raw_phn_none_multi/latest.pth \

./svs.sh \
    --lang zh \
    --stage 6 \
    --stop_stage 100 \
    --local_data_opts "--stage 2 $(pwd)" \
    --feats_type raw \
    --pitch_extract None \
    --fs "${fs}" \
    --fmax "${fmax}" \
    --n_fft "${n_fft}" \
    --n_shift "${n_shift}" \
    --win_length "${win_length}" \
    --token_type phn \
    --g2p ${g2p} \
    --cleaner ${cleaner} \
    --train_config "${train_config}" \
    --inference_config "${inference_config}" \
    --train_set "${train_set}" \
    --valid_set "${valid_set}" \
    --test_sets "${test_sets}" \
    --score_feats_extract "${score_feats_extract}" \
    --srctexts "data/${train_set}/text" \
    --svs_exp ${expdir} \
    --ignore_init_mismatch true \
    --pretrained_model /home/exx/jiatong/projects/svs/Muskits/egs/opencpop/svs1/exp/xiaoice_nodp/train.loss.best.pth \
    --vocoder_file /home/exx/jiatong/projects/svs/ParallelWaveGAN/egs/kising/voc1/exp/tr_no_dev_kising_hifigan.v1/checkpoint-300000steps.pkl \
    --ngpu 1 \
    ${opts} "$@"
