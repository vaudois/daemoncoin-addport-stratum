#!/bin/bash
#####################################################
# Source https://mailinabox.email/ https://github.com/mail-in-a-box/mailinabox
# Updated by cryptopool.builders for crypto use...
# Modified by Xavatar
#####################################################

echo
echo
echo -e "$CYAN => Check prerequisite : $COL_RESET"

if [ "`lsb_release -d | sed 's/.*:\s*//' | sed 's/18\.04\.[0-9]/18.04/' `" == "Ubuntu 18.04 LTS" ]; then
  DISTRO=18
  sudo chmod g-w /etc /etc/default /usr
elif [ "`lsb_release -d | sed 's/.*:\s*//' | sed 's/16\.04\.[0-9]/16.04/' `" == "Ubuntu 16.04 LTS" ]; then
  DISTRO=16
elif [ "`lsb_release -d | sed 's/.*:\s*//' | sed 's/20\.04\.[0-9]/20.04/' `" == "Ubuntu 20.04 LTS" ]; then
  DISTRO=22
  sudo chmod g-w /etc /etc/default /usr
elif [ "`lsb_release -d | sed 's/.*:\s*//' | sed 's/22\.04\.[0-9]/22.04/' `" == "Ubuntu 22.04 LTS" ]; then
  DISTRO=22
    echo -e "$REDThis Script not supports on distro ${DISTRO} system stratum run on max distro Ubuntu 20.04 LTS $COL_RESET"
    echo -e "$REDStop installation now! $COL_RESET"
    exit
  #sudo chmod g-w /etc /etc/default /usr
fi


ARCHITECTURE=$(uname -m)
if [ "$ARCHITECTURE" != "x86_64" ]; then
  if [ -z "$ARM" ]; then
    echo -e "$REDYiimP Install Script only supports x86_64 and will not work on any other architecture, like ARM or 32 bit OS. $COL_RESET"
    echo -e "$REDYour architecture is $ARCHITECTURE $COL_RESET"
    exit
  fi
fi
