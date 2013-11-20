#!/bin/bash
#SSH Failed Login Checker

#A file containing a list of logs
#that we've already read
CHECKED_LOGS=/home/test/checked.log

#Figure out how many different source IP addresses failed to login
#in the past 2 minutes (NOT 120 seconds! - more like in the current minute and the
#previous minute)
FAILED_IPs=$(grep --color=auto -i 'sshd' /var/log/auth.log | grep -i 'failed password' | grep --color=auto "$(date +'%b %d %R')\|$(date --date='-1 minute' +'%b %d %R')" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')

IFS=$'\n'
for IP in $(echo "$FAILED_IPs" | sort -u)
do
	#See how many failed logins the IP we are looking at had
	#in the past 2 minutes
	if [[ $(echo "$FAILED_IPs" | grep -c "^${IP}$") -ge 10 ]]
	then
		#$IP has made over 10 failed attempts to login in the past 10 minutes

		#Make sure $IP is not already blocked by iptables
		if ! iptables -nL INPUT | grep "$IP[^0-9]" | grep -q REJECT
		then
			iptables -A INPUT -s $IP -p tcp --dport 22 -j REJECT

			#Start a new thread that will unblock the IP after x seconds
			( sleep 300; iptables -D INPUT -s $IP -p tcp --dport 22 -j REJECT ) & 
		fi
	fi
done

exit 0
