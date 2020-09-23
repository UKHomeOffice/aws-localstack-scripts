#!/bin/bash

home_directory="$(dirname "$PWD")"
STAGE_NAME=dev
LAMBDA_RUNTIME=nodejs8.10
lambda=$1

aws lambda delete-function \
  --function-name $STAGE_NAME-$lambda \
  --endpoint-url=http://localhost:4574

./lib/create-lambda.sh $lambda $STAGE_NAME $LAMBDA_RUNTIME $home_directory
