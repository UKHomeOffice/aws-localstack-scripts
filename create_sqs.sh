#!/bin/bash

_set_queue_attributes=_set_queue_attributes.json

queueUrls=$(aws sqs list-queues | grep "$STAGE_NAME" | tr -s ' ' | tr '\n' ' ')

IFS=', ' read -ra urls <<< "$queueUrls"

for url in "${urls[@]}"
do
  name=$(echo $url | grep -o "$STAGE_NAME[^[:blank:]]*")
  name="${name%\"}"
  name="${name#\"}"

  url="${url%\"}"
  url="${url#\"}"
  attr=$(aws sqs get-queue-attributes --queue-url $url --attribute-names All)
  attr=$(echo $attr | sed -e 's/[[:digit:]]\{12\}/000000000000/g')
  attr=$(echo $attr | jq -r --arg attr "$attr" '.Attributes')

  echo $attr > $_set_queue_attributes

  aws sqs create-queue \
    --queue-name $name \
    --attributes file://$_set_queue_attributes \
    --endpoint-url=http://localhost:4576

  rm $_set_queue_attributes
done
