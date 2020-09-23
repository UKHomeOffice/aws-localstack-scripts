#!/bin/bash

# Env vars
dev_api_id=$DEV_API_ID

# private vars
_temp_api_file=_temp_api.json
_temp_paths_file=_paths.json
_temp_methods_file=_methods.json

if [ -z $dev_api_id ]
  then
    printf '$DEV_API_ID NOT SET! Using Default which may be deprecated. API creation may not work.\n\n'
    dev_api_id=$DEFAULT_DEV_API_KEY
fi

# Import remote API Gateway as local Swagger json file
aws apigateway get-export --parameters extensions='apigateway' --rest-api-id=$dev_api_id --stage-name=$STAGE_NAME --export-type oas30 $_temp_api_file

# Setup LocalStack API Gateway
apiCreationResponse=$(aws apigateway create-rest-api --name 'API Gateway Mock' --endpoint-url=http://localhost:4567)
apiId=$(echo $apiCreationResponse | jq -r --arg apiCreationResponse "$apiCreationResponse" '.id')
apiParentResponse=$(aws apigateway get-resources --rest-api-id $apiId --endpoint-url=http://localhost:4567)
apiParentId=$(echo $apiParentResponse | jq -r --arg apiParentResponse "$apiParentResponse" '.items[0].id')

# Output all api endpoints into json file
jq '.paths' $_temp_api_file > $_temp_paths_file
endpoints=( $(jq 'keys[]' $_temp_paths_file) )

# cycle through each endpoint and create it along with all resources on localstack
for uri in "${endpoints[@]}"
do
  uri_part=$(echo $uri | sed -e 's|^\"/||' | sed -e 's|\"$||')
  echo $uri_part

  resourceResponse=$(aws apigateway create-resource \
    --rest-api-id $apiId \
    --parent-id $apiParentId \
    --path-part $uri_part \
    --endpoint-url=http://localhost:4567)

  resourceId=$(echo $resourceResponse | jq -r --arg resourceResponse "$resourceResponse" '.id')

  # echo $(jq ".$uri" $_temp_paths_file)
  jq ".$uri" $_temp_paths_file > $_temp_methods_file
  methods=( $(jq 'keys[]' $_temp_methods_file) )

  for method in "${methods[@]}"
  do
    # echo $(jq ".$method.parameters" $_temp_methods_file)
    # echo $(jq ".$method.\"x-amazon-apigateway-integration\".uri" $_temp_methods_file)
    http_method=$(echo $method | tr a-z A-Z)
    http_method="${http_method%\"}"
    http_method="${http_method#\"}"

    uri_arn=$(jq ".$method.\"x-amazon-apigateway-integration\".uri" $_temp_methods_file)
    uri_arn="${uri_arn%\"}"
    uri_arn="${uri_arn#\"}"
    uri_local_arn=$(echo $uri_arn | sed -e 's/[[:digit:]]\{12\}/000000000000/')

    if [ "$http_method" != "OPTIONS" ]
      then
        echo $method

        aws apigateway put-method \
          --rest-api-id $apiId \
          --resource-id $resourceId \
          --http-method $http_method \
          --authorization-type "NONE" \
          --endpoint-url=http://localhost:4567

        aws apigateway put-integration \
          --rest-api-id $apiId \
          --resource-id $resourceId \
          --http-method $http_method \
          --type AWS_PROXY \
          --integration-http-method POST \
          --uri $uri_local_arn \
          --passthrough-behavior WHEN_NO_MATCH \
          --endpoint-url=http://localhost:4567
    fi
  done
done

aws apigateway create-deployment \
  --rest-api-id $apiId \
  --stage-name $STAGE_NAME \
  --endpoint-url=http://localhost:4567

rm $_temp_api_file
rm $_temp_paths_file
rm $_temp_methods_file

echo "Access API on http://localhost:4567/restapis/$apiId/$STAGE_NAME/_user_request_/"

substituteAPINameInProfile='s|LOCALSTACK.*|LOCALSTACK=http://localhost:4567/restapis/'
substituteAPINameInProfile+=$apiId
substituteAPINameInProfile+='/'
substituteAPINameInProfile+=$STAGE_NAME
substituteAPINameInProfile+='/_user_request_|g'

sed -i '' -e "$substituteAPINameInProfile" $BASH_PROFILE
source $BASH_PROFILE
