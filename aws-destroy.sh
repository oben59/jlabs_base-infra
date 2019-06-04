#!/usr/bin/env bash

set -e

make tf-destroy-aws-pp LAYER=002-asg
make tf-destroy-aws-pp LAYER=001-vpc
