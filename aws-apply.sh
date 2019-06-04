#!/usr/bin/env bash

set -e

make tf-apply-aws-pp LAYER=001-vpc
make tf-apply-aws-pp LAYER=002-asg
