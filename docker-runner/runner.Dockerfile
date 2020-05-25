FROM python:3.8-slim

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends apt-utils && \
    apt-get install -y --no-install-recommends curl && \
    apt-get install -y --no-install-recommends wget && \
    apt-get install -y --no-install-recommends jq && \
    apt-get install -y --no-install-recommends docker.io && \
    apt-get install -y --no-install-recommends docker-compose && \
    apt-get install -y --no-install-recommends sudo && \
    echo "*** INSTALLED: ubuntu modules ***"

ENV RUNNER_ALLOW_RUNASROOT=1

WORKDIR /work-runner

RUN export RUNNER_URL=$(curl -s https://api.github.com/repos/actions/runner/releases/latest | jq -r '.assets[].browser_download_url | select(. | contains("linux-x64"))') && \
    wget ${RUNNER_URL} && \
    export RUNNER_VERSION=$(curl -s https://api.github.com/repos/actions/runner/releases/latest | jq -r '.assets[].name | select(. | contains("linux-x64"))') && \
    tar xzf ${RUNNER_VERSION} && \
    bin/installdependencies.sh && \
    echo "*** INSTALLED: GitHub actions modules ***"

COPY entrypoint.sh .
ENTRYPOINT ["bash", "entrypoint.sh"]
