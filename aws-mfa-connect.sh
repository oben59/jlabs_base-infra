#!/bin/bash

set -e

# NOTE
# call the script like this to connect :
# emulate bash -c 'source ~/dev/www/github/infra-jdxlabs/mfa-connect.sh'

unset AWS_DEFAULT_REGION
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN


# if [[ $# -ne 1 ]]; then
#     echo "usage: $0 <current_env> (e.g. \`$0 prod\`)" > /dev/stderr
#     exit 127
# fi

MASTER_KEY_NAME=aws-jdxmaster
TOTP_KEY=$TOTP_KEY_JDX_USER

CURRENT_ENV=${1-'pp'}

if [ "$CURRENT_ENV" == "pp" ]; then
    DISTANTACCOUNT="586212427949"
    ROLENAME="Administrator"
    ANSIBLE_CFG="./jlabs-pp-ansible.cfg"
elif [ "$CURRENT_ENV" == "prod" ]; then
    DISTANTACCOUNT=""
    ROLENAME=""
    ANSIBLE_CFG=""
else
    echo "$0 error: Please current env should be one of them : 'pp', 'prod'." > /dev/stderr
    exit 127
fi

if ! which jq 2>&1 > /dev/null ; then
    echo "$0 error: Please install 'jq'." > /dev/stderr
    exit 127
fi

if ! which aws 2>&1 > /dev/null ; then
    echo "$0 error: Please install 'awscli'." > /dev/stderr
    exit 127
fi

# Checks if the correct profile is selected
export AWS_PROFILE=$MASTER_KEY_NAME
AWSNAME="$(echo $AWS_PROFILE)"
if [ $AWS_PROFILE != $MASTER_KEY_NAME ]; then
    echo "$0 error: incorrect profile found, please switch on this one :" > /dev/stderr
    echo "export AWS_PROFILE=$MASTER_KEY_NAME" > /dev/stderr
    exit 127
fi

# Get user arn
USERARN="$(aws --output json iam get-user | jq -r .User.Arn)"
if [[ -z "$USERARN" ]]; then
    echo "$0 error: unable to determine AWS IAM user.  Did you run 'aws configure'?" > \
        /dev/stderr
    exit 128
fi

REGION="eu-west-1"
ROLEARN="arn:aws:iam::$DISTANTACCOUNT:role/$ROLENAME"
IAMUSER="$(basename $USERARN)"
ACCOUNT="$(echo $USERARN | cut -d: -f5)"
MFAARN="arn:aws:iam::$ACCOUNT:mfa/$IAMUSER"

# echo -n "Enter MFA token code for $MFAARN: "
# read MFACODE
# echo ""
MFACODE="$(oathtool --totp --base32 $TOTP_KEY)"

# assume role for distant account
RESP="$(aws --region $REGION sts assume-role \
    --role-arn $ROLEARN \
    --role-session-name assumption-$IAMUSER-$(date +%s) \
    --serial-number $MFAARN \
    --token-code $MFACODE 2> /dev/null )"

AKI="$(echo $RESP | jq -r .Credentials.AccessKeyId)"
if [[ -z "$AKI" ]]; then
    echo "Failure." > /dev/stderr
    exit 129
fi
SAK="$(echo $RESP | jq -r .Credentials.SecretAccessKey)"
ST="$(echo $RESP | jq -r .Credentials.SessionToken)"

echo "export AWS_PROFILE=$MASTER_KEY_NAME"
echo "export AWS_DEFAULT_REGION=\"$REGION\""
export AWS_DEFAULT_REGION="$REGION"
echo "export AWS_ACCESS_KEY_ID=\"$AKI\""
export AWS_ACCESS_KEY_ID="$AKI"
echo "export AWS_SECRET_ACCESS_KEY=\"$SAK\""
export AWS_SECRET_ACCESS_KEY="$SAK"
echo "export AWS_SESSION_TOKEN=\"$ST\""
export AWS_SESSION_TOKEN="$ST"
