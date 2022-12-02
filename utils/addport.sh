#!/usr/bin/env bash

FUNC=/etc/functionscoin.sh
if [[ ! -f "$FUNC" ]]; then
	source /etc/functions.sh
else
	source /etc/functionscoin.sh
fi

source ${absolutepath}/${installtoserver}/conf/info.sh

#####################################################
# Dedicated Port config generator
# Created by afiniel for yiimpool
# This generator will modify the main algo.conf file
# Create the new coin.algo.conf file
# And update the stratum start file
#####################################################

clear

# Generate random open PORT
function EPHYMERAL_PORT(){
    LPORT=2768;
    UPORT=6999;
    while true; do
        MPORT=$[$LPORT + ($RANDOM % $UPORT)];
        (echo "" >/dev/tcp/127.0.0.1/${MPORT}) >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo $MPORT;
            return 0;
        fi
    done
}

coinport=$(EPHYMERAL_PORT)

GETPORT="$1"

if [[("$GETPORT" == "CREATECOIN")]]; then
	echo -e "$YELLOW Add port to coin:$COL_RESET $GREEN $2 $COL_RESET"
	echo
	CREATECOIN="true"
fi

cd ${PATH_STRATUM}/config
if [[("$CREATECOIN" != "true")]]; then
	echo -e "$YELLOW Thanks for using the addport script by Vaudois. $COL_RESET"
	echo
fi

echo -e "$YELLOW addport will randomly selects an open port for the coin between ports 2768 and 6999 and open the port in UFW. $COL_RESET"

if [[("$CREATECOIN" != "true")]]; then
	echo -e "$YELLOW It will also create a new symbol.algo.conf in $RED $PATH_STRATUM/config $COL_RESET"
	echo -e "$YELLOW and will create a new stratum.symbol run file in $RED /usr/bin. $COL_RESET"
fi
echo

if [[("$CREATECOIN" == "true")]]; then
coinsymbol="$2"
else
	echo
	echo -e "$RED Make sure coin symbol is all UPPER case.$COL_RESET"
	read -e -p "Please enter the coin SYMBOL : " coinsymbol
fi
echo ""
echo -e "$RED Make sure algo is in all lower case and a valid algo in yiimp.$COL_RESET"
read -e -p "Please enter the coin algo : " coinalgo
echo ""
read -e -p "Would you like to set a minimum nicehash value for this stratum? (y/n) : " nicehash
if [[ ("$nicehash" == "y" || "$nicehash" == "Y" || "$nicehash" == "yes" || "$nicehash" == "YES") ]]; then
read -e -p "Please enter a whole value, example: 750000 : " nicevalue
fi

# Make the coin symbol lower case
coinsymbollower=${coinsymbol,,}
# make sure algo is lower as well since we are Here
coinalgo=${coinalgo}
# and might as well make sure the symbol is upper case
coinsymbol=${coinsymbol^^}

# Make sure the stratum.symbol config doesnt exist and that the algo file does.
if [ -f ${PATH_STRATUM}/config/stratum.${coinsymbollower} ]; then
  read -r -e -p "A file for ${coinsymbol} already exists. Are you sure you want to overwrite? A new port will be generated and you will need to update your coind.conf blocknotify line (y/n) : " overwrite
  if [[ ("$overwrite" == "n" || "$overwrite" == "N" || "$overwrite" == "no" || "$overwrite" == "NO") ]]; then
    echo -e "$RED Exiting... $COL_RESET"
    exit 0
  fi
if [ ! -f $PATH_STRATUM/config/$coinalgo.conf ]; then
  echo -e "$YELLOW Sorry that algo config file doesn't exist in $RED ${PATH_STRATUM}/config/ $YELLOW please double check and try again. $COL_RESET"
  exit 0
fi
fi

# Prevent duplications from people running addport multiple times for the same coin...Also known as asshats...
if [ -f $PATH_STRATUM/config/$coinsymbollower.$coinalgo.conf ]; then
  if [[ ("$overwrite" == "y" || "$overwrite" == "Y" || "$overwrite" == "yes" || "$overwrite" == "YES") ]]; then
    # Insert the port in to the new symbol.algo.conf
    sed -i '/port/c\port = '${coinport}'' $coinsymbollower.$coinalgo.conf
    echo -e "$YELLOW Port updated! Remeber to update your blocknotify line!! $COL_RESET"
  fi
else
# Since this is a new symbol we are going to add it to the other conf files first.
# First we need to check if this is the first time addport has been ran
files=(*.$coinalgo.conf)
if [ -e "${files[0]}" ]; then
for r in *.$coinalgo.conf; do
  if ! grep -Fxq "exclude = ${coinsymbol}" "$r"; then
    sed -i -e '$a\
[WALLETS]\
exclude = '${coinsymbol}'' "$r"
fi
done
fi
sleep 2
# Copy the default algo.conf to the new symbol.algo.conf
  cp -r $coinalgo.conf $coinsymbollower.$coinalgo.conf
  sleep 1
# Insert the port in to the new symbol.algo.conf
  sed -i '/port/c\port = '${coinport}'' $coinsymbollower.$coinalgo.conf
  sleep 1
# If setting a nicehash value
if [[ ("$nicehash" == "y" || "$nicehash" == "Y" || "$nicehash" == "yes" || "$nicehash" == "YES") ]]; then
  sed -i -e '/difficulty =/a\
nicehash = '${nicevalue}'' $coinsymbollower.$coinalgo.conf
fi
sleep 1
# Insert the include in to the new symbol.algo.conf
  sed -i -e '$a\
[WALLETS]\
include = '${coinsymbol}'' $coinsymbollower.$coinalgo.conf
fi
sleep 2

