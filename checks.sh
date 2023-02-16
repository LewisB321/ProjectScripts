#! /bin/bash

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

#flags to alter script behaviour
while getopts h:p:f:r:w: flag
do
	case "${flag}" in
		h) host=${OPTARG};;
		p) publicsite=${OPTARG};;
		f) force=${OPTARG};;
		r) resourceskip=${OPTARG};;
		w) wapp=${OPTARG};;

	esac
done
nmapscript_referer
output
exit
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Thank you for using this script. Please contact" 
echo "lewisblythe0121@gmail.com if something doesn't work"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

#pingtest for host's availability. Will exit if host is unreachable
ping $host -q -c 4 2>&1 >/dev/null

#return code from ping is always 0 if host can be reached
if [[ $? == 0 ]]
then
	false
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

echo -e "\nBeginning test for web server\n"
webservercheck

echo -e "\nBeginning test for supported http methods\n"

httpmethods

######MULTIPLE######
echo -e "\nNow running tests to determine 1) Use of ASP.NET 2) PHP version(s) or 3) JS version(s) or libraries"
xpoweredby
if [[ $resourceskip == "y" ]] #skips resource check if flag is given
then
	false
else
	resourceaccess
fi

mention 
####################

#####PHP#######
phpinfo
phpmyadmin
##############

##########JS###########
nmapscript_referer
if [[ $resourceskip == "y" ]] #skips resource check if flag is given
then
	false
else
	jsfolderaccess
fi

#optional test which depends on whether the site is publicly available or not
#uses the API of the Wappalyzer tool to scrape web info and see if we find JS information that way
if echo $* | grep -e "-w" -q
then
	if [[ $wapp == "y" ]]
	then
		wappalyzer
	else
		false
	fi
else
	false
fi
#######################

########OTHERS#########
etag_check

echo -e "\nNow probing target to determine TLS ciphersuite"

#the below code will make a curl request to see if host responds to https requests. Will be empty
#if https is unavailable, meaning the ciphersuite analysis will be bypassed
#could do this using openssl -connect but this achieves the same goal
httpscheck=$(curl -s -L https://$host)
httpscheck_wc=$(echo $httpscheck | wc -w)

#enum_ciphers isn't playing nice within the main script. Must fix!!!!
if [[ $httpscheck_wc == 0 ]]
then
	echo "Host is unsuitable for ciphersuite analysis (cannot be contacted on port 443)"
else
	echo "Host is suitable for ciphersuite analysis"
	enum_ciphers
fi
########################



read -p "Would you like to output this summary to a text file? (Y/N)" output

if [[ $output == 'y' ]]
then
	output
else
	echo "End of script"
fi
