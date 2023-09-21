#!/bin/bash

if [ $# -eq 0 ]
then
    echo "$0 <target-directory>"
    exit 1
fi

target_dir=$1
repo_path=https://github.com/SeisComP

echo "Cloning base repository into $1"
git clone $repo_path/seiscomp.git $1

echo "Cloning base components"
cd $1/src/base
git clone $repo_path/seedlink.git
git clone $repo_path/common.git
git clone $repo_path/main.git
git clone $repo_path/extras.git

echo "Cloning external base components"
git clone $repo_path/contrib-gns.git
git clone $repo_path/contrib-ipgp.git
git clone https://github.com/swiss-seismological-service/sed-SeisComP-contributions.git contrib-sed

echo "Done"

cd ../../

echo "If you want to use 'mu', call 'mu register --recursive'"
echo "To initialize the build, run 'make'."

# cd $BUILD_DIR/
# cmake -DCMAKE_INSTALL_PREFIX=${BUILD_DIR} ${DEV_DIR}
# make install
