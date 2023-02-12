#! /bin/bash

webservercheck(){
#hardcoded latest versions. Can't really find an accurate way of scraping this so it'll have to do
latest_version_apache="Apache/2.4.55"
latest_version_nginx="nginx/1.23.3"
latest_version_gunicorn="gunicorn/20.1.0"
latest_version_iis="Microsoft-IIS/10.0"

#standard public check
if [[ $publicsite == 'y' ]]
then
	version=$(curl -sI -L https://"$host" | grep -m 1 -iw "Server:" | awk '{print $2}')
else
	version=$(curl -sI -L http://"$host" | grep -m 1 -iw "Server:" | awk '{print $2}')
fi

#wordcount for later use
version_wc=$(echo $version | wc -w)

#check whether anything in variable i.e. whether anything at all has been grepped
identified=$(echo $version | wc -w)

#will output web server version if it's been found
if [[ $identified == 0 ]]
then
	echo "Web server could not be identified"
else
	echo "The web server detected on the host is: "$version
	found_webserver=true
fi
#check to see whether numbers are present i.e. a version number 
if [[ $version =~ [0-9] ]]
then
	has_version=true
else
	#quick check uisng the wordcount to end the function if nothing is returned from the version. If not, the else clause always runs
	if [[ $version_wc == 0 ]]
	then
		return 0
	else
		echo "Webserver identified but is not advertising version number, therefore skipping version number comparison"
	fi
fi

#tests to determine different webserver software
test_for_apache=$(echo $version | grep -o "Apache" | wc -w)
if [[ $test_for_apache == 1 ]]
then
	is_apache=true
else
	false
fi

test_for_nginx=$(echo $version | grep -o "nginx" | wc -w)
if [[ $test_for_nginx == 1 ]]
then
	is_nginx=true
else
	false
fi

test_for_gunicorn=$(echo $version | grep -o "gunicorn" | wc -w)
if [[ $test_for_gunicorn == 1 ]]
then
	is_gunicorn=true
else
	false
fi

test_for_iis=$(echo $version | grep -o "IIS" | wc -w)
if [[ $test_for_iis == 1 ]]
then
	is_iis=true
else
	false
fi

#final comparison if version number has been identified. A check is ran based on earlier flags and a comparison is made 
#based on the correct software
if [[ $has_version == true ]]
then
	#charcount is used because I needed to remove the newline character from $version in order to compare it 
	#to the hardcoded latest version that I have
	charcount_1=$(echo -n $version | wc -c)
	if [[ $is_apache == true ]]
	then
		apache_ver_check
	else
		false
	fi
	if [[ $is_nginx == true ]]
	then
		nginx_ver_check
	else
		false
	fi
	if [[ $is_gunicorn == true ]]
	then
		gunicorn_ver_check
	else
		false
	fi
	if [[ $is_iis == true ]]
	then
		iis_ver_check
	else
		false
	fi
else
	return 0
fi
}

#placed the check code inside of their own functions to help with scalability if necessary
apache_ver_check() {
	apache=$(echo -n $version)
	if [[ $latest_version_apache == $apache ]]
	then
		echo "Latest Apache version identified"
		webservlatest=true
	else
		echo "Latest Apache version:" $latest_version_apache
		echo -e "\nNew Apache version available for download. Please visit httpd.apache.org/download.cgi for more information"
		echo "Running an old web server version may leave the instance succeptible to disclosed vulnerabilities but it is not always the best option either. Please think carefully before (not) upgrading your instance"
	fi
}

nginx_ver_check() {
	nginx=$(echo -n $version)
	if [[ $latest_version_nginx == $nginx ]]
	then
		echo "Latest nginx version identified"
		webservlatest=true
	else
		echo "Latest nginx version:" $latest_version_nginx
		echo -e "\nNew nginx version available for download. Please visit www.nginx.org/en/download.html for more information"
		echo "Running an old web server version may leave the instance succeptible to disclosed vulnerabilities but it is not always the best option either. Please think carefully before (not) upgrading your instance"
	fi
}

gunicorn_ver_check() {
	gun=$(echo -n $version)
	if [[ $latest_version_gunicorn == $gun ]]
	then
		echo "Latest gunicorn version identified"
		webservlatest=true
	else
		echo "Latest gunicorn version:" $latest_version_gunicorn
		echo -e "\nNew gunicorn version available for download. Please visit www.pypi.org/projects/gunicorn for more information"
		echo "Running an old web server version may leave the instance succeptible to disclosed vulnerabilities but it is not always the best option either. Please think carefully before (not) upgrading your instance"
	fi
}

iis_ver_check() {
	iis=$(echo -n $version)
	if [[ $latest_version_iis == $iis ]]
	then
		echo "Latest IIS version identified"
		webservlatest=true
	else
		echo "Latest IIS version:" $latest_version_iis
		echo -e "\nNew IIS version available for download. Please visit iis.net/downloads for more information"
		echo "Running an old web server version may leave the instance succeptible to disclosed vulnerabilities but it is not always the best option either. Please think carefully before (not) upgrading your instance"
	fi
}
