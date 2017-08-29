#!/bin/sh

# This script updates the quotas for each user in the selected AD groups

# refence: http://www.synology-forum.de/showthread.html?53918-Quota-f%FCr-1000-Dom%E4nen-Benutzer
#---updateQuots.sh---
# csv=/volume2/homes/admin/scripts/userQuotas.csv
# export IFS=";"
# cat $csv | while read a b; do echo setquota -u "$a" $b $b 0 0 -a /dev/md3
# done
#---userQuotas.csv---
# DOMAIN\\Benutzer1;102400
# DOMAIN\\Benutzer2;102400
#---


GROUPS="myunit1 myunit2" # AD groups
USER_QUOTA="200" # in GigaBytes


HOME_VOL=$(find / -type d -name homes -maxdepth 2 | cut -d/ -f2)
HOME_DEVICE=$(cat /etc/mtab | grep $HOME_VOL | cut -d' ' -f1)
KB_QUOTA=$((${USER_QUOTA} * 1048576))

for g in $GROUPS
do
	echo "Retrieving $g group members..."
	wbinfo --group-info="INTRANET\\$g" 2>/dev/null | cut -d: -f4- | sed 's|,|\n|g' > $g.users
	cat $g.users | \
		while read -r a; do 
			echo "Updating quota for user $a ...";
			setquota -u "$a" $KB_QUOTA $KB_QUOTA 0 0 $HOME_DEVICE
		done
done
rm $g.users
