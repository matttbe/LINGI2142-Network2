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

sshcmd "opkg install *.ipk"


echo
echo "Here is the list of routers"
ls ../part1
read -p "Which one do you want? " RouterDir
test -d ../part1/$RouterDir && echo "Copy in progress" || echo "Wrong dir"
scpcmd -r ../part1/$RouterDir/* root@$dest:/

echo "Install done - Restart the router"
sshcmd "reboot"
