#! /bin/bash

phpinfo(){
	 #this test will use curl to check the response to access attempts for phpinfo in its default location

	 if [[ $publicsite == "y" ]]
	 then
		php_returncode=$(curl -sI -L https://$host/phpinfo.php | grep "HTTP" | awk '{print $2}')
	 else
	 	php_returncode=$(curl -sI -L http://$host/phpinfo.php | grep "HTTP" | awk '{print $2}')
	 fi
	 #echo $php_returncode
	 if [[ $php_returncode == 200 ]]
	 then
	 	
	 	echo -e "\nphpinfo.php test was potentially successful. Host is advertising something at {host}/phpinfo.php"
	 	found_php=true
	 else
	 	echo -e "\nphpinfo.php test not found"
	 fi
}

phpmyadmin(){
	 #this test will use curl to check the response to access attempts for phpmyadmin in its default location

	 if [[ $publicsite == "y" ]]
	 then
	 	myadmin_returncode=$(curl -sI -L https://$host/phpmyadmin | grep "HTTP" | awk '{print $2}')
	 else
	 	myadmin_returncode=$(curl -sI -L http://$host/phpmyadmin | grep "HTTP" | awk '{print $2}')
	 fi
	 #echo $myadmin_returncode
	 if [[ $myadmin_returncode == 200 ]]
	 then
	 	echo -e "\nphpmyadmin test was potentially successful. Host is advertising something at {host}/phpmyadmin"
	 	found_php=true
	 else
	 	echo -e "\nphpmyadmin not found. It's possible that this is being obscured or just simply isn't there"
	 fi
}