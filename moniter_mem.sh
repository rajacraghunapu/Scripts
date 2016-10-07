#!/bin/bash

#Sorting out the processes with Memory usage
#then Awk PID, Memory  AND PROGRAM to a Text file.
ps aux --sort=-%mem | awk 'NR==1{print $2,$4,$11}NR>1{if($4!=0.0) print $2,$4,$11}' >> MeM_Test.txt

#Printing Text file and emailing using Mailx
cat MeM_Test.txt | mailx -s "SUBJECT" "Memory Usage" rajacraghunapu@outlook.com
