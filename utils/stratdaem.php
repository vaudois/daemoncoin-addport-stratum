<?php

function BackendStratdaemStatus()
{
	if(defined("STRATUM_AUTO_STATUS"))
	{
		if(defined("STRATUM_MANU_COIN"))
		{
			if(defined("STRATUM_DAEMON_COIN"))
			{
				if(STRATUM_AUTO_STATUS == false)
					echo "\nSTRATUM is DISABLED for enable define -> STRATUM_AUTO_STATUS to true in serverconfig.php";
				else
				{
					$ESC_SEQ	= "\x1b[";
					$COL_RESET	= $ESC_SEQ."39;49;00m";
					$RED		= $ESC_SEQ."31;01m";
					$GREEN		= $ESC_SEQ."32;01m";
					$YELLOW		= $ESC_SEQ."33;01m";
					$BLUE		= $ESC_SEQ."34;01m";
					$MAGENTA	= $ESC_SEQ."35;01m";
					$CYAN		= $ESC_SEQ."36;01m";

					echo "\n======================================================================================";
					echo "\n=$YELLOW  COIN     SET-AUTO      CONNECTIONS    STRATUM   DAEMON  AUTO-STRATUM  AUTO-DAEMON$COL_RESET =";
					echo "\n= ---------------------------------------------------------------------------------- =";
					$t1 = microtime(true);
					$coins_run = getdbolist('db_coins', "enable and installed order by symbol asc");
					foreach($coins_run as $coin)
					{
						$symbol		= $coin->symbol;
						$program	= $coin->program;
						$coinfolder	= $coin->conf_folder;
						$coinname	= $coin->name;
						$connec		= $coin->connections?$coin->connections:'0';
						$setauto	= $coin->auto_ready;
						$coinletters = strlen($symbol);
						if($coinletters === 2)
							$coinspace = '		';
						else if($coinletters === 3)
							$coinspace = ' 	';
						else if($coinletters === 4)
							$coinspace = ' 	';
						else if($coinletters === 5)
							$coinspace = ' 	';
						else if($coinletters === 6)
							$coinspace = ' 	';
						else
							$coinspace = '	';

						if(!in_array($symbol,STRATUM_MANU_COIN))
						{
							$AutoStratum = $GREEN."	On".$COL_RESET;
							echo "\n=  ".$CYAN.$coin->symbol.$COL_RESET.$coinspace.$setauto.'		'.$connec;
							if($coin->auto_ready && $connec >= 1)
							{
								$coinlover = strtolower($symbol);
								
								$coin_on = exec('screen -S '.$coinlover.' -Q select .');

								if($coin_on)
								{
									if (file_exists("/usr/bin/stratum.".$coinlover))
									{
										echo "\n======================================================================================\n";
										echo "  Starting Stratum of coin -> ".$symbol." ";
										system("bash /usr/bin/stratum.$coinlover restart $coinlover");
										echo "  Done.";
										echo "\n======================================================================================\n";
										echo "\n=  ".$CYAN.$coin->symbol.$COL_RESET.$coinspace.$setauto.'		'.$connec;
										echo $GREEN."	    On ".$COL_RESET;
									}
									else
									{
										echo "\n======================================================================================\n";
										echo "  Starting Stratum of coin -> ".$symbol."\n";
										echo "	ERROR: file stratum.$coinlover on /usr/bin/ Not Exist! please Create!";
										echo "\n======================================================================================\n";
										echo "\n=  ".$CYAN.$coin->symbol.$COL_RESET.$coinspace.$setauto.'		'.$connec;
										echo $RED."	    Off".$COL_RESET;
									}
								}
								else
								{
									if (!empty($coin->errors))
									{
										echo $CYAN."	    On ".$COL_RESET;
									}
									else
									{
										echo $GREEN."	    On ".$COL_RESET;
									}
								}
							}
							else
							{
								$coinlover = strtolower($symbol);
								
								$coin_off = exec('screen -S '.$coinlover.' -Q select .');

								if(!$coin_off)
								{
									if (file_exists("/usr/bin/stratum.".$coinlover))
									{
										echo "\n======================================================================================\n";
										echo "  Stop Stratum of coin -> ".$symbol." ";
										system("bash /usr/bin/stratum.$coinlover stop $coinlover");
										echo "  Done.";
										echo "\n======================================================================================\n";
										echo "\n=  ".$CYAN.$coin->symbol.$COL_RESET.$coinspace.$setauto.'		'.$connec;
										echo $GREEN."	    	On ".$COL_RESET;
									}
									else
									{
										echo "\n======================================================================================\n";
										echo "  Starting Stratum of coin -> ".$symbol."\n";
										echo "	ERROR: file stratum.$coinlover on /usr/bin/ Not Exist! please Create!";
										echo "\n======================================================================================\n";
										echo "\n=  ".$CYAN.$coin->symbol.$COL_RESET.$coinspace.$setauto.'		'.$connec;
										echo $RED."	    Off".$COL_RESET;
									}
								}
								else
								{
									if (!empty($coin->errors))
									{
										echo $CYAN."	    Off".$COL_RESET;
									}
									else
									{
										$coin->auto_ready = 1;
										$coin->save();
										echo $RED."	    Off".$COL_RESET;
									}
								}
							}
						}
						else
						{
							echo "\n=  ".$CYAN.$coin->symbol.$COL_RESET.$coinspace.$setauto.'		'.$connec;
							$AutoStratum = $RED."	Off".$COL_RESET;
							$StratNormal = "1";
							if($coin->auto_ready && $connec >= 1)
							{
								echo $GREEN."	    On ".$COL_RESET;
							}
							else
							{
								echo $RED."	    Off".$COL_RESET;
							}
						}

						if(!in_array($symbol,STRATUM_DAEMON_COIN))
						{
							$AutoDaemon = $GREEN."		On ".$COL_RESET;
							if($coin->installed)
							{
								$RunDaemon = null;//exec('pgrep -x '.$program);
								
								$filesPid = glob($coinfolder.'/*.pid');
								foreach($filesPid as $filePid)
								{
									$PidFile = file($filePid, FILE_IGNORE_NEW_LINES)[0];
									$RunDaemon = exec ("ps aux | awk '{print $2 }' | grep ".$PidFile);
									//echo $RunDaemon." ".$coinname."\n";
								}

								if($RunDaemon)
								{
									$reindex = (isset($coin->reindex) && $coin->reindex == 1)?1:0;
									$RunDaemonAgain = exec('pgrep -x '.$program);
									if($RunDaemonAgain && $reindex == 1)
									{
										echo $MAGENTA."      Reindex".$COL_RESET;
										$daemon = substr($program, 0, -1);
										echo "\n======================================================================================\n";
										echo "  STOP Daemon Coin -> ".$symbol."\n";
										echo "  Sleep 30 sec to full stop\n";
										system($daemon."-cli -datadir=".$coinfolder." -conf=".substr($program, 0, -1).".conf stop");
										sleep(30);
										$PidDaemon = exec('pgrep -x '.$program);
										if(!$PidDaemon)
										{
											echo "  Daemon STOPPED.... Done.";
											$coin->reindex = 0;
											$coin->save();
											sleep(5);
											echo "  Starting Daemon Coin -> ".$symbol." WITH -reindex ->\n";
											system($program." -datadir=".$coinfolder." -conf=".substr($program, 0, -1).".conf -daemon -shrinkdebugfile -reindex");
											sleep(3);
											$PidDaemon = exec('pgrep -x '.$program);
											if($PidDaemon) echo "  Pid daemon -> ".$program. " is: ".$PidDaemon."\n";
											echo "  Run With -reindex.... Done.";
										}
										else
										{
											echo "  ERROR not STOPPED... try again!";
										}
										echo "\n======================================================================================\n";
									}
									else
									{
										echo $GREEN."      On ".$COL_RESET;
									}
								}
								else
								{
									$reindex = (isset($coin->reindex) && $coin->reindex === 1)?1:0;

									$RunDaemonAgain = exec('pgrep -x '.$program);
									
									echo $RED."      Off".$COL_RESET;

									if($RunDaemonAgain && $reindex === 1)
									{
										$daemon = substr($program, 0, -1);
										echo "\n======================================================================================\n";
										echo "  STOP Daemon Coin -> ".$symbol."\n";
										echo "  Sleep 30 sec to full stop\n";
										system($daemon."-cli -datadir=".$coinfolder." -conf=".substr($program, 0, -1).".conf stop");
										sleep(30);
										$PidDaemon = exec('pgrep -x '.$program);
										if(!$PidDaemon)
										{
											echo "  Daemon STOPPED.... Done.";
											$coin->reindex = 0;
											$coin->save();
											sleep(5);
											echo "  Starting Daemon Coin -> ".$symbol." WITH -reindex ->\n";
											system($program." -datadir=".$coinfolder." -conf=".substr($program, 0, -1).".conf -daemon -shrinkdebugfile -reindex");
											sleep(3);
											$PidDaemon = exec('pgrep -x '.$program);
											if($PidDaemon) echo "  Pid daemon -> ".$program. " is: ".$PidDaemon."\n";
											echo "  Run With -reindex.... Done.";
										}
										else
										{
											echo "  ERROR not STOPPED... try again!";
										}
										echo "\n======================================================================================\n";
									}
									else if(!$RunDaemonAgain)
									{
										echo "\n======================================================================================\n";
										echo "  Starting Daemon Coin -> ".$symbol."\n";//.$programd;
										echo "  Sleep 15 sec before to start....\n";
										sleep(15);
										system("bash /usr/bin/stratum.$coinlover restart $coinlover");
										system($program." -datadir=".$coinfolder." -conf=".substr($program, 0, -1).".conf -daemon -shrinkdebugfile");
										sleep(1);
										$PidDaemon = exec('pgrep -x '.$program);
										if($PidDaemon) echo "  Pid daemon -> ".$program. " is: ".$PidDaemon."\n";
										echo "  Done.";
										echo "\n======================================================================================\n";
									}
								}
							}
						}
						else
						{
							if($coin->installed)
							{
								$RunDaemon = null;
								$filesPid = glob($coinfolder.'/*.pid');
								foreach($filesPid as $filePid)
								{
									$PidFile = file($filePid, FILE_IGNORE_NEW_LINES)[0];
									$RunDaemon = exec ("ps aux | awk '{print $2 }' | grep ".$PidFile);
								}
								if($RunDaemon)
								{
									echo $GREEN."      On ".$COL_RESET;
								}
								else
								{
									echo $RED."      Off".$COL_RESET;
								}
							}
							$AutoDaemon = $RED."		Off".$COL_RESET;
							$DaemonNormal = "1";
						}
						echo $AutoStratum;
						echo $AutoDaemon;
						echo "     =";
					}
				}
			}
			else
			{
				echo "\n||=========================================================================||\n";
				echo "	Please create STRATUM_DAEMON_COIN in serverconfig.php\n\n	define('STRATUM_DAEMON_COIN', array(\n	'COIN',\n	));\n\n	Adding => 'COIN', => DAEMON is ignored to AUTO start and AUTO stop";
				echo "\n||=========================================================================||";
			}
		}
		else
		{
			echo "\n||=========================================================================||\n";
			echo "	Please create STRATUM_MANU_COIN in serverconfig.php\n\n	define('STRATUM_MANU_COIN', array(\n	'COIN',\n	));\n\n	Adding => 'COIN', => STRATUM is ignored to AUTO restart and AUTO stop";
			echo "\n||=========================================================================||";
		}
	}
	else
	{
		echo "\n||=========================================================================||\n";
		echo "	Please create STRATUM_AUTO_STATUS in serverconfig.php\n\n	define('STRATUM_AUTO_STATUS', true);\n\n	Set true STRATUM AUTO is enabled, Set false is disabled!.";
		echo "\n||=========================================================================||";
	}
	if (isset($StratNormal) && isset($DaemonNormal))
	{
		echo "\n======================================================================================";
		echo "\n----------------------------------------------------------";
		echo "\n".strftime('%A %d %B %Y %I:%M:%S')." All Run Normal Skip";
		echo "\n----------------------------------------------------------";
	}
}