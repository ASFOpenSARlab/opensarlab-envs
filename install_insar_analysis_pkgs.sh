#!/bin/bash
set -e
env="insar_analysis"
local="/home/jovyan/.local"
env_prefix=$local"/envs/"$env
site_packages=$env_prefix"/lib/python3.8/site-packages"

######## ISCE ########

# start building local path and pythonpath variables
pythonpath=$site_packages/isce:$PYTHONPATH
path=$site_packages/isce/applications:$env_prefix/bin:$PATH

# set ISCE_HOME
conda env config vars set -n $env ISCE_HOME=$site_packages/isce

######## ARIA-Tools ########

# clone the ARIA-Tools repo and build ARIA-Tools
aria=$local"/ARIA-tools"
if [ ! -d $aria ]
then
    git clone https://github.com/aria-tools/ARIA-tools.git $aria
    wd=$(pwd)
    cd $aria
    conda run python $aria/setup.py build
    conda run python $aria/setup.py install
    cd $wd
fi

# clone the ARIA-tools-docs repo
aria_docs="/home/jovyan/ARIA-tools-docs"
if [ ! -d $aria_docs ]
then
    git clone -b master --depth=1 --single-branch https://github.com/aria-tools/ARIA-tools-docs.git $aria_docs
fi

######## MintPy ########

mintpy=$local"/MintPy"
pyaps=$local"/PyAPS"
proj=$local"/envs/"$env"/share/proj"

# set MintPy env variables
conda env config vars set -n $env MINTPY_HOME=$mintpy
conda env config vars set -n $env PYAPS_HOME=$pyaps
conda env config vars set -n $env PROJ_LIB=$proj

#update local path and pythonpath variables
path=$mintpy"/mintpy:"$path
pythonpath=$mintpy":"$pyaps":"$pythonpath

# clone MintPy
if [ ! -d $mintpy ]
then
    git clone -b v1.3.0 --depth=1 --single-branch https://github.com/insarlab/MintPy.git $mintpy
fi

# clone pyaps
if [ ! -d $pyaps ]
then
    git clone -b main --depth=1 --single-branch https://github.com/yunjunz/pyaps3.git $pyaps
fi

# install pykml
$env_prefix/bin/pip install pykml -e git+https://github.com/yunjunz/pykml.git#egg=pykml

#######################

# set PATH and PYTHONPATH
conda env config vars set -n $env PYTHONPATH=$pythonpath
conda env config vars set -n $env PATH=$path