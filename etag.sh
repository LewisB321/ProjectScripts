#! /bin/bash

etag_check(){

	has_etag=false


	#simple check for presence of eTag header
	if [[ $publicsite == 'y' ]]
	then
	header_contents=$(curl -sI -L https://"$host" | grep -i "eTag")
	else
	header_contents=$(curl -sI -L http://"$host" | grep -i "eTag")
	fi

	etag_present=$(echo $header_contents | grep -i "eTag" | wc -w)
	if [[ $etag_present == 0 ]]
	then
		echo "eTag header not present"
	else
		echo "eTag header present"
		echo "Unless necessary, it's usually a good idea to remove this header"
		echo "More information is available at your vendor's website"
		has_etag=true
	fi

}
