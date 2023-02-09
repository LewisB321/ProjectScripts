#! /bin/bash

phpinfo(){
	 #this test will use curl to check the response to access attempts for phpinfo in its default location
	 #return code not good indicator for silent redirects. Used the source code size instead
	 #again, not perfect because the size could be dynamic but I see this as the most likely method

	 if [[ $publicsite == "y" ]]
	 then
		php_returncode=$(curl -sI https://$host/phpinfo.php | grep "HTTP" | awk '{print $2}')
		indexpage=$(curl -sI -L https://$host | wc -c)	
		phpinfopage=$(curl -sI -L https://$host/phpinfo.php | wc -c)
	 else
	 	php_returncode=$(curl -sI http://$host/phpinfo.php | grep "HTTP" | awk '{print $2}')
	 	indexpage=$(curl -sI -L http://$host | wc -c)	
		phpinfopage=$(curl -sI -L http://$host/phpinfo.php | wc -c)
	 fi
	 #echo $php_returncode
	 if [ $indexpage -eq $phpinfopage ]
	 then
	 	echo "Silent redirect detected. phpinfo.php most likely not present"
	 else
	 	if [[ $php_returncode == 200 ]]
	 	then
	 		echo -e "\nphpinfo.php webpage found. Visit {host}/phpinfo.php to confirm"
	 		found_php=true
	 	else
	 		if [[ $php_returncode == 403 ]]
	 		then
	 			echo "Permission to access phpinfo.php blocked"
	 		else
	 			echo -e "\nphpinfo.php not present"
	 		fi
	 	fi
	 fi
}

phpmyadmin(){

	 #this test will use curl to check the response to access attempts for phpmyadmin in its default location
	 if [[ $publicsite == "y" ]]
	 then
	 	myadmin_returncode=$(curl -sI https://$host/phpmyadmin/ | grep "HTTP" | awk '{print $2}')
	 	indexpage=$(curl -sI -L https://$host | wc -c)	
		phpmyadminpage=$(curl -sI -L https://$host/phpmyadmin | wc -c)
	 else
	 	myadmin_returncode=$(curl -sI http://$host/phpmyadmin/ | grep "HTTP" | awk '{print $2}')
	 	indexpage=$(curl -sI -L http://$host | wc -c)	
		phpmyadminpage=$(curl -sI -L http://$host/phpmyadmin | wc -c)
	 fi
	 #echo $myadmin_returncode
	 if [ $indexpage -eq $phpmyadminpage ]
	 then
	 	echo "Silent redirect detected. phpmyadmin most likely not present"
	 else
	 	if [[ $myadmin_returncode == 200 ]]
	 	then
	 		echo -e "\nphpmyadmin directory detected. Visit {host}/phpmyadmin to confirm this"
	 	else
	 		if [[ $myadmin_returncode == 403 ]]
	 		then
	 			echo -e "\nPermission to access phpmyadmin blocked"
	 		else
	 			if [[ $myadmin_returncode == 301 ]]
	 			then
	 				echo "Redirect detected"
	 			else
					echo -e "\nphpmyadmin not detected"
				fi
	 		fi
	 	fi
	 fi

	

}