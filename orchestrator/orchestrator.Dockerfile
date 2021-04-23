FROM python:3.8-slim

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends apt-utils && \
    apt-get install -y --no-install-recommends curl && \
    apt-get install -y --no-install-recommends wget && \
    apt-get install -y --no-install-recommends jq && \
    apt-get install -y --no-install-recommends docker.io && \
    apt-get install -y --no-install-recommends docker-compose && \
    apt-get install -y --no-install-recommends cron && \
    apt-get install -y --no-install-recommends procps && \
    echo "*** INSTALLED: ubuntu modules ***"

WORKDIR /home/orchestrator

COPY orchestrator_scripts/* ./

ENTRYPOINT ["bash", "cronpoint.sh"]