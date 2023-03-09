#!/bin/bash
set -e

env="train"
local="/home/jovyan/.local"
env_prefix=$local"/envs/"$env
site_packages=$env_prefix"/lib/python3.8/site-packages"
train=$local"/TRAIN"

# clone TRAIN patched for Python3 in the OpenSARlab
if [ ! -d $train ]
then
    git clone -b OpenSARlab --single-branch https://github.com/asfadmin/hyp3-TRAIN.git $train
fi

conda env config vars set -n $env PYTHONPATH=$train/src