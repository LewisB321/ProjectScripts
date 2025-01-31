#! /bin/bash

nmapscript_referer(){

	#Uses nmap http-referer-checker script to determine the use of third party scripts
	#Use grep & sed to remove any instances of port number from the host temporarily (incase of a container)
	if echo $host | grep -q ':';then
		temp_host=$(echo $host | grep -oP '(.*?)\:' | sed 's/://')
		nmap -o nmap_script_output.txt -p80,443 --script http-referer-checker.nse $temp_host >/dev/null
	else
		nmap -o nmap_script_output.txt -p80,443 --script http-referer-checker.nse $host >/dev/null
	fi

	#Wordcount
	test_nmap=$(cat nmap_script_output.txt | grep "Couldn't find any cross-domain scripts" | wc -w)
	if [[ $test_nmap == 0 ]];then
		test_nmap=$(cat nmap_script_output.txt | grep -i "Closed" | wc -w)
	fi


	#Variable will be empty if something has been returned
	if [[ $test_nmap != 0 ]];then
		echo "Host is not using any Cross-Domain JS scripts"
	else
		echo "Fourth test (nmap http-referer script) was successful"
		echo "Here are the cross-domains scripts found on the host: " 
		
		#Grepping any/all scripts, putting into an array and printing them. Sed is used to remove annoying chars
		nmap_results_var=$(cat nmap_script_output.txt | grep -o -E "https?://\S+")
		nmap_results_var=$(echo $nmap_results_var | sed 's/[[:space:]]*$//')
		IFS=' ' read -a nmap_results_array <<< $nmap_results_var
		for element in ${nmap_results_array[@]}
		do
			echo $element
		done
		declare -x nmap_results_array
		http_referer_successful=true
	fi
	rm nmap_script_output.txt
}

jsfolderaccess() {

	#Attempt to read all from /js

	#200 if this folder exists
	if [[ $publicsite == "y" ]];then
		returncode=$(curl -sI -L https://$host/js/ | grep "HTTP" | awk '{print $2}')
		indexpage=$(curl -sI -L https://$host | wc -c)	
		jsfolder=$(curl -sI -L https://$host/js/ | wc -c)
	else
		returncode=$(curl -sI -L http://$host/js/ | grep "HTTP" | awk '{print $2}')
		indexpage=$(curl -sI -L http://$host | wc -c)	
		jsfolder=$(curl -sI -L http://$host/js/ | wc -c)
	fi

	#Silent redirect checker. NOT ALWAYS RELIABLE but the best idea I have
	if [ $indexpage -eq $jsfolder ];then
		echo "Silent redirected detected when attempting to access /js"
	else	
		case $returncode in
			
			*403*)
				echo "Permission denied when attempting to access /js"
				return 0
				;;
			*200*)
				echo "JS folder potentially identified but cannot be guaranteed"
				#Grep mention of javascript then get the wordcount of that. 0 if nothing is found
				js_folder_accessed=true
				curl -sL -o JSfolder.txt $host/js/ 
				jsfolderfiles=$(grep -o -P 'href=.*\.js(?=">)' JSfolder.txt | sed 's/href="//')
				jsfolderfiles_wc=$(echo $jsfolderfiles | wc -w)
				rm JSfolder.txt
	
				if [[ $jsfolderfiles_wc == 0 ]];then
					echo "No mention of JavaScript found"
					echo "Note: Some hosts may use this space for a different purpose and this test does not make that distinction"
				else
					js_in_js_folder=true
					echo "JS identified"
					echo "Below are all the discovered files in /js that contain the .js extension:"

					#Using sed to remove instances of space that mess with how the string is read into the array
					jsfolderfiles=$(echo $jsfolderfiles | sed 's/[[:space:]]*$//')
					IFS=' ' read -ra allfiles <<< $jsfolderfiles
					for element in ${allfiles[@]}
					do
						echo $element
					done
					declare -x allfiles
				
					echo -e "\nNote: These are only the scripts used on the host, they may not contain any indication of vulnerability or version number(s)"
				fi
				;;
			*)
				echo "Unknown error occured when trying to access /js. Unable to determine existence"
				;;
		esac
	fi

}
