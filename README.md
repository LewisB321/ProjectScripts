# ProjectScripts

CHECKS.SH = MAIN SCRIPT. ONLY USE THIS, OTHERS ARE JUST WHERE THE FUNCTIONS ARE

Flags:


p - Public. yes or https:// 


f - Force. Use this for any public sites because 9/10 times they won't respond to pings


h - Hostname. Can be url or ip. Takes port number as an argument as well i.e. 172.17.0.2:3000


w - Wappaylzer. Uses API of Wappalyzer tool. I have limited calls so be nice


r - Resource(skip). Skips the checks for /resources and /js if you know it's used for other purposes


These flags are no by default so you only have to specify if you want them on


PUBLIC EXAMPLE:
bash checks.sh -h www.twitter.com -p y -f y -w y -r y

PRIVATE EXAMPLE:
bash checks.sh -h localhost

RESOURCE AND JAVASCRIPT FOLDER LOOKUP DOESN'T WORK >:(
At the end you'll be asked if you want to output findings to a text file. Work in progress.
