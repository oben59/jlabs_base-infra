#!/bin/bash

if [[ $# -ne 4 ]]; then
    echo "usage: $0 <env> <layer> <resource> <nb> (e.g. \`$0 pp 04-elasticsearch aws_instance.es-instance-workers 3\`)" > /dev/stderr
    exit 127
fi

TEAM=jlabs

if [ "$1" == "pp" ]; then
    ENV="pp"
elif [ "$1" == "prod" ]; then
    ENV="prod"
else
    echo "$0 error: Please current env should be one of them : 'pp', 'prod'." > /dev/stderr
    exit 127
fi

LAYER=$2
RESOURCE=$3
NB=$4
# echo $NB
# echo $LAYER
# echo $RESOURCE

# MAX_NB=$(($NB - 1))
# echo $MAX_NB

cd terraform/$LAYER

# connect to S3 terraform layer
terraform init \
-backend-config "bucket=$TEAM-$ENV-eu-west-1-tfstate" \
-backend-config "key=$LAYER.$TEAM-$ENV-eu-west-1.tfstate" \
-backend-config "region=eu-west-1" \
-backend-config "dynamodb_table=$TEAM-$ENV-eu-west-1-tfstate-lock" \
-force-copy \
&& \
terraform get -update

# update resources to be tainted
# for ((i=0; i<=$MAX_NB; i++))
# do
#    terraform taint $RESOURCE.$i
# done
terraform taint $RESOURCE.$NB
