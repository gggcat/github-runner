#!/bin/bash

CONTAINER_REPOSITORY_NAME="zzzcat/github-runner"
# GitHub Runner
RUNNER_VERSION=$(curl -s https://api.github.com/repos/actions/runner/releases/latest | jq -r '.assets[].name | select(. | contains("linux-x64"))' | perl -pe s/'actions-runner-linux-x64-([0-9\.]+).tar.gz/$1/g')
# DockerHub
DOCKER_HUB_VERSIONS=$(curl -s https://registry.hub.docker.com/v1/repositories/${CONTAINER_REPOSITORY_NAME}/tags | jq -r '.[].name')
TAG_NAME=${RUNNER_VERSION}

# Docker Hubにイメージがある場合はスキップする
for DOCKERHUB_VERSION in ${DOCKER_HUB_VERSIONS[@]}; do
    if [ ${DOCKERHUB_VERSION} = ${RUNNER_VERSION} ]; then
        echo "already docker images ${RUNNER_VERSION}"
        exit 0
    fi
done

# DockerHub に Push
CONTAINER_NAME="${CONTAINER_REPOSITORY_NAME}:${TAG_NAME}"
CONTAINER_LATEST="${CONTAINER_REPOSITORY_NAME}:latest"
docker login -u ${DOCKERHUB_USER} -p ${DOCKERHUB_TOKEN}
docker build -t ${CONTAINER_NAME} -t ${CONTAINER_LATEST} -f runner.Dockerfile .
docker push ${CONTAINER_NAME}
