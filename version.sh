#! /bin/bash

webservercheck(){
	#hardcoded latest Apache version. Not familiar with how to parse the html content from Apache's website
latest_version_apache=Apache/2.4.54


#curl request to check web server version (Apache only for now)
version=$(curl -sI $host | grep "Server" | awk '{print $2}')

#check whether anything in variable i.e. whether anything has been grepped
identified=$(echo $version | wc -w)

#will output web server version if it's been found and contingency if not
if [[ $identified != 1 ]]
then
	echo "Web server version could not be identified"
else
	echo "The web server detected on the host is:"
	echo -e $version"\n"
fi

#conditional statement to check if latest version. It's up to the user to decide whether appropriate
if [[ $version == $latest_version_apache ]]
then
	echo "Latest Apache version present"
else
	if [[ $identified != 1 ]]
	then
		#do nothing if web server isn't identified
		false
	else
		#advisory information for if it is identified
		echo "New Apache version available for download. Please visit httpd.apache.org/download.cgi for more information"
		echo "Alternatively you may want to run the command 'sudo apt-get update && sudo apt-get upgrade'"
		echo -e "\nRunning an old web server version may leave the instance succeptible to disclosed vulnerabilities but it is not always the best option either. Please think carefully before (not) upgrading your instance"
	fi
fi
}

#testing
#webservercheck