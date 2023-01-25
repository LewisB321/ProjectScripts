#! /bin/bash

xpoweredby(){

	#Try to retrieve x-powered-by header information. Conditional statement for whether https should be tried
	if [[ $publicsite == 'y' ]]
	then
		Header_Data=$(curl -sI https://"$host" | grep -i "x-powered-by" | awk '{$1=""}1')
	else
		Header_Data=$(curl -sI http://"$host" | grep -i "x-powered-by" | awk '{$1=""}1')
	fi
	#use to store the wordcount
	test_xpb=$(echo $Header_Data | wc -w)
	#echo $Header_Data

	#variable won't be empty if the header was retrieved
	if [[ $test_xpb == 0 ]]
	then
		echo -e "\nX-Powered-By header not present"
	else
		echo -e "\nX-Powered-By header present"
		#echo $Header_Data
		aspcheck
		phpcheck
		jscheck
	fi
}

aspcheck(){
	#function for grepping header return for string "ASP.NET"
	asp_check=$(echo $Header_Data | grep -i "ASP.NET")
	asp_check_wc=$(echo $asp_check | wc -w)
	if [[ $asp_check_wc == 0 ]]
	then
		echo "ASP.NET undiscovered by xpb header"
	else
		echo "ASP.NET discovered on host"
		found_asp=true
	fi
}

phpcheck(){
	#function for grepping header return for string "PHP"
	php_check=$(echo $Header_Data | grep -i "PHP")
	php_check_wc=$(echo $php_check | wc -w)
	if [[ $php_check_wc == 0 ]]
	then
		echo "PHP undiscovered by xpb header"
	else
		echo "PHP version discovered on host:"$php_check
		found_php=true
	fi
}

jscheck(){
	#function for grepping header return for string for several indications of JS
	echo "Express" > jschecklist
	echo "Node.js" >> jschecklist
	echo "AngularJS" >> jschecklist

	js_check=$(echo $Header_Data | grep -i -f jschecklist)
	js_check_wc=$(echo $js_check | wc -w)
	if [[ $js_check_wc == 0 ]]
	then
		echo "JavaScript undiscovered by xpb header"
	else
		echo "JavaScript libraries/frameworks discovered on host:"$js_check
		found_js=true
	fi
}
