#!/bin/bash

OWNER=$1
REPO=$2
PAT=$3
NAME=$4

# if set this script will only run ./config.sh
# it will not run the actions runner
REGISTER_ONLY=$5

cleanup() {
    token=$(curl -s -XPOST \
        -H "authorization: token ${PAT}" \
        https://api.github.com/repos/${OWNER}/${REPO}/actions/runners/registration-token | jq -r .token)
        sleep 5.0
    ./config.sh remove --token $token
    echo "CLEAN: $?"
}

echo "TOKEN-URL: https://api.github.com/repos/${OWNER}/${REPO}/actions/runners/registration-token"
token=$(curl -s -XPOST \
    -H "authorization: token ${PAT}" \
    https://api.github.com/repos/${OWNER}/${REPO}/actions/runners/registration-token | jq -r .token)

echo "CONFIG-URL: https://github.com/${OWNER}/${REPO}"
./config.sh \
    --unattended \
    --replace \
    --url https://github.com/${OWNER}/${REPO} \
    --token ${token} \
    --name ${NAME} \
    --work _work

if [ -z ${REGISTER_ONLY} ]; then
    ./run.sh --once
    cleanup
fi
