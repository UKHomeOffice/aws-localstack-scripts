#!/bin/bash

# Constants
export STAGE_NAME=dev
export LAMBDA_RUNTIME=nodejs8.10
export DEFAULT_DEV_API_KEY='e.g. API Gateway key (dlkhjhlk)'
export BASH_PROFILE=~/.bashrc

# lambdas for local setup
LAMBDAS=(
  'example lambda name 1'
  'example lambda name 2'
  'example lambda name 3'
)

command -v jq >/dev/null 2>&1 || { echo >&2 "I require 'jq' but it's not installed. Please run 'brew install jq'. Aborting."; exit 1; }

if [ -z "$AWS_SECRET_KEY" ] || [ -z "$AWS_ACCESS_KEY" ] || [ -z "$AWS_REGION" ]
  then
    echo 'You need to setup $AWS_SECRET_KEY, $AWS_ACCESS_KEY and $AWS_REGION env vars.'
    echo 'If that does not mean anything to you,'
    echo 'then I would strongly advise you to get more familiar with aws services/credentials before continuing on with this process.'
    exit 1;
fi

if [ "$1" == 'setup' ]
  then
    docker-compose up -d
    sed -i '' -e "s|export LOCALSTACK.*||g" $BASH_PROFILE
    sed -i '' -e '/^[[:space:]]*$/d' $BASH_PROFILE
    echo "export LOCALSTACK=''" >> $BASH_PROFILE
    source $BASH_PROFILE
    sleep 20
elif [ "$1" == 'restart' ]
  then
    docker restart localstack
    sleep 20
elif [ "$1" == 'stop' ]
  then
    docker stop localstack
    sed -i '' -e "s|export LOCALSTACK.*||g" $BASH_PROFILE
    sed -i '' -e '/^[[:space:]]*$/d' $BASH_PROFILE
    source $BASH_PROFILE
    docker container prune
fi

if [ "$1" != 'stop' ]
  then
    ./create_sqs.sh
    ./create_lambdas.sh "${LAMBDAS[@]}"
    ./create_api.sh
fi
