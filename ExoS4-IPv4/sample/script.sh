#!/bin/bash

MYDIR="/home/melchizedech/netkit/labs/lingi2142"

cd $MYDIR

DIRS=`ls -l $MYDIR | egrep '^d' | awk '{print $9}'`

for DIR in $DIRS
do

echo $DIR ...

cd $DIR
cp /home/melchizedech/netkit/labs/lingi2142/hosts.sample etc/hosts

cd ..
echo next...

done
