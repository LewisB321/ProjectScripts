#! /bin/bash

wappalyzer(){

	#Uses the wappalyzer api 
	#the custom API key is free but limited use

	#comment the below when not using
	wappresults=$(curl -sH "x-api-key: FqQpCWs3UN3Ajz8umQRvc2YRnpVTkgXy9hnMAwt4" "https://api.wappalyzer.com/lookup/v2/?url=https://$host")


	#the api call will return invalid if the remote host can't be found. This if statement is to determine this
	#and only print the output if the test was successful
	if echo $wappresults | grep -q "Invalid";then
		echo -e "\nWappalyzer test unsuccessful. It's very likely that the host could not be queried or the API key has ran out"
	else
		#read the raw output from the API into an array seperated by commas
		IFS=',' read -r -a wapparray <<< $wappresults
		#prints the array. Must find a way to clean this up
		echo "Wappalyzer test successful. Output is too large for the command line. Please refer to the text file"
		echo "An error has occured if the text file is empty"
		echo "Raw Wappalyzer output: " ${wapparray[@]}
	fi
	
	
	wap_javascript_check
	wap_programming_language_check
	wap_webserver_check



}

wap_javascript_check(){
	#the following ungodly chunk of code is aimed at trying to narrow down the raw wappalyzer output to pick out any JavaScript related entities and print them
	#as well as store them inside their own text file. The syntax is awkward but goes like this:
	#1) read each element to see if it contains the substring JavaScript
	#2) if so, begin adding each prior element until it reaches the next "category"
	#3) Parse once again to remove lines with the substring "Hits"
	#4) use Tr to remove special characters, then output to a text file
	#5) use sed to tidy the text file up a bit
	#It's far from perfect but it kind of works
	touch wap_jstechnologies.txt
	touch temp.txt

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

	#quick check to see if anything's been returned under a JavaScript header
	if [ ${#refined_array[@]} -eq 0 ]
	then
		echo "No JavaScript discovered by Wappalyzer"
	else
		wap_found_js=true
	fi

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

 	sed '/JavaScript/{N; s/\n/ /};' temp.txt > wap_jstechnologies.txt
	rm temp.txt
	rm jstechnologies_wap.txt
}



wap_programming_language_check(){
	language_array=()
	touch pl_wap.txt
	touch temp.txt
	touch programming_languages_wap.txt
	for ((i=0; i<=${#wapparray[@]}; i++));do
	if [[ ${wapparray[i]} =~ .*Programming.* ]]
	then
		echo ${wapparray[i]}
		language_array+=(${wapparray[i]})
		for ((a=1; a<=10; a++))
		do
			if [[ ${wapparray[i-a]} =~ .*categories.* ]]
			then
				break
			else	
				echo ${wapparray[i-a]}
				language_array+=(${wapparray[i-a]})
			fi
		done
	else
		false
	fi
	done

	#quick check to see if anything's been returned under a Programming Languages header
	if [ ${#language_array[@]} -eq 0 ]
	then
		echo "No programming languages discovered by Wappalyzer"
	else
		wap_found_prog_language=true
	fi

	for (( i=0; i<=${#language_array[@]}; i++ ))
	do
	if [[ "${language_array[$i]}" == *"hits"* ]]
	then
		unset 'language_array[$i]'
	fi
	done


	for elem in "${language_array[@]}"
	do
		echo "$elem" | tr -d '"{}' >> pl_wap.txt
	done

	sed '/^$/d; /\bname\b/{N; s/\n\(.*categories\)/\n\n\1/};' pl_wap.txt > temp.txt
	sed '/Programming/{N; s/\n/ /};' temp.txt > programming_languages_wap.txt
	rm pl_wap.txt
	rm temp.txt
}

wap_webserver_check(){
	webserver_array=()
	touch ws_temp.txt
	touch temp.txt
	touch webserver_wap.txt
	for ((i=0; i<=${#wapparray[@]}; i++));do
	if [[ ${wapparray[i]} =~ .*servers.* ]]
	then
		echo ${wapparray[i]}
		webserver_array+=(${wapparray[i]})
		for ((a=1; a<=10; a++))
		do
			if [[ ${wapparray[i-a]} =~ .*categories.* ]]
			then
				break
			else	
				echo ${wapparray[i-a]}
				webserver_array+=(${wapparray[i-a]})
			fi
		done
	else
		false
	fi
	done

	#quick check to see if anything's been returned under a Programming Languages header
	if [ ${#webserver_array[@]} -eq 0 ]
	then
		echo "No web server discovered by Wappalyzer"
	else
		wap_found_webserver=true
	fi

	for (( i=0; i<=${#webserver_array[@]}; i++ ))
	do
	if [[ "${webserver_array[$i]}" == *"hits"* ]]
	then
		unset 'webserver_array[$i]'
	fi
	done


	for elem in "${webserver_array[@]}"
	do
		echo "$elem" | tr -d '"{}' >> ws_temp.txt
	done

	#sed '/^$/d; /\bname\b/{N; s/\n\(.*categories\)/\n\n\1/};' pl_wap.txt > temp.txt
	#sed '/Programming/{N; s/\n/ /};' temp.txt > programming_languages_wap.txt
}