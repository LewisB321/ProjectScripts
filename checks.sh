#! /bin/bash

source version.sh
source methods.sh
source jschecks.sh
source phpchecks.sh
source https-ciphers.sh
source xpoweredby.sh
source resourceaccess.sh
source mention.sh

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

phpmyadmin
exit
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

#POTENTIAL REDIRECT CHECK. NOT SURE IF NECESSARY
#curl -s -I -o redirectmaybe.txt $host
#redirected=$(cat redirectmaybe.txt | grep -i "HTTP/" | awk '{print $2}')
#echo $redirected
#if [[ $redirected == "301" ]]
#then
	#new_address=$(cat redirectmaybe.txt | grep -i "Location" | awk '{print $2}')
	#echo "Attempts to access this URL return a redirect address. Please use the following address and run the script again:" $new_address
#else
	#echo "No redirect found"
#fi
#exit
#echo -e "\nNow querying the host's web server version"

webservercheck

echo -e "\nBeginning test for supported http methods on the host"

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
if [[ $resourceskip == "y" ]] #skips resource check if flag is given
then
	false
else
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
jsfolderaccess
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
	echo "Outputting information to text file remote-host-summary.txt"

	#Web server output
	if [[ $identified != 1 ]]
	then
		echo "Webserver could not be identified on" $host
	else
		echo "Webserver: "$version > remote-host-summary.txt
		if [[ $webservlatest == false ]]
		then
			echo "New webserver version available for download" >> remote-host-summary.txt
		else
			echo "Latest webserver version detected" >> remote-host-summary.txt
		fi
	fi

	#http methods output
	if [[ $methods_wc == 0 ]]
	then
		echo -e "\nhttp methods could not be identified on" $host
	else
		echo -e "\nMethods:"$methods >> remote-host-summary.txt 
		if [[ $unsecuremethodcounter == 0 ]]
		then
			echo "No dangerous http methods identified" >> remote-host-summary.txt
		else
			echo $unsecuremethodcounter "Unsecure http methods found on host" >> remote-host-summary.txt
			echo "Please visit developer.mozilla.org/en-US/docs/Web/HTTP/Methods for further information" >. remote-host-summary.txt
		fi	
	fi

	#js version(s) output
	echo "Placeholder for JS" >> remote-host-summary.txt
	#ciphersuite analysis output
	echo "Placeholder for Ciphersuite analysis" >> remote-host-summary.txt
else
	false
fi