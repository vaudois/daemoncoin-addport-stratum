#!/bin/bash
################################################################################
#
# Current Created by : Vaudois
# web: https://coinXpool.com
# Program:
#   Install Daemon Coin on Ubuntu 18.04 / 20.04
#   v0.8.4 rev.3 (2023-07-20)
#
################################################################################

if [ -z "${TAG}" ]; then
	TAG=v0.8.4
fi

clear

if [ -z "$1" ]; then
	sudo chmod -R 755 $HOME/daemoncoin-addport-stratum
	sudo find $HOME/daemoncoin-addport-stratum/ -type d -exec chmod 755 {} \;
	sudo find $HOME/daemoncoin-addport-stratum/ -type d -exec chmod 755 {} \;
	./start $TAG
else
	sudo chmod -R 777 $1
	sudo find $1/ -type d -exec chmod 755 {} \;
	sudo find $1/ -type d -exec chmod 755 {} \;
	./start $TAG $1 $2 $3
fi
