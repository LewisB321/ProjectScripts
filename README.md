# ProjectScripts

CHECKS.SH = MAIN SCRIPT. ONLY USE THIS, OTHERS ARE JUST WHERE THE FUNCTIONS ARE

Flags:


s - Secure (https)

h - Hostname. Can be url or ip. Takes port number as an argument as well i.e. 172.17.0.2:3000


w - Wappaylzer. Uses API of Wappalyzer tool. I have limited calls so be nice. MUST BE AN EXTERNAL FACING HOST


r - Resource(skip). Skips the checks for /resources and /js if you know it's used for other purposes


p - PHP(skip). Skips the checks for phpinfo.php and /phpmyadmin if you know the host isn't using PHP


These flags are no by default so you only have to specify if you want them on (Y)


PUBLIC EXAMPLE:
bash checks.sh -h gigabyte.com -s y -w y -r n -p n

PRIVATE EXAMPLE:
bash checks.sh -h localhost

At the end you'll be asked if you want to output findings to a text file. If yes, you'll get all of the collated information alongside a brief vulnerability lookup using the following API: https://services.nvd.nist.gov/rest/json/cves/2.0
