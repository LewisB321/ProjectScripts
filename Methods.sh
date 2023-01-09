#! /bin/bash



#CURL request to the host for HTTP Methods
curl -X OPTIONS 10.0.19.58 -i -s > temp.txt

Methods=$(grep 'Allow' temp.txt -i)

#echo "$Methods" | sed 's/Allow: //'

Methods2=$(echo "$Methods" | sed 's/Allow: //')

#echo $Methods2

IFS="," read -a MethodsArray <<< $Methods2

#echo ${MethodsArray[@]}

unsecuremethodcounter=0
for httpmethod in ${MethodsArray[@]}; do
	[[ "PUT" == $httpmethod ]] && ((unsecuremethodcounter=unsecuremethodcounter+1))
	[[ "DELETE" == $httpmethod ]] && ((unsecuremethodcounter=unsecuremethodcounter+1))
	[[ "CONNECT" == $httpmethod ]] && ((unsecuremethodcounter=unsecuremethodcounter+1))
	[[ "TRACE" == $httpmethod ]] && ((unsecuremethodcounter=unsecuremethodcounter+1))
	[[ "PATCH" == $httpmethod ]] && ((unsecuremethodcounter=unsecuremethodcounter+1))
done

if [[ $unsecuremethodcounter != 0 ]]
then
	echo "There are $unsecuremethodcounter unsecure http methods supported by the host"
else
	echo "No unsecure http methods found on the host"
fi