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

if [[ ("${LATESTVER}" > "${VERSION}" && "${LATESTVER}" != "null") ]]; then
	message_box " Updating This script to ${LATESTVER}" \
	"You are currently using version ${VERSION}
	\n\nAre you going to update it to the version ${LATESTVER}"
	TAG="${LATESTVER}"

	cd ~
	clear

	hide_output sudo git config --global url."https://github.com/".insteadOf git@github.com:
	hide_output sudo git config --global url."https://".insteadOf git://
	sleep 1

	REPO="vaudois/daemoncoin-addport-stratum"

	temp_dir="$(mktemp -d)" && \
		git clone -q git@github.com:${REPO%.git} "${temp_dir}" && \
			cd "${temp_dir}/" && \
				git -c advice.detachedHead=false checkout -q tags/${TAG}
	sleep 1
	test $? -eq 0 ||
		{ 
			echo
			echo -e "$RED Error cloning repository. $COL_RESET";
			echo
			sudo rm -f $temp_dir
			exit 1;
		}
	
	FILEINSTALLEXIST="${temp_dir}/install.sh"
	if [ -f "$FILEINSTALLEXIST" ]; then
		hide_output sudo chown -R $USER ${temp_dir}
		sleep 1
		cd ${temp_dir}
		sudo find . -type f -name "*.sh" -exec chmod -R +x {} \;
		sleep 1
		./install.sh "${temp_dir}"
	fi

	sudo rm -rf $temp_dir

	echo -e "$CYAN  -------------------------------------------------------------------------- 	$COL_RESET"
	echo -e "$RED    Thank you using this scrpt Updating is Finish!				 				$COL_RESET"
	echo -e "$CYAN  -------------------------------------------------------------------------- 	$COL_RESET"
	echo
	cd ~
	exit

else
	message_box " Updating This script " \
	"Check if this scrypt needs update.
	\n\nYou are currently using version ${VERSION}"

	cd ~
	clear
	echo -e "$CYAN  -------------------------------------------------------------------------- 	$COL_RESET"
	echo -e "$RED    Thank you using this scrpt!			 				$COL_RESET"
	echo -e "$CYAN  -------------------------------------------------------------------------- 	$COL_RESET"
	echo
	echo -e "$CYAN  -------------------------------------------------------------------------- 	$COL_RESET"
	echo -e "$GREEN	Donations are welcome at wallets below:					  					$COL_RESET"
	echo -e "$YELLOW  BTC: $COL_RESET $MAGENTA ${BTCDEP}	$COL_RESET"
	echo -e "$YELLOW  LTC: $COL_RESET $MAGENTA ${LTCDEP}	$COL_RESET"
	echo -e "$YELLOW  ETH: $COL_RESET $MAGENTA ${ETHDEP}	$COL_RESET"
	echo -e "$YELLOW  BCH: $COL_RESET $MAGENTA ${BCHDEP}	$COL_RESET"
	echo -e "$CYAN  -------------------------------------------------------------------------- 	$COL_RESET"
	echo
	cd ~
	exit

fi

