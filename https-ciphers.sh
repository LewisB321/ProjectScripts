#! /bin/bash

enum_ciphers(){
	
	#Will use nmap to determine the encryption algorithms used on host
	nmap --script ssl-enum-ciphers -p 443 -oN nmapoutput.txt $host >/dev/null

	#To catch the failed to resolve hostname error if nmap can't understand the hostname
	failed_to_resolve=$(cat nmapoutput.txt | grep -w "0 IP addresses")
	#Wordcount will be 0 if error is not present
	failed_to_resolve_wc=$(echo $failed_to_resolve | wc -w)


	#To catch the failure of nmap probing the remote host
	host_is_down=$(cat nmapoutput.txt | grep -w "Note: Host seems down")
	#Wordcount will be 0 if error is not present
	host_is_down_wc=$(echo $host_is_down | wc -w)
	

	#Condition if the hostname is invalid and the ciphers cannot be read
	if [[ $failed_to_resolve_wc != 0 ]];then
		echo "Hostname invalid. Skipping this test"
		return 0
	else
		#this stays doing nothing since a valid host will be here and trigger echo_results twice if I place it here as well
		false
	fi	

	#condition if the hostname is valid but host is blocking the nmap probe. Will activitae an internal flag
	#so that the function will try the second method of enumerating ciphersuites
	#else statement here is different as it calls the first function to output important info
	if [[ $host_is_down_wc != 0 ]];then
		echo "Host doesn't seem to be responding to an attempt to enumerate ciphersuite. Skipping this test"
		return 0
	else
		ciphers_found=true
		echo_results
	fi

}

echo_results() {
	
	#This function will only be called internally
	#It will take the cipher with the least strength and output it as the overall grade. Not the best way to grade but it'll do 
	grade=$(cat nmapoutput.txt | grep -w "least strength" | awk '{print $4}')
	echo -e "\nThe encryption strength of the remote host is:" $grade
	echo "This grade represents the security strength of the weakest cipher algorithm in all available cipher suites"
	echo "The grading system used is extracted from the SSL Labs Server Rating Guide, available at https://www.ssllabs.com/projects/rating-guide"
	echo -e "For a full list of returned output, Please refer to "$host"_Cipher_Analysis.txt\n"	

	#Could've maybe iterated but I tried and couldn't get it to work unless hardcoded
	A_count=$(cat nmapoutput.txt | grep '\sA' | wc -l)
	B_count=$(cat nmapoutput.txt | grep '\sB' | wc -l)
	C_count=$(cat nmapoutput.txt | grep '\sC' | wc -l)
	D_count=$(cat nmapoutput.txt | grep '\sD' | wc -l)
	E_count=$(cat nmapoutput.txt | grep '\sE' | wc -l)
	F_count=$(cat nmapoutput.txt | grep '\sF\s' | wc -l) #Have to explictly do this otherwise it picks up 'Friday'
	
	#setting up 2 arrays for the next nested loop
	grade_array=('A' 'B' 'C' 'D' 'E' 'F')
	count_array=($A_count $B_count $C_count $D_count $E_count $F_count)
	len1=${#grade_array[@]}
	len2=${#count_array[@]}

	#this awkward bit of syntax will iterate through both arrays and then
	#provide an output as to how many instances each algorithm grade has
	for ((i=0;i<=$len1;i++))
	do
		for ((j=0;j<$len2;j++))
		do
			if [ $i -eq $j ];then
				echo "Remote host has" ${count_array[j]} "instances of" ${grade_array[i]} "grade cipher(s)"
			fi
		done
	done

	cipher_file_name=$host"_Cipher_Analysis.txt" #Setting up a seperate timestamped text file just with the nmap results
	cat nmapoutput.txt > $cipher_file_name
	rm nmapoutput.txt

}
