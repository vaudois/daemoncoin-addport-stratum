#!/usr/bin/env bash
#####################################################
# This is the entry point for configuring the system.
# Updated by Vaudois
#####################################################

source /etc/coinbuild.sh
source ${absolutepath}/${installtoserver}/conf/info.sh

cd ${absolutepath}/${installtoserver}/daemon_builder
# Ensure Python reads/writes files in UTF-8. If the machine
# triggers some other locale in Python, like ASCII encoding,
# Python may not be able to read/write files. This is also
# in the management daemon startup script and the cron script.

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

if (( $EUID == 0 )); then
	# Welcome
	message_box "Coinbuild" \
	"Hello and thanks for using the Coinbuild
	\nYou are logged in to ROOT
	\n\nIMPORTANT: Please run this scrypt logged in USER Thanks you."
	cd ..
	cd ~
	clear
	exit;
else
	message_box " Daemon Installer " \
	"Warning! This Scrypt only works with servers setup with the Yiimp!
	\n\nSetup for the most part is fully automated. Very little user input is required."

	# Start the installation.
	source menu.sh
fi
