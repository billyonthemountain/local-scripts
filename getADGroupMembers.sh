#/bin/sh

# This script retrieves the members of a given group of the AD

# if less than two arguments supplied, display usage 
if [  $# -le 0 ] 
then 
	echo -e "\nUsage:\n$0 [group] \n"
	exit 1
fi

echo Looking up Members of group "$1"

wbinfo --group-info=$1 2>/dev/null | cut -d: -f4-

echo -e "\n"
