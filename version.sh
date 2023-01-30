#! /bin/bash

webservercheck(){
	#hardcoded latest Apache version. Not familiar with how to parse the html content from Apache's website
latest_version_apache="Apache/2.4.55"
latest_version_nginx="nginx/1.23.3"
latest_version_gunicorn="gunicorn/20.1.0"
latest_version_iis="Microsoft-IIS/10.0"

#curl request to check web server version and make a wordcount for a later check

if [[ $publicsite == 'y' ]]
	then
			version=$(curl -sI https://"$host" | grep "Server" | awk '{print $2}')
	else
			version=$(curl -sI http://"$host" | grep "Server" | awk '{print $2}')
	fi

version_wc=$(echo $version | wc -w)
#extra variable for use later in determining if the server is Apache. The reason for this is that Apache is the
#only commonly used host that advertises it's version number in the header
isapache=false
isnginx=false
isgunicorn=false
isiis=false
hasversion=false
webservlatest=false

#tests to determine different webserver software
test_for_apache=$(echo $version | grep -o "Apache" | wc -w)
if [[ $test_for_apache == 1 ]]
then
	isapache=true
else
	false
fi

test_for_nginx=$(echo $version | grep -o "nginx" | wc -w)
if [[ $test_for_nginx == 1 ]]
then
	isnginx=true
else
	false
fi

test_for_gunicorn=$(echo $version | grep -o "gunicorn" | wc -w)
if [[ $test_for_gunicorn == 1 ]]
then
	isgunicorn=true
else
	false
fi

test_for_iis=$(echo $version | grep -o "IIS" | wc -w)
if [[ $test_for_iis == 1 ]]
then
	isiis=true
else
	false
fi


#check whether anything in variable i.e. whether anything at all has been grepped
identified=$(echo $version | wc -w)

#will output web server version if it's been found and contingency if not
if [[ $identified != 1 ]]
then
	echo "Web server could not be identified"
else
	echo "The web server detected on the host is:" $version
fi

#check to see whether numbers are present i.e. a version number is present
if [[ $version =~ [0-9] ]]
then
	hasversion=true
else
	#quick check uisng the wordcount to end the function if nothing is returned from the version. If not, the else clause always runs
	if [[ $version_wc == 0 ]]
	then
		return 0
	else
		echo "Webserver identified but is not advertising version number, therefore skipping version number comparison"
	fi
fi

#final comparison if version number has been identified. A check is ran based on earlier flags and a comparison is made based on the correct software
if [[ $hasversion == true ]]
then
	#charcount is used because I needed to remove the newline character from $version in order to compare it to the hardcoded latest version that I have
	charcount_1=$(echo -n $version | wc -c)
	if [[ $isapache == true ]]
	then
		apache_ver_check
	else
		false
	fi
	if [[ $isnginx == true ]]
	then
		nginx_ver_check
	else
		false
	fi
	if [[ $isgunicorn == true ]]
	then
		gunicorn_ver_check
	else
		false
	fi
	if [[ $isiis == true ]]
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
	charcount_apache=$(echo $latest_version_apache | wc -c)
	if [[ $charcount_1 == $charcount_apache ]]
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
	charcount_nginx=$(echo $latest_version_nginx | wc -c)
	if [[ $charcount_1 == $charcount_nginx ]]
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
	charcount_gun=$(echo $latest_version_gunicorn | wc -c)
	if [[ $charcount_1 == $charcount_gun ]]
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
	charcount_iis=$(echo $latest_version_iis | wc -c)
	if [[ $charcount_1 == $charcount_iis ]]
	then
		echo "Latest IIS version identified"
		webservlatest=true
	else
		echo "Latest IIS version:" $latest_version_iis
		echo -e "\nNew IIS version available for download. Please visit iis.net/downloads for more information"
		echo "Running an old web server version may leave the instance succeptible to disclosed vulnerabilities but it is not always the best option either. Please think carefully before (not) upgrading your instance"
	fi
}
