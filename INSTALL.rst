How it works
============

Overview
--------

The script is a single file that gets triggered by cron every minute.
It checks /var/log/auth.log for failed login attempts for the past 2 minutes.
If there are 10 or more for any IP, it blocks that IP with iptables for 5
minutes. It unblocks after 5 minutes because right after it blocks, it starts
a new thread whose purpose is to wait 5 minutes and unblock the IP that was
blocked.

Installing the Script
---------------------

To use this script, simply run::

	sudo cp -v ssh_flc /usr/bin/

Now, edit your cron table::

	sudo crontab -e

	NOTE: If you don't know how vi works (the default text editor
	on most systems), try:

		sudo EDITOR=gedit crontab -e
		OR
		sudo EDITOR=pluma crontab -e

and paste this at the end::

	*/1 * * * * /bin/bash -c '/usr/bin/ssh_flc'

Uninstall
---------

To uninstall the script, delete the line you added during script installation
to the cron table::

	sudo crontab -e
	#Delete line that starts with */1 and has
	#the words "ssh_flc" in it

and delete it from /usr/bin/::

	sudo rm -v /usr/bin/ssh_flc

Notes
-----

If you want to remove a blocked entry from iptables early, try::

	ps -Af | grep 'PID\|sleep 300' | grep -v grep

to find the PID of the entry you need (this is easier when there's
only one since there's no way to tell between different ones) and
use the kill command on it::

	sudo kill [PID]

this will kill the sleep command, and make the command that removes
the entry from iptables run right away.

NOTE: If you do this right after the entry gets added to iptables,
it may get added to iptables again a minute later. This will only
happen once. As long as more than one minute has passed since the
entry was added, you should be fine.

NOTE 2: Unless you have some custom scripts that save your iptables
rules when you power off the system, and restore them when you start
up, a simple reboot will clear everyone from the ban list
