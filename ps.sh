#!/bin/bash

proc=$(find /proc/ -maxdepth 1 -name '[0-9]*')
echo "PID TTY STAT" > ps
for i in $proc
do
pid=$(echo $i | awk -F'/' '{print$3}')
tty=`ls -l /proc/${pid}/fd 2>/dev/null| grep -oP 'tty\d|pts\/\d{1,2}' | head -n1`
if ! [ -z $tty ]; then
	tty2=$tty
else
	tty2='?'
fi

if [[ -f /proc/${pid}/stat ]] ; then
	stat2=`cat /proc/${pid}/stat | rev | awk '{printf $50}' | rev`
	time=`cat /proc/${pid}/stat | rev | awk '{print $36" "$37" "$38" "$39}' | rev | awk '{sum=$1+$2+$3+$4}END{print sum/100}' | awk '{("date +%M:%S -d @"$1)| getline $1}1'`
else
	stat2='' 
	time=''

fi
cmd=`cat /proc/$pid/cmdline | strings -1  |  tr -d '\n' | tr -d ' '| head -c 100`
if [ -z $cmd ]; then 
	cmd2=`cat /proc/$pid/status | head -n 1 | awk '{print$2}'`
else
	cmd2=$cmd
fi
echo $pid $tty2 $stat2 $time ${cmd2} >> ps

done

cat ps | column -t 
