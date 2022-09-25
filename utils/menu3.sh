#!/usr/bin/env bash
#####################################################
# Source code https://github.com/end222/pacmenu
# Updated by Vaudois
# Menu: Update new Stratum
#####################################################

FUNC=/etc/functionscoin.sh
if [[ ! -f "$FUNC" ]]; then
	source /etc/functions.sh
else
	source /etc/functionscoin.sh
fi

source ${absolutepath}/${installtoserver}/conf/info.sh

message_box " Stratum compiler " \
"This Scrypt of Stratum run in future builds sorry
\n\nCheck again later in Update this scrypt Menu"

cd ~
clear

echo -e "$CYAN --------------------------------------------------------------------------- 	$COL_RESET"
echo -e "$RED    Type ${daemonname} at anytime to run this Scrypt!			 				$COL_RESET"
echo -e "$CYAN --------------------------------------------------------------------------- 	$COL_RESET"
exit
