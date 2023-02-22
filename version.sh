#! /bin/bash

webservercheck(){
#Hardcoded latest versions. Can't really find an accurate way of web scraping the versions so it'll have to do
latest_version_apache="Apache/2.4.55"
latest_version_nginx="nginx/1.23.3"
latest_version_gunicorn="gunicorn/20.1.0"
latest_version_iis="Microsoft-IIS/10.0"

if [[ $publicsite == 'y' ]];then
	version=$(curl -sI -L https://"$host" | grep -m 1 -iw "Server:" | awk '{print $2}')
else
	version=$(curl -sI -L http://"$host" | grep -m 1 -iw "Server:" | awk '{print $2}')
fi


version_wc=$(echo $version | wc -w)
identified=$(echo $version | wc -w)

#Check if anything's been found
if [[ $identified == 0 ]];then
	echo "Web server could not be identified"
else
	echo "The web server detected on the host is: "$version
	found_webserver=true
	
fi

#To discover whether the software is supported in this script and pass if it's not
touch supportedchecklist
echo "Apache" >> supportedchecklist
echo "nginx" >> supportedchecklist
echo "gunicorn" >> supportedchecklist
echo "IIS" >> supportedchecklist
type=$(echo $version | grep -iof supportedchecklist | wc -w)
if [[ $type == 0 ]];then
	echo "This script does not yet support this web server software"
	not_supported_ws=true
	return 0
fi
rm supportedchecklist

#Check to see whether there's a version number 
if [[ $version =~ [0-9] ]];then
	has_version=true
else
	#Quick check uisng the wordcount to end the function if nothing is returned from the version. If not, the else clause always runs
	if [[ $version_wc == 0 ]];then
		return 0
	else
		echo "Webserver identified but is not advertising version number, therefore skipping version number comparison"
	fi
fi

#Small tests to determine different webserver software
test_for_apache=$(echo $version | grep -o "Apache" | wc -w)
if [[ $test_for_apache == 1 ]];then
	is_apache=true
else
	false
fi

test_for_nginx=$(echo $version | grep -o "nginx" | wc -w)
if [[ $test_for_nginx == 1 ]];then
	is_nginx=true
else
	false
fi

test_for_gunicorn=$(echo $version | grep -o "gunicorn" | wc -w)
if [[ $test_for_gunicorn == 1 ]];then
	is_gunicorn=true
else
	false
fi

test_for_iis=$(echo $version | grep -o "IIS" | wc -w)
if [[ $test_for_iis == 1 ]];then
	is_iis=true
else
	false
fi

#Final comparison if version number has been identified. A check is ran based on earlier flags and a comparison is made 
#Based on the correct software
if [[ $has_version == true ]];then

	if [[ $is_apache == true ]];then
		apache_ver_check
	else
		false
	fi
	if [[ $is_nginx == true ]];then
		nginx_ver_check
	else
		false
	fi
	if [[ $is_gunicorn == true ]];then
		gunicorn_ver_check
	else
		false
	fi
	if [[ $is_iis == true ]];then
		iis_ver_check
	else
		false
	fi
else
	return 0
fi
}

#Placed the check code inside of their own functions to help with scalability if necessary
apache_ver_check() {
	apache=$(echo -n $version | tr -d '[:space:]')
	if [[ $latest_version_apache == $apache ]];then
		echo "Latest Apache version identified"
		webservlatest=true
	else
		echo "Latest Apache version:" $latest_version_apache
		echo -e "\nNew Apache version available for download"

	fi
}

nginx_ver_check() {
	nginx=$(echo -n $version | tr -d '[:space:]')
	if [[ $latest_version_nginx == $nginx ]];then
		echo "Latest nginx version identified"
		webservlatest=true
	else
		echo "Latest nginx version:" $latest_version_nginx
		echo -e "\nNew nginx version available for download"

	fi
}

gunicorn_ver_check() {
	gun=$(echo -n $version | tr -d '[:space:]')
	if [[ $latest_version_gunicorn == $gun ]];then
		echo "Latest gunicorn version identified"
		webservlatest=true
	else
		echo "Latest gunicorn version:" $latest_version_gunicorn
		echo -e "\nNew gunicorn version available for download"

	fi
}

iis_ver_check() {
	iis=$(echo -n $version | tr -d '[:space:]')
	if [[ $latest_version_iis == $iis ]];then
		echo "Latest IIS version identified"
		webservlatest=true
	else
		echo "Latest IIS version:" $latest_version_iis
		echo -e "\nNew IIS version available for download"

	fi
}
