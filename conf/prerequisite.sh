#!/bin/bash
##################################################################
# Current Modified by Vaudois for Daemon coin & addport & stratum
##################################################################

source conf/colors.sh
sleep 2

echo
echo -e "$CYAN => Check prerequisite : $COL_RESET"

# Vérifier la version d'Ubuntu
UBUNTU_VERSION=$(lsb_release -rs)
case "$UBUNTU_VERSION" in
    "16.04"|"16.04."*)
        DISTRO=16
        echo -e "$RED This script does not support Ubuntu 16.04. Supported versions are Ubuntu 20.04 and 22.04 LTS. $COL_RESET"
        echo -e "$RED Stopping installation now! $COL_RESET"
        exit 1
        ;;
    "18.04"|"18.04."*)
        DISTRO=18
        echo -e "$RED This script does not support Ubuntu 18.04. Supported versions are Ubuntu 20.04 and 22.04 LTS. $COL_RESET"
        echo -e "$RED Stopping installation now! $COL_RESET"
        exit 1
        ;;
    "20.04"|"20.04."*)
        DISTRO=20
        echo -e "$GREEN Detected Ubuntu 20.04 LTS. Proceeding with installation... $COL_RESET"
        sudo chmod g-w /etc /etc/default /usr
        ;;
    "22.04"|"22.04."*)
        DISTRO=22
        echo -e "$GREEN Detected Ubuntu 22.04 LTS. Proceeding with installation... $COL_RESET"
        sudo chmod g-w /etc /etc/default /usr
        ;;
    *)
        echo -e "$RED Unknown or unsupported Ubuntu version: $UBUNTU_VERSION. Supported versions are Ubuntu 20.04 and 22.04 LTS. $COL_RESET"
        echo -e "$RED Stopping installation now! $COL_RESET"
        exit 1
        ;;
esac

# Vérifier l'architecture
ARCHITECTURE=$(uname -m)
if [ "$ARCHITECTURE" != "x86_64" ]; then
    if [ -z "$ARM" ]; then
        echo -e "$RED YiimP Install Script only supports x86_64 and will not work on any other architecture, like ARM or 32 bit OS, unless ARM is explicitly enabled. $COL_RESET"
        echo -e "$RED Your architecture is $ARCHITECTURE $COL_RESET"
        exit 1
    fi
fi

echo -e "$GREEN Done...$COL_RESET"
