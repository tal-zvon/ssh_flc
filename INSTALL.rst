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
