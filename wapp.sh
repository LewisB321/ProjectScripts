#! /bin/bash

wappalyzer(){

	#Uses the wappalyzer api 
	#The API is limited use and uses a key I bought
	#Returns a messy JSON output so lots of cleaning necessary - often has some repeating values
	wappresults=$(curl -sH "x-api-key: YHyeImfviK4i1cjlQcSVeQFPjRp6U447lccmIoz8" "https://api.wappalyzer.com/lookup/v1/?url=https://$host")


	#The api call will return invalid if the remote host can't be found. This if statement is to determine this
	#And only print the output if the test was successful
	if echo $wappresults | grep -qE "Invalid|could not be resolved";then
		echo -e "\nWappalyzer test unsuccessful. It's very likely that the host could not be queried or the API key has ran out"
		return 0
	else
		#Read the raw output from the API into an array seperated by commas
		wap=true
		IFS=',' read -r -a wapparray <<< $wappresults
		#Prints the array. Must find a way to clean this up
		echo -e "\nWappalyzer test successful. Output is too large for the command line. Please refer to the text files"
		#echo "Raw Wappalyzer output: " ${wapparray[@]}
	fi
	
	
	wap_javascript_check
	wap_programming_language_check
	wap_webserver_check




}

#These following tests all follow the same format:
# 1: Grab every instance of a string like JavaScript and place it into it's own array along with the accompanying data alongside it
# 2: Check if anything's been returned
# 3: Unset every instance of the string 'hits' because it's useless and I needed the blankspace line
# 4: Remove uneccessary characters and get it to an easily-readable format
# 5: Make another temporary text file with values that are instead appropriate for the vulnerability lookup. Will be deleted in the output function
# 6: Perform some minor alterations based on each use case i.e. some include the string 'applications:' for seemingly no reason


wap_javascript_check(){

	touch JavaScript_Wappalyzer.txt
	touch temp.txt

	refined_array=()
	touch jstechnologies_wap.txt
	for ((i=0; i<=${#wapparray[@]}; i++));do
		if [[ ${wapparray[i]} =~ .*JavaScript.* ]]
		then
			#echo ${wapparray[i]}
			refined_array+=(${wapparray[i]})
			for ((a=1; a<=10; a++))
			do
				if [[ ${wapparray[i-a]} =~ .*categories.* ]]
				then
					break
				else	
					#echo ${wapparray[i-a]}
					refined_array+=(${wapparray[i-a]})
				fi
			done
		else
			false
		fi
	done

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

 	sed '/JavaScript/{N; s/\n/ /};' temp.txt > JavaScript_Wappalyzer.txt
	rm temp.txt
	rm jstechnologies_wap.txt
	
	
	#making it appropriate for the cve API lookup
	touch temp
	while read line; do
		if [[ $line == *"name"* ]]; then
			echo $line | tr -d "[]" | sed 's/name://g' >> temp
		fi
		if [[ $line == *"versions"* ]]; then
			echo $line | tr -d "[]" | sed 's/versions://g' >> temp
		fi
	done < JavaScript_Wappalyzer.txt

	
	sed -i '/^$/d' temp #removing blank lines
	
	awk '!x[$0]++' temp > temp2 #removing duplicates
	
	touch wap_output_for_security_check_js
	
	while IFS= read -r line; do
		if [[ $line =~ [0-9] ]]; then
			next_line=$(IFS= read -r; echo "$REPLY")
			echo "$next_line $line"
		fi
		if [[ "$line" == applications:* ]];then
			line=${line#applications:}
		fi
	done < temp2 > wap_output_for_security_check_js

	#removing the string applications: which sometimes occurs and messes up the API lookup
	sed -i 's/^applications://' wap_output_for_security_check_js 

	rm temp
	rm temp2
}



wap_programming_language_check(){
	
	language_array=()
	touch Languages_Wappalyzer.txt
	touch temp
	touch lan_wap
	
	for ((i=0; i<=${#wapparray[@]}; i++));do
	if [[ ${wapparray[i]} =~ .*Programming.* ]]
	then
		#echo ${wapparray[i]}
		language_array+=(${wapparray[i]})
		for ((a=1; a<=10; a++))
		do
			if [[ ${wapparray[i-a]} =~ .*categories.* ]]
			then
				break
			else	
				#echo ${wapparray[i-a]}
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
		echo "$elem" | tr -d '"{}' >> lan_wap
	done

	sed '/^$/d; /\bname\b/{N; s/\n\(.*categories\)/\n\n\1/};' lan_wap > temp
	sed '/Programming/{N; s/\n/ /};' temp > Languages_Wappalyzer.txt
	rm lan_wap
	rm temp
	
	touch temp
	while read line; do
		if [[ $line == *"name"* ]]; then
			echo $line | tr -d "[]" | sed 's/name://g' >> temp
		fi
		if [[ $line == *"versions"* ]]; then
			echo $line | tr -d "[]" | sed 's/versions://g' >> temp
		fi
	done < Languages_Wappalyzer.txt
	
	sed -i '/^$/d' temp #removing blank lines
	
	awk '!x[$0]++' temp > temp2 #removing duplicates
	
	touch wap_output_for_security_check_pl
	
	while IFS= read -r line; do
	if [[ $line =~ [0-9] ]]; then
		next_line=$(IFS= read -r; echo "$REPLY")
		echo "$next_line $line"
	fi
	done < temp2 > wap_output_for_security_check_pl
	
	#removing the string applications: which sometimes occurs and messes up the API lookup
	sed -i 's/^applications://' wap_output_for_security_check_pl

	
	rm temp
	rm temp2
}

wap_webserver_check(){
	webserver_array=()
	touch ws_wap
	touch temp
	touch Webserver_Wappalyzer.txt
	for ((i=0; i<=${#wapparray[@]}; i++));do
	if [[ ${wapparray[i]} =~ .*servers.* ]]
	then
		#echo ${wapparray[i]}
		webserver_array+=(${wapparray[i]})
		for ((a=1; a<=10; a++))
		do
			if [[ ${wapparray[i-a]} =~ .*categories.* ]]
			then
				break
			else	
				#echo ${wapparray[i-a]}
				webserver_array+=(${wapparray[i-a]})
			fi
		done
	else
		false
	fi
	done

	#quick check to see if anything's been returned under Webserver header
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
		echo "$elem" | tr -d '"{}' >> ws_wap
	done
	

	sed '/^$/d; /\bname\b/{N; s/\n\(.*categories\)/\n\n\1/};' ws_wap > temp
	sed '/Web/{N; s/\n/ /};' temp > Webserver_Wappalyzer.txt
	
	rm ws_wap
	rm temp
	
	touch temp
	while read line; do
		if [[ $line == *"name"* ]]; then
			echo $line | tr -d "[]" | sed 's/name://g' >> temp
		fi
		if [[ $line == *"versions"* ]]; then
			echo $line | tr -d "[]" | sed 's/versions://g' >> temp
		fi
	done < Webserver_Wappalyzer.txt
	
	sed -i '/^$/d' temp #removing blank lines
	
	awk '!x[$0]++' temp > temp2 #removing duplicates

	touch wap_output_for_security_check_ws
	
	while IFS= read -r line; do #not doing vulnerability lookup so no need for the if statement
		next_line=$(IFS= read -r; echo "$REPLY")
		echo "$next_line $line"
	done < temp2 > wap_output_for_security_check_ws
	
	#removing the string applications: which sometimes occurs and messes up the API lookup
	sed -i 's/^applications://' wap_output_for_security_check_ws
	
	rm temp
	rm temp2
}
