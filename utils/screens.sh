#!/bin/bash
############################################################################################################################
# Updated by Vaudois for Yiimp...                                                                                   #
############################################################################################################################

source FILEFUNCCOLOR
CRONS=DIRCRONS
LOG_DIR=DIRLOG

#!/bin/sh -e

if [[ -f "${CRONS}/$2.sh" ]]; then
	if [ ! -x ${CRONS}/$2.sh ]; then
		sudo chmod 754 ${CRONS}/$2.sh
		echo -e "$RED => File $YELLOW$2.sh$RED is not Executable Modify and executing... $COL_RESET"
		echo ""
		echo -e "$GREEN => Done run... $COL_RESET"
		else
		echo -e "$GREEN => File $YELLOW$2.sh$GREEN is Executable run $COL_RESET"
	fi
fi

main="screen -dmS main ${CRONS}/main.sh"
mainstop='screen -X -S main quit'
loop2="screen -dmS loop2 ${CRONS}/loop2.sh"
loop2stop='screen -X -S loop2 quit'
blocks="screen -dmS blocks ${CRONS}/blocks.sh"
blocksstop='screen -X -S blocks quit'
mem="screen -dmS mem ${CRONS}/mem.sh"
memstop='screen -X -S mem quit'
stratdaem="screen -dmS stratdaem ${CRONS}/stratdaem.sh"
stratdaemstop='screen -X -S stratdaem quit'
debug="screen -dmS debug tail -f ${LOG_DIR}/debug.log"
debugstop='screen -X -S debug quit'

startstop_service() {
    cmd=$1
    name=$2
    sudo service $name $cmd
}

startstop_main() {
    cmd=$1
    case $cmd in
        stop) $mainstop ;;
        start) $main ;;
        restart)
            $mainstop
            sleep 1
            $main
            ;;
    esac
}

startstop_loop2() {
    cmd=$1
    case $cmd in
        stop) $loop2stop ;;
        start) $loop2 ;;
        restart)
            $loop2stop
            sleep 2
            $loop2
            ;;
    esac
}

startstop_blocks() {
    cmd=$1
    case $cmd in
        stop) $blocksstop ;;
        start) $blocks ;;
        restart)
            $blocksstop
            sleep 1
            $blocks
            ;;
    esac
}

startstop_mem() {
    cmd=$1
    case $cmd in
        stop) $memstop ;;
        start) $mem ;;
        restart)
            $memstop
            sleep 1
            $mem
            ;;
    esac
}

startstop_stratdaem() {
    cmd=$1
    case $cmd in
        stop) $stratdaemstop ;;
        start) $stratdaem ;;
        restart)
            $stratdaemstop
            sleep 1
            $stratdaem
            ;;
    esac
}

startstop_debug() {
    cmd=$1
    case $cmd in
        stop) $debugstop ;;
        start) $debug ;;
        restart)
            $debugstop
            sleep 1
            $debug
            ;;
    esac
}

case "$1" in
    start|stop|restart) cmd=$1 ;;
    *)
        shift
        servicenames=${@-servicenames}
        echo "usage: $0 [start|stop|restart] $servicenames"
        exit 1
esac
shift

for name; do
    case "$name" in
        main) startstop_main $cmd ;;
        loop2) startstop_loop2 $cmd ;;
        blocks) startstop_blocks $cmd ;;
        debug) startstop_debug $cmd ;;
		mem) startstop_mem $cmd ;;
		stratdaem) startstop_stratdaem $cmd ;;
        *) startstop_service $cmd $name ;;
    esac
done
