#! /bin/bash

test1-xpoweredby(){

	#test-1 try to retrieve x-powered-by header information. Conditional statement for whether https should be tried
	if [[ $publicsite == 'y' ]]
	then
		Header_Info=$(curl -sI https://"$host" | grep -i "x-powered-by" | awk '{$1=""}1')
	else
		Header_Info=$(curl -sI http://"$host" | grep -i "x-powered-by" | awk '{$1=""}1')
	fi
	echo $Header_Info
	#use to store the wordcount
	test1=$(echo $Header_Info | wc -w)

	#testing
	#echo $test1

	#variable won't be empty if the header was retrieved
	if [[ $test1 == 0 ]]
	then
		echo "First test (Header info exposure) was unsuccessful"
	else
		echo "First test (Header info exposure) was potentially successful"
		echo "Technologies discovered on the host:"$Header_Info
		found=true
		successful_tests=$((successful_tests+1))
	fi
}

test2-nmapscript(){

	#test2 use nmap http-referer-checker script
	nmap_scan=$(nmap --script http-referer-checker.nse $host)

	#NEED TO ADD A FAILSAFE ON WHETHER CONNECTION REFUSED OR NOT

	#used to store wordcount
	test2=$(echo $nmap_scan | grep "Couldn't find any cross-domain scripts" | wc -w)


	#variable will be empty if nothing was found
	if [[ $test2 != 0 ]]
	then
		echo "Second test (nmap http-referer script) was unsuccessful"
	else
		echo "Second test (nmap http-referer script) was potentially successful"
		echo "Raw nmap script output: " $nmap_scan
		found=true
		successful_tests=$((successful_tests+1))
	fi
}

test3-mention(){

	#test3 grep returned html for any mention of js (decided to miss out php since many false positives may be returned)


	#add https to hostname before check if site is public
	#the search term is the most common way a js file is mentioned
	if [[ $publicsite == 'y' ]]
	then
		webpage=$(curl -s https://"$host" | grep -i 'script type="text/javascript"' )
	else
		webpage=$(curl -s $host | grep -i 'script type="text/javascript"')
	fi
	#echo $webpage

	test3=$(echo $webpage | wc -w)
	#testing
	#echo $test3

	if [[ $test3 == 0 ]]
	then
		echo "Third test (Mention in body) was unsuccessful"
	else
		echo "Third test (Mention in body) was potentially successful"

		#filtered will contain every line that has src=<WILDCARD></script>
		filtered=$(echo $webpage | grep -o -P "src=.*(?=</script>)")

		#filtered2 will further develop this output to remove uneccesary characters using sed
		filtered2=$(echo $filtered | sed 's/^src="//' | sed 's/">$//')
		
		#testing
		echo "All instances of the mention of JavaScript on the site: " $filtered2
		found=true
		successful_tests=$((successful_tests+1))
	fi
}

test4-resourceaccess() {

	#test4 attempt to read all from /resources (last resort, very unlikely to work)

	#200 if this folder exists, 404 if not. Check before it reads contents
	returncode=$(curl -sI $host/resources/ | grep "HTTP" | awk '{print $2}')
	if [[ $returncode != 200 ]]
	then
		echo "Fourth test (/resources folder) has not identified JS version(s)"
	else
		resourcecontents=$(curl -s $host/resources/ )
		#echo $resourcecontents

		#the following uses grep to grab the search criteria, .js file, and then sed to refine the output
		jsfiles=$(echo $resourcecontents | grep -o -P 'href.*.js(?=">)' | sed 's/href="//')
		
		#decides whether anything with the .js extension has been found
		if [[ $jsfiles == 0 ]]
		then
			echo "Fourth test (/resources folder) has not identified JS version(s)"
		else
			echo "Fourth test (/resources folder has potentailly identified JS version(s)"
			echo "Below are all the discovered files in /resources that contain the .js extension"
			echo $jsfiles
			echo -e "\nOne of these may contain a clue as to JavaScript usage on the host"
			found=true
			successful_tests=$((successful_tests+1))
		fi
	fi

}

test5-wappalyzer(){

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
		echo "Fifth test (Wappalyzer) has not been able to identify JavaScript version(s)"
	else
		#read the raw output from the API into an array seperated by commas
		IFS=',' read -ra wapparray <<< $wappresults
		#prints the array. Must find a way to clean this up
		echo "Raw Wappalyzer output: " ${warrarray[@]}
		found=true
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

test6-phpinfo(){
	 #this test will use curl to check the response to access attempts for phpinfo in its default location

	 php_returncode=$(curl -sI $host/phpinfo.php | grep "HTTP" | awk '{print $2}')
	 echo $php_returncode
	 if [[ $php_returncode != 302 ]]
	 then
	 	echo "PHP info page not discovered on host. This could be for several reasons"
	 else
	 	echo "PHP info page discovered on host at /phpinfo.php. This will show PHP configuration on the host"
	 fi
}

test7-phpmyadmin(){
	 #this test will use curl to check the response to access attempts for phpmyadmin in its default location

	 myadmin_returncode=$(curl -sI $host/phpmyadmin | grep "HTTP" | awk '{print $2}')
	 echo $php_returncode
	 if [[ $php_returncode != 302 ]]
	 then
	 	echo "phpmyadmin not discovered on host. This could be for several reasons"
	 else
	 	echo "phpmyadmin discovered on host at /phpmyadmin. This is a dashboard for developers and should really be hidden"
	 fi
}