#! /bin/bash

httpmethods(){
	#curl request to grab supported http methods
	methods=$(curl -sI -X OPTIONS 10.0.19.58 | grep "Allow" | awk '{print $2}')

	#testing
	#echo $methods

	#read the new variable into an array
	IFS="," read -a MethodsArray <<< $methods

	#testing
	#echo ${MethodsArray[@]}

	#parse the array for unsecure methods. Definitely an easier way to do this so i'll come back to it later
	unsecuremethodcounter=0
	for httpmethod in ${MethodsArray[@]}; do
		[[ "PUT" == $httpmethod ]] && ((unsecuremethodcounter=unsecuremethodcounter+1))
		[[ "DELETE" == $httpmethod ]] && ((unsecuremethodcounter=unsecuremethodcounter+1))
		[[ "CONNECT" == $httpmethod ]] && ((unsecuremethodcounter=unsecuremethodcounter+1))
		[[ "TRACE" == $httpmethod ]] && ((unsecuremethodcounter=unsecuremethodcounter+1))
		[[ "PATCH" == $httpmethod ]] && ((unsecuremethodcounter=unsecuremethodcounter+1))
	done

	echo -e "\nThe supported http methods on the host are as follows:" ${MethodsArray[@]}

	#final check whether unsecure methods are present
	if [[ $unsecuremethodcounter != 0 ]]
	then
		echo "There are $unsecuremethodcounter unsecure http methods supported by the host"
		echo -e "\nFor more information on http methods please visit developer.mozilla.org/en-US/docs/Web/HTTP/Methods" #will add more info later
	else
		echo "No unsecure http methods discovered"
	fi
}