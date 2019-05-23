#!/bin/bash

if [[ $# -ne 3 ]]; then
    echo "usage: $0 <env> <layer> <tf_cmd> (e.g. \`$0 pp 04-nomad-workers 'state list'\`)" > /dev/stderr
    exit 127
fi

if [ "$1" == "pp" ]; then
    ENV="pp"
elif [ "$1" == "prod" ]; then
    ENV="prod"
else
    echo "$0 error: Please current env should be one of them : 'pp', 'prod'." > /dev/stderr
    exit 127
fi

LAYER=$2
TF_CMD=$3

cd terraform/$LAYER

# connect to S3 terraform layer
terraform init \
-backend-config "bucket=jlabs-$ENV-ctn-eu-west-1-tfstate" \
-backend-config "key=$LAYER.jlabs-$ENV-ctn-eu-west-1.tfstate" \
-backend-config "region=eu-west-1" \
-backend-config "dynamodb_table=jlabs-$ENV-ctn-eu-west-1-tfstate-lock" \
-force-copy \
&& \
terraform get -update

terraform $TF_CMD
