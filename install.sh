#!/bin/bash
################################################################################
#
# Current Created by : Vaudois
# web: https://coinXpool.com
# Program:
#   Install Daemon Coin on Ubuntu 18.04 / 20.04
#   v0.8.3.3 rev.2 (2023-07-02)
#
################################################################################

if [ -z "${TAG}" ]; then
	TAG=v0.8.3.2
fi

clear
	TEMPINSTALL="$1"
	STRATUMFILE="$2"
	EXIT="false"

	if [ -z "${STRATUMFILE}" ]; then
		echo "Starting installer..."
	else
		DISTRO="$3"
		path_stratum=${STRATUMFILE}
	fi
	
	BTCDEP="bc1qt8g9l6agk7qrzlztzuz7quwhgr3zlu4gc5qcuk"
	LTCDEP="MGyth7od68xVqYnRdHQYes22fZW2b6h3aj"
	ETHDEP="0xc4e42e92ef8a196eef7cc49456c786a41d7daa01"
	BCHDEP="bitcoincash:qp9ltentq3rdcwlhxtn8cc2rr49ft5zwdv7k7e04df"

	daemonname=coinbuild
	namescryptinstall="DaemonBuilder % Addport & StratumBuilder"
	installtoserver=coin-setup
	absolutepath=$HOME

	if [ -z "${TEMPINSTALL}" ]; then
		installdirname="${absolutepath}/daemoncoin-addport-stratum"
	else
		installdirname="${TEMPINSTALL}"
	fi
 
	source conf/updates.conf
 
	sudo sed -i 's#btcdons#'$BTCDEP'#' conf/coinbuild.sh
	sleep 1

	sudo sed -i 's#ltcdons#'$LTCDEP'#' conf/coinbuild.sh
	sleep 1

	sudo sed -i 's#ethdons#'$ETHDEP'#' conf/coinbuild.sh
	sleep 1

	sudo sed -i 's#bchdons#'$BCHDEP'#' conf/coinbuild.sh
	sleep 1

	sudo sed -i 's#daemonnameserver#'$daemonname'#' conf/coinbuild.sh
	sleep 1

	sudo sed -i 's#installpath#'$installtoserver'#' conf/coinbuild.sh
	sleep 1
	
	sudo sed -i 's#absolutepathserver#'$absolutepath'#' conf/coinbuild.sh
	sleep 1

	sudo sed -i 's#versiontag#'$TAG'#' conf/coinbuild.sh
	sleep 1
	
	sudo sed -i 's#distroserver#'$DISTRO'#' conf/coinbuild.sh
	sleep 1

	if [ -z "${STRATUMFILE}" ]; then
		source conf/coinbuild.sh
		source ${installdirname}/conf/prerequisite.sh
		source ${installdirname}/conf/getip.sh
	fi

	# Are we running as root?
if (( $EUID == 0 )); then

	source conf/coinbuild.sh

	if ! locale -a | grep en_US.utf8 > /dev/null; then
		# Generate locale if not exists
		sudo locale-gen en_US.UTF-8
	fi

	export LANGUAGE=en_US.UTF-8
	export LC_ALL=en_US.UTF-8
	export LANG=en_US.UTF-8
	export LC_TYPE=en_US.UTF-8

	# Fix so line drawing characters are shown correctly in Putty on Windows. See #744.
	export NCURSES_NO_UTF8_ACS=1

	# Welcome
	message_box "Coinbuild & Addport & Stratum Installer" \
	"Hello and thanks for using the Coinbuild & Addport & Stratum!
	\n\nInstallation for the most part is fully automated. In most cases any user responses that are needed are asked prior to the installation.
	\n\nNOTE: You should only install this on a brand new Ubuntu 18.04 or Ubuntu 20.04 installation.
	\n\nIMPORTANT: Please run this scrypt logged in Sudo User Thnaks you."
	cd ..
	sudo rm -rf ${installdirname}/
	cd ~
	clear
	exit;
