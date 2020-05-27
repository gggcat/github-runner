#!/bin/bash

REPOSITORY_NAME=$1
RUNNER_NAME=$2
IS_ONLY_REGIST=$3
CLEAN_WAIT_TIME=5.0

if [ -z ${REPOSITORY_NAME} ] || [ -z ${RUNNER_NAME} ]; then
    echo "Usage: entrypoint.sh REPOSITORY_NAME RUNNER_NAME"
    exit 1
fi

#
# Run Github Self-hosted runners
#
if [ -z ${GITHUB_TOKEN} ] || [ -z ${GITHUB_USER} ]; then
    echo "need export GITHUB_USER and GITHUB_TOKEN"
    exit 1
fi

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
    echo "Run ... ${RUNNER_NAME} on ${REPOSITORY_NAME}"
    ./run.sh --once
    sleep ${CLEAN_WAIT_TIME}
    ./config.sh remove --token ${RUNNER_TOKEN}
else
    echo "Skip run ... registration only"
fi
