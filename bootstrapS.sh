#!/bin/sh
TMP_DIR=$(mktemp -d --suffix='.S')

cd $TMP_DIR
git clone https://github.com/joshuacox/S.git
cd S
git pull
sudo make install
cd
rm -Rf $TMP_DIR
