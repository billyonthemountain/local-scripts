#/bin/sh

# if less than two arguments supplied, display usage 
if [  $# -le 0 ] 
then 
	echo -e "\nUsage:\n$0 [username] \n"
	exit 1
fi

echo Looking up membership for user "$1"

USER_SID=`wbinfo -n $1 | cut -d' ' -f0`
GROUPS_SIDS=$(wbinfo --user-domgroups=${USER_SID})

for i in ${GROUPS_SIDS}
do
    GID=$(wbinfo --sid-to-gid=$i 2>/dev/null)
    if [ -n GID ]; then
    	wbinfo --gid-info=${GID} 2>/dev/null | cut -d: -f0 
    	#wbinfo --gid-info=${GID} 2>/dev/null 
   	fi
done
