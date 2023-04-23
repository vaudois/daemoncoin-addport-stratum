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
					$t1 = microtime(true);
					$coins_run = getdbolist('db_coins', "enable and visible");
					foreach($coins_run as $coin)
					{
						$symbol		= $coin->symbol;
						$program	= $coin->program;
						$coinfolder	= $coin->conf_folder;
						$coinname	= $coin->name;
		 
						if(!in_array($symbol,STRATUM_MANU_COIN))
						{
							if($coin->auto_ready)
							{
								$coinlover = strtolower($symbol);
								
								$coin_on = exec('screen -S '.$coinlover.' -Q select .');

								if($coin_on)
								{
									if (file_exists("/usr/bin/stratum".$coinlover))
									{
										echo "\n||=====================================================================||\n";
										echo "  Starting Stratum of coin -> ".$symbol." ";
										system("bash /usr/bin/stratum.$coinlover restart $coinlover");
										echo "  Done.";
										echo "\n||=====================================================================||";
									}
									else
									{
										echo "\n||=====================================================================||\n";
										echo "  Starting Stratum of coin -> ".$symbol."\n";
										echo "	ERROR: file stratum.$coinlover on /usr/bin/ Not Exist! please Create!";
										echo "\n||=====================================================================||";
									}
								}
							}
							else
							{
								$coinlover = strtolower($symbol);
								
								$coin_off = exec('screen -S '.$coinlover.' -Q select .');

								if(!$coin_off)
								{
									if (file_exists("/usr/bin/stratum".$coinlover))
									{
										echo "\n||=========================================================================||\n";
										echo "  Stop Stratum of coin -> ".$symbol." ";
										system("bash /usr/bin/stratum.$coinlover stop $coinlover");
										echo "  Done.";
										echo "\n||=========================================================================||";
									}
									else
									{
										echo "\n||=====================================================================||\n";
										echo "  Starting Stratum of coin -> ".$symbol."\n";
										echo "	ERROR: file stratum.$coinlover on /usr/bin/ Not Exist! please Create!";
										echo "\n||=====================================================================||";
									}
								}
							}
						}

						if(!in_array($symbol,STRATUM_DAEMON_COIN))
						{
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

								if(!$RunDaemon)
								{
									$RunDaemonAgain = exec('pgrep -x '.$program);
									
									if(!$RunDaemonAgain)
									{
										echo "\n||=========================================================================||\n";
										echo "  Starting Daemon Coin -> ".$symbol."\n";//.$programd;
										system($program." -datadir=".$coinfolder." -conf=".substr($program, 0, -1).".conf -daemon -shrinkdebugfile");
										sleep(1);
										$PidDaemon = exec('pgrep -x '.$program);
										if($PidDaemon) echo "  Pid daemon -> ".$program. " is: ".$PidDaemon."\n";
										echo "  Done.";
										echo "\n||=========================================================================||";
									}
								}
							}
						}
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
}
