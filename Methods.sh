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



echo -e "Beginning test for supported http methods on the host\n"

#curl request to grab supported http methods
methods=$(curl -sI -X OPTIONS 10.0.19.58 | grep "Allow" | awk '{print $2}')

#testing
#echo $methods

#read the new variable into an array
IFS="," read -a MethodsArray <<< $methods

#testing
#echo ${MethodsArray[@]}

#parse the array for unsecure methods. Definitely an easier way to do this
unsecuremethodcounter=0
for httpmethod in ${MethodsArray[@]}; do
	[[ "PUT" == $httpmethod ]] && ((unsecuremethodcounter=unsecuremethodcounter+1))
	[[ "DELETE" == $httpmethod ]] && ((unsecuremethodcounter=unsecuremethodcounter+1))
	[[ "CONNECT" == $httpmethod ]] && ((unsecuremethodcounter=unsecuremethodcounter+1))
	[[ "TRACE" == $httpmethod ]] && ((unsecuremethodcounter=unsecuremethodcounter+1))
	[[ "PATCH" == $httpmethod ]] && ((unsecuremethodcounter=unsecuremethodcounter+1))
done

echo "The supported http methods on the host are as follows:" ${MethodsArray[@]}

#final check whether unsecure methods are present
if [[ $unsecuremethodcounter != 0 ]]
then
	echo "There are $unsecuremethodcounter unsecure http methods supported by the host"
	echo -e "\n"
	echo "For more information on http methods please visit developer.mozilla.org/en-US/docs/Web/HTTP/Methods" #will add more info later
else
	echo "No unsecure http methods discovered. Moving onto next test"
fi