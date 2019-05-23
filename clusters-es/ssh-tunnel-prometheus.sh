#!/bin/bash

TEAM=$1
ENV=$2

ssh monitor-instance \
    -L 3000:localhost:3000 \
    -L 9090:localhost:9090 \
    -F $TEAM-$ENV-ssh.cfg
