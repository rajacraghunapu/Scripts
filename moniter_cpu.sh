#!/bin/bash

#Sorting out the processes with CPU usage
#then Awk PID, CPU AND PROGRAM to a Text file.
ps aux --sort=-%cpu | awk 'NR==1{print $2,$3,$11}NR>1{if($3!=0.0) print $2,$3,$11}' >> Test.tx

#Printing Text file and emailing using Mailx
cat Test.txt | mailx -r "rcraja82@gmail.com" -s "SUBJECT" "CPU Usage"
