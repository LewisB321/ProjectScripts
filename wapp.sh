#! /bin/bash

wappalyzer(){

	#Uses the wappalyzer api 
	#the custom API key is free but limited use

	#comment the below when not using
	wappresults=$(curl -sH "x-api-key: n690XzXXMv3VtoJVcyzhWPr8geusC7B3avX5ZJra" "https://api.wappalyzer.com/lookup/v1/?url=https://$host")


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
	


	#I replaced every line which included hits with a blankspace. Blankspace is important for later although 
	#I could've probably done without anyway
	for ((i=0; i<${#wapparray[@]}; i++))
	do
		rm_hits=$(echo ${wapparray[i]} | grep -i 'hits' | wc -w)
		#echo $rm_hits
		if [[ $rm_hits == 1 ]]
		then
			unset wapparray[i]
		else
			false
		fi
	done
	echo ${wapparray[@]}


	#CLEANING UP THE OUTPUT
	#removing from previous tests then starting afresh
	rm jstechnologies_wap.txt
	touch unrefined.txt
	touch jstechnologies_wap.txt


	#the following ungodly chunk of code is aimed at trying to narrow down the raw wappalyzer output to pick out any JavaScript related entities and print them
	#as well as store them inside their own text file. The syntax is awkward but goes like this:
	#1) read the line and compare it to a string i.e. JavaScript library
	#2) begin to loop and read every line after a match and stop at a line that's a blank space. Output everything between the match and the blankspace
	#3) Add everything to the txt file
	#4) If a blankspace is discovered, the loop will break and open back up once a new match has been found
	#5) I had troubles placing everything inside of 1 giant loop so it's all somewhat abstracted from eachother. Ineffective but it works
	for ((a=0; a<${#wapparray[@]}; a++))
	do
		
		grep=$(echo ${wapparray[a]} | grep -i "js" | wc -w)
		if [[ $grep == 1 ]]
		then
			for ((z=-1; z<10; z++))
			do
				wordcount=$(echo ${wapparray[a+z]} | wc -w)
				if [[ $wordcount != 0 ]]
				then
					#echo ${wapparray[a+z]}
					echo ${wapparray[a+z]} >> unrefined.txt
				else
					break
				fi
			done
		else
			false
		fi

		#echo ${wapparray[a]}
		if [[ ${wapparray[a]} == '"categories":["JavaScript libraries"]}' ]]
		then
			for ((b=0; b<10; b++))
			do
				wordcount=$(echo ${wapparray[a+b]} | wc -w)
				#echo $wordcount
				if [[ $wordcount != 0 ]]
				then
					#echo ${wapparray[a+b]}
					echo ${wapparray[a+b]} >> unrefined.txt
				else
					break
				fi
			done
		else
			false
		fi

		if [[ ${wapparray[a]} == '"categories":["JavaScript frameworks"]}' ]]
		then
			for ((c=0; c<10; c++))
			do
				wordcount=$(echo ${wapparray[a+c]} | wc -w)
				#echo $wordcount
				if [[ $wordcount != 0 ]]
				then
					#echo ${wapparray[a+c]}
					echo ${wapparray[a+c]} >> unrefined.txt
				else
					break
				fi
			done
		else
			false
		fi

		if [[ ${wapparray[a]} == '"categories":["JavaScript graphics"]}' ]]
		then
			for ((d=0; d<10; d++))
			do
				wordcount=$(echo ${wapparray[a+d]} | wc -w)
				#echo $wordcount
				if [[ $wordcount != 0 ]]
				then
					#echo ${wapparray[a+d]}
					echo ${wapparray[a+d]} >> unrefined.txt
				else
					break
				fi
			done
		else
			false
		fi
	done

	#tidy up the text file by removing {}" characters and making a new one. sed wasn't playing nice so did it this was instead
	while IFS= read -r line
	do
		clean=$(echo $line | tr -d '{}"')
		echo $clean >> jstechnologies_wap.txt
	done < unrefined.txt

	cat jstechnologies_wap.txt
	rm unrefined.txt
}