#! /bin/bash


#This function uses the API of https://nvd.nist.gov with keyword parameters to query the database using the software & version number as a base. Will then return
#and output the instances to the main outputted text file

securitylookup(){
	
	technology=$1
	version_number=$2
	output_file=$3
	touch temp_file_api.txt
	curl -so temp_file_api.txt https://services.nvd.nist.gov/rest/json/cves/2.0?keywordSearch=$technology%20$version_number
	results=$(grep -Po '(?<=totalResults":)[0-9]+' temp_file_api.txt)
	echo "Potential associated vulnerabilities: "$results >> $output_file
	rm temp_file_api.txt

}
