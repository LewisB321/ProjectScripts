#! /bin/bash

securitylookup(){
	
	technology=$1
	version_number=$2
	output_file=$3
	curl -so temp_file_api.txt https://services.nvd.nist.gov/rest/json/cves/2.0?keywordSearch=$technology%20$version_number
	results=$(grep -Po '(?<=totalResults":)[0-9]+' temp_file_api.txt)
	echo "Potential vulnerabilities found: "$results >> $output_file
	rm temp_file_api.txt

}