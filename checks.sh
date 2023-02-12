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

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Thank you for using this script. This brief script will" 
echo "hopefully be able to discover basic components of the remote"
echo "host using common enumeration techniques"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

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

echo -e "\nBeginning test for supported http methods on the host\n"

httpmethods

#these flags will be used during text file output later
found_php=false
found_js=false
found_asp=false
found_framework=false
successful_tests_php=0
successful_tests_js=0
successful_tests_asp=0

######MULTIPLE######
echo -e "\nNow running tests to determine 1) Use of ASP.NET 2) PHP version(s) or 3) JS version(s) or libraries"
xpoweredby
echo -e "\n"
if [[ $resourceskip == "y" ]] #skips resource check if flag is given
then
	false
else
	echo "Now attempting to read the contents of /resources"
	resourceaccess
fi
#mention DOESN'T WORK!!!!!
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
	echo "Now attempting to read the contents of /js"
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

read -p "Would you like to output this summary to a text file? (Y/N)" output

if [[ $output == 'y' ]]
then
	#making the timestamped file
	timestamp=$(date +"%Y-%m-%d_%H:%M:%S")
	file_name=$host"_"$timestamp".txt"
	touch $file_name

	###########################WEBSERVER OUTPUT###############################
	if [ $found_webserver ]
	then
		echo "Webserver: "$version >> $file_name
		if [ $has_version ]
		then
			if [ $webservlatest ]
			then
				echo "Latest web server version detected" >> $file_name
			else
				echo "New version available for download" >> $file_name
			fi
		else
			echo "Version could not be identified" >> $file_name
		fi
	else
		echo "Webserver could not be identified" >> $file_name
	fi
	########################################################################
	echo " " >> $file_name
	#########################METHODS OUTPUT#################################
	if [ $found_methods ]
	then
		echo "HTTP Methods supported by the host: "${MethodsArray[@]} >> $file_name
		echo "There are $unsecuremethodcounter unsecure http methods supported by the host" >> $file_name
		echo "For more information on http methods please visit developer.mozilla.org/en-US/docs/Web/HTTP/Methods" >> $file_name
	else
		echo "Host is not advertising supported HTTP Methods" >> $file_name
	fi
else
	echo "End of script"
fi