#! /bin/bash

#This script and all subsequent scripts were created by Lewis Blythe as part of his final year project in Cybersecurity
source version.sh
source methods.sh
source jschecks.sh
source phpchecks.sh
source https-ciphers.sh
source xpoweredby.sh
source resourceaccess.sh
source mention.sh
source wapp.sh
source etag.sh
source output.sh
source securitylookup.sh

#flags to alter script behaviour
while getopts h:s:r:w:p: flag
do
	case "${flag}" in
		h) host=${OPTARG};; #Specify the host
		s) publicsite=${OPTARG};; #Specify whether to use http or https for most test cases
		r) resourceskip=${OPTARG};; #Specify whether to skip the functions to access /resources and /js
		w) wapp=${OPTARG};; #Specify whether to use the Wappalyzer API to try and discover technologies
		p) phpskip=${OPTARG};; #Specify whether to skip the function to try phpinfo.php and /phpmyadmin
	esac
done

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Thank you for using this script. Please contact" 
echo "lewisblythe0121@gmail.com if something doesn't work"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"


if [[ $publicsite == 'y' ]];then
	response=$(curl -s --fail --max-time 15 https://$host 2>/dev/null) #Initial curl request to try and catch bad hosts. Upgraded from pingtest
	exit_code=$?
	if [[ $exit_code == 35 ]];then
		echo "Host is refusing certain curl connections, so this script will not behave properly. Stopping script execution"
		exit
	fi
	if [[ $exit_code == 6 ]];then
		echo "Host is unreachable. Stopping script execution"
		exit
	fi
	if [[ $exit_code == 60 ]];then
		echo "Host's SSL certificate cannot be trusted. Stopping script execution"
		echo "You may want to try -p n to try HTTP rather than HTTPS but the script"
		echo "may misbehave and show innacurate results if port80 is closed/filtered"
		exit
	fi
	if [[ $exit_code == 28 ]];then
		echo "Host is taking too long to respond. Stopping script execution"
		exit
	fi
fi

timestamp=$(date +"%Y-%m-%d_%H:%M:%S")
file_name=$host"_"$timestamp".txt"
mkdir $file_name
cp official-cpe-dictionary_v2.3.xml $file_name
cd $file_name

#The beginning of the tests

webservercheck #Will attempt to identify the host's webserver software based upon returned headers

echo -e "\n"

httpmethods #Will attempt to identify the supported http methods on the host

echo -e "\n"

xpoweredby #Will attempt to read the x-powered-by header which sometimes discloses used technologies


if [[ $resourceskip == "y" ]];then
	false
else
	resourceaccess #Will attempt to read /resources and return anything with the .php or .js extension
fi

mention #Will attempt to read the host's index source code and return any mention of JavaScript scripts (not simply the string)

if echo $* | grep -e "-w" -q;then
	if [[ $wapp == "y" ]];then
		wappalyzer #Uses the API of the Wappalyzer tool to scrape web info and see if we find JS information that way
	else
		false
	fi
else
	false
fi

if [[ $phpskip == 'y' ]];then
	false
else
	phpinfo #Will make a curl request to /phpinfo.php to discover whether it exists
	phpmyadmin #Will make a curl request to /phpmyadmin to discover whether it exists
fi

nmapscript_referer #Uses an nmap script to find any third-party script usage

if [[ $resourceskip == "y" ]];then
	false
else
	jsfolderaccess #Will attempt to read /js and return anything with the .js extension
fi

etag_check #Simply checks for the eTag header which may cause a small security risk

echo -e "\nNow probing target to determine TLS ciphersuite"

#the below code will make a curl request to see if host responds to https requests. Will be empty
#if https is unavailable, meaning the ciphersuite analysis will be bypassed
#could do this using openssl -connect but this achieves the same goal
httpscheck=$(curl -sL https://$host)
httpscheck_wc=$(echo $httpscheck | wc -w)

#will run enum ciphers if https is possible
if [[ $httpscheck_wc == 0 ]];then
	echo "Host is unsuitable for ciphersuite analysis (cannot be contacted on port 443)"
else
	echo "Host is suitable for ciphersuite analysis"
	enum_ciphers
fi

#Calls the output script if user selects yes
read -p "Would you like to output this summary to a text file? (Y/N)" output

if [[ $output == 'y' ]];then
	output
else
	echo "End of script"
fi

rm official-cpe-dictionary_v2.3.xml
cd ..
