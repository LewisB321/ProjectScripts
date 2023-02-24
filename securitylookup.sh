#! /bin/bash


#This function uses the API of https://nvd.nist.gov with the parameter of CpeName. 
#If the CpeName of a component can't be found, a secondary test based on Keyword is made based on the software & version number
#The output is directed towards the outputted file at the end of checks.sh

securitylookup(){

	technology=$1
	version_number=$2
	output_file=$3

	if [[ $version_number =~ ^([0-9]+)\.([0-9])+\.([0-9]+)+$ ]]; then #currently only supports software in a x.y.z version number format
		escaped=$(echo $version_number | sed 's/\./\\./g') #To pipe into the API search I need to escape . characters to be interpreted by grep. Example = 2\.4\.29
		#The below line queries a local instance of the cpe dictionary v2.3, created & updated by nist.gov. This is to grab the relevant CpeName of a software version
		search_query=$(grep -i -m 1 -A 10 "$technology:.*$escaped" official-cpe-dictionary_v2.3.xml | grep '<cpe-23' | grep -o 'cpe:2\.3:[^"]*')
		sq_wc=$(echo $search_query | wc -w)
		if [[ $sq_wc == 0 ]];then #quick wordcount check to ensure that something has been returned. If not, we try _lastresort using them as keywords instead
			securitylookup_lastresort $technology $version_number $output_file
		else
			touch temp_file_api.txt
			curl -so temp_file_api.txt https://services.nvd.nist.gov/rest/json/cves/2.0?cpeName=$search_query #API query
			results=$(grep -Po '(?<=totalResults":)[0-9]+' temp_file_api.txt) #Grepping the useful data from the huge output we receive from the API
			echo "Associated vulnerabilities: "$results >> $output_file #Output the total vulnerability number into the text file
			rm temp_file_api.txt
		fi
	else
		echo "Technology is in an unsuitable format for vulnerability lookup. Apologies" >> $output_file #If not in the x.y.z format
	fi


}


securitylookup_lastresort(){
	
	#This function is a little simpler but follows the same format as the second half of the first. Uses the technology/software in combination with the version number
	#Oftentimes this is not a good solution as there are many false positives involed. It all depends on the package name, i.e. D3, and how often it becomes a substring
	#I would use the ?keywordExactMatch parameter but as of 24/02/23 it doesn't seem to work. Tried on multiple platforms, still nothing
	technology=$1
	version_number=$2
	output_file=$3
	touch temp_file_api.txt
	curl -so temp_file_api.txt https://services.nvd.nist.gov/rest/json/cves/2.0?keywordSearch=$technology%20$version_number
	results=$(grep -Po '(?<=totalResults":)[0-9]+' temp_file_api.txt)
	echo "Potential associated vulnerabilities: "$results  >> $output_file
	rm temp_file_api.txt

}
