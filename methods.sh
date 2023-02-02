#! /bin/bash

httpmethods(){

	#curl request to grab supported http methods
	if [[ $publicsite == "y" ]]
	then
		methods=$(curl -sI -L -X OPTIONS https://$host | grep -i "Allow:" |awk '{$1=""}1')
	else
		methods=$(curl -sI -L -X OPTIONS http://$host | grep -i "Allow:" |awk '{$1=""}1')
	fi
	methods_wc=$(echo $methods | wc -w)


	#read into an array
	IFS="," read -a MethodsArray <<< $methods

	#parse the array for unsecure methods. Definitely an easier way to do but this is fine for now. Adds to a tally
	unsecuremethodcounter=0
	for httpmethod in ${MethodsArray[@]} 
	do
		#new variable because the last element in the array will have ^m. tr -d will remove it.
		no_hidden_chars=$(echo $httpmethod | tr -d '\r')
		if [[ $no_hidden_chars == "PUT" ]]
		then
			((unsecuremethodcounter=unsecuremethodcounter+1))
		fi
		if [[ $no_hidden_chars == "DELETE" ]]
		then
			((unsecuremethodcounter=unsecuremethodcounter+1))
		fi
		if [[ $no_hidden_chars == "CONNECT" ]]
		then
			((unsecuremethodcounter=unsecuremethodcounter+1))
		fi
		if [[ $no_hidden_chars == "TRACE" ]]
		then
			((unsecuremethodcounter=unsecuremethodcounter+1))
		fi
		if [[ $no_hidden_chars == "PATCH" ]]
		then
			((unsecuremethodcounter=unsecuremethodcounter+1))
		fi
	done

	

	#final check whether unsecure methods are present
	if [[ $methods_wc == 0 ]]
	then
		echo "No http methods could be identified"
	else
		echo -e "\nThe supported http methods on the host are as follows:" ${MethodsArray[@]}
		if [[ $unsecuremethodcounter != 0 ]]
		then
			#outputs how many unsecure methods are found
			echo "There are $unsecuremethodcounter unsecure http methods supported by the host"
			echo -e "\nFor more information on http methods please visit developer.mozilla.org/en-US/docs/Web/HTTP/Methods to learn more"
		else
			echo "No unsecure http methods discovered"
		fi
	fi
}