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
					
					$coins_run = getdbolist('db_coins', "enable and visible and auto_ready");

					$mem = system("free -m | awk 'NR==2{printf \"%.0f\", $3*100/$2 }'");
					
					$memlimit = 95;

					if($mem > $memlimit)
					{
						echo "% of Memory is too up of limit $memlimit%";
						echo "\n";
						echo "-------------------> START <-------------------";
						echo "\n";
						foreach($coins_run as $coin)
						{
							$coinlover = strtolower($coin->symbol);
							echo "Restarting Stratum of coin -> ".$coin->symbol." ";
							system("stratum.$coinlover restart $coinlover");
							echo "Done.\n";
							sleep(10);
						}
						echo strftime('%A %d %B %Y %I:%M:%S')." ALL COINS restarted Done. Now Memory is ";
						system("free -m | awk 'NR==2{printf \"%.0f\", $3*100/$2 }'");
						echo "%\n";
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
