#!/usr/bin/env bash
#####################################################
# Source code https://github.com/end222/pacmenu
# Updated by Vaudois
# Updrade this scrypt
#####################################################


FUNC=/etc/functionscoin.sh
if [[ ! -f "$FUNC" ]]; then
	source /etc/functions.sh
else
	source /etc/functionscoin.sh
fi

source ${absolutepath}/${installtoserver}/conf/info.sh

if [[ ("${LATESTVER}" != "${VERSION}" && "${LATESTVER}" != "null") ]]; then
	message_box " Updating This script to ${LATESTVER}" \
	"You are currently using version ${VERSION}
	\n\nAre you going to update it to the version ${LATESTVER}"
else
	message_box " Updating This script " \
	"Check if this scrypt needs update.
	\n\nYou are currently using version ${VERSION}"
fi

cd ~
clear

sudo curl https://raw.githubusercontent.com/vaudois/install_DmcAddpStrm/master/bootstrap.sh | bash

echo -e "$CYAN --------------------------------------------------------------------------- 	$COL_RESET"
echo -e "$RED    Thank you using this scrpt Updating is Finish!				 				$COL_RESET"
echo -e "$CYAN --------------------------------------------------------------------------- 	$COL_RESET"
exit

