#!/usr/bin/env bash

set -e

make tf-apply-aws-pp LAYER_PATH=001-vpc
make tf-apply-aws-pp LAYER_PATH=002-asg