else
	cd ~

	output() {
	printf "\E[0;33;40m"
	echo $1
	printf "\E[0m"
	}

	displayErr() {
	echo
	echo $1;
	echo
	exit 1;
	}

	#Add user group sudo + no password
	whoami=$(whoami)
	sudo usermod -aG sudo ${whoami}
	echo '# yiimp
	# It needs passwordless sudo functionality.
	'""''"${whoami}"''""' ALL=(ALL) NOPASSWD:ALL
	' | sudo -E tee /etc/sudoers.d/${whoami} >/dev/null 2>&1

	if [[ -f "${absolutepath}/${installtoserver}/conf/info.sh" ]]; then
		source ${absolutepath}/${installtoserver}/conf/info.sh
		if [[ ("$VERSION" == "$TAG") ]]; then
			source ${installdirname}/conf/coinbuild.sh

			if ! locale -a | grep en_US.utf8 > /dev/null; then
				# Generate locale if not exists
				sudo locale-gen en_US.UTF-8
			fi

			export LANGUAGE=en_US.UTF-8
			export LC_ALL=en_US.UTF-8
			export LANG=en_US.UTF-8
			export LC_TYPE=en_US.UTF-8

			# Fix so line drawing characters are shown correctly in Putty on Windows. See #744.
			export NCURSES_NO_UTF8_ACS=1

			# Same Version
			message_box "Daemoncoin & Addport & Stratum Installer" \
			"Hello and thanks for using the Daemoncoin & Addport & Stratum!
			\n\nAfte check system already have Same version in your computer!.
			\n\nNOTE: You version is ${VERSION}, and your installer is ${TAG}.
			\n\nIMPORTANT: It is not necessary to install this version because you already have it, thanks"
			cd ..
			sudo rm -rf ${installdirname}/
			cd ~
			clear
			if [ -z "${STRATUMFILE}" ]; then
				exit;
			fi
			EXIT="true"
		else
			FILEINFO=true
		fi
	else
		INSTVERSION=${TAG}
	fi

	if [[ ("${INSTVERSION}" == "${TAG}" && "${EXIT}" == "false") ]]; then
		#Copy needed files
		cd ${installdirname}
		sudo mkdir -p ${absolutepath}/${installtoserver}/conf/

		source ${installdirname}/conf/coinbuild.sh
		
		FUNC=/etc/coinbuild.sh
		if [[ ! -f "$FUNC" ]]; then
			sudo cp -r ${installdirname}/conf/coinbuild.sh /etc/
			FUNCTIONFILE=coinbuild.sh
			source /etc/coinbuild.sh
		fi

		SCSCRYPT=/etc/screen-scrypt.sh
		if [[ ! -f "$SCSCRYPT" ]]; then
			hide_output sudo cp -r ${installdirname}/utils/screen-scrypt.sh /etc/
			hide_output sudo chmod +x /etc/screen-scrypt.sh
			
			#Add to contrab screen-scrypt
			(crontab -l 2>/dev/null; echo "@reboot sleep 20 && /etc/screen-scrypt.sh") | crontab -
		fi

		EDITCONFAPP=/usr/bin/editconf.py
		if [[ ! -f "$EDITCONFAPP" ]]; then
			hide_output sudo cp -r ${installdirname}/conf/editconf.py /usr/bin/
			hide_output sudo chmod +x /usr/bin/editconf.py
		fi

		hide_output sudo cp -r ${installdirname}/conf/getip.sh ${absolutepath}/${installtoserver}/conf

	else
		if [[ ("${EXIT}" == "false") ]]; then
			source ${installdirname}/conf/coinbuild.sh

			FUNC=/etc/coinbuild.sh
			if [[ ! -f "$FUNC" ]]; then
				sudo cp -r ${installdirname}/conf/coinbuild.sh /etc/
				FUNCTIONFILE=coinbuild.sh
			fi
		fi
	fi
	
	if [[ ("${EXIT}" == "false") ]]; then
		term_art

		# Update package and Upgrade Ubuntu
		echo
		echo -e "$CYAN => Updating system and installing required packages :$COL_RESET"
		sleep 3

		hide_output sudo apt -y update 
		hide_output sudo apt -y upgrade
		hide_output sudo apt -y autoremove
		hide_output sudo apt-get install -y software-properties-common
		hide_output sudo apt install -y dialog python3 python3-pip acl nano apt-transport-https figlet jq
		echo -e "$GREEN Done...$COL_RESET"

		sleep 3

		if ! locale -a | grep en_US.utf8 > /dev/null; then
		# Generate locale if not exists
		sudo locale-gen en_US.UTF-8
		fi

		export LANGUAGE=en_US.UTF-8
		export LC_ALL=en_US.UTF-8
		export LANG=en_US.UTF-8
		export LC_TYPE=en_US.UTF-8

		# Fix so line drawing characters are shown correctly in Putty on Windows. See #744.
		export NCURSES_NO_UTF8_ACS=1

		if [[ "${FILEINFO}" == "true" ]]; then
			if [ -z "${PATH_STRATUM}" ]; then
				echo
				echo -e "$RED Make sure you double check before hitting enter! Only one shot at these! $COL_RESET"
				echo
				DEFAULT_path_stratum=/var/stratum
				input_box " Path Stratum " \
				"Enter path to stratum directory.
				\n\n Example: /var/stratum
				\n\nPath Stratum:" \
				${DEFAULT_path_stratum} \
				path_stratum
			else
				path_stratum=${PATH_STRATUM}
			fi
			
			if [ -z "${FUNCTION_FILE}" ]; then
				FUNCTIONFILE=coinbuild.sh
			else
				FUNCTIONFILE=${FUNCTION_FILE}
			fi

			clear
			term_art

			echo
			echo -e "$YELLOW Updating your version to $TAG! $COL_RESET"
			NEWVERSION=${TAG}

		else
			FUNC=/etc/coinbuild.sh
			if [[ ! -f "$FUNC" ]]; then
				source /etc/coinbuild.sh
				FUNCTIONFILE=coinbuild.sh
			fi


			if [ -z "${STRATUMFILE}" ]; then
				echo
				echo -e "$RED Make sure you double check before hitting enter! Only one shot at these! $COL_RESET"
				echo
				DEFAULT_path_stratum=/var/stratum
				input_box " Path Stratum " \
				"Enter path to stratum directory.
				\n\n Example: /var/stratum
				\n\nPath Stratum:" \
				${DEFAULT_path_stratum} \
				path_stratum
			fi

			if [ -z "${path_stratum}" ]; then
				# user hit ESC/cancel
				clear
				echo
				echo -e "$RED You are Cancelled this install! to run again => $COL_RESET$YELLOWsudo bash ${installdirname}/install.sh $COL_RESET"
				echo
				exit
			fi

			clear
			term_art
		fi

		# Installing other needed files
		echo
		echo -e "$CYAN => Installing other needed files : $COL_RESET"
		sleep 3

		hide_output sudo apt-get -y install dialog acl libgmp3-dev libmysqlclient-dev libcurl4-gnutls-dev libkrb5-dev libldap2-dev libidn11-dev gnutls-dev \
		librtmp-dev sendmail mutt screen git make
		hide_output sudo apt -y install pwgen unzip p7zip-full
		echo -e "$GREEN Done...$COL_RESET"
		sleep 3

		# Installing Package to compile crypto currency
		echo
		echo -e "$CYAN => Installing Package to compile crypto currency $COL_RESET"
		sleep 3

		hide_output sudo apt-get -y install build-essential libzmq5 \
		libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils cmake libboost-all-dev zlib1g-dev \
		libseccomp-dev libcap-dev libminiupnpc-dev gettext libcanberra-gtk-module libqrencode-dev libzmq3-dev \
		libqt5gui5 libqt5core5a libqt5webkit5-dev libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler
		if [[ ("${DISTRO}" == "18") ]]; then
			hide_output sudo apt-get -y install libz-dev libminiupnpc10
			hide_output sudo add-apt-repository -y ppa:bitcoin/bitcoin
			hide_output sudo apt -y update && sudo apt -y upgrade
			hide_output sudo apt -y install libdb4.8-dev libdb4.8++-dev libdb5.3 libdb5.3++
		fi
		hide_output sudo apt -y install libdb5.3 libdb5.3++

		echo -e "$GREEN Done...$COL_RESET"

		# Installing Package to compile crypto currency
		echo
		echo -e "$CYAN => Installing additional system files required for daemons $COL_RESET"
		sleep 3

		hide_output sudo apt-get -y update
		hide_output sudo apt -y install build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev libboost-all-dev libminiupnpc-dev \
		libqt5gui5 libqt5core5a libqt5webkit5-dev libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler libqrencode-dev libzmq3-dev \
		libgmp-dev cmake libunbound-dev libsodium-dev libunwind8-dev liblzma-dev libreadline6-dev libldns-dev libexpat1-dev libpgm-dev libhidapi-dev \
		libusb-1.0-0-dev libudev-dev libboost-chrono-dev libboost-date-time-dev libboost-filesystem-dev libboost-locale-dev libboost-program-options-dev \
		libboost-regex-dev libboost-serialization-dev libboost-system-dev libboost-thread-dev python3 ccache doxygen graphviz default-libmysqlclient-dev \
		libnghttp2-dev librtmp-dev libssh2-1 libssh2-1-dev libldap2-dev libidn11-dev libpsl-dev libnatpmp-dev systemtap-sdt-dev qtwayland5
		if [[ ("${DISTRO}" == "18") ]]; then
			hide_output sudo apt -y install ibsqlite3-dev
		else
			hide_output sudo apt -y install libdb-dev
			hide_output sudo apt -y install libdb5.3++ libdb5.3++-dev
		fi
		hide_output sudo apt -y install libgtest-dev
  		sleep 2
		cd /usr/src/gtest
		hide_output sudo cmake .
  		sleep 2
		hide_output sudo make
  		sleep 2
		if [[ -d "/usr/src/gtest/lib" ]]; then
			hide_output sudo mv /usr/src/gtest/lib/libg* /usr/lib/
		else
			hide_output sudo mv /usr/src/gtest/libg* /usr/lib/
		fi

		echo -e "$GREEN Additional System Files Completed...$COL_RESET"

		# Updating gcc & g++ to version 8
		echo
		echo -e "$CYAN => Updating GCC & G++ ... $COL_RESET"
		sleep 3

		hide_output sudo apt-get update -y
		hide_output sudo apt-get upgrade -y
		hide_output sudo apt-get dist-upgrade -y
		hide_output sudo apt-get install build-essential software-properties-common -y
		if [[ ("${DISTRO}" == "18") ]]; then
			hide_output sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y
		fi
		hide_output sudo apt-get update -y
		hide_output sudo apt-get install gcc-8 g++-8 -y
		hide_output sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 60 --slave /usr/bin/g++ g++ /usr/bin/g++-8
		hide_output sudo update-alternatives --config gcc

		echo -e "$GREEN Updated GCC & G++ Completed...$COL_RESET"
		echo
		sleep 3

			cd ~
			sudo mkdir -p ${absolutepath}/daemon_setup/tmp/

		function berkeley_pacht_4x_5x
		{
			sudo sed -i 's/__atomic_compare_exchange/__atomic_compare_exchange_db/g' ${absolutepath}/daemon_setup/tmp/$1/dbinc/atomic.h
			#if [[ ("${DISTRO}" == "20") ]]; then
			#	sudo sed -i 's/__atomic_compare_exchange/__atomic_compare_exchange_db/g' ${absolutepath}/daemon_setup/tmp/$1/dbinc/atomic.h
			#fi
		}

		if [[ ! -d "${absolutepath}/${installtoserver}/berkeley/db4" ]]; then
			echo -e "$YELLOW Building Berkeley 4.8, this may take several minutes...$COL_RESET"
			sleep 3

			sudo mkdir -p ${absolutepath}/${installtoserver}/berkeley/db4/
			cd ${absolutepath}/daemon_setup/tmp
			hide_output sudo wget 'https://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz'
			hide_output sudo tar -xzvf db-4.8.30.NC.tar.gz
			cd db-4.8.30.NC/build_unix/
			hide_output sudo ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=${absolutepath}/${installtoserver}/berkeley/db4/
			berkeley_pacht_4x_5x "db-4.8.30.NC"
			hide_output sudo make install
			cd ${absolutepath}/daemon_setup/tmp/
			sudo rm -r db-4.8.30.NC.tar.gz db-4.8.30.NC
			echo -e "$GREEN Berkeley 4.8 Completed...$COL_RESET"
			DONEINST=true
		fi

		if [[ ! -d "${absolutepath}/${installtoserver}/berkeley/db5" ]]; then
			echo -e "$YELLOW Building Berkeley 5.1, this may take several minutes...$COL_RESET"
			sleep 3

			sudo mkdir -p ${absolutepath}/${installtoserver}/berkeley/db5/
			cd ${absolutepath}/daemon_setup/tmp/
			hide_output sudo wget 'https://download.oracle.com/berkeley-db/db-5.1.29.tar.gz'
			hide_output sudo tar -xzvf db-5.1.29.tar.gz
			cd db-5.1.29/build_unix/
			hide_output sudo ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=${absolutepath}/${installtoserver}/berkeley/db5/
			berkeley_pacht_4x_5x "db-5.1.29/src"
			hide_output sudo make install
			cd ${absolutepath}/daemon_setup/tmp
			sudo rm -r db-5.1.29.tar.gz db-5.1.29
			echo -e "$GREEN Berkeley 5.1 Completed...$COL_RESET"
			DONEINST=true
		fi

		if [[ ! -d "${absolutepath}/${installtoserver}/berkeley/db5.3" ]]; then
			echo -e "$YELLOW Building Berkeley 5.3, this may take several minutes...$COL_RESET"
			sleep 3

			sudo mkdir -p ${absolutepath}/${installtoserver}/berkeley/db5.3/
			cd ${absolutepath}/daemon_setup/tmp/
			hide_output sudo wget 'https://anduin.linuxfromscratch.org/BLFS/bdb/db-5.3.28.tar.gz'
			hide_output sudo tar -xzvf db-5.3.28.tar.gz
			cd db-5.3.28/build_unix/
			hide_output sudo ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=${absolutepath}/${installtoserver}/berkeley/db5.3/
			berkeley_pacht_4x_5x "db-5.3.28/src"
			hide_output sudo make install
			cd ${absolutepath}/daemon_setup/tmp/
			sudo rm -r db-5.3.28.tar.gz db-5.3.28
			echo -e "$GREEN Berkeley 5.3 Completed...$COL_RESET"
			DONEINST=true
		fi

		if [[ ! -d "${absolutepath}/${installtoserver}/berkeley/db6.2" ]]; then
			echo -e "$YELLOW Building Berkeley 6.2, this may take several minutes...$COL_RESET"
			sleep 3

			sudo mkdir -p ${absolutepath}/${installtoserver}/berkeley/db6.2/
			cd ${absolutepath}/daemon_setup/tmp/
			hide_output sudo wget 'https://download.oracle.com/berkeley-db/db-6.2.23.tar.gz'
			hide_output sudo tar -xzvf db-6.2.23.tar.gz
			cd db-6.2.23/build_unix/
			hide_output sudo ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=${absolutepath}/${installtoserver}/berkeley/db6.2/
			hide_output sudo make install
			cd ${absolutepath}/daemon_setup/tmp/
			sudo rm -r db-6.2.23.tar.gz db-6.2.23
			echo -e "$GREEN Berkeley 6.2 Completed...$COL_RESET"
			DONEINST=true
		fi

		if [[ ! -d "${absolutepath}/${installtoserver}/berkeley/db18" ]]; then
			echo -e "$YELLOW Building Berkeley 18, this may take several minutes...$COL_RESET"
			sleep 3

			sudo mkdir -p ${absolutepath}/${installtoserver}/berkeley/db18/
			cd ${absolutepath}/daemon_setup/tmp/
			hide_output sudo wget 'https://download.oracle.com/berkeley-db/db-18.1.40.tar.gz'
			hide_output sudo tar -xzvf db-18.1.40.tar.gz
			cd db-18.1.40/build_unix/
			hide_output sudo ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=${absolutepath}/${installtoserver}/berkeley/db18/
			hide_output sudo make install
			cd ${absolutepath}/daemon_setup/tmp/
			sudo rm -r db-18.1.40.tar.gz db-18.1.40
			echo -e "$GREEN Berkeley 18.xx Completed...$COL_RESET"
			DONEINST=true
		fi

		if [[ ! -d "${absolutepath}/${installtoserver}/openssl" ]]; then
			echo -e "$YELLOW Building OpenSSL 1.0.2g, this may take several minutes...$COL_RESET"
			sleep 3

			cd ${absolutepath}/daemon_setup/tmp/
			hide_output sudo wget https://www.openssl.org/source/old/1.0.2/openssl-1.0.2g.tar.gz --no-check-certificate
			hide_output sudo tar -xf openssl-1.0.2g.tar.gz
			cd openssl-1.0.2g
			hide_output sudo ./config --prefix=${absolutepath}/${installtoserver}/openssl --openssldir=${absolutepath}/${installtoserver}/openssl shared zlib
			hide_output sudo make
			hide_output sudo make install
			cd ${absolutepath}/daemon_setup/tmp/
			sudo rm -r openssl-1.0.2g.tar.gz openssl-1.0.2g
			echo -e "$GREEN OpenSSL 1.0.2g Completed...$COL_RESET"
			DONEINST=true
		fi

		if [[ "${INSTVERSION}" == "$TAG" ]]; then
			echo -e "$YELLOW Building bls-signatures, this may take several minutes...$COL_RESET"
			sleep 3

			cd ${absolutepath}/daemon_setup/tmp/
			hide_output sudo wget 'https://github.com/codablock/bls-signatures/archive/v20181101.zip'
			hide_output sudo unzip v20181101.zip
			cd bls-signatures-20181101
			hide_output sudo cmake .
			hide_output sudo make install
			cd ${absolutepath}/daemon_setup/tmp/
			sudo rm -r v20181101.zip bls-signatures-20181101
			echo -e "$GREEN bls-signatures Completed...$COL_RESET"
			DONEINST=true
		fi

		if [[ ("${DONEINST}" == "true") ]]; then
			echo
		fi

		if [[ "${INSTVERSION}" == "$TAG" ]]; then
			# Update Timezone
			echo -e "$CYAN => Update default timezone. $COL_RESET"
			sleep 3

			if [ ! -f /etc/timezone ]; then
				echo "Etc/UTC" > sudo /etc/timezone
				sudo systemctl restart rsyslog >/dev/null 2>&1
			fi
			sudo systemctl status rsyslog | sed -n "1,3p" >/dev/null 2>&1
			echo -e "$GREEN Done...$COL_RESET"
			sleep 3
		fi

		if [[ "${NEWVERSION}" == "$TAG" ]] || [[ "${INSTVERSION}" == "$TAG" ]]; then
			if [[ "${NEWVERSION}" == "$TAG" ]]; then
				echo
				# Updating Daemonbuilder
				echo -e "$YELLOW Updating Coinbuild Coin! $COL_RESET"
				sleep 3
			else
				# Install Daemonbuilder
				echo
				echo -e "$CYAN => Installing Coinbuild $COL_RESET"
				sleep 3
			fi

			cd ${installdirname}
			sudo mkdir -p ${absolutepath}/${installtoserver}/daemon_builder/

			hide_output sudo cp -r ${installdirname}/utils/start.sh ${absolutepath}/${installtoserver}/daemon_builder/
			hide_output sudo cp -r ${installdirname}/utils/menu.sh ${absolutepath}/${installtoserver}/daemon_builder/
			hide_output sudo cp -r ${installdirname}/utils/menu1.sh ${absolutepath}/${installtoserver}/daemon_builder/
			hide_output sudo cp -r ${installdirname}/utils/menu2.sh ${absolutepath}/${installtoserver}/daemon_builder/
			hide_output sudo cp -r ${installdirname}/utils/menu3.sh ${absolutepath}/${installtoserver}/daemon_builder/
			hide_output sudo cp -r ${installdirname}/utils/menu4.sh ${absolutepath}/${installtoserver}/daemon_builder/
			hide_output sudo cp -r ${installdirname}/utils/source.sh ${absolutepath}/${installtoserver}/daemon_builder/
			sleep 3
			hide_output sudo chmod +x ${absolutepath}/${installtoserver}/daemon_builder/start.sh
			hide_output sudo chmod +x ${absolutepath}/${installtoserver}/daemon_builder/menu.sh
			hide_output sudo chmod +x ${absolutepath}/${installtoserver}/daemon_builder/menu1.sh
			hide_output sudo chmod +x ${absolutepath}/${installtoserver}/daemon_builder/menu2.sh
			hide_output sudo chmod +x ${absolutepath}/${installtoserver}/daemon_builder/menu3.sh
			hide_output sudo chmod +x ${absolutepath}/${installtoserver}/daemon_builder/menu4.sh
			hide_output sudo chmod +x ${absolutepath}/${installtoserver}/daemon_builder/source.sh
			sleep 3
			echo -e "$GREEN Done...$COL_RESET"

			if [[ "${NEWVERSION}" == "$TAG" ]]; then
				# Updating Addport
				echo -e "$YELLOW Updating Addport Coin! $COL_RESET"
				sleep 3
			else
				# Install Addport
				echo
				echo -e "$CYAN => Installing Addport $COL_RESET"
				sleep 3
			fi

			hide_output sudo cp -r ${installdirname}/utils/addport.sh /usr/bin/addport
			hide_output sudo chmod +x /usr/bin/addport

			if [[ "${INSTVERSION}" == "$TAG" ]]; then
				sleep 3
				echo '#!/usr/bin/env bash
				source /etc/'"${FUNCTIONFILE}"' # load our coinbuild.sh
				cd '"${absolutepath}"'/'"${installtoserver}"'/daemon_builder
				bash start.sh
				cd ~' | sudo -E tee /usr/bin/${daemonname} >/dev/null 2>&1
				hide_output sudo chmod +x /usr/bin/${daemonname}
			fi

			echo -e "$GREEN Done...$COL_RESET"
			sleep 5
		fi

		if [[ "${INSTVERSION}" == "$TAG" ]]; then
			# Final Directory permissions
			echo
			echo -e "$CYAN => Final Directory permissions $COL_RESET"
			sleep 3

			#Restart service
			hide_output sudo systemctl restart cron.service
			
			echo -e "$GREEN Done...$COL_RESET"
			sleep 5
		fi

		if [[ "${FILEINFO}" == "true" ]]; then
			echo -e "$YELLOW Updating info file to $TAG! $COL_RESET"
			sleep 3
			if [ -z "${VERSION}" ]; then
				echo '#!/bin/sh
				USERSERVER='"${whoami}"'
				PATH_STRATUM='"${path_stratum}"'
				FUNCTION_FILE='"${FUNCTIONFILE}"'
				VERSION='"${TAG}"'
				BTCDEP='"${BTCDEP}"'
				LTCDEP='"${LTCDEP}"'
				ETHDEP='"${ETHDEP}"'
				BCHDEP='"${BCHDEP}"''| sudo -E tee ${absolutepath}/${installtoserver}/conf/info.sh >/dev/null 2>&1
				hide_output sudo chmod +x ${absolutepath}/${installtoserver}/conf/info.sh
			else
				if [[ ! "$VERSION" == "$TAG" ]]; then
					echo '#!/bin/sh
					USERSERVER='"${whoami}"'
					PATH_STRATUM='"${path_stratum}"'
					FUNCTION_FILE='"${FUNCTIONFILE}"'
					VERSION='"${TAG}"'
					BTCDEP='"${BTCDEP}"'
					LTCDEP='"${LTCDEP}"'
					ETHDEP='"${ETHDEP}"'
					BCHDEP='"${BCHDEP}"''| sudo -E tee ${absolutepath}/${installtoserver}/conf/info.sh >/dev/null 2>&1
					hide_output sudo chmod +x ${absolutepath}/${installtoserver}/conf/info.sh
				fi
				echo -e "$GREEN Done...$COL_RESET"
				sleep 5
			fi
		else
			echo -e "$YELLOW FINISH! Creating info file to Version $TAG! $COL_RESET"
			sleep 3
			echo '#!/bin/sh
			USERSERVER='"${whoami}"'
			PATH_STRATUM='"${path_stratum}"'
			FUNCTION_FILE='"${FUNCTIONFILE}"'
			VERSION='"${TAG}"'
			BTCDEP='"${BTCDEP}"'
			LTCDEP='"${LTCDEP}"'
			ETHDEP='"${ETHDEP}"'
			BCHDEP='"${BCHDEP}"'' | sudo -E tee ${absolutepath}/${installtoserver}/conf/info.sh >/dev/null 2>&1
			hide_output sudo chmod +x ${absolutepath}/${installtoserver}/conf/info.sh
			echo -e "$GREEN Done...$COL_RESET"
			sleep 5
		fi

		echo -e "$YELLOW FINISH! Updating New Cron for adding MEM if necesary $COL_RESET"
		sleep 3

		INFOCONFSH=${absolutepath}/${installtoserver}/conf/info.sh
		if [[ -f "${INFOCONFSH}" ]]; then
			source ${INFOCONFSH}
			PATH_STRATUM_CHANGE=${PATH_STRATUM::-7}
			if [[ -d "${PATH_STRATUM_CHANGE}crons" ]]; then
			    PATH_CRONS=${PATH_STRATUM_CHANGE}crons 
			else
			    PATH_CRONS=${PATH_STRATUM_CHANGE}web/crons
			fi
			MEMSH=${PATH_CRONS}/mem.sh
			STRATUMDAEMSH=${PATH_CRONS}/stratum.sh
			SCREENS=/usr/bin/screens
			
			if [[ ! -f "$SCREENS" ]]; then
				echo -e "$RED File SCREENS not exist creating...$COL_RESET"

				hide_output sudo cp -r ${installdirname}/utils/screens /usr/bin/screens
				sleep 1
				sudo sed -i 's#DIRCRONS#'${PATH_CRONS}'#' /usr/bin/screens
				sleep 1
				sudo sed -i 's#DIRLOG#'${PATH_STRATUM_CHANGE}log/'#' /usr/bin/screens
				sleep 1
				sudo sed -i 's#FILEFUNCCOLOR#'/etc/${FUNCTION_FILE}'#' /usr/bin/screens
				sleep 1
				hide_output sudo chmod +x /usr/bin/screens

				echo -e "$GREEN Done.$COL_RESET"
				echo
				echo -e "$YELLOW to start crons shell command: $GREENscreens mem restart$YELLOW AND$GREEN screens stratum restart$COL_RESET"
				sleep 7
			else
				echo -e "$YELLOW File SCREENS exist updating...$COL_RESET"

				hide_output sudo cp -r /usr/bin/screens /usr/bin/screens-old
				hide_output sudo rm -f /usr/bin/screens
				hide_output sudo cp -r ${installdirname}/utils/screens /usr/bin/screens
				sleep 1
				sudo sed -i 's#DIRCRONS#'${PATH_CRONS}'#' /usr/bin/screens
				sleep 1
				sudo sed -i 's#DIRLOG#'${PATH_STRATUM_CHANGE}log/'#' /usr/bin/screens
				sleep 1
				sudo sed -i 's#FILEFUNCCOLOR#'/etc/${FUNCTION_FILE}'#' /usr/bin/screens
				sleep 1
				hide_output sudo chmod +x /usr/bin/screens
								
				echo -e "$GREEN Done.$COL_RESET"
				echo
				echo -e "$YELLOW to start crons shell command: $GREENscreens mem restart$YELLOW AND$GREEN screens stratum restart$COL_RESET"
				sleep 7
				echo -e "$RED For old file SCREENS backup to$YELLOW SCREENS-OLD$RED in$YELLOW /urs/bin$COL_RESET"
				echo -e "$RED if you have problems with the new file contact the admin of this script$COL_RESET"
				echo -e "$RED revert to the previous version of$YELLOW SCREENS$RED by renaming$YELLOW SCREENS-OLD$RED to$YELLOW SCREEN$COL_RESET"
				echo -e "$GREEN------$COL_RESET"
				sleep 7
			fi

			if [[ ! -f "$MEMSH" ]]; then
				hide_output sudo cp -r ${installdirname}/utils/mem.sh ${PATH_CRONS}/mem.sh
				hide_output sudo cp -r ${installdirname}/utils/mem.php ${PATH_STRATUM_CHANGE}web/yaamp/core/backend/mem.php
				sudo sed -i 's#WEBDIR#'${PATH_STRATUM_CHANGE}web/'#' ${PATH_CRONS}/mem.sh

				NUMBERSLINES=$(grep -wn '}' ${PATH_STRATUM_CHANGE}web/yaamp/modules/thread/CronjobController.php| cut -d ':' -f 1)
				LISTNUMONFILE=$(echo ${NUMBERSLINES})
				COUNTLISTLINES=$(echo "$NUMBERSLINES" | wc -l)
				GETNUMBERCHANGE=$(echo "${LISTNUMONFILE}" | cut -d ' ' -f $COUNTLISTLINES)

				INSERTNEWLINES='\tpublic function actionRunMem()\n\t\t{\n\t\t\tset_time_limit(0);\n\n\t\t\t''$this''->monitorApache();\n\n\t\t\tBackendMemCheck();\n\t\t}\n\t}'
				sudo sed -i "${GETNUMBERCHANGE}s#}#${INSERTNEWLINES}#" ${PATH_STRATUM_CHANGE}web/yaamp/modules/thread/CronjobController.php
				
				INSERTREQUIRE="\nrequire_once('mem.php');"
				sudo sed -i '$s#$#'${INSERTREQUIRE}'#' ${PATH_STRATUM_CHANGE}web/yaamp/core/backend/backend.php

				hide_output sudo chmod +x ${PATH_CRONS}/mem.sh
				hide_output sudo chgrp www-data ${PATH_STRATUM_CHANGE}web/yaamp/core/backend/mem.php
				hide_output sudo chmod 664 ${PATH_STRATUM_CHANGE}web/yaamp/core/backend/mem.php
				sleep 5
			else
				if [[ ("$MEM_SH_UP" == "1") ]]; then
					echo -e "$YELLOW There is a new version of file$GREEN MEM.SH...$YELLOW Installing...$COL_RESET"
					hide_output sudo cp -r ${installdirname}/utils/mem.sh ${PATH_CRONS}/mem.sh
					hide_output sudo chmod +x ${PATH_CRONS}/mem.sh
					echo -e "$GREEN Done...$COL_RESET"
					sleep 3
				else
					echo -e "$GREEN File MEM.SH already exist Skip...$COL_RESET"
					sleep 5
				fi

				if [[ ("$MEM_PHP_UP" == "1") ]]; then
					echo -e "$YELLOW There is a new version of file$GREEN MEM.PHP...$YELLOW Installing...$COL_RESET"
					hide_output sudo cp -r ${installdirname}/utils/mem.php ${PATH_STRATUM_CHANGE}web/yaamp/core/backend/mem.php
					hide_output sudo chgrp www-data ${PATH_STRATUM_CHANGE}web/yaamp/core/backend/mem.php
					hide_output sudo chmod 664 ${PATH_STRATUM_CHANGE}web/yaamp/core/backend/mem.php
					echo -e "$GREEN Done...$COL_RESET"
					sleep 3
				else
					echo -e "$GREEN File MEM.PHP already exist Skip...$COL_RESET"
					sleep 5
				fi
			fi

			if [[ ! -f "$STRATUMDAEMSH" ]]; then
				hide_output sudo cp -r ${installdirname}/utils/stratdaem.sh ${PATH_CRONS}/stratdaem.sh
				hide_output sudo cp -r ${installdirname}/utils/stratdaem.php ${PATH_STRATUM_CHANGE}web/yaamp/core/backend/stratdaem.php
				sudo sed -i 's#WEBDIR#'${PATH_STRATUM_CHANGE}web/'#' ${PATH_CRONS}/stratdaem.sh

				NUMBERSLINES=$(grep -wn '}' ${PATH_STRATUM_CHANGE}web/yaamp/modules/thread/CronjobController.php| cut -d ':' -f 1)
				LISTNUMONFILE=$(echo ${NUMBERSLINES})
				COUNTLISTLINES=$(echo "$NUMBERSLINES" | wc -l)
				GETNUMBERCHANGE=$(echo "${LISTNUMONFILE}" | cut -d ' ' -f $COUNTLISTLINES)

				INSERTNEWLINES='\tpublic function actionRunStratdaem()\n\t\t{\n\t\t\tset_time_limit(0);\n\n\t\t\t''$this''->monitorApache();\n\n\t\t\tBackendStratdaemStatus();\n\t\t}\n\t}'
				sudo sed -i "${GETNUMBERCHANGE}s#}#${INSERTNEWLINES}#" ${PATH_STRATUM_CHANGE}web/yaamp/modules/thread/CronjobController.php
				
				INSERTREQUIRE="\nrequire_once('stratdaem.php');"
				sudo sed -i '$s#$#'${INSERTREQUIRE}'#' ${PATH_STRATUM_CHANGE}web/yaamp/core/backend/backend.php

				hide_output sudo chmod +x ${PATH_CRONS}/stratdaem.sh
				hide_output sudo chgrp www-data ${PATH_STRATUM_CHANGE}web/yaamp/core/backend/stratdaem.php
				hide_output sudo chmod 664 ${PATH_STRATUM_CHANGE}web/yaamp/core/backend/stratdaem.php
				sleep 5
			else
				if [[ ("$STRATDAEM_SH_UP" == "1") ]]; then
					echo -e "$YELLOW There is a new version of$GREEN STRATDAEM.SH...$YELLOW Installing...$COL_RESET"
					hide_output sudo cp -r ${installdirname}/utils/stratdaem.sh ${PATH_CRONS}/stratdaem.sh
     					hide_output sudo chmod +x ${PATH_CRONS}/stratdaem.sh
					echo -e "$GREEN Done...$COL_RESET"
					sleep 3
				else
					echo -e "$GREEN File STRATDAEM.SH already exist Skip...$COL_RESET"
					sleep 5
				fi
    
				if [[ ("$STRATDAEM_PHP_UP" == "1") ]]; then
					echo -e "$YELLOW There is a new version of$GREEN STRATDAEM.PHP...$YELLOW Installing...$COL_RESET"
					hide_output sudo cp -r ${installdirname}/utils/stratdaem.php ${PATH_STRATUM_CHANGE}web/yaamp/core/backend/stratdaem.php
					hide_output sudo chgrp www-data ${PATH_STRATUM_CHANGE}web/yaamp/core/backend/stratdaem.php
					hide_output sudo chmod 664 ${PATH_STRATUM_CHANGE}web/yaamp/core/backend/stratdaem.php
					echo -e "$GREEN Done...$COL_RESET"
					sleep 3
				else
					echo -e "$GREEN File STRATDAEM.PHP already exist Skip...$COL_RESET"
					sleep 5
				fi
			fi
		else
			echo -e "$RED File INFO not find PLEASE contact Admin...$COL_RESET"
			sleep 5
		fi

		echo -e "$GREEN FINISSED!!!! $COL_RESET"
		sleep 3

	sleep 1

		#Misc
		sudo rm -rf ${installdirname}
		sudo rm -rf ${absolutepath}/daemon_setup

		if [ -z "${STRATUMFILE}" ]; then
			echo
			install_end_message
			echo
			cd ~
		fi
	fi
fi
