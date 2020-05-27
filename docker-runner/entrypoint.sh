#!/bin/bash

REPOSITORY_NAME=$1
RUNNER_NAME=$2
IS_ONLY_REGIST=$3
CLEAN_WAIT_TIME=5.0

#
# CIFS Mount
#
mkdir -p ${CIFS_LOCAL_PATH}
mount -t cifs -o username=${CIFS_USER},password=${CIFS_PASS} //${CIFS_HOST}${CIFS_REMOTE_PATH} ${CIFS_LOCAL_PATH}

#
# Run Github Self-hosted runners
#
echo "Runner-token url: https://api.github.com/repos/${GITHUB_USER}/${REPOSITORY_NAME}/actions/runners/registration-token"
RUNNER_TOKEN=$(curl -s -X POST \
    -H "authorization: token ${GITHUB_TOKEN}" \
    https://api.github.com/repos/${GITHUB_USER}/${REPOSITORY_NAME}/actions/runners/registration-token | jq -r .token)

echo "REGIST: https://github.com/${GITHUB_USER}/${REPOSITORY_NAME}"
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
