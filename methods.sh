#! /bin/bash

httpmethods(){

	#curl request to grab supported http methods
	#the nested if/else statements are to try the second possible header instead
	#if secondary header is present (i.e. on a 204 code) then the wordcount will be altered
	
	if [[ $publicsite == "y" ]];then
		methods=$(curl -sI -L -X OPTIONS https://"$host" | grep -i "Allow:" | awk '{$1=""}1')
		methods_wc=$(echo $methods | wc -w)
		if [[ $methods_wc == 0 ]];then
			methods=$(curl -sI -L -X OPTIONS https://"$host" | grep -i "Access-Control-Allow-Methods:" | awk '{$1=""}1')
			methods_wc=$(echo $methods | wc -w)
		else
			false
		fi
	else
		methods=$(curl -sI -L -X OPTIONS http://"$host" | grep -i "Allow:" | awk '{$1=""}1')
		methods_wc=$(echo $methods | wc -w)
		if [[ $methods_wc == 0 ]];then
			methods=$(curl -sI -L -X OPTIONS http://"$host" | grep -i "Access-Control-Allow-Methods:" | awk '{$1=""}1')
			methods_wc=$(echo $methods | wc -w)
		else
			false
		fi
	fi
	

	#final check whether unsecure methods are present
	if [[ $methods_wc == 0 ]];then
		echo "No http methods could be identified"
	else
		found_methods=true
		#read into an array
		IFS="," read -a MethodsArray <<< $methods

		#parse the array for unsecure methods. Definitely an easier way to do but this is fine for now. Adds to a tally
		unsecuremethodcounter=0
		for httpmethod in ${MethodsArray[@]} 
		do
			#new variable because the last element in the array will have ^m. tr -d will remove it.
			no_hidden_chars=$(echo $httpmethod | tr -d '\r')
			if [[ $no_hidden_chars == "PUT" ]];then
				((unsecuremethodcounter=unsecuremethodcounter+1))
			fi
			if [[ $no_hidden_chars == "DELETE" ]];then
				((unsecuremethodcounter=unsecuremethodcounter+1))
			fi
			if [[ $no_hidden_chars == "CONNECT" ]];then
				((unsecuremethodcounter=unsecuremethodcounter+1))
			fi
			if [[ $no_hidden_chars == "TRACE" ]]
			then
				((unsecuremethodcounter=unsecuremethodcounter+1))
			fi
			if [[ $no_hidden_chars == "PATCH" ]];then
				((unsecuremethodcounter=unsecuremethodcounter+1))
			fi
		done
		
		echo "The supported http methods on the host are as follows:" ${MethodsArray[@]}
		if [[ $unsecuremethodcounter != 0 ]];then
			#outputs how many unsecure methods are found
			echo "There are $unsecuremethodcounter unsecure http methods supported by the host"
			echo -e "\nFor more information on http methods please visit developer.mozilla.org/en-US/docs/Web/HTTP/Methods"
		else
			echo "No unsecure http methods discovered"
		fi
	fi
}