#!/bin/bash

# Exit codes
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

PROGNAME=`/usr/bin/basename $0`

print_usage() {
   echo "Usage: $PROGNAME  -w <warn> -c <crit>"
}

# Make sure the correct number of command line
# arguments have been supplied

if [[ $# -lt 1 ]]; then
   print_usage
   exit $STATE_UNKNOWN
fi

# Grab the command line arguments

time_period=""
thresh_warn=""
thresh_crit=""
exitstatus=$STATE_OK
while test -n "$1"; do
    case "$1" in
        --time)
          time_period=$2
          shift;;
        -t)
          time_period=$2
          shift;;
        --warning)
          thresh_warn=$2
          shift;;
        -w)
          thresh_warn=$2
          shift;;
        --critical)
          thresh_crit=$2
          shift;;
        -c)
          thresh_crit=$2
          shift;;
        *)
         echo "Unknown argument: $1"
        print_usage
        exit $STATE_UNKNOWN;;
   esac
   shift
 done

#Get the time stamps

d1=$(date --date="-$time_period secs" "+%b %_d %H:%M")
d2=$(date "+%b %_d %H:%M")

rm -f beelzebub_temp1
rm -f beelzebub_temp2

#Select lines on time stamps, extract the required fields(txn number, time stamp, status)
#and sort the lines on transaction number
while read line; do
    [[ $line > $d1 && $line < $d2 || $line =~ $d2 ]] && echo $line |grep "beelzebub"| awk -F" " '{print $7 , $1, $2 ,$3,$8}' >>beelzebub_temp1
done < /var/log/syslog

sort -n beelzebub_temp1 > beelzebub_temp2

prev_id=0
prev_id_secs=0
time=0
count=0
while read txn
do
  fields=($txn)
  id=${fields[0]}
  status=${fields[4]}
  timestamp=${fields[3]}
  declare -i seconds
  seconds=`echo $timestamp | awk -F: '{ print $1*3600+$2*60+$3}'`
  if [[ $prev_id -eq $id ]]
    then
     elapsed=$(($seconds - $prev_id_seconds))
     time=$(($time + $elapsed))
     count=$(($count + 1))
  fi
  prev_id=$id
  prev_id_seconds=$seconds
done < beelzebub_temp2

avg=$(($time / $count))
exitstatus=$STATE_OK
echo "Average time it took is $avg seconds"

##### Compare with thresholds

warning=$thresh_warn
critial=$thresh_crit

if [[ "$avg" -ge  "$warning" && "$avg" -lt "$critial" ]]; then
   echo "$avg seconds - STATE Warning"
   exitstatus=$STATE_WARNING
elif [[ "$avg" -ge "$critial" ]]; then
   echo "$avg seconds - STATE Critical"
   exitstatus=$STATE_CRITICAL
else
   echo "STATE OK"
   exitstatus=$STATE_OK
fi

exit $exitstatus
