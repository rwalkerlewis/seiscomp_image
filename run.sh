#!/bin/bash

#docker run --rm -it seiscomp

export seiscomp_path=${HOME}/projects/seiscomp

# docker run --name seiscomp-dev --rm -it -v ${seiscomp_path}:/home/seiscomp-user seiscomp
docker run -e DISPLAY=unix$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
        -v /tmp/.docker.xauth:/tmp/.docker.xauth:rw -e XAUTHORITY=/tmp/.docker.xauth \
        --name seiscomp-dev --rm -it -v ${seiscomp_path}:/home/seiscomp-user seiscomp
