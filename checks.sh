#! /bin/bash

source version.sh
source methods.sh
source jsversion.sh
source https-ciphers.sh

#flag for specifying the host (can be IP or domain)
while getopts h:p:f:o: flag
do
	case "${flag}" in
		h) host=${OPTARG};;
		p) publicsite=${OPTARG};;
		f) force=${OPTARG};;
	esac
done

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Thank you for using this script. This brief script will" 
echo "hopefully be able to discover basic components of the remote"
echo "host using common enumeration techniques"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

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
			echo -e "\nForce flag detected. Moving on"
		fi
	fi
fi

echo -e "\nNow querying the host's web server version"

webservercheck

echo -e "\nBeginning test for supported http methods on the host"

httpmethods

echo -e "\nBeginning the identification of supported Javascript version(s). This may take a while"

found=false
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

if [[ $found == false ]]
then
	echo -e "\nSupported JavaScript version(s)/libraries unable to be discovered"
else
	echo -e "\nFound JavaScript placeholder"
fi

echo -e "\nNow probing target to determine TLS ciphersuite"

#enum_ciphers is not playing nice in the main script due to a different output from nmap messing up the rest of the function. MUST FIX!!!!
#enum_ciphers

read -p "Would you like to output this summary to a text file? (Y/N)" output

if [[ $output == 'y' ]]
then
	echo "Outputting information to text file remote-host-summary.txt"
	touch remote-host-summary.txt
	#Web server output
	echo "Webserver: "$version >> remote-host-summary.txt
	#http methods output
	echo "Methods: "$methods >> remote-host-summary.txt 
	#js version(s) output
	echo "Placeholder for JS" >> remote-host-summary.txt
	#ciphersuite analysis output
	echo "Placeholder for Ciphersuite analysis" >> remote-host-summary.txt
else
	false
fi





