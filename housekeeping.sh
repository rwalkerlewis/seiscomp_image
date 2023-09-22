#!/bin/bash

# Script to build environment after building docker container

# Build & source .bashrc
${BUILD_DIR}/bin/seiscomp print env  > ~/.bashrc
source ~/.bashrc

# Setup Database
export NEW_PASSWORD=Password

sudo /etc/init.d/mysql start
sudo mysql -e "SET old_passwords=0; ALTER USER root@localhost IDENTIFIED BY '${NEW_PASSWORD}'; FLUSH PRIVILEGES;"

