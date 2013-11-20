#!/bin/bash
#SSH Failed Login Checker

#A file containing a list of logs
#that we've already read
CHECKED_LOGS=/home/test/checked.log

while [[ true ]]
do
	#Figure out how many different source IP addresses failed to login
	#in the past 2 minutes (NOT 120 seconds! - more like in the current minute and the
	#previous minute)
	FAILED_IPs=$(grep --color=auto -i 'sshd' /var/log/auth.log | grep -i 'failed password' | grep --color=auto "$(date +'%b %d %R')\|$(date --date='-1 minute' +'%b %d %R')" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')

	IFS=$'\n'
	for IP in $(echo "$FAILED_IPs" | sort -u)
	do
		#See how many failed logins the IP we are looking at had
		#in the past 2 minutes
		if [[ $(echo "$FAILED_IPs" | grep -c "^${IP}$") -gt 10 ]]
		then
			echo "$IP should be blocked"
		fi
	done

	exit 0
done
