#!/bin/bash

dest="192.168.1.1"
if [ $# -gt 0 ]; then
	dest=$1;
fi

ssh-keygen -R $dest
echo "=== ACCEPT THE NEW KEY (pass: 'root') ==="
echo "ssh root@$dest echo Hello"
ssh root@$dest "echo Hello" || echo "ERROR"

echo "scp packages/*.ipk root@$dest:/root"
sshpass -p "root" scp packages/*.ipk root@$dest:/root

commands="opkg install *.ipk;iptables -F;iptables -X;iptables -P INPUT ACCEPT;iptables -P FORWARD ACCEPT;iptables -P OUTPUT ACCEPT;/etc/init.d/quagga start"
set -- "$commands"
IFS=";"; declare -a Array=($*)
for item in ${Array[*]}; do
	echo "ssh root@$dest $item"
	sshpass -p "root" ssh root@$dest "$item"
done

sshcmd() {
	echo "$@"
	sshpass -p 'root' ssh root@$dest "$@"
}

sshcmd "sed -i '/^exit 0/ s/exit 0/\n\/etc\/init.d\/quagga start\n\nexit 0/g' /etc/rc.local"

echo "Install done - Restart the router"
sshcmd "halt"
