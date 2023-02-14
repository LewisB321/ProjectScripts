#! /bin/bash

mention(){

	#Grep returned source code for mention of JavaScript, PHP or ASP.NET


	#add https to hostname before check if site is public
	if [[ $publicsite == 'y' ]]
	then
		webpage=$(curl -sL https://$host)
	else
		webpage=$(curl -sL http://$host)
	fi
	
	webpage_wc=$(echo $webpage | wc -w)

	if [[ $webpage_wc == 0 ]]
	then
		echo "Could not read host's source code"
		return 0
	else
		mention_JavaScript
		mention_php
		mention_asp
	fi

}

mention_JavaScript(){

	mention_js=$(echo $webpage | grep -i 'script type="text/javascript"')
	mention_js_wc=$(echo $mention_js | wc -w)
	#echo $mention_js
	if [[ $mention_js_wc == 0 ]]
	then
		echo "No mention of JavaScript in source code"
		return 0
	else
		found_js=true
	fi

	js_filtered=$(echo $webpage | grep -oE 'src=".+\.js">')
	#array to add every JS element
	js_array_refined=()

	#Removing newline chars with sed and putting into an array
	js_filtered=$(echo $js_filtered | sed 's/[[:space:]]*$//')
	IFS=' ' read -a js_array <<< $js_filtered
	echo "Every mention of a JS file found in the host's source code:"
	unset '${js_array[1]}'
	for element in ${js_array[@]}
	do
		if echo $element | grep -q ".js" #if element contains the substring .js
		then
			#get the output but remove unecessary characters
			add_to_array=$(echo $element | sed 's/^src="//' | sed 's#"></script><script$##')
			add_to_array=$(echo $add_to_array | tr -d '">')
			echo $add_to_array
			js_array_refined+=($add_to_array)
		else
			false
		fi
	done

	#final array with everything in
	#echo ${js_array_refined[@]}
}


mention_php(){

	mention_php=$(echo $webpage | grep -i '.php')
	mention_php_wc=$(echo $mention_php | wc -w)
	#echo $mention_php
	if [[ $mention_php_wc == 0 ]]
	then
		echo "No mention of PHP in source code"
		return 0
	else
		found_php=true
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

	
}


mention_asp(){

	#these 2 strings are often hidden and used by asp. Presence of these indicates ASP is being used
	echo "__VIEWSTATE" > mention_asp.txt
	echo "__EVENTVALIDATION" >> mention_asp.txt
	echo "ASP.NET" >> mention_asp.txt

	mention_asp=$(echo $webpage | grep -io -f mention_asp.txt)
	mention_asp_wc=$(echo $mention_asp | wc -w)
	rm mention_asp.txt
	if [[ $mention_asp_wc == 0 ]]
	then
		echo "No mention of ASP.NET in source code"
		return 0
	else
		found_asp=true
	fi


	mention_asp_filtered=$(echo $mention_asp | sed 's/[[:space:]]*$//')
	IFS=' ' read -ra asp_array <<< $mention_asp_filtered
	echo "Every trace of ASP found in the host's source code:"
	for element in ${asp_array[@]}
	do
		echo $element
	done

}