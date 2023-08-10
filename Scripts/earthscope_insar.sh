#!/bin/bash
set -e

# Assume gitpuller already installed

PATH=$HOME/.local/bin:$PATH

############### Copy to .local/envs ###############

LOCAL="$HOME"/.local
NAME="earthscope_insar"
python_version=$(conda run -n $NAME python --version | cut -b 8-11)
SITE_PACKAGES="$LOCAL/envs/$NAME/lib/python"$python_version"/site-packages"
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

######## Install ARIA-Tools ########

# clone the ARIA-Tools repo and build ARIA-Tools
aria="$LOCAL/ARIA-tools"
if [ ! -d "$aria" ]
then
    git clone -b v1.1.6 https://github.com/aria-tools/ARIA-tools.git "$aria"
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