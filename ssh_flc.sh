#!/bin/bash
#SSH Failed Login Checker

#Only run if user is root
uid=$(/usr/bin/id -u) && [ "$uid" = "0" ] ||
{ echo "You must be root to run $0. Try again with the command 'sudo $0'" | fmt -w `tput cols`; exit 1; }

#Figure out how many different source IP addresses failed to login
#in the past 2 minutes
FAILED_IPs=$(TEST=$(date -d "now-2minutes" +"%b %d %R:%S"); IFS=$'\n'; grep -i 'sshd' /var/log/auth.log | grep -i 'failed password' | for LINE in $(cat /dev/stdin); do if [[ $LINE > $TEST ]]; then echo $LINE; fi; done | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')

IFS=$'\n'
for IP in $(echo "$FAILED_IPs" | sort -u)
do
	#See how many failed logins the IP we are looking at had
	#in the past 2 minutes
	if [[ $(echo "$FAILED_IPs" | grep -c "^${IP}$") -ge 10 ]]
	then
		#$IP has made over 10 failed attempts to login in the past 10 minutes

		#Make sure $IP is not already blocked by iptables
		if ! iptables -nL INPUT | grep "[^0-9]$IP[^0-9]" | grep -q REJECT
		then
			iptables -A INPUT -s $IP -p tcp --dport 22 -j REJECT

			#Start a new thread that will unblock the IP after x seconds
			( sleep 300; iptables -D INPUT -s $IP -p tcp --dport 22 -j REJECT ) & 
		fi
	fi
done

exit 0
