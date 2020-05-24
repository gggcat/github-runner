#!/bin/bash

SELF_HOSTED_REPOSITORIES="repositories.jsonl"
REPOSITORY_NAME=$1

function get_repositories () {
    REPOSITORIES=$( curl -s -H "accept: application/vnd.github.antiope-preview+json" \
        -H "authorization: token ${GITHUB_TOKEN}" \
        https://api.github.com/８user/repos \
        | jq -r '.[].name')

    echo ${REPOSITORIES}
}

# GET /repos/:owner/:repo/actions/secrets
function have_self_hosted_runner_flag_secrets () {
    REPOSITORY_NAME=$1

    curl -s -H "accept: application/vnd.github.antiope-preview+json" \
        -H "authorization: token ${GITHUB_TOKEN}" \
        https://api.github.com/repos/${GITHUB_USER}/${REPOSITORY_NAME}/actions/secrets \
        | jq -r '.secrets[] | select(.name == "IS_SELF_HOSTED") | .name'
}

for REPOSITORY_NAME in $( get_repositories ); do
    IS_SELF_HOSTED=$( have_self_hosted_runner_flag_secrets ${REPOSITORY_NAME} )
    if [ "${IS_SELF_HOSTED}" == "IS_SELF_HOSTED" ]; then
        echo "{ \"repository_name\": \"${REPOSITORY_NAME}\" }" > ${SELF_HOSTED_REPOSITORIES}
    fi
done
