#! /bin/bash



xpoweredby(){

	#Try to retrieve x-powered-by header information. Conditional statement for whether https should be tried
	if [[ $publicsite == 'y' ]]
	then
		Header_Info=$(curl -sI https://"$host" | grep -i "x-powered-by" | awk '{$1=""}1')
	else
		Header_Info=$(curl -sI http://"$host" | grep -i "x-powered-by" | awk '{$1=""}1')
	fi
	#echo $Header_Info
	#use to store the wordcount
	test_xpb=$(echo $Header_Info | wc -w)

	#variable won't be empty if the header was retrieved
	if [[ $test_xpb == 0 ]]
	then
		echo -e "\nThird test (Header info exposure) was unsuccessful"
	else
		echo -e "\nThird test (Header info exposure) was potentially successful"
		echo "Technologies discovered on the host via the x-powered-by header:"$Header_Info
		found_js=true
		successful_tests=$((successful_tests+1))
	fi
}

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

mention(){

	#Grep returned html for any mention of js 


	#add https to hostname before check if site is public
	#the search term is the most common way a js file is mentioned
	if [[ $publicsite == 'y' ]]
	then
		webpage=$(curl -s https://"$host" | grep -i 'script type="text/javascript"' )
	else
		webpage=$(curl -s $host | grep -i 'script type="text/javascript"')
	fi
	#echo $webpage

	test_mention=$(echo $webpage | wc -w)

	if [[ $test_mention == 0 ]]
	then
		echo -e "\nFifth test (Mention in body) was unsuccessful"
	else
		echo -e "\nFifth test (Mention in body) was potentially successful"

		#filtered will contain every line that has src=<WILDCARD></script>
		filtered=$(echo $webpage | grep -o -P "src=.*(?=</script>)")

		#filtered2 will further develop this output to remove uneccesary characters using sed
		filtered2=$(echo $filtered | sed 's/^src="//' | sed 's/">$//')
		
		echo "All instances of the mention of JavaScript in the site's source code:" $filtered2
		found_js=true
		successful_tests=$((successful_tests+1))
	fi
}

resourceaccess() {

	#Attempt to read all from /resources (last resort, very unlikely to work)

	#200 if this folder exists, 404 if not. Check before it reads contents
	returncode=$(curl -sI $host/resources/ | grep "HTTP" | awk '{print $2}')
	if [[ $returncode != 200 ]]
	then
		echo -e "\nSixth test (/resources folder) has not identified JS version(s)"
	else
		curl -s -o test_ra.txt $host/resources/ 

		#the following uses grep to grab the search criteria, .js file, and then sed to refine the output
		jsfiles=$(cat test_ra.txt | grep -o -P 'href.*.js(?=">)' | sed 's/href="//')
		
		#decides whether anything with the .js extension has been found
		if [[ $jsfiles == 0 ]]
		then
			echo -e "\nSixth test (/resources folder) has not identified JS version(s)"
		else
			echo -e "\nSixth test (/resources folder has potentailly identified JS version(s)"
			echo "Below are all the discovered files in /resources that contain the .js extension"
			echo $jsfiles
			echo -e "\nNote: it's possible none of these may contain a clue as to JavaScript usage"
			found_js=true
			successful_tests=$((successful_tests+1))
		fi
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

