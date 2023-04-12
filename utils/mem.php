<?php

function BackendMemCheck()
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
