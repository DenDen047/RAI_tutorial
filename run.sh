#!/bin/bash

WORKDIR=/root/work

nvidia-docker run -it --rm \
    -w ${WORKDIR} \
    -v ${PWD}/src:${WORKDIR} \
    denden047/rai \
    /bin/bash