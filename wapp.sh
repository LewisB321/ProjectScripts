#! /bin/bash

wappalyzer(){

	#Uses the wappalyzer api 
	#the custom API key is free but limited use

	#comment the below when not using
	wappresults=$(curl -sH "x-api-key: 6ZdlygJjAS8xTAN0jx79s5QRPH3NjLIS5ntAXPjY" "https://api.wappalyzer.com/lookup/v1/?url=https://$host")


	#the api call will return invalid if the remote host can't be found. This if statement is to determine this
	#and only print the output if the test was successful
	if echo $wappresults | grep -q "Invalid"
	then
		echo -e "\nWappalyzer test unsuccessful. It's very likely that the host could not be queried or the API key has ran out"
	else
		#read the raw output from the API into an array seperated by commas
		IFS=',' read -r -a wapparray <<< $wappresults
		#prints the array. Must find a way to clean this up
		echo "Wappalyzer test successful. Output is too large for the command line"
		echo "An error has occured if the text file is empty"
		#echo "Raw Wappalyzer output: " ${wapparray[@]}
		found_js=true
	fi
	
	touch wap_jstechnologies.txt
	touch temp.txt


	#the following ungodly chunk of code is aimed at trying to narrow down the raw wappalyzer output to pick out any JavaScript related entities and print them
	#as well as store them inside their own text file. The syntax is awkward but goes like this:
	#1) read each element to see if it contains the substring JavaScript
	#2) if so, begin adding each prior element until it reaches the next "category"
	#3) Parse once again to remove lines with the substring "Hits"
	#4) use Tr to remove special characters, then output to a text file
	#5) use sed to tidy the text file up a bit
	#It's far from perfect but it kind of works
	refined_array=()
	touch jstechnologies_wap.txt
	for ((i=0; i<=${#wapparray[@]}; i++));do
		if [[ ${wapparray[i]} =~ .*JavaScript.* ]]
		then
			echo ${wapparray[i]}
			refined_array+=(${wapparray[i]})
			for ((a=1; a<=10; a++))
			do
				if [[ ${wapparray[i-a]} =~ .*categories.* ]]
				then
					break
				else	
					echo ${wapparray[i-a]}
					refined_array+=(${wapparray[i-a]})
				fi
			done
		else
			false
		fi
	done

	for (( i=0; i<=${#refined_array[@]}; i++ ))
	do
	if [[ "${refined_array[$i]}" == *"hits"* ]]
	then
		unset 'refined_array[$i]'
	fi
	done

	for elem in "${refined_array[@]}"
	do
		echo "$elem" | tr -d '"{}' >> jstechnologies_wap.txt
	done

 	sed '/^$/d; /\bname\b/{N; s/\n\(.*categories\)/\n\n\1/};'  jstechnologies_wap.txt > temp.txt
 	sed '/JavaScript/{N; s/\n/ /};' jstechnologies_wap.txt > wap_jstechnologies.txt
	rm temp.txt
	rm jstechnologies_wap.txt
}