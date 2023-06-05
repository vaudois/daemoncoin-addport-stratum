<?php

function BackendMemCheck()
{
	if(defined("MEM_LIMIT_STATUS"))
	{
		if(MEM_LIMIT_STATUS == false)
			echo "\n\nMEM is DISABLED for enable define -> MEM_LIMIT_STATUS to true in serverconfig.php\n";
			elseif(defined("MEM_LIMIT_SET_MAX"))
			{
				if(MEM_LIMIT_SET_MAX >= 75)
				{
					$t1 = microtime(true);

					$CheckRunStratum = system('screen -S stratdaem -Q select .');
					if(!$CheckRunStratum)
					{
						$check_daemon = exec("ps aux | grep '[php] cronjob/runStratdaem' | awk 'NR=1{printf \"%s\", $9}' | sed 's/://'");
						$check_date = exec("date -d '-1 hour ago' \"+ %H%M\"");

						if ( !empty($check_daemon) && $check_daemon < $check_date)
						{
							echo strftime('%A %d %B %Y %I:%M:%S')." --> ";
							echo "Daemon: $check_daemon & Date: $check_date = Stratum & Daemon Controller blocked! restarting... <--\n";
							system('bash /usr/bin/screens restart stratdaem');
							sleep (1);
						}
					}
					
					$coins_run = getdbolist('db_coins', "enable and visible and auto_ready");

					echo strftime('%A %d %B %Y %I:%M:%S')." --> ";
					$mem = system("free -m | awk 'NR==2{printf \"%.0f\", $3*100/$2 }'");
					
					$memlimit = MEM_LIMIT_SET_MAX;

					if($mem > $memlimit)
					{
						echo "% of Memory is too up of limit $memlimit%";
						echo "\n";
						echo "-------------------> START <-------------------";
						echo "\n";
						$RunStratumAuto = system('screen -S stratdaem -Q select .');
						if(!$RunStratumAuto)
						{
							echo "--> Stoping Stratum & Daemon Controller... <--\n";
							system('bash /usr/bin/screens stop stratdaem');
							sleep (1);
						}
						foreach($coins_run as $coin)
						{
							$coinlover = strtolower($coin->symbol);
							if (file_exists("/usr/bin/stratum.".$coinlover))
							{
								echo "Restarting Stratum of coin -> ".$coin->symbol." ";
								system("bash /usr/bin/stratum.$coinlover restart $coinlover");
								echo "Done.\n";
								sleep(5);
							}
							else
							{
								echo "||=====================================================================||\n";
								echo "  Restarting Stratum of coin -> ".$coin->symbol."\n";
								echo "	ERROR: file stratum.$coinlover on /usr/bin/ Not Exist! please Create!";
								echo "\n||=====================================================================||";	
							}
						}
						echo strftime('%A %d %B %Y %I:%M:%S')." ALL COINS restarted Done. Now Memory is ";
						system("free -m | awk 'NR==2{printf \"%.0f\", $3*100/$2 }'");
						echo "%\n";
						echo "--------->> RESTARTS CRONS <<----------\n";
						//system('bash /usr/bin/screens restart loop2');
						//sleep(1);
						//system('bash /usr/bin/screens restart blocks');
						//sleep(1);
						//system('bash /usr/bin/screens restart main');
						//sleep(1);
						//system('bash /usr/bin/screens restart debug');
						//ps aux | grep '120 runconsole.php cronjob/runStratdaem' | awk 'NR=2{print f, $9}'

						sleep(1);
						if(!$RunStratumAuto)
						{
							echo "--> Starting Stratum & Daemon Controller... <--\n";
							system('bash /usr/bin/screens restart stratdaem');
						}
						echo "-------------------> END <-------------------";
						echo "\n";
					}
					else
					{
						echo "% of Memory is good no need restart coins, Limit is $memlimit%";
						echo "\n";
					}

					$d1 = microtime(true) - $t1;
					controller()->memcache->add_monitoring_function(__METHOD__, $d1);
				}
				else
				{
					echo "\n\nLimit Memory is ".MEM_LIMIT_SET_MAX.", actualy MEM is disabled limit mem is too low, set min 75 in serverconfig.php in MEM_LIMIT_SET_MAX\n";
				}
			}
			else
			{
				echo "\n\nPlease create MEM_LIMIT_SET_MAX in serverconfig.php => define('MEM_LIMIT_SET_MAX', 95); -> setting 0~74 is disabled min setting 75\n";
			}
	}
	else
	{
		echo "\n\nPlease create MEM_LIMIT_STATUS in serverconfig.php => define('MEM_LIMIT_STATUS', true);\n";
	}
}
