#! /bin/bash

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

echo -e "Now querying the host's web server version\n"

#hardcoded latest Apache version. Not familiar with how to parse the html content from Apache's website
latest_version_apache=Apache/2.4.54


#curl request to check web server version (Apache only for now)
version=$(curl -sI 10.0.19.58 | grep "Server" | awk '{print $2}')

#output web server information
echo "The web server detected on the host is:"
echo -e $version"\n"

#conditional statement to check if latest version. It's up to the user to decide whether appropriate
if [[ "$version" == "$latest_version_apache" ]]
then
	echo "Latest Apache version present"
else
	#advisory information
	echo "New Apache version available for download. Please visit httpd.apache.org/download.cgi for more information"
	echo "Alternatively you may want to run the command 'sudo apt-get update && sudo apt-get upgrade'
fi