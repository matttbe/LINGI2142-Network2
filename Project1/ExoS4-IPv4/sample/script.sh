#!/bin/bash

MYDIR="/etinfo/users/2011/matbourgeois/Bureau/NETWORK2/LINGI2142-Network2/ExoS4-IPv4"

cd $MYDIR

DIRS=`ls -l $MYDIR | egrep '^d' | awk '{print $9}'`

for DIR in $DIRS
do

echo $DIR ...

cd $DIR
cp /etinfo/users/2011/matbourgeois/Bureau/NETWORK2/LINGI2142-Network2/ExoS4-IPv4/hosts.sample etc/hosts

cd ..
echo next...

done
