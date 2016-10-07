#!/bin/bash

find="/usr/bin/find"
xargs="/usr/bin/xargs"
tail="/usr/bin/tail"
awk="/usr/bin/awk"
cut="/usr/bin/cut"
wc="/usr/bin/wc"

PROGNAME=`/usr/bin/basename $0`

# Exit codes
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4

print_usage() {
    echo "Usage: $PROGNAME -d <path> -w <warn> -c <crit>"
}

# Make sure the correct number of command line
# arguments have been supplied

if [ $# -lt 1 ]; then
    print_usage
    exit $STATE_UNKNOWN
fi

# Grab the command line arguments

thresh_warn=""
thresh_crit=""
exitstatus=$STATE_WARNING #default
while test -n "$1"; do
    case "$1" in
        --dirname)
            dirpath=$2
            shift
            ;;
        -d)
            dirpath=$2
            shift
            ;;
        --warning)
            thresh_warn=$2
            shift
            ;;
        -w)
            thresh_warn=$2
            shift
            ;;
        --critical)
            thresh_crit=$2
            shift
            ;;
        -c)
            thresh_crit=$2
            shift
            ;;
        *)
            echo "Unknown argument: $1"
            print_usage
            exit $STATE_UNKNOWN
            ;;
    esac
    shift
done

##### Get size of specified directory

error=""
statresult=`$find $dirpath -maxdepth 1 -type f | $wc -l |$tail -1`
dirsize=`echo $statresult`
result="ok"
exitstatus=$STATE_OK

##### Compare with thresholds

if [ "$thresh_warn" != "" ]; then
    if [ $dirsize -ge $thresh_warn ]; then
        result="warning"
        exitstatus=$STATE_WARNING
    fi
fi
if [ "$thresh_crit" != "" ]; then
    if [ $dirsize -ge $thresh_crit ]; then
        result="critical"
        exitstatus=$STATE_CRITICAL
    fi
fi

echo "$dirsize Files - $result"
exit $exitstatus

