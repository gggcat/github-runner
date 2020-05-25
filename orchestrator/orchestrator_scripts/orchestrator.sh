#!/bin/bash


function have_commit () {
    REPOSITORY_NAME=$1

    COMMIT_STATUS=$(curl -s -H "accept: application/vnd.github.antiope-preview+json" \
        -H "authorization: token ${GITHUB_TOKEN}" \
        https://api.github.com/repos/${GITHUB_USER}/${REPOSITORY_NAME}/commits \
        -o /dev/null -w '%{http_code}\n' -s)
    echo ${COMMIT_STATUS}
}

function get_last_commit () {
    REPOSITORY_NAME=$1

    COMMIT_STATUS=$( have_commit ${REPOSITORY_NAME} )
    if [ ${COMMIT_STATUS} = "200" ]; then
        COMMITS=$(curl -s -H "accept: application/vnd.github.antiope-preview+json" \
            -H "authorization: token ${GITHUB_TOKEN}" \
            https://api.github.com/repos/${GITHUB_USER}/${REPOSITORY_NAME}/commits/HEAD \
            | jq -r '.sha')
        echo ${COMMITS}
    else
        echo "Getting commits from the HEAD ... no commits"
        exit 0
    fi
}

function get_commits_queue () {
    REPOSITORY_NAME=$1
    COMMIT=$2

    COMMIT_STATUS=$( curl -s \
        -H "accept: application/vnd.github.antiope-preview+json" \
        -H "authorization: token ${GITHUB_TOKEN}"\
        https://api.github.com/repos/${GITHUB_USER}/${REPOSITORY_NAME}/commits/${COMMIT}/check-runs?status=queued \
        | jq -r '.check_runs[] | "\(.status)"' )
    echo ${COMMIT_STATUS}
}

function run_self_hosted_runner() {
    REPOSITORY_NAME=$1
    RUNER_NAME=$2

    # check commits
    echo "Getting commits from the last HEAD ..."
    for COMMIT in $( get_last_commit ${REPOSITORY_NAME} ); do 
        echo "Checking ${COMMIT} for check requests ..."

        # for each check run requested for this commit, get the "status"
        # field and assign to the "COMMIT_STATUS" variable 
        for COMMIT_STATUS in $( get_commits_queue ${REPOSITORY_NAME} ${COMMIT} ); do
            echo "Found check run request with status ${COMMIT_STATUS}, launching job ..."
            docker-compose run runner ${REPOSITORY_NAME} ${RUNNER_NAME}
            docker-compose down
        done
    done
}


# make sure we have values for all our arguments
[ -z ${GITHUB_TOKEN} ] || [ -z ${GITHUB_USER} ] && {
    echo "need export GITHUB_USER and GITHUB_TOKEN"
    exit 1
}

SELF_HOSTED_REPOSITORIES="repositories.jsonl"
REPOSITORIES=$(cat ${SELF_HOSTED_REPOSITORIES} | jq --slurp -r '.[].repository_name')
# get latest runner image
docker-compose pull

for REPOSITORY_NAME in ${REPOSITORIES}; do 
    # repository have runnners?
    HAVE_RUNNERS=$(curl -s -H "accept: application/vnd.github.antiope-preview+json" \
        -H "authorization: token ${GITHUB_TOKEN}" \
        https://api.github.com/repos/${GITHUB_USER}/${REPOSITORY_NAME}/actions/runners \
        | jq -r '.total_count')

    # repository dont have runnners. create it. (but its never use.)
    echo "${REPOSITORY_NAME} have runners (${HAVE_RUNNERS})"
    if [ ${HAVE_RUNNERS} = "0" ]; then
        RUNNER_NAME="${REPOSITORY_NAME}-REG"
        echo "regist initial runner at ${REPOSITORY_NAME}"
        docker-compose run runner ${REPOSITORY_NAME} ${RUNNER_NAME} "1"
        docker-compose down
    elif [ ${HAVE_RUNNERS} = "1" ]; then
        # add repository
        RUNNER_NAME="${REPOSITORY_NAME}-RUN"
        echo "regist runner at ${REPOSITORY_NAME} ..."
        run_self_hosted_runner ${REPOSITORY_NAME} ${RUNNER_NAME}
    else
        echo "${REPOSITORY_NAME} already have runners"
    fi
done
