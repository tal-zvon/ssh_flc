#!/bin/bash

#A file containing a list of logs
#that we've already read
CHECKED_LOGS=/home/test/checked.log

#If the $CHECKED_LOGS file exists, check if it has any records from the previous 2 minutes
if [[ -e ${CHECKED_LOGS} ]]
then
	#If there are no logs from the previous 2 minutes, delete the file
	if ! cat ${CHECKED_LOGS} | grep -q "$(date +'%b %d %R')\|$(date --date='-1 minute' +'%b %d %R')"
	then
		rm -f ${CHECKED_LOGS}
	fi
fi

while [[ true ]]
do
	#Looks at current month, day, hour, and minute, and finds logs from current minute, and the minute before that
	#Ex: If it's Nov 19, 9:29:56, it will find all logs made on:
	  #Nov 19, 9:28:xx and Nov 19, 9:29:xx
	SSH_LOGS=$(grep --color=auto -i 'sshd' /var/log/auth.log | grep -i 'failed password' | grep --color=auto "$(date +'%b %d %R')\|$(date --date='-1 minute' +'%b %d %R')")

	#If the $CHECKED_LOGS file exists, ignore all the logs
	#that are in that file
	if [[ -e ${CHECKED_LOGS} ]]
	then
		UNREAD_SSH_LOGS="$(echo "$SSH_LOGS" | grep -v -f ${CHECKED_LOGS})"
	else
		UNREAD_SSH_LOGS="$SSH_LOGS"
	fi

	IFS=$'\n'
	for LOG_ENTRY in $UNREAD_SSH_LOGS
	do
		#echo $LOG_ENTRY
		#Check if IP address of current entry shows up more than 10 times
		#this would indicate that in the past 1-2 minutes, someone tried to login
		#to SSH and failed over 10 times
		SOURCE_IP=$(echo $LOG_ENTRY | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
		echo $SOURCE_IP

		#Now count up how many times SOURCE_IP shows up in $UNREAD_SSH_LOGS
		#If 10 or more, email root@localhost, and add to iptables ban list for 5 minutes
			#See if I can do this buy starting a new, disowned thread that just says (sleep 300 && #remove from iptables)

		if [[ $(echo "${UNREAD_SSH_LOGS}" | grep -c $SOURCE_IP) -gt 10 ]]
		then
			echo $SOURCE_IP being banned
		fi

		#Only mark log entry as read if it's older than 2 minutes
		#echo "$LOG_ENTRY" | sed 's/\[/\\[/g' | sed 's/\]/\\]/g' >> ${CHECKED_LOGS}
		if ! echo "$LOG_ENTRY" | grep -q "$(date +'%b %d %R')\|$(date --date='-1 minute' +'%b %d %R')"
		then
			echo "$LOG_ENTRY" | sed 's/\[/\\[/g' | sed 's/\]/\\]/g' >> ${CHECKED_LOGS}
		fi
	done

	#Test every 30 seconds
	sleep 30
done
