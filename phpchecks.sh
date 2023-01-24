#! /bin/bash

phpinfo(){
	 #this test will use curl to check the response to access attempts for phpinfo in its default location

	 php_returncode=$(curl -sI $host/phpinfo.php | grep "HTTP" | awk '{print $2}')
	 #echo $php_returncode
	 if [[ $php_returncode == 200 ]]
	 then
	 	
	 	echo -e "\nphpinfo.php test was potentially successful. Host is advertising php info at {host}/phpinfo.php"
	 	found_php=true
	 else
	 	echo -e "\nphpinfo.php test was unsuccessful"
	 fi
}

phpmyadmin(){
	 #this test will use curl to check the response to access attempts for phpmyadmin in its default location

	 myadmin_returncode=$(curl -sI $host/phpmyadmin | grep "HTTP" | awk '{print $2}')
	 #echo $myadmin_returncode
	 if [[ $myadmin_returncode == 200 ]]
	 then
	 	echo -e "\nphpmyadmin test was potentially successful. Host is advertising php dashboard at {host}/phpmyadmin"
	 	found_php=true
	 else
	 	echo -e "\nphpmyadmin test was unsuccessful"
	 fi
}