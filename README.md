# ProjectScripts

Working on re-organising the tool to implement an actual name. Prior to running please unzip the cpe dictionary, it's absolutely necessary in order to run the vulnerability lookups

CHECKS.SH = main script. Please use this as the other scripts are just areas for functions

Flags:

s - Secure. Will try http if secure is set to no, yes means https


h - Hostname. Can be url or ip. Takes port number as an argument as well i.e. 172.17.0.2:3000


w - Wappaylzer. Uses API of Wappalyzer tool. I have limited calls so be nice. MUST BE AN EXTERNAL FACING HOST


r - Resource(skip). Skips the checks for /resources and /js if you know it's used for other purposes


p - PHP(skip). Skips the checks for phpinfo.php and /phpmyadmin if you know the host isn't using PHP


Flags are set to no by default


PUBLIC EXAMPLE:
bash checks.sh -h gigabyte.com -s y -w y -r n -p n


bash checks.sh -h httpbin.org -s y -w y -r y -p y


PRIVATE EXAMPLE:
bash checks.sh -h localhost


At the end you'll be asked if you want to output findings to a text file, placed inside it's own unique folder. If yes, you'll get all of the collated information alongside a brief vulnerability lookup using the following API: https://services.nvd.nist.gov/rest/json/cves/2.0. The vulnerability checks only run on an outputted text file. Semi-cleaned Wappalyzer findings are also provided to see what the tool has returned incase it's not reflected well inside the main text file.
