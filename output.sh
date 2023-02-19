#! /bin/bash

output() {
	#making the timestamped file
	timestamp=$(date +"%Y-%m-%d_%H:%M:%S")
	file_name=$host"_"$timestamp".txt"
	touch $file_name
	echo "results saved in the file - "$file_name

	###########################WEBSERVER OUTPUT###############################
	if [ $found_webserver ];then
		echo "Webserver: "$version >> $file_name
		if [ $has_version ];then
			if [ $webservlatest ];then
				echo "Latest web server version detected" >> $file_name
			else
				echo "New version available for download" >> $file_name
			fi
			if [ $is_apache ];then
			software=$(echo $version | grep -io "Apache")
			version_num=$(echo $version | grep -Eo '[0-9]+\.[0-9]+\.')
			version_num="${version_num}x"
			securitylookup $software $version_num $file_name
			fi
			if [ $is_nginx ];then
			software=$(echo $version | grep -io "nginx")
			version_num=$(echo $version | grep -Eo '[0-9]+\.[0-9]+\.')
			version_num="${version_num}x"
			securitylookup $software $version_num $file_name
			fi
			if [ $is_gunicorn ];then
			software=$(echo $version | grep -io "gunicorn")
			version_num=$(echo $version | grep -Eo '[0-9]+\.[0-9]+\.')
			version_num="${version_num}x"
			securitylookup $software $version_num $file_name
			fi
			if [ $is_iis ];then
			software=$(echo $version | grep -io "Microsoft-IIS")
			version_num=$(echo $version | grep -Eo '[0-9]+\.[0-9]+\.')
			version_num="${version_num}x"
			securitylookup $software $version_num $file_name
			fi
		else
			echo "Version could not be identified" >> $file_name
		fi
	else
		echo "Webserver could not be identified" >> $file_name
	fi
	########################################################################

	echo " " >> $file_name

	#############################METHODS OUTPUT#############################
	if [ $found_methods ];then
		echo "HTTP Methods supported by the host: "${MethodsArray[@]} >> $file_name
		echo "There are $unsecuremethodcounter unsecure http methods supported by the host" >> $file_name
		echo "For more information on http methods please visit developer.mozilla.org/en-US/docs/Web/HTTP/Methods" >> $file_name
	else
		echo "Host is not advertising supported HTTP Methods" >> $file_name
	fi
	########################################################################

	echo " " >> $file_name

	###########################XPB OUTPUT###################################
	if [ $xpb ];then
		if [ $found_asp_no_version_xpb ];then
			echo "ASP discovered but no version number identified" >> $file_name
		else
			if [ $found_asp_xpb ];then
				echo "ASP version discovered by XPB Header: "$asp_extra_check >> $file_name
			else
				echo "ASP undiscovered by XPB Header" >> $file_name
			fi
		fi

		if [ $found_php_xpb ];then
			echo "PHP version discovered by XPB Header: "$php_check >> $file_name
		else
			echo "PHP undiscovered by XPB Header" >> $file_name
		fi

		if [ $found_js_xpb ];then
			echo "JS libraries/versions discovered by XPB Header: "$js_check >> $file_name
		else
			echo "JS undiscovered by XPB Header" >> $file_name
		fi

		if [ $found_framework_xpb ];then
			echo "Framework discovered by XPB Header: "$framework_check >> $file_name
		else
			echo "Framework undiscovered by XPB Header" >> $file_name
		fi
	else
		echo "X-Powered-By header not detected" >> $file_name
	fi
	############################################################################

	echo " " >> $file_name

	##############################RESOURCE ACCESS###############################
	if [ $resource_folder_accessed ];then
		echo "Resource folder discovered" >> $file_name
		if [ $found_js_resource_access ];then
			echo "Javascript files found inside the resource folder: " >> $file_name
			for element in ${jsfiles_array[@]};do
				echo $element >> $file_name
			done
		else
			echo "No trace of JavaScript in the resource folder" >> $file_name
		fi
		if [ $found_php_resource_access ];then
			echo "PHP files found inside the resource folder: " >> $file_name
			for element in ${phpfiles_array[@]};do
				echo $element >> $file_name
			done
		else
			echo "No trace of PHP in the resource folder" >> $file_name
		fi
	else
		echo "Resource folder has not been discovered or is inaccessible by this script" >> $file_name
	fi
	############################################################################

	echo " " >> $file_name

	#############################JS ACCESSED####################################
	if [ $js_folder_accessed ];then
		if [ $js_in_js_folder ];then
			echo "JavaScript files found inside the JavaScript folder: " >> $file_name
			for element in ${allfiles[@]};do
				echo $element >> $file_name
			done
		else
			echo "JavaScript folder discovered but no traces of JavaScript" >> $file_name
		fi
	else
		echo "JavaScript folder has not been discovered or is inaccessible by this script" >> $file_name
	fi
	############################################################################

	echo " " >> $file_name

	##################################MENTION###################################
	if [ $source_code_accessible ];then
		if [ $mention_js ];then
			echo "JavaScript mentioned in source code: " >> $file_name
			for element in ${js_array_refined[@]};do
				echo $element >> $file_name
			done
		else
			echo "No traces of JavaScript in source code" >> $file_name
		fi
		if [ $mention_php_flag ];then
			echo "PHP mentioned in source code: " >> $file_name
			for element in ${php_array[@]};do
				echo $element >> $file_name
			done
		else
			echo "No traces of PHP in source code" >> $file_name
		fi
		if [ $mention_asp_flag ];then
			echo "ASP mentioned in source code: " >> $file_name
			for element in ${asp_array[@]};do
				echo $element >> $file_name
			done
		else
			echo "No traces of ASP in source code" >> $file_name
		fi
	else
		echo "Source code could not be read" >> $file_name
	fi
	##########################################################################

	echo " " >> $file_name

	#################################PHP######################################
	if [ $found_phpinfo ];then
		echo "phpinfo.php discovered at {host}/phpinfo.php" >> $file_name
	else
		echo "phpinfo.php undetected/inaccessible" >> $file_name
	fi
	if [ $found_phpmyadmin ];then
		echo "phpmyadmin discovered at {host}/phpmyadmin" >> $file_name
	else
		echo "phpmyadmin undetected/inaccessible" >> $file_name
	fi
	###########################################################################

	echo " " >> $file_name

	##################################ETAG#####################################
	if [ $has_etag ];then
		echo "Host is using eTag header" >> $file_name
		echo "Unless necessary, it's usually a good idea to remove this header" >> $file_name
	else
		echo "eTag header not present" >> $file_name
	fi
	###########################################################################
	
	echo " " >> $file_name
	
	###########################CROSS DOMAIN SCRIPTS############################
	if [ $http_referer_successful ];then
		echo "Third party scripts discovered:" >> $file_name
		for element in ${nmap_results_array[@]};do
			echo $element >> $file_name
		done
		echo "Note: Using third party scripts is generally not advantageous for security purposes" >> $file_name
		echo "It's much better to include them locally to reduce third-party compromise" >> $file_name
	else
		echo "Host is not using third party scripts" >> $file_name
	fi
	#############################################################################

	echo " " >> $file_name

	###############################WAPPALYZER####################################

	#############################################################################

	echo " " >> $file_name

	##################################CIPHERS####################################

	if [ $ciphers_found ];then
		echo "Ciphersuite discovered. The grade for the host is: "$grade >> $file_name
		echo "For the full discovery, please see the following text file: "$cipher_file_name >> $file_name
	else
		echo "Ciphersuite unable to be discovered" >> $file_name
	fi

	
}