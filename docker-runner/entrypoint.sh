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
# CIFS Mount
#
if [ -z ${CIFS_USER} ] || [ -z ${CIFS_PASS} ] || [ -z ${CIFS_HOST} ] || [ -z ${CIFS_REMOTE_PATH} ] || [ -z ${CIFS_LOCAL_PATH} ]; then
    echo "need export CIFS_XXXXXX"
    exit 1
fi

mkdir -p ${CIFS_LOCAL_PATH}
mount -t cifs -o username=${CIFS_USER},password=${CIFS_PASS} //${CIFS_HOST}${CIFS_REMOTE_PATH} ${CIFS_LOCAL_PATH}
MOUNT_STATUS=$?
if [ ${MOUNT_STATUS} = "0" ]; then
    echo "Mount Status: ${MOUNT_STATUS}"
    echo "Mount From: ${CIFS_HOST}:${CIFS_REMOTE_PATH}"
    echo "Mount To: ${CIFS_LOCAL_PATH}"
else
    echo "Mount Status: ${MOUNT_STATUS}"
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

#
# CIFS Umount
#
umount ${CIFS_LOCAL_PATH}
