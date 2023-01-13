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
		echo "test1 has not identified JS version(s)"
	else
		echo "Javascript version identified as PLACEHOLDER"
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
		echo "test2 has not identified JS version(s)"
	else
		echo "Javascript version identified as PLACEHOLDER"
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
		echo "test3 has not identified JS version(s)"
	else
		echo "Javascript version identified as PLACEHOLDER"
	fi
}

test4-resourceaccess() {

	#test4 attempt to read all from /resources (last resort)

	#200 if this folder exists, 404 if not. Check before it reads contents
	returncode=$(curl -sI $host/resources/ | grep "HTTP" | awk '{print $2}')
	if [[ $returncode != 200 ]]
	then
		echo "test4 has not identified JS version(s)"
	else
		resourcecontents=$(curl -s $host/resources/ )
		jsfiles=$(echo $resourcecontents)
		
		#decides whether anything with the .js extension has been found
		if [[ $jsfiles == 0 ]]
		then
			echo "test4 has not identified JS version(s)"
		else
			echo "js identified PLACEHOLDER"
			echo $jsfiles
			#echo $jsfiles #just dump it for now, not sure how to work with this using grep.
			#it picks up all files with the js extension but can't seperate it
		fi
	fi

}

test5-wappalyzer(){

	#this 'hidden' test will use the wappalyzer api as a last resort to try and find any js libraries and version used
	#since this is a public service it will only work on public domains. 
	#As such, it's accessed by a flag

	#comment the below when not using
	#wappresults=$(curl -H "x-api-key: n690XzXXMv3VtoJVcyzhWPr8geusC7B3avX5ZJra" "https://api.wappalyzer.com/lookup/v1/?url=$host")

	#read the raw output from the API into an array seperated by commas
	IFS=',' read -r -A wapparray <<< $wappresults
	
	#testing
	#for element in ${wapparray[@]}
	#do
		#echo $element
	#done

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