#! /bin/bash


#This function uses the API of https://nvd.nist.gov with keyword parameters to query the database using the software & version number as a base. Will then return
#and output the instances to the main outputted text file

securitylookup_regular(){

	technology=$1
	version_number=$2
	output_file=$3

	if [[ $version_number =~ ^([0-9]+)\.([0-9])+\.([0-9]+)+$ ]]; then
		escaped=$(echo $version_number | sed 's/\./\\./g')
		search_query=$(grep -m 1 -A 10 "$technology:.*$escaped" official-cpe-dictionary_v2.3.xml | grep '<cpe-23' | grep -o 'cpe:2\.3:[^"]*')
		sq_wc=$(echo $search_query | wc -w)
		if [[ $sq_wc == 0 ]];then
			securitylookup_other $technology $version_number $output_file
		else
			touch temp_file_api.txt
			curl -so temp_file_api.txt https://services.nvd.nist.gov/rest/json/cves/2.0?cpeName=$search_query
			results=$(grep -Po '(?<=totalResults":)[0-9]+' temp_file_api.txt)
			echo "Associated vulnerabilities: "$results >> $output_file
			rm temp_file_api.txt
		fi
	else
		echo "Technology is in an unsuitable format for vulnerability lookup. Apologies"
	fi


}


securitylookup_other(){
	
	technology=$1
	version_number=$2
	output_file=$3
	touch temp_file_api.txt
	curl -so temp_file_api.txt https://services.nvd.nist.gov/rest/json/cves/2.0?keywordSearch=$technology%20$version_number
	results=$(grep -Po '(?<=totalResults":)[0-9]+' temp_file_api.txt)
	echo "Potential associated vulnerabilities: "$results  >> $output_file
	rm temp_file_api.txt

}
