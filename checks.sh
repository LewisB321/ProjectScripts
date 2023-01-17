#! /bin/bash

source version.sh
source methods.sh
source jsversion.sh
source https-ciphers.sh

#flag for specifying the host (can be IP or domain)
while getopts h:p:f: flag
do
	case "${flag}" in
		h) host=${OPTARG};;
		p) publicsite=${OPTARG};;
		f) force=${OPTARG};;
	esac
done

#testing
#echo $host

#pingtest for host's availability. WIll exit if host is unreachable
ping $host -q -c 4 2>&1 >/dev/null

#return code from ping is always 0 if host can be reached
if [[ $? == 0 ]]
then
	echo "The host appears to be online. Moving on"
else
	echo "The host appears to be offline or not responding to a pingtest. "
	#exit 1
	if echo $* | grep -e "-f" -q
	then
		if [[ $force != "y" ]]
		then
			echo -e "\nStopping script execution"
			exit 1
		else
			echo -e "'nForce flag detected. Moving on"
		fi
	fi
fi

echo -e "\nNow querying the host's web server version"

webservercheck

echo -e "\nBeginning test for supported http methods on the host"

httpmethods

echo -e "\nBeginning the identification of supported Javascript version(s). This may take a while"

test1-xpoweredby
test2-nmapscript
test3-mention
test4-resourceaccess

#optional test which depends on whether the site is publicly available or not
#uses the API of the Wappalyzer tool to scrape web info and see if we find JS information that way
if echo $* | grep -e "-p" -q
then
	if [[ $publicsite == "y" ]]
	then
		test5-wappalyzer
	else
		false
	fi
else
	false
fi

echo -e "\nNow probing target to determine TLS ciphersuite"

#the below code will make a curl request to see if host responds to https requests. Will be empty
#if https is unavailable, meaning the ciphersuite analysis will be bypassed
#could do this using openssl -connect but this achieves the same goal
httpscheck=$(curl -s https://$host)
httpscheck_wc=$(echo $httpscheck | wc -w)

#enum_ciphers isn't playing nice within the main script. Must fix!!!!
if [[ $httpscheck_wc == 0 ]]
then
	echo "Host is unsuitable for ciphersuite analysis"
else
	echo "Host is suitable for ciphersuite analysis"
	#enum_ciphers
fi





