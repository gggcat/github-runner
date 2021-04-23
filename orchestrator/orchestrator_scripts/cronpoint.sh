CRON_CONFIG=/etc/cron.d/runner-cron
CRON_LOG=/var/log/cron.log

# make repositories.jsonl
bash get_repositories.sh
sleep 2.0
bash clean_runner.sh
sleep 2.0

env > ${CRON_CONFIG}
echo "" >> ${CRON_CONFIG}
# update repositories.jsonl
echo "0,2 0 * * * root pgrep -f \"[o]orchestrator.sh\" || cd /home/orchestrator && bash get_repositories.sh >> ${CRON_LOG}" >> ${CRON_CONFIG}
# clean runners
echo "1 0 * * * root pgrep -f \"[o]orchestrator.sh\" || cd /home/orchestrator && bash clean_runner.sh >> ${CRON_LOG}" >> ${CRON_CONFIG}
# do self-hosted runners
echo "5,10,15,20,25,30,35,40,45,50,55 * * * * root pgrep -f \"[o]orchestrator.sh\" || cd /home/orchestrator && bash orchestrator.sh >> ${CRON_LOG}" >> ${CRON_CONFIG}
chmod 0644 ${CRON_CONFIG}
crontab ${CRON_CONFIG}
touch ${CRON_LOG}

# do cron
cron && tail -f ${CRON_LOG}
