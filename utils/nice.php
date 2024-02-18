<?php
if(!$_GET) return;

$json = file_get_contents('https://api2.nicehash.com/main/api/v2/public/buy/info');
if(!$json) return;

$obj = json_decode($json);

if(!$obj) return;

foreach($obj->miningAlgorithms as $key => $value)
{
	if(strtolower($value->name) === $_GET["algo"])
	{
		echo $value->min_diff_initial;
	}
}