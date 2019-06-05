#!/usr/bin/env bash

set -e

eksctl create cluster --name jlabs-pp-eks \
    --region eu-west-1 \
    --nodes 2 --nodes-min 1 --nodes-max 2 \
    --node-type=t3.medium
