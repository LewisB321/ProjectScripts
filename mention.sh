#! /bin/bash

mention(){

	#Grep returned source code for mention of JavaScript, PHP or ASP.NET
	if [[ $publicsite == 'y' ]];then
		webpage=$(curl -sL https://$host)
	else
		webpage=$(curl -sL http://$host)
	fi
	
	webpage_wc=$(echo $webpage | wc -w)

	if [[ $webpage_wc == 0 ]];then
		echo "Could not read host's source code"
		return 0
	else
		source_code_accessible=true
		mention_JavaScript
		mention_php
		mention_asp
	fi

}

mention_JavaScript(){

	mention_js=$(echo $webpage | grep -oi 'script type="text/javascript"') #Grabs every line that includes this
	mention_js_wc=$(echo $mention_js | wc -w)
	
	if [[ $mention_js_wc == 0 ]];then
		echo "No mention of JavaScript in source code"
		return 0
	else
		mention_js=true
	fi

	js_filtered=$(echo $webpage | grep -o 'src=[^<]*</script>')
	#array to add every JS element
	js_array_refined=()

	#Removing newline chars with sed and putting into an array
	js_filtered=$(echo $js_filtered | sed 's/[[:space:]]*$//')
	IFS=' ' read -a js_array <<< $js_filtered
	echo "Every mention of a JS file found in the host's source code:"

	for element in ${js_array[@]}
	do
		if echo $element | grep -q ".js";then #if element contains the substring .js
			#Get the output but remove unecessary characters (1: The source tag 2: the start of script 3: the end of script) to leave just the name
			add_to_array=$(echo $element | sed 's/^src="//' | sed 's#"></script><script$##' | sed 's#"></script>#\n#')
			echo $add_to_array
			js_array_refined+=($add_to_array)
		else
			false
		fi
	done
	declare -x js_array_refined
	echo "Note: Not every mention is going to disclose a script and some detections may not be understandable"
	#final array with everything in
	#echo ${js_array_refined[@]}
}


mention_php(){

	mention_php=$(echo $webpage | grep -o "\.php")
	mention_php_wc=$(echo $mention_php | wc -w)

	if [[ $mention_php_wc == 0 ]];then
		echo "No mention of PHP in source code"
		return 0
	else
		mention_php_flag=true
	fi

	#php_filtered will contain every instance of a string with the .php file extension
	php_filtered=$(echo $webpage | grep -oP '\b\w+\.php\b')

	#Removing the whitespace using sed substitution & Putting into the array
	php_filtered=$(echo $php_filtered | sed 's/[[:space:]]*$//')
	IFS=' ' read -ra php_array <<< $php_filtered

	echo "Every trace of PHP found in the host's source code:"
	for element in ${php_array[@]}
	do
		echo $element
	done
	declare -x php_array

	
}


mention_asp(){

	#First 2 strings are often hidden and used by asp. Presence of these indicates ASP is being used
	echo "__VIEWSTATE" > mention_asp.txt
	echo "__EVENTVALIDATION" >> mention_asp.txt
	echo "ASP.NET" >> mention_asp.txt

	mention_asp=$(echo $webpage | grep -io -f mention_asp.txt)
	mention_asp_wc=$(echo $mention_asp | wc -w)
	rm mention_asp.txt
	if [[ $mention_asp_wc == 0 ]];then
		echo "No mention of ASP.NET in source code"
		return 0
	else
		mention_asp_flag=true
	fi


	mention_asp_filtered=$(echo $mention_asp | sed 's/[[:space:]]*$//') #Similar cleaning procedure as the above 2 functions
	IFS=' ' read -ra asp_array <<< $mention_asp_filtered
	echo "Every mention of ASP found in the host's source code:"
	for element in ${asp_array[@]}
	do
		echo $element
	done
	declare -x asp_array

}
