#!/usr/bin/env bash

PHP_CLI='php -d max_execution_time=120'

DIR=##WEBDIR##
cd ${DIR}

date
echo started in ${DIR}

while true; do
${PHP_CLI} runconsole.php cronjob/runMem
sleep 1800
done
exec bash
