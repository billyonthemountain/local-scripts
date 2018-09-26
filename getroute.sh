#!/usr/bin/env bash

# Test an IP address for validity:
# Usage:
#      valid_ip IP_ADDRESS
#      if [[ $? -eq 0 ]]; then echo good; else echo bad; fi
#   OR
#      if valid_ip IP_ADDRESS; then echo good; else echo bad; fi
#
# https://www.linuxjournal.com/content/validating-ip-address-bash-script
#
function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }

if ! valid_ip $1; then
	ip=$(host $1 | grep address | cut -d' ' -f4)
else
	ip=$1
fi

[[ -z $ip ]] && die "Unvalid ip address or unreachable hostname"

iface=$(ip -o route get $ip | perl -nle 'if ( /dev\s+(\S+)/ ) {print $1}')

printf "$ip will be accessed using the $iface interface\n\n"
printf "The routes that have been evaluated are (lowest metric is preferred):\n"
ip route show to match $ip
