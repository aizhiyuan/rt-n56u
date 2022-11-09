#!/bin/bash

aton()
{
    echo $1|gawk '{c=256;split($0,ip,".");print ip[4]+ip[3]*c+ip[2]*c^2+ip[1]*c^3}'
}

D2B()
{
        num="$1"
        d2b=`echo "obase=2;$num" | bc`
        echo $d2b
}

is_valid_ip()
{
    match_rule="^((25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)([.](?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)){3})$"
        if [ `echo $1 | grep -P $match_rule` > /dev/null ]; then
                return 1
        else
                return 0
        fi

}

is_valid_mask()
{
    nm=$(aton $1)

    bit=1
    flag=0
    for i in {0..31}
    do
        v=$(($bit << $i))
        flag=$(($nm & $v))
        if [ $flag -ne 0 ]; then
            break;
        fi
    done

    if [ "$i" -lt 2 ]; then
        return 1
    fi

    for j in `seq $i 31`
    do
        v=$(($bit << $j))
        flag=$(($nm & $v))
        if [ $flag -eq 0 ]; then
            break
        fi
    done

    if [ "$flag" -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

is_valud_mask2()
{
    echo $1 | grep "^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$" > /dev/null
        if [ $? = 1 ]; then
                return 0
        fi

        a=`echo $1 | awk -F. '{print $1}'`
        b=`echo $1 | awk -F. '{print $2}'`
        c=`echo $1 | awk -F. '{print $3}'`
        d=`echo $1 | awk -F. '{print $4}'`

        a=`D2B $a`
        b=`D2B $b`
        c=`D2B $c`
        d=`D2B $d`

        for i in $a $b $c $d;do
                [[ $i != 0 && ${#i} != 8 ]] && return 0
        done
        mask=$a$b$c$d
        [[ "$mask" =~ ^1[1]*[0]*$ ]] || return 0

        return 1
}

is_same_subnet()
{
   local ip1=$1
   local ip2=$2
   local mask=$3

   local ip1n=$(aton $ip1)
   local ip2n=$(aton $ip2)
   local maskn=$(aton $mask)

    if [ $(($ip1n & $maskn)) -ne $(($ip2n & $maskn))]; then
        return 1
    else
        return 0
    fi
}

get_network()
{
    local ip1=$(echo $1 | awk -F "." '{print $1}')
    local ip2=$(echo $1 | awk -F "." '{print $2}')
    local ip3=$(echo $1 | awk -F "." '{print $3}')
    local ip4=$(echo $1 | awk -F "." '{print $4}')

    local mask1=$(echo $2 | awk -F "." '{print $1}')
    local mask2=$(echo $2 | awk -F "." '{print $2}')
    local mask3=$(echo $2 | awk -F "." '{print $3}')
    local mask4=$(echo $2 | awk -F "." '{print $4}')

    var=1
    var=$[$var+1]
    local gate1=$(($ip1 & $mask1))
    local gate2=$(($ip2 & $mask2))
    local gate3=$(($ip3 & $mask3))
    local gate4=$(($ip4 & $mask4))

    network=$gate1.$gate2.$gate3.$gate4
}
#####################################################################

ip route flush cache

if [ $# -gt 0 ]; then
    ip route flush dev $1 scope global
else
    if [ $(nvram get vpnc_ov_mode) == "0" ]; then
        dev_name=tap0
    else
        dev_name=tun0
    fi

    ip route flush dev $dev_name scope global
fi

rule_num=$(nvram get p2p_num_x)
if [ $rule_num -le 0 ]; then
    exit 0
fi
if [ $rule_num -ge 256 ]; then
    rule_num=256
fi

i=0
until [ ! $i -lt $rule_num ]
do
    ip=$(nvram get p2p_local_ip_x$i)
    mask=$(nvram get p2p_local_mask_x$i)
    gw=$(nvram get p2p_gw_ip_x$i)

    get_network $ip $mask

    echo $network $mask $gw $dev_name
    route add -net $network netmask $mask gw $gw dev $dev_name
    i=`expr $i + 1`
done