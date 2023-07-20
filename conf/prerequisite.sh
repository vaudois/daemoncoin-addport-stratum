#!/bin/bash
##################################################################
# Current Modified by Vaudois for Daemon coin & addport & stratum
##################################################################

echo
echo -e "$CYAN => Check prerequisite : $COL_RESET"

if [ "`lsb_release -d | sed 's/.*:\s*//' | sed 's/18\.04\.[0-9]/18.04/' `" == "Ubuntu 18.04 LTS" ]; then
	DISTRO=18
 	echo -E "$YELLOW WARRING$RED php7.3 not supported on Ubuntu 18.*"
  	sleep 7
	#sudo chmod g-w /etc /etc/default /usr
     	echo -e "$RED Stop installation now! $COL_RESET"
	sudo rm -rf 
 	exit
elif [ "`lsb_release -d | sed 's/.*:\s*//' | sed 's/16\.04\.[0-9]/16.04/' `" == "Ubuntu 16.04 LTS" ]; then
  	DISTRO=16
    	echo -e "$RED This Script not supports on distro ${DISTRO} This run on Ubuntu 18.04 LTS and Ubuntu 20.04 LTS $COL_RESET"
    	echo -e "$RED Stop installation now! $COL_RESET"
	exit
elif [ "`lsb_release -d | sed 's/.*:\s*//' | sed 's/20\.04\.[0-9]/20.04/' `" == "Ubuntu 20.04 LTS" ]; then
	DISTRO=20
	#sudo chmod g-w /etc /etc/default /usr
elif [ "`lsb_release -d | sed 's/.*:\s*//' | sed 's/22\.04\.[0-9]/22.04/' `" == "Ubuntu 22.04 LTS" ]; then
	DISTRO=22
    	echo -e "$RED This Script not supports on distro ${DISTRO} This run on Ubuntu 18.04 LTS and Ubuntu 20.04 LTS $COL_RESET"
    	echo -e "$RED Stop installation now! $COL_RESET"
	exit
 	#sudo chmod g-w /etc /etc/default /usr
fi

ARCHITECTURE=$(uname -m)
if [ "$ARCHITECTURE" != "x86_64" ]; then
  if [ -z "$ARM" ]; then
    echo -e "$RED YiimP Install Script only supports x86_64 and will not work on any other architecture, like ARM or 32 bit OS. $COL_RESET"
    echo -e "$RED Your architecture is $ARCHITECTURE $COL_RESET"
    exit
  fi
fi

echo -e "$GREEN Done...$COL_RESET"
