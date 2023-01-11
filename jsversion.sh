#! /bin/bash

test1-xpoweredby(){

	#test-1 try to retrieve x-powered-by header information
	Header_Info=$(curl -sI 10.0.19.58 | grep "X-Powered-By" | awk '{print $2}')

	#use to store the wordcount
	test1=$(echo $Header_Info | wc -w)

	#testing
	#echo $test1

	#variable won't be empty if the header was retrieved
	if [[ $test1 == 0 ]]
	then
		echo "test1 has not identified JS version"
	else
		echo "Javascript version identified as PLACEHOLDER"
	fi
}

test2-nmapscript(){

	#test2 use nmap http-referer-checker script
	nmap_scan=$(nmap --script http-referer-checker.nse $host)

	#the grep string will be in the results if the test was unsuccesful
	nmap_results=$(echo $nmap_scan | grep "Couldn't find any cross-domain scripts")
	#NEED TO ADD A FAILSAFE ON WHETHER CONNECTION REFUSED OR NOT

	#used to store wordcount
	test2=$(echo $nmap_results | wc -w)

	#testing
	#echo $test2

	#variable will be empty if JS version was identified by the script
	if [[ $test2 == 0 ]]
	then
		echo "Javascript version identified as PLACEHOLDER"
	else
		echo "test2 has not identified JS version"
	fi
}

