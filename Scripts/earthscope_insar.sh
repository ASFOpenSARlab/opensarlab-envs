#!/bin/bash
set -e

# Assume gitpuller already installed

PATH=$HOME/.local/bin:$PATH

############### Copy to .local/envs ###############

LOCAL="$HOME"/.local
NAME="earthscope_insar"
python_version=$(conda run -n $NAME python --version | cut -b 8-11)
SITE_PACKAGES="$LOCAL/envs/$NAME/lib/python"$python_version"/site-packages"

pythonpath="$PYTHONPATH"
path="$PATH"

######## Set ISCE env vars ########

# set path and pythonpath variables
pythonpath=$SITE_PACKAGES/isce:"$pythonpath"
path="$SITE_PACKAGES"/isce/applications:"$LOCAL"/envs/"$NAME"/bin:$path
conda env config vars set -n $NAME PYTHONPATH="$pythonpath"
conda env config vars set -n $NAME PATH="$path"

# set ISCE_HOME
conda env config vars set -n $NAME ISCE_HOME="$SITE_PACKAGES"/isce

####### Clone the ARIA-tools-docs repo ########
aria_docs="/home/jovyan/ARIA-tools-docs"
if [ ! -d $aria_docs ]
then
    git clone -b master --depth=1 --single-branch https://github.com/aria-tools/ARIA-tools-docs.git $aria_docs
fi


BASH_PROFILE=$HOME/.bash_profile
if ! test -f "$BASH_PROFILE"; then
cat <<EOT >> $BASH_PROFILE
if [ -s ~/.bashrc ]; then
    source ~/.bashrc;
fi
EOT
fi