#Again preventing asshat duplications...
if ! grep -Fxq "exclude = ${coinsymbol}" "$coinalgo.conf"; then
# Insert the exclude in to algo.conf
  sed -i -e '$a\
[WALLETS]\
exclude = '${coinsymbol}'' $coinalgo.conf
else
  echo -e "$YELLOW ${coinsymbol} is already in $coinalgo.conf, skipping... Which means you are trying to run this multiple times for the same coin. $COL_RESET"
fi
sleep 1

# New coin stratum start file
echo '#####################################################
# Source code from https://codereview.stackexchange.com/questions/55077/small-bash-script-to-sta$
# Updated by Vaudois for Daemon Coin use...
#####################################################

STRATUM_DIR='""''"${PATH_STRATUM}"''""'
#!/usr/bin/env bash

'""''"${coinsymbollower}"''""'="screen -dmS '""''"${coinsymbollower}"''""' bash $STRATUM_DIR/run.sh '""''"${coinsymbollower}"''""'.'""''"${coinalgo}"''""'"
'""''"${coinsymbollower}"''""'stop="'screen -X -S ${coinsymbollower} quit'"

startstop_'""''"${coinsymbollower}"''""'() {
    cmd=$1
    case $cmd in
        stop) $'""''"${coinsymbollower}"''""'stop ;;
        start) $'""''"${coinsymbollower}"''""' ;;
        restart)
            $'""''"${coinsymbollower}"''""'stop
            sleep 1
            $'""''"${coinsymbollower}"''""'
            ;;
    esac
}

case "$1" in
    start|stop|restart) cmd=$1 ;;
    *)
        shift
        servicenames=${@-servicenames}
        echo "usage: $0 [start|stop|restart] algo"
        exit 1
esac


shift

for name; do
    case "$name" in
    '""''"${coinsymbollower}"''""') startstop_'""''"${coinsymbollower}"''""' $cmd ;;
    *) startstop_service $cmd $name ;;
    esac
done ' | sudo -E tee ${PATH_STRATUM}/config/stratum.${coinsymbollower} >/dev/null 2>&1
sudo chmod +x ${PATH_STRATUM}/config/stratum.${coinsymbollower}
sleep 1

sudo cp -r ${PATH_STRATUM}/config/stratum.${coinsymbollower} /usr/bin
sudo ufw allow $coinport
sleep 1

echo
echo "Adding stratum.${coinsymbollower} to crontab for autostart at system boot."
(crontab -l 2>/dev/null; echo "@reboot sleep 10 && bash stratum.${coinsymbollower} start ${coinsymbollower}") | crontab -
echo
echo -e "$YELLOW Starting your new stratum...$COL_RESET"
bash stratum.${coinsymbollower} start ${coinsymbollower}
sleep 1

if [[("$CREATECOIN" == 'true')]]; then
	echo '
	COINPORT='""''"${coinport}"''""'
	COINALGO='""''"${coinalgo}"''""'
	' | sudo -E tee ${absolutepath}/${installtoserver}/daemon_builder/.addport.cnf >/dev/null 2>&1;
	echo -e "$CYAN --------------------------------------------------------------------------- 	$COL_RESET"
	echo -e "$GREEN    The assigned dedicated port for this coins stratum is :$YELLOW $coinport $COL_RESET"
	echo -e "$GREEN    Addport finish return to config...										$COL_RESET"
	echo -e "$CYAN --------------------------------------------------------------------------- 	$COL_RESET"
	sleep 4
else
	echo -e "$YELLOW Your new stratum is$GREEN started...$YELLOW Do NOT run the start command manually...$COL_RESET"
	echo
	echo -e "$YELLOW To use your new stratum type,$BLUE stratum.${coinsymbollower} start|stop|restart ${coinsymbollower} $COL_RESET"
	echo
	echo -e "$YELLOW To see the stratum screen type,$MAGENTA screen -r ${coinsymbollower} $COL_RESET"
	echo
	echo -e "$YELLOW The assigned dedicated port for this coins stratum is :$GREEN $coinport $COL_RESET"
	echo
	echo -e "$YELLOW Make sure to add this to the Dedicated Port section in your YiiMP admin panel! $COL_RESET"
	echo
	echo -e "$CYAN  --------------------------------------------------------------------------- 	$COL_RESET"
	echo -e "$GREEN	Donations are welcome at wallets below:					  	$COL_RESET"
	echo -e "$YELLOW  BTC: $COL_RESET $MAGENTA bc1qt8g9l6agk7qrzlztzuz7quwhgr3zlu4gc5qcuk	$COL_RESET"
	echo -e "$YELLOW  LTC: $COL_RESET $MAGENTA MGyth7od68xVqYnRdHQYes22fZW2b6h3aj	$COL_RESET"
	echo -e "$YELLOW  ETH: $COL_RESET $MAGENTA 0xc4e42e92ef8a196eef7cc49456c786a41d7daa01	$COL_RESET"
	echo -e "$YELLOW  BCH: $COL_RESET $MAGENTA bitcoincash:qp9ltentq3rdcwlhxtn8cc2rr49ft5zwdv7k7e04df	$COL_RESET"
	echo -e "$CYAN  --------------------------------------------------------------------------- 	$COL_RESET"
	cd ~
	exit 0
fi
