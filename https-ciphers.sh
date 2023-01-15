#! /bin/bash

echo_results() {
	
	grade=$(echo $full_list | grep -w "least strength" | awk '{print $4}')
	echo -e "\nThe encryption strength of the remote host is: " $grade
	echo "This grade represents the security strength of the weakest cipher algorithm in all available cipher suites"
	echo "For a full list of returned output, PLACEHOLDER"	

}
enum_ciphers(){
	
	#This test will use a combination of sslclient & nmap to determine the encryption algorithms used on the remote host

	full_list=$(nmap --script ssl-enum-ciphers -p 443 $host)
	#echo $full_list

	#to catch the failed to resolve hostname error if nmap can't understand the hostname
	failed_to_resolve=$(echo $full_list | grep -w "0 IP addresses")
	#wordcount will be 0 if error is not present
	failed_to_resolve_wc=$(echo $failed_to_resolve | wc -w)


	#to catch the failure of nmap probing the remote host
	host_is_down=$(echo $full_list | grep -w "Note: Host seems down")
	#wordcount will be 0 if error is is present
	host_is_down_wc=$(echo $host_is_down | wc -w)
	

	#condition if the hostname is invalid and the ciphers cannot be read
	if [[ $failed_to_resolve_wc != 0 ]]
	then
		echo "Hostname invalid. Please check again & ensure that host is online"
	else
		false
	fi	

	#condition if the hostname is valid but host is blocking the nmap probe. Will activitae an internal flag
	#so that the function will try the second method of enumerating ciphersuites
	#else statement here is different as it calls the first function to output important info
	if [[ $host_is_down_wc != 0 ]]
	then
		echo "Method 1 for cipher enumeration failed. Switching to method 2"
		try_second_method=true
	else
		echo_results
	fi

	#echo $full_list

	if [[ $try_second_method == true ]]
	then
		echo "trying second method to return encryption methods"
	else
		false
	fi

}