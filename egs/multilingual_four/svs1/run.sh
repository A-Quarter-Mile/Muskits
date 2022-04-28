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
use_sid=true
use_lid=true

combine_path=""
combine_path+="$(realpath ../../oniku_kurumi_utagoe_db/svs1/dump/raw/)"
combine_path+="|$(realpath ../../ofuton_p_utagoe_db/svs1/dump/raw/)"
combine_path+="|$(realpath ../../kiritan/svs1/dump/raw/)"
combine_path+="|$(realpath ../../natsume/svs1/dump/raw/)"
combine_path+="|$(realpath ../../opencpop/svs1/dump/raw/)"
combine_path+="|$(realpath ../../csd/svs1/dump_en/raw/)"
combine_path+="|$(realpath ../../csd/svs1/dump_kr/raw/)"

lang_seq="jp|jp|jp|jp|zh|en|kr"

score_feats_extract=frame_score_feats   # frame_score_feats | syllable_score_feats

opts=
if [ "${fs}" -eq 48000 ]; then
    # To suppress recreation, specify wav format
    opts="--audio_format wav "
else
    opts="--audio_format flac "
fi

train_set=tr_no_dev
valid_set=dev
test_sets=eval

# training and inference configuration
# train_config=conf/train.yaml
# train_config=conf/tuning/train_naive_rnn.yaml
train_config=conf/tuning/train_xiaoice_noDP.yaml
inference_config=conf/decode.yaml

# text related processing arguments
g2p=none
cleaner=none

#     --tag "with_lid" \

./svs.sh \
    --lang multi \
    --stage 8 \
    --stop_stage 8 \
    --local_data_opts "--combine_path ${combine_path} --lang_seq ${lang_seq}" \
    --feats_type raw \
    --use_sid ${use_sid} \
    --use_lid ${use_lid} \
    --pitch_extract None \
    --tag "with_lid" \
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
    --ngpu 1 \
    --vocoder_file /home/exx/jiatong/projects/svs/ParallelWaveGAN/egs/multilingual/voc1/exp/train_nodev_multilingual_hifigan.v1/checkpoint-600000steps.pkl \
    ${opts} "$@"
