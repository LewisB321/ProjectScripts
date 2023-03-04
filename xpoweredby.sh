#! /bin/bash

xpoweredby(){

	#Try to retrieve x-powered-by header information. Conditional statement for public host
	if [[ $publicsite == 'y' ]];then
		Header_Data=$(curl -sI -L https://"$host" | grep -i "x-powered-by" | awk '{$1=""}1')
		asp_extra_check=$(curl -sI -L https://"$host" | grep -i "x-aspnet" | awk '{$1=""}1')
	else
		Header_Data=$(curl -sI -L http://"$host" | grep -i "x-powered-by" | awk '{$1=""}1')
		asp_extra_check=$(curl -sI -L http://"$host" | grep -i "x-aspnet" | awk '{$1=""}1')
	fi

	test_xpb=$(echo $Header_Data | wc -w)
	#Had to trim beginning whitespace in a very awkward way, just wouldn't work with sed, xargs or parameter expansion
	Header_Data=$(echo $Header_Data | tr -s ' ' | cut -d ' ' -f 2-)

	#Variable empty if header not there
	if [[ $test_xpb == 0 ]];then
		echo -e "X-Powered-By header not present"
		return 0
	else
		echo -e "X-Powered-By header present. Attempting to discover technologies\n"
		xpb=true
		#echo $Header_Data
		frameworkcheck
		aspcheck
		phpcheck
		jscheck
	fi
}

	#Sometimes there may be a x-ASPNET(MSV)-version header that we can also look for
aspcheck(){
	#Function for grepping header return for string "ASP.NET"
	asp_check=$(echo $Header_Data | grep -i "ASP.NET")
	asp_check_wc=$(echo $asp_check | wc -w)
	asp_extra_check_wc=$(echo $asp_extra_check | wc -w)
	if [[ $asp_check_wc == 0 ]];then
		echo "ASP.NET undiscovered by header data"
	else
		if [[ $asp_extra_check_wc == 0 ]];then
			echo "ASP.NET discovered on host but no version identified"
			found_asp_no_version_xpb=true
		else
			asp_extra_check="ASP$asp_extra_check"
			echo "ASP.NET discovered version:"$asp_extra_check
			found_asp_xpb=true
		fi
	fi
}

phpcheck(){
	#Function for grepping header return for string "PHP"
	#Had to add regex check for the hashtopolis example to remove the substring about the operating system. Does not affect others
	php_check=$(echo $Header_Data | grep -i "PHP")
	php_check=$(echo $php_check | grep -o "^[^-]*")
	php_check_wc=$(echo $php_check | wc -w)
	if [[ $php_check_wc == 0 ]];then
		echo "PHP undiscovered by header data"
	else
		echo "PHP version discovered on host:"$php_check
		found_php_xpb=true
	fi
}

jscheck(){
	#Function for grepping header return for string for several indications of JS. Could be extended but for proof of concept this is fine
	echo "express" > jschecklist
	echo "node" >> jschecklist
	echo "backbone" >> jschecklist
	echo "vue" >> jschecklist
	echo "angularJS" >> jschecklist
	echo "ember" >> jschecklist
	echo "bootstrap" >> jschecklist
	echo "dojo" >> jschecklist
	echo "requireJS" >> jschecklist
	echo "jquery" >> jschecklist
	echo "react" >> jschecklist
	echo "zope" >> jschecklist
	echo "next" >> jschecklist

	js_check=$(echo $Header_Data | grep -i -f jschecklist)
	js_check_wc=$(echo $js_check | wc -w)
	if [[ $js_check_wc == 0 ]];then
		echo "JavaScript undiscovered by header data"
	else
		echo "JavaScript libraries/frameworks discovered on host: "$js_check
		found_js_xpb=true
	fi
	rm jschecklist
}

frameworkcheck(){
	#Function for grepping header return for framework indication. Big longshot
	echo "wordpress" > frameworkchecklist
	echo "laravel" >> frameworkchecklist
	echo "ruby" >> frameworkchecklist #ruby on rails

	framework_check=$(echo $Header_Data | grep -i -f frameworkchecklist)
	framework_check_wc=$(echo $framework_check | wc -w)
	if [[ $framework_check_wc == 0 ]];then
		echo "Application framework undiscovered by header data"
	else
		echo "Application framework discovered on host:"$framework_check
		found_framework_xpb=true
	fi
	rm frameworkchecklist
}
