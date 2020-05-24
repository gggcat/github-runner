#!/bin/bash

CONTAINER_REPOSITORY_NAME="zzzcat/github-runner-orchestrator"

# DockerHub に Push
CONTAINER_LATEST="${CONTAINER_REPOSITORY_NAME}:latest"
docker login -u ${DOCKERHUB_USER} -p ${DOCKERHUB_TOKEN}
docker build -t ${CONTAINER_LATEST} -f orchestrator.Dockerfile .
docker push ${CONTAINER_LATEST}