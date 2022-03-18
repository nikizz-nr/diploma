#!/bin/bash
curl --silent -X POST -u admin:$2 "http://$1:8082/api/projects/create?name=$3&project=$3" > /dev/null
token=`curl --silent -X POST -u admin:$2 "http://$1:8082/api/user_tokens/generate?name=jenkins_token" | jq -r ".token"`
if [ "$token" == "null" ]; then
    token=`terraform output -json sq-token | sed "s/\"//g"`
fi
jq . <<< "{\"token\": \"$token\"}"
