#! /bin/bash


resourceaccess() {

	#Attempt to access and read contents of /resources
	if [[ $publicsite == "y" ]];then
		returncode=$(curl -sI -L https://www.$host/resources/ | grep "HTTP" | awk '{print $2}')
		indexpage=$(curl -sI -L https://$host | wc -c)	
		resourcefolder=$(curl -sI -L https://$host/resources/ | wc -c)
	else
		returncode=$(curl -sI -L http://$host/resources/ | grep "HTTP" | awk '{print $2}')
		indexpage=$(curl -sI -L http://$host | wc -c)	
		resourcefolder=$(curl -sI -L http://$host/resources/ | wc -c)
	fi

	#Silent direct checker. Not perfect but works sometimes
	if [ $indexpage -eq $resourcefolder ];then
		echo "Silent redirect detected when attempting to access /resources"
		return 0
	else
		if [[ ! $returncode =~ 200 ]];then
			echo "Resources folder not present"
			return 0
		else
			echo "Resources folder found"
			echo "Note: Some hosts may use this space for a different purpose and this test does not make that distinction"
			echo "If you know a host is using this space for a different purpose, please use the -r flag"
			resource_folder_accessed=true

			#Output the contents to a txt file to preserve html format
			if [[ $publicsite == "y" ]];then
				curl -s -o ra.txt https://www.$host/resources/ 
			else
				curl -s -o ra.txt http://$host/resources/ 
			fi

			#Run the functions, get the important info and remove the file
			ra_js
			ra_php
			rm ra.txt
		fi
	fi
	

}

ra_js() {

	#Grep & sed to find a mention of JS
	jsfiles=$(cat ra.txt | grep -o -P 'href.*.js(?=">)' | sed 's/href="//')
	jsfile_wc=$(echo $jsfiles | wc -w)
	#decides whether anything with the .js extension has been found
	if [[ $jsfile_wc == 0 ]];then
		echo -e "\nNo traces of JavaScript in /resources"
	else
		echo -e "\nJS identified in the resource folder"
		jsfiles=$(echo $jsfiles | sed 's/[[:space:]]*$//') #Removing space
		IFS=' ' read -a jsfiles_array <<< $jsfiles
		for element in ${jsfiles_array[@]};do
			echo $element
		done
		declare -x jsfiles_array
		echo -e "\nNote: May not contain any indication of vulnerability"
		found_js_resource_access=true
	fi
}

ra_php() {

	#Grep & sed to find a mention of PHP
	phpfiles=$(cat ra.txt | grep -o -P 'href.*.php(?=">)' | sed 's/href="//')
	phpfiles_wc=$(echo $phpfiles | wc -w)
		
	#decides whether anything with the .php extension has been found
	if [[ $phpfiles_wc == 0 ]];then
		echo -e "\nNo traces of PHP in /resources"
	else
		echo -e "\nPHP identified in the resource folder"
		phpfiles=$(echo $phpfiles | sed 's/[[:space:]]*$//') #Removing space
		IFS=' ' read -a phpfiles_array <<< $phpfiles
		for element in ${phpfiles_array[@]};do
			echo $element
		done
		declare -x phpfiles_array
		echo -e "\nNote: May not contain any indication of vulnerability"
		found_php_resource_access=true
	fi
}
