#! /bin/bash

echo_results() {
	
	#This function will only be called by the below function and not in the main script
	grade=$(echo $full_list | grep -w "least strength" | awk '{print $4}')
	echo -e "\nThe encryption strength of the remote host is:" $grade
	echo "This grade represents the security strength of the weakest cipher algorithm in all available cipher suites"
	echo "The grading system used is extracted from the SSL Labs Server Rating Guide, available at https://www.ssllabs.com/projects/rating-guide"
	echo -e "For a full list of returned output, Please refer to the outputted text file\n"	
	echo $full_list > https-encryption-summary.txt

	#couldn't work out a working method to iterate this
	A_count=$(echo $full_list | grep '\sA' | wc -l)
	B_count=$(echo $full_list | grep '\sB' | wc -l)
	C_count=$(echo $full_list | grep '\sC' | wc -l)
	D_count=$(echo $full_list | grep '\sD' | wc -l)
	E_count=$(echo $full_list | grep '\sE' | wc -l)
	#F_count=$(echo $full_list | grep '\sF' | wc -l)
	
	#setting up 2 arrays for the next nested loop
	grade_array=('A' 'B' 'C' 'D' 'E')
	count_array=($A_count $B_count $C_count $D_count $E_count)
	len1=${#grade_array[@]}
	len2=${#count_array[@]}

	#this awkward bit of syntax will iterate through both arrays (I know they're the same length) and then
	#provide an output as to how many instances each algorithm grade has
	#doesn't show E probably due to misconfigurations but i'm fine with that
	for ((i=1;i<$len1;i++))
	do
		for ((j=1;j<$len2;j++))
		do
			if [ $i -eq $j ]
			then
				echo "Remote host has" $count_array[j] "instances of" $grade_array[i] "grade cipher(s)"
			fi
		done
	done

}


enum_ciphers(){
	
	#This test will use nmap to determine the encryption algorithms used on the remote host
	full_list=$(nmap --script ssl-enum-ciphers -p 443 $host)
	echo $full_list

	#to catch the failed to resolve hostname error if nmap can't understand the hostname
	failed_to_resolve=$(echo $full_list | grep -w "0 IP addresses")
	#wordcount will be 0 if error is not present
	failed_to_resolve_wc=$(echo $failed_to_resolve | wc -w)


	#to catch the failure of nmap probing the remote host
	host_is_down=$(echo $full_list | grep -w "Note: Host seems down")
	#wordcount will be 0 if error is not present
	host_is_down_wc=$(echo $host_is_down | wc -w)
	

	#condition if the hostname is invalid and the ciphers cannot be read
	if [[ $failed_to_resolve_wc != 0 ]]
	then
		echo "Hostname invalid. Please check again & ensure that host is online"
		#return 0 will end prematurely and ensure that the the function is exited before the next check takes place
		return 0
	else
		#this stays doing nothing since a valid host will be here and trigger echo_results twice if I place it
		#here too
		false
	fi	

	#the below code will make a curl request to see if host responds to https requests. Will be empty
	#if https is unavailable, meaning the ciphersuite analysis will be bypassed
	#could do this using openssl -connect but this achieves the same goal
	httpscheck=$(curl -s https://$host)
	httpscheck_wc=$(echo $httpscheck | wc -w)

	#enum_ciphers isn't playing nice within the main script. Must fix!!!!
	if [[ $httpscheck_wc == 0 ]]
	then
		echo "Host is unsuitable for ciphersuite analysis (cannot be contacted on port 443)"
		return 0
	else
		echo "Host is suitable for ciphersuite analysis"
	fi

	#condition if the hostname is valid but host is blocking the nmap probe. Will activitae an internal flag
	#so that the function will try the second method of enumerating ciphersuites
	#else statement here is different as it calls the first function to output important info
	if [[ $host_is_down_wc != 0 ]]
	then
		echo "Host doesn't seem to be responding to an attempt to enumerate ciphersuite. Please attempt to manually validate and try again"
		return 0
	else
		#echo $full_list
		echo_results
	fi

}