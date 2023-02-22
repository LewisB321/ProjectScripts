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
		h) host=${OPTARG};;
		s) publicsite=${OPTARG};;
		r) resourceskip=${OPTARG};;
		w) wapp=${OPTARG};;
		p) phpskip=${OPTARG};;
	esac
done

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Thank you for using this script. Please contact" 
echo "lewisblythe0121@gmail.com if something doesn't work"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"


if [[ $publicsite == 'y' ]];then
	response=$(curl -s --fail --max-time 15 https://$host 2>/dev/null)
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

#The beginning of the tests

webservercheck
echo -e "\n"
httpmethods

######MULTIPLE TECHNOLOGIES######
echo -e "\nNow running tests to determine 1) Use of ASP.NET 2) PHP version(s) or 3) JS version(s) or libraries"
xpoweredby
if [[ $resourceskip == "y" ]];then #skips resource check if flag is given
	false
else
	resourceaccess
fi
mention 

#optional test which depends on whether the site is publicly available or not
#uses the API of the Wappalyzer tool to scrape web info and see if we find JS information that way
if echo $* | grep -e "-w" -q;then
	if [[ $wapp == "y" ]];then
		wappalyzer
	else
		false
	fi
else
	false
fi
#################################

##############PHP################
if [[ $phpskip == 'y' ]];then
	false
else
	phpinfo
	phpmyadmin
fi
################################

##############JS################
nmapscript_referer
if [[ $resourceskip == "y" ]];then #skips resource check if flag is given
	false
else
	jsfolderaccess
fi

##############################

###########OTHERS#############
etag_check

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
#############################



read -p "Would you like to output this summary to a text file? (Y/N)" output

if [[ $output == 'y' ]];then
	output
else
	echo "End of script"
fi
