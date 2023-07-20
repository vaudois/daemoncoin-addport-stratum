#!/bin/bash

PHP_CLI='php -d max_execution_time=120'

DIR=WEBDIR
cd ${DIR}

date
echo started in ${DIR}

while true; do
${PHP_CLI} runconsole.php cronjob/runStratdaem
sleep 25
done
exec bash
