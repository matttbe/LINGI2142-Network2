dest="192.168.1.1"
if [ $# -gt 0 ]; then
	dest=$1;
fi

echo "sshpass -p root scp packages/*.ipk root@$dest:/root"
sshpass -p "root" scp packages/*.ipk root@$dest:/root

commands="opkg install *.ipk;iptables -F;iptables -X;iptables -P INPUT ACCEPT;iptables -P FORWARD ACCEPT;iptables -P OUTPUT ACCEPT" 
set -- "$commands" 
IFS=";"; declare -a Array=($*) 
for item in ${Array[*]}; do
	echo "sshpass -p root ssh root@$dest $item"
	sshpass -p "root" ssh root@$dest "$item"
done

