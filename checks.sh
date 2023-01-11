#! /bin/bash

source version.sh
source methods.sh
source jsversion.sh

#flag for specifying the host (can be IP or domain)
while getopts h: flag
do
	case "${flag}" in
		h) host=${OPTARG};;
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
	echo "The host appears to be offline. Please check the host's availability"
	exit 1
fi

echo -e "\nNow querying the host's web server version"

webservercheck

echo -e "\nBeginning test for supported http methods on the host"

httpmethods

echo -e "\nBeginning the identification of supported Javascript version(s). This may take a while"

test1-xpoweredby
test2-nmapscript





