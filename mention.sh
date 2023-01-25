#! /bin/bash

mention(){

	#Grep returned source code for mention of JavaScript or ASP.NET


	#add https to hostname before check if site is public
	if [[ $publicsite == 'y' ]]
	then
		webpage=$(curl -s https://"$host")
	else
		webpage=$(curl -s $host)
	fi
	#echo $webpage

	webpage_wc=$(echo $webpage | wc -w)

	if [[ $webpage_wc == 0 ]]
	then
		echo "Could not read host's source code"
		return 0
	else
		mention_JavaScript
		mention_asp
	fi
	
		
	



}

mention_JavaScript(){

	mention_js=$(echo $webpage | grep -i 'script type="text/javascript"')
	mention_js_wc=$(echo $mention_js | wc -w)

	if [[ mention_js_wc == 0 ]]
	then
		echo "No mention of JavaScript in source code"
		return 0
	else
		false
	fi

	#js_filtered will contain every line that has src=<WILDCARD></script>
	js_filtered=$(echo $webpage | grep -o -P "src=.*(?=</script>)")

	#array to add every JS element
	js_array_refined=()

	#Will take the raw output, put it into array and parse the array for matches
	#Upon a match, it will be placed inside it's own array for usage later
	IFS=' ' read -A js_array <<< $js_filtered
	echo "Every trace of JavaScript found in the host's source code:"
	for element in ${js_array[@]}
	do
		if echo $element | grep -q ".js" #if element contains the substring .js
		then
			#get the output but remove unecessary characters
			add_to_array=$(echo $element | sed 's/^src="//' | sed 's#"></script><script$##')
			echo $add_to_array
			js_array_refined+=($add_to_array)
		else
			false
		fi
	done

	#echo ${js_array_refined[@]}
}

mention_asp(){

	#these 2 strings are often hidden and used by asp. Presence of these indicates ASP is being used
	echo "__VIEWSTATE" > mention_asp.txt
	echo "__EVENTVALIDATION" >> mention_asp.txt

	mention_asp=$(echo $webpage | grep -i -f mention_asp.txt)
	mention_asp_wc=$(echo $mention_asp | wc -w)

	if [[ $mention_asp_wc == 0 ]]
	then
		echo "No mention of ASP.NET in source code"
		return 0
	else
		echo "PLACEHOLDER. ASP.NET DISCOVERED"
	fi

	#asp_filtered will contain every line that has src=<WILDCARD></script>
	#asp_filtered=$(echo $webpage | grep -o -P "src=.*(?=</script>)")

	#array to add every JS element
	#js_array_refined=()

	#Will take the raw output, put it into array and parse the array for matches
	#Upon a match, it will be placed inside it's own array for usage later
	#IFS=' ' read -A js_array <<< $js_filtered
	#echo "Every trace of JavaScript found in the host's source code:"
	#for element in ${js_array[@]}
	#do
		#if echo $element | grep -q ".js" #if element contains the substring .js
		#then
			#get the output but remove unecessary characters
			#add_to_array=$(echo $element | sed 's/^src="//' | sed 's#"></script><script$##')
			#echo $add_to_array
			#js_array_refined+=($add_to_array)
		#else
			#false
		#fi
	#done

	#echo ${js_array_refined[@]}
}