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




wappalyzer(){

	#this 'hidden' test will use the wappalyzer api as a last resort to try and find any js libraries and version used
	#since this is a public service it will only work on public domains. 
	#As such, it's accessed by a flag
	#the custom API key is free and limited use

	#comment the below when not using
	wappresults=$(curl -sH "x-api-key: n690XzXXMv3VtoJVcyzhWPr8geusC7B3avX5ZJra" "https://api.wappalyzer.com/lookup/v1/?url=$host")


	#the api call will return invalid if the remote host can't be found. This if statement is to determine this
	#and only print the output if the test was successful
	if echo $wappresults | grep -q "Invalid"
	then
		echo -e "\nSeventh test (Wappalyzer) was unsuccessful"
	else
		#read the raw output from the API into an array seperated by commas
		IFS=',' read -ra wapparray <<< $wappresults
		#prints the array. Must find a way to clean this up
		echo -e "\nSeventh test (Wappalyzer) was potentially successful"
		echo "Raw Wappalyzer output: " ${warrarray[@]}
		found_js=true
		successful_tests=$((successful_tests+1))
	fi
	
	#does not work
	#for ((i=0; i<${#wapparray[@]}; i++))
	#do
		#if echo ${array[i]} | grep -w "JavaScript" > /dev/null
		#then
			#next_index=$((i+1))
			#echo "${array[next_index]}"
		#fi
	#done

}

