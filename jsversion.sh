#! /bin/bash

test1-xpoweredby(){

	#test-1 try to retrieve x-powered-by header information
	Header_Info=$(curl -sI $host | grep "X-Powered-By" | awk '{print $2}')

	#use to store the wordcount
	test1=$(echo $Header_Info | wc -w)

	#testing
	#echo $test1

	#variable won't be empty if the header was retrieved
	if [[ $test1 == 0 ]]
	then
		echo "First test (Header exposed info) has not identified JS version(s)"
	else
		echo "First test (Header exposed info) has potentially been able to identify JS version(s)"
		echo "Raw header info output: "$Header_Info
		found=true
	fi
}

test2-nmapscript(){

	#test2 use nmap http-referer-checker script
	nmap_scan=$(nmap --script http-referer-checker.nse $host)

	#the grep string will be in the results if the test was unsuccesful
	nmap_results=$(echo $nmap_scan | grep "Couldn't find any cross-domain scripts")
	#NEED TO ADD A FAILSAFE ON WHETHER CONNECTION REFUSED OR NOT

	#used to store wordcount
	test2=$(echo $nmap_results | wc -w)

	#testing
	#echo $nmap_results
	#echo $test2

	#variable will be empty if JS version was identified by the script
	if [[ $test2 != 0 ]]
	then
		echo "Second test (nmap http-referer script) has not identified JS version(s)"
	else
		echo "Second test (nmap http-referer script) has potentailly been able to identify JS version(s)"
		echo "Raw nmap script output: " $nmap_scan
		found=true
	fi
}

test3-mention(){

	#test3 grep returned html for any mention of js

	#make a file to use with grep to match multiple potential expressions
	echo "javascript" > greptests.txt
	echo "jscript" >> greptests.txt
	echo "jquery" >> greptests.txt
	#echo "index" >> greptests.txt #testing
	webpage=$(curl -s $host | grep -i -f greptests.txt)
	rm greptests.txt
	#echo $webpage

	test3=$(echo $webpage | wc -w)
	#testing
	#echo $test3

	if [[ $test3 == 0 ]]
	then
		echo "Third test (Mention in body) has not identified JS version(s)"
	else
		echo "Third test (Mention in body) has potentially identified JS version(s)"
		echo "Raw mention output: " $webpage
		found=true
	fi
}

test4-resourceaccess() {

	#test4 attempt to read all from /resources (last resort)

	#200 if this folder exists, 404 if not. Check before it reads contents
	returncode=$(curl -sI $host/resources/ | grep "HTTP" | awk '{print $2}')
	if [[ $returncode != 200 ]]
	then
		echo "Fourth test (/resources folder) has not identified JS version(s)"
	else
		resourcecontents=$(curl -s $host/resources/ )
		jsfiles=$(echo $resourcecontents | grep -o '.js')
		
		#decides whether anything with the .js extension has been found
		if [[ $jsfiles == 0 ]]
		then
			echo "Fourth test (/resources folder) has not identified JS version(s)"
		else
			echo "Fourth test (/resources folder has potentailly identified JS version(s)"
			#echo "Raw /resources output: " $resourcecontents
			echo "Below are all the discovered files in /resources that contain the .js extension"
			echo $jsfiles
			found=true
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