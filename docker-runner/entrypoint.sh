#!/bin/bash

REPOSITORY_NAME=$1
RUNNER_NAME=$2
IS_ONLY_REGIST=$3
CLEAN_WAIT_TIME=5.0

echo "Runner-token url: https://api.github.com/repos/${GITHUB_USER}/${REPOSITORY_NAME}/actions/runners/registration-token"
RUNNER_TOKEN=$(curl -s -X POST \
    -H "authorization: token ${GITHUB_TOKEN}" \
    https://api.github.com/repos/${GITHUB_USER}/${REPOSITORY_NAME}/actions/runners/registration-token | jq -r .token)

./config.sh \
    --unattended \
    --replace \
    --url https://github.com/${GITHUB_USER}/${REPOSITORY_NAME} \
    --token ${RUNNER_TOKEN} \
    --name ${RUNNER_NAME} \
    --work _work

if [ -z ${IS_ONLY_REGIST} ]; then
    ./run.sh --once
    sleep ${CLEAN_WAIT_TIME}
    ./config.sh remove --token ${RUNNER_TOKEN}
fi
