#!/bin/bash
set -e

# Assume gitpuller already installed

PATH=$HOME/.local/bin:$PATH

############### Copy to .local/envs ###############
LOCAL="$HOME"/.local
NAME=unavco
SITE_PACKAGES="$LOCAL/envs/$NAME/lib/python3.8/site-packages"
##############################################################

#conda run -n "$NAME" kernda --display-name $NAME $LOCAL/envs/$NAME/share/jupyter/kernels/python3/kernel.json -o

pythonpath="$PYTHONPATH"
path="$PATH"

######## Set ISCE env vars ########

# start building local path and pythonpath variables
pythonpath=$SITE_PACKAGES/isce:"$pythonpath"
path="$SITE_PACKAGES"/isce/applications:"$LOCAL"/envs/"$NAME"/bin:$path

# set ISCE_HOME
conda env config vars set -n $NAME ISCE_HOME="$SITE_PACKAGES"/isce

######## Install MintPy ########

MINTPY_HOME="$LOCAL"/MintPy
PYAPS_HOME="$LOCAL"/PyAPS

# set MintPy env variables
conda env config vars set -n $NAME MINTPY_HOME="$MINTPY_HOME"
conda env config vars set -n $NAME PYAPS_HOME="$PYAPS_HOME"

#update local path and pythonpath variables
path="$MINTPY_HOME"/mintpy:"$path"
pythonpath="$MINTPY_HOME":"$PYAPS_HOME":"$pythonpath"

# clone MintPy
if [ ! -d "$MINTPY_HOME" ]
then
    git clone -b v1.3.1 --depth=1 --single-branch https://github.com/insarlab/MintPy.git "$MINTPY_HOME"
fi

# clone pyaps
if [ ! -d "$PYAPS_HOME" ]
then
    git clone -b main --depth=1 --single-branch https://github.com/yunjunz/PyAPS.git "$PYAPS_HOME"
fi

######## Install ARIA-Tools ########

# clone the ARIA-Tools repo and build ARIA-Tools
aria="$LOCAL/ARIA-tools"
if [ ! -d "$aria" ]
then
    git clone -b release-v1.1.2 https://github.com/aria-tools/ARIA-tools.git "$aria"
    wd=$(pwd)
    cd "$aria"
    conda run -n $NAME python "$aria"/setup.py build
    conda run -n $NAME python "$aria"/setup.py install
    cd "$wd"
fi

path="$LOCAL/ARIA-tools/tools/bin:$LOCAL/ARIA-tools/tools/ARIAtools:"$path
pythonpath="$LOCAL/ARIA-tools/tools:$LOCAL/ARIA-tools/tools/ARIAtools:"$pythonpath
conda env config vars set -n $NAME GDAL_HTTP_COOKIEFILE=/tmp/cookies.txt
conda env config vars set -n $NAME GDAL_HTTP_COOKIEJAR=/tmp/cookies.txt
conda env config vars set -n $NAME VSI_CACHE=YES

# clone the ARIA-tools-docs repo
aria_docs="/home/jovyan/ARIA-tools-docs"
if [ ! -d $aria_docs ]
then
    git clone -b master --depth=1 --single-branch https://github.com/aria-tools/ARIA-tools-docs.git $aria_docs
fi

#######################

# set PATH and PYTHONPATH
conda env config vars set -n $NAME PYTHONPATH="$pythonpath"
conda env config vars set -n $NAME PATH="$path"


BASH_PROFILE=$HOME/.bash_profile
if ! test -f "$BASH_PROFILE"; then
cat <<EOT >> $BASH_PROFILE
if [ -s ~/.bashrc ]; then
    source ~/.bashrc;
fi
EOT
fi