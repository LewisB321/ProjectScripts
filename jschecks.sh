#! /bin/bash

nmapscript_referer(){

	#Use nmap http-referer-checker script
	nmap_scan=$(nmap --script http-referer-checker.nse $host)

	#used to store wordcount
	test_nmap=$(echo $nmap_scan | grep "Couldn't find any cross-domain scripts" | wc -w)


	#variable will be empty if nothing was found
	if [[ $test_nmap != 0 ]]
	then
		echo -e "\nFourth test (nmap http-referer script) was unsuccessful"
	else
		echo -e "\nFourth test (nmap http-referer script) was potentially successful"
		#must tidy up???
		echo "Raw nmap script output: " $nmap_scan
		found_js=true
		successful_tests=$((successful_tests+1))
	fi
}

jsfolderaccess() {

	#Attempt to read all from /js

	#200 if this folder exists, 404 if not. Check before it reads contents
	returncode=$(curl -sI $host/js/ | grep "HTTP" | awk '{print $2}')
	if [[ $returncode != 200 ]]
	then
		echo -e "\nJS folder not present"
	else
		curl -s -o JSfolder.txt $host/js/ 
		jsfolderfiles=$(cat JSfolder.txt | grep -o -P 'href.*.js(?=">)' | sed 's/href="//')
		jsfolderfiles_wc=$(echo jsfolderfiles | wc -w)
		if [[ $jsfolderfiles_wc == 0 ]]
		then
			echo -e "\nJS folder present but couldn't find a trace of JS"
		else
			echo -e "\nJS identified in the JS folder"
			echo "Below are all the discovered files in /js that contain the .js extension"
			echo $jsfolderfiles
			echo -e "\nNote: These are only the scripts used on the host, they may not contain any indication of vulnerability or version number(s)"
			found_js=true
		fi
	fi

}


wappalyzer(){

	#this 'hidden' test will use the wappalyzer api as a last resort to try and find any js libraries and version used
	#since this is a public service it will only work on public domains. 
	#As such, it's accessed by a flag
	#the custom API key is free and limited use

	#comment the below when not using
	#wappresults=$(curl -sH "x-api-key: n690XzXXMv3VtoJVcyzhWPr8geusC7B3avX5ZJra" "https://api.wappalyzer.com/lookup/v1/?url=https://$host")


	#the api call will return invalid if the remote host can't be found. This if statement is to determine this
	#and only print the output if the test was successful
	if echo $wappresults | grep -q "Invalid"
	then
		echo -e "\nSeventh test (Wappalyzer) was unsuccessful"
	else
		#read the raw output from the API into an array seperated by commas
		IFS=',' read -r -A wapparray <<< $wappresults
		#prints the array. Must find a way to clean this up
		echo -e "\nSeventh test (Wappalyzer) was potentially successful"
		echo "Raw Wappalyzer output: " ${wapparray[@]}
		found_js=true
		successful_tests=$((successful_tests+1))
	fi
	


	#needs further work
	for ((i=0; i<${#wapparray[@]}; i++))
	do
		rm_hits=$(echo ${wapparray[i]} | grep -i 'hits' | wc -w)
		#echo $rm_hits
		if [[ $rm_hits == 1 ]]
		then
			echo ${wapparray[i]}
			unset wapparray[i]
		else
			false
		fi
	done

	#for testing
	for ((k=0; k<${#wapparray[@]}; k++))
	do
		echo ${wapparray[k]}
	done
}

