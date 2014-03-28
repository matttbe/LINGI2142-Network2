#!/bin/bash

DIR=`pwd`
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


wget goo.gl/sh9wsg && eog sh9wsg 

ssh-keygen -R $dest
echo "=== ACCEPT THE NEW KEY (pass: 'root') ==="
echo "ssh root@$dest echo Hello"
ssh root@$dest "echo Hello" || echo "ERROR"

echo "scp packages/*.ipk root@$dest:/root"
scpcmd packages/*.ipk root@$dest:/root

sshcmd "opkg install *.ipk"


echo
read -p "Which part? (1, 2) " PART
PARTDIR=../part$PART
echo "Here is the list of routers"
ls $PARTDIR
read -p "Which one do you want? " RouterDir
test -d $PARTDIR/$RouterDir && echo "Copy in progress" || (echo "Wrong dir" && exit 1)

# configure script
if test -f "$PARTDIR/configure.sh"; then
	cd "$PARTDIR"
	./configure.sh $RouterDir tmp
	RouterDir=tmp
	cd "$DIR"
fi
scpcmd -r $PARTDIR/$RouterDir/* root@$dest:/

echo "Install done - Restart the router"
sshcmd "reboot"
