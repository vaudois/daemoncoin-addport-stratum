#!/bin/bash

FUNC=/etc/functionscoin.sh
if [[ ! -f "$FUNC" ]]; then
	source /etc/functions.sh
else
	source /etc/functionscoin.sh
fi

source ${absolutepath}/${installtoserver}/conf/info.sh

	LOG_DIR=/var/log/daemon-coin
	STRATUM_DIR=${PATH_STRATUM}
	USR_BIN=/usr/bin