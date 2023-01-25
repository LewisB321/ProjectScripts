# ProjectScripts

CHECKS.SH = MAIN SCRIPT. ONLY USE THIS, OTHERS ARE JUST WHERE THE FUNCTIONS ARE

Flags:
p - for public sites. Will add https:// by default when running some of the tests. For now i've disabled the API lookup because it's gonna ruin my free usage
f - force. Use this for any public sites because 9/10 times they won't respond to pings
h - hostname. Can be url or just ip

by default p & f will be set to no. If you wanna enable them, do -p y or -f y

PUBLIC EXAMPLE:
bash checks.sh -h www.twitter.com -p y -f y

PRIVATE EXAMPLE:
bash checks.sh -h localhost

TEST1 - WEB SERVER VERSION. Works but fairly useless unless target is Apache, won't advertise version number


TEST2 - HTTP METHODS. Works but again fairly useless since 99% of the time they will be safe


TEST3 - MULTIPLE SUBTESTS FOR JS/PHP. Still a work in progress, especially making the output useful


TEST4 - ENCRYPTION. Still doesn't play nice in the main script so you'll have to run it individually :-(

TWITTER IS AN ASSHOLE SITE SO IT OMITS WWW OR THE TESTS DON'T WORK >:(
