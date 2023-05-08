#!/bin/bash
set -e

# installing OPERA s1-reader
S1=$HOME/.local/s1-reader
curl -sSL https://github.com/opera-adt/s1-reader/archive/refs/tags/v0.1.6.tar.gz -o ~/.local/s1_reader_src.tar.gz
tar -xvf ~/.local/s1_reader_src.tar.gz --directory ~/.local
if ! [ -d "$S1" ]; then
ln -s ~/.local/s1-reader-0.1.6 "$S1"
fi
rm ~/.local/s1_reader_src.tar.gz
mamba run -n isce3_rtc python -m pip install "$S1"

# installing OPERA RTC
RTC=$HOME/.local/RTC
if [ -d "$RTC" ]; then
rm -rf "$RTC"
fi
git clone https://github.com/opera-adt/RTC.git "$RTC"
cd "$RTC"
git checkout 503a197aac3c88c725eb229beaa0370c13e4b050
mamba run -n isce3_rtc python -m pip install "$RTC"