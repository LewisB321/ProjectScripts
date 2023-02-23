#! /bin/bash


#This function uses the API of https://nvd.nist.gov with keyword parameters to query the database using the software & version number as a base. Will then return
#and output the instances to the main outputted text file

securitylookup_regular(){

	technology=$1
	version_number=$2
	output_file=$3

	if [[ $version_number =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
		segment1="${BASH_REMATCH[1]}"
		segment2="${BASH_REMATCH[2]}"
		segment3="${BASH_REMATCH[3]}"
		search_query=$(grep -m 1 -A 5 "'$technology'.*'$segment1'\.'$segment2'\.'$segment3'" official-cpe-dictionary_v2.3.xml | grep '<cpe-23' | grep -o 'cpe:2\.3:[^"]*')
		echo $serach_query
		#touch temp_file_api.txt
		#curl -so temp_file_api.txt https://services.nvd.nist.gov/rest/json/cves/2.0?$search_query
		#results=$(grep -Po '(?<=totalResults":)[0-9]+' temp_file_api.txt)
		#echo "Potential associated vulnerabilities: "$results >> $output_file
		#rm temp_file_api.txt
	else
		echo "Technology is in an unsuitable format for vulnerability lookup. Apologies" >> $output_file
	fi


}


securitylookup_other(){
	
	technology=$1
	version_number=$2
	output_file=$3
	touch temp_file_api.txt
	curl -so temp_file_api.txt https://services.nvd.nist.gov/rest/json/cves/2.0?keywordSearch=$technology%20$version_number
	results=$(grep -Po '(?<=totalResults":)[0-9]+' temp_file_api.txt)
	echo "Potential associated vulnerabilities: "$results >> $output_file
	rm temp_file_api.txt

}
