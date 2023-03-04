#! /bin/bash

phpinfo(){
	 #This test will use curl to check the response to access attempts for phpinfo in its default location
	 #Return code not good indicator for silent redirects. Used the source code size instead
	 #Again, not perfect because the size could be dynamic but I see this as the most likely method

	 if [[ $publicsite == "y" ]];then
		php_returncode=$(curl -sIL https://$host/phpinfo.php | grep "HTTP" | awk '{print $2}')
		indexpage=$(curl -sI -L https://$host | wc -c)	
		phpinfopage=$(curl -sI -L https://$host/phpinfo.php | wc -c)
	 else
	 	php_returncode=$(curl -sIL http://$host/phpinfo.php | grep "HTTP" | awk '{print $2}')
	 	indexpage=$(curl -sI -L http://$host | wc -c)	
		phpinfopage=$(curl -sI -L http://$host/phpinfo.php | wc -c)
	 fi
	 
	 if [ $indexpage -eq $phpinfopage ];then
	 	echo "Silent redirect detected. phpinfo.php most likely not present"
	 else
	 	case $php_returncode in
	 	
	 		*200*)
	 			echo "phpinfo.php potentially discovered at /phpinfo.php"
	 			found_phpinfo=true
	 			;;
	 		*403*)
	 			echo "Permission to access phpinfo.php blocked"
	 			;;
	 		*301*)
	 			echo "Redirect detected when trying to access /phpinfo.php. Most likely does not exist"
	 			;;
	 		*)
	 			echo "phpinfo.php not detected"
	 			;;
	 	esac
	 	
	 fi
}

phpmyadmin(){

	 #This test will use curl to check the response to access attempts for phpmyadmin in its default location
	 if [[ $publicsite == "y" ]];then
	 	myadmin_returncode=$(curl -sIL https://$host/phpmyadmin | grep "HTTP" | awk '{print $2}')
	 	indexpage=$(curl -sI -L https://$host | wc -c)	
		phpmyadminpage=$(curl -sI -L https://$host/phpmyadmin | wc -c)
	 else
	 	myadmin_returncode=$(curl -sIL http://$host/phpmyadmin | grep "HTTP" | awk '{print $2}')
	 	indexpage=$(curl -sI -L http://$host | wc -c)	
		phpmyadminpage=$(curl -sI -L http://$host/phpmyadmin | wc -c)
	 fi

	 if [ $indexpage -eq $phpmyadminpage ];then
	 	echo "Silent redirect detected. phpmyadmin most likely not present"
	 else
	 	case $myadmin_returncode in
	 	
	 		*200*)
	 			echo "phpmyadmin directory potentially accessible at /phpmyadmin"
	 			found_phpmyadmin=true
	 			;;
	 		*403*)
	 			echo "Permission to access phpmyadmin blocked"
	 			;;
	 		*301*)
	 			echo "Redirect detected when trying to access /phpmyadmin. Most likely does not exist"
	 			;;
	 		*)
	 			echo "phpmyadmin not detected"
	 			;;
	 	esac
	 fi
}
