#!/bin/sh

#-udp 5246 200 53 137
#-tcp 80 8080 
#-ip 192.168.0.1
#-mac 11:22:33:44:55:66

count=3
strTime=`date "+%Y%m%d_%H%M%S"`

udp_arr=()
tcp_arr=()
ip_arr=()
mac_arr=()

echo usage: $0 [-udp port1 port] [-tcp port1 port2] [-ip xx.xx.xx.xx] [-mac aa:bb:cc:aa:bb:cc]
var=100

for item in $@
do
	if [ "$item"x = "-udp"x ]; then
	    var=1
	    continue
	elif [ "$item"x = "-tcp"x ]; then
	    var=2
	    continue
	elif [ "$item"x = "-ip"x ]; then
	    var=3
	    continue
	elif [ "$item"x = "-mac"x ]; then
	    var=4
	    continue
	elif [ "$item"x = "-count"x ]; then
	    var=5
	    continue
	fi
	case $var in
	    1)
	        udp_arr[${#udp_arr[@]}]=$item
			;;
		2)
	        tcp_arr[${#tcp_arr[@]}]=$item
			;;
		3)
	        ip_arr[${#ip_arr[@]}]=$item
			;;
		4)
	        mac_arr[${#mac_arr[@]}]=$item
			;;
		5)
	        count=$item
			;;
		*)
		    echo $var
	esac
done

echo ${tcp_arr[*]}
echo ${udp_arr[*]}
echo ${ip_arr[*]}
echo ${mac_arr[*]}

tcp_str=${tcp_arr[0]}
for((i=1;i<${#tcp_arr[@]};i++))
do
    tcp_str=$tcp_str" or ${tcp_arr[$i]}"
done
echo $tcp_str
tcp_str_final=""
if [ "$tcp_str"x != ""x ]; then
    tcp_str_final="or tcp dst port "$tcp_str
fi

udp_str=${udp_arr[0]}
udp_str_final=""
for((i=1;i<${#udp_arr[@]};i++))
do
    udp_str=$udp_str" or ${udp_arr[$i]}"
done
echo $udp_str
if [ "$udp_str"x != ""x ]; then
    udp_str_final="or udp port "$udp_str
fi
    
  

mac_str=${mac_arr[0]}
if [ "$mac_str"x != ""x ]; then
    mac_str_final="and ether src "$mac_str
fi
ip_str=${ip_arr[0]}
if [ "$ip_str"x != ""x ]; then
    ip_str_final="and ip host "$ip_str
fi

echo $tcp_str_final
echo $udp_str_final
echo $mac_str_final
echo $ip_str_final

ip_str=${ip_arr[0]}


#capture on specify port and specify mac
if [ $# -eq 0 ]; then
    tcpdump -s 0 -w pacpfile_$strTime.pcap udp port 53 or 137 or 5246 or 2000 or tcp dst port 80 -c $count 
else
    echo tcpdump -s 0 -w pacpfile_$strTime.pcap udp port ! 1\
	   	$udp_str_final $tcp_str_final $mac_str_final $ip_str_final -c $count 
    tcpdump -s 0 -w pacpfile_$strTime.pcap udp port ! 1\
	   	$udp_str_final $tcp_str_final $mac_str_final $ip_str_final -c $count 
fi

