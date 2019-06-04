#!/usr/bin/env bash

set -e

make tf-destroy-aws-pp LAYER_PATH=002-asg
make tf-destroy-aws-pp LAYER_PATH=001-vpc
