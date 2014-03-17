#!/bin/bash

dest="192.168.1.1"
if [ $# -gt 0 ]; then
	dest=$1;
fi

sshcmd() {
	echo "$@"
	sshpass -p 'root' ssh root@$dest "$@"
}

scpcmd() {
	echo "scp $@"
	sshpass -p 'root' scp $@
}

ssh-keygen -R $dest
echo "=== ACCEPT THE NEW KEY (pass: 'root') ==="
echo "ssh root@$dest echo Hello"
ssh root@$dest "echo Hello" || echo "ERROR"

echo "scp packages/*.ipk root@$dest:/root"
scpcmd packages/*.ipk root@$dest:/root

commands="opkg install *.ipk;iptables -F;iptables -X;iptables -P INPUT ACCEPT;iptables -P FORWARD ACCEPT;iptables -P OUTPUT ACCEPT;/etc/init.d/quagga start"
set -- "$commands"
IFS=";"; declare -a Array=($*)
for item in ${Array[*]}; do
	echo "ssh root@$dest $item"
	sshpass -p "root" ssh root@$dest "$item"
done

echo
echo "Here is the list of routers"
ls ../part1
read -p "Which one do you want? " RouterDir
test -d ../part1/$RouterDir && echo "Copy in progress" || echo "Wrong dir"
scpcmd -r ../part1/$RouterDir/* root@$dest:/


sshcmd "sed -i '/^exit 0/ s/exit 0/\n\/etc\/init.d\/quagga start\n\nexit 0/g' /etc/rc.local"

echo "Install done - Restart the router"
sshcmd "halt"
