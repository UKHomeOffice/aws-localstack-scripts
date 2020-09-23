#!/bin/bash

lambda=$1
STAGE_NAME=$2
LAMBDA_RUNTIME=$3
home_directory=$4

handler=index.handler

if [ "$1" == 'motion-detector' ]
  then
    LAMBDA_RUNTIME=Python3.7
    handler=motion_detector.message_processor.handle_event
fi

aws lambda create-function \
  --function-name $STAGE_NAME-$lambda \
  --code S3Bucket="__local__",S3Key="$home_directory/$lambda" \
  --timeout 300 \
  --handler $handler \
  --runtime $LAMBDA_RUNTIME \
  --role whatever \
  --endpoint-url=http://localhost:4574

# extract remote lambdas env vars
remoteConfig=$(aws lambda get-function-configuration --function-name $STAGE_NAME-$lambda)
remoteVariables=$(echo $remoteConfig | jq -r --arg remoteConfig "$remoteConfig" '.Environment')
# replace account number with generic localstack account
remoteVariables=$(echo $remoteVariables | sed -e 's/[[:digit:]]\{12\}/000000000000/g')
# replace sqs domains with localstack localhost port
remoteVariables=$(echo $remoteVariables | sed -e 's|https://sqs.eu-west-1.amazonaws.com/000000000000|http://localhost:4576/queue|g')
# replace environment host domain with local
remoteVariables=$(echo $remoteVariables | sed -e 's|https://person.*uk|http://localhost|g')
# inject aws credentials into env vars for lambdas so they can call remote services (i.e. DynamoDB)
addCredsToEnvsStringSed='s|Variables": {|Variables":{ "AWS_ACCESS_KEY": "'
addCredsToEnvsStringSed+=$AWS_ACCESS_KEY
addCredsToEnvsStringSed+='", "AWS_SECRET_KEY": "'
addCredsToEnvsStringSed+=$AWS_SECRET_KEY
addCredsToEnvsStringSed+='", "AWS_REGION": "'
addCredsToEnvsStringSed+=$AWS_REGION
addCredsToEnvsStringSed+='",|'
remoteVariables=$(echo $remoteVariables | sed -e "$addCredsToEnvsStringSed")

aws lambda update-function-configuration \
  --function-name $STAGE_NAME-$lambda \
  --environment "$remoteVariables" \
  --endpoint-url=http://localhost:4574

aws lambda create-event-source-mapping \
  --function-name $STAGE_NAME-$lambda \
  --batch-size 1 \
  --event-source-arn arn:aws:sqs:eu-west-1:000000000000:$STAGE_NAME-$lambda \
  --endpoint-url=http://localhost:4574
