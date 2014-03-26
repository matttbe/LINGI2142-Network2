#!/bin/bash

ROUTER_ID=$1
ROUTER_DIR=$2
DEFAULT=default

echo "Copy files"
## a new tmp dir
rm -rf "$ROUTER_DIR"
## copy networkfile
cp -r "$ROUTER_ID" "$ROUTER_DIR"
## copy files supported by the script
cp -r "$DEFAULT"/* "$ROUTER_DIR"

#################
## Modif files ##
#################

## zebra.conf ##
echo "zebra.conf"
sed -i "s/@ROUTER_ID@/$ROUTER_ID/g" "$ROUTER_DIR/etc/quagga/zebra.conf"

## ospf6d.conf ##
echo "ospf6d.conf"
INTERFACES=`grep "config interface 'eth" "$ROUTER_DIR/etc/config/network" | cut -d\' -f2`
for INTF in $INTERFACES; do
	echo "interface $INTF
 ipv6 ospf6 cost 1
 ipv6 ospf6 hello-interval 10
 ipv6 ospf6 dead-interval 40
 ipv6 ospf6 retransmit-interval 5
 ipv6 ospf6 priority 1
 ipv6 ospf6 transmit-delay 1
 ipv6 ospf6 instance-id 0
!
!" >> "$ROUTER_DIR/etc/quagga/ospf6d.conf"
done

echo "router ospf6
 router-id 255.1.1.$ROUTER_ID" >> "$ROUTER_DIR/etc/quagga/ospf6d.conf"

for INTF in $INTERFACES; do
	echo " interface $INTF area 0.0.0.0" >> "$ROUTER_DIR/etc/quagga/ospf6d.conf"
done

echo "!
log file /etc/quagga/ospf6d.log
!" >> "$ROUTER_DIR/etc/quagga/ospf6d.conf"

touch "$ROUTER_DIR/etc/quagga/ospf6d.log"

echo "Creating Hosts"
for R in *; do
	# skip if it's a file, tmp or default
	test ! -d "$R" -o "$R" = "$ROUTER_DIR" -o "$R" = "$DEFAULT" && continue
	i=0
	for IP in `grep "option ip6addr '" $R/etc/config/network | cut -d \' -f2`; do
		echo "$IP r${R}-${i}" >> "$ROUTER_DIR/etc/hosts"
		i=$(($i+1))
	done
done

