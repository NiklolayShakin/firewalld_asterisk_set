#!/bin/bash

#be careful this removes all current services
CURRENT_SERVICES=$(firewall-cmd --list-services)

for SERVICE in $CURRENT_SERVICES
do firewall-cmd --remove-service=$SERVICE --permanent
echo "Removing $SERVICE service"
done


#VARs set
PHONE_IPS=(
'192.168.20.0/24'
)

SIP_PROVIDER_IPS=()
SIP_PROVIDER_FQDNS=(
    'login.mtt.ru'
    'sip.mtt.ru'
    'multifon.ru'
)

AMI_IPS=(
'192.168.1.0/24'
)
ARI_IPS=(
'192.168.1.0/24'
)
SSH_IPS=(
'192.168.1.0/24'
'172.16.0.0/24'
'10.32.0.0/24'
)
PROVISIONING_MACS=(
'00:04:f2:4a:b8:59'
'00:04:f2:4a:bd:d6'
'00:04:f2:4a:ba:ab'
'00:04:f2:4a:bc:f0'
'00:04:f2:4a:b7:66'
'00:04:f2:4a:bd:d3'
'00:04:f2:4a:b9:75'
'00:04:f2:4a:bd:d1'
'00:04:f2:4a:b8:5c'
'00:04:f2:4a:b7:d5'
'00:04:f2:4a:b7:d3'
'00:04:f2:4a:b7:fe'
'00:04:f2:4a:ba:bb'
'00:04:f2:4a:b9:c0'
'00:04:f2:4a:b9:72'
'00:04:f2:4a:bc:59'
'00:04:f2:4a:b6:3b'
'00:04:f2:4a:bc:e1'
'00:04:f2:4a:ba:8b'
'00:04:f2:4a:ba:ac'
'00:04:f2:4a:bb:3c'
'00:04:f2:4a:bc:6b'
'00:04:f2:4a:b9:73'
'00:04:f2:4a:b7:70'
'00:04:f2:4a:ba:6f'
'00:04:f2:4a:bb:94'
'00:04:f2:4a:ba:ae'
'00:04:f2:4a:ba:9a'
'00:04:f2:4a:bc:e4'
'00:04:f2:4a:ba:9e'
'e0:2f:6d:61:2f:05'
'00:04:f2:f3:49:67'
)


firewall-cmd --permanent --new-ipset=phones-mac --type=hash:mac
for ITEM in ${PROVISIONING_MACS[@]}; do
    echo "firewall-cmd --ipset=phones-mac --add-entry=$ITEM --permanent"
    firewall-cmd --ipset=phones-mac --add-entry=$ITEM --permanent
    echo -e "\tAdded $ITEM to: phones-mac\n"
done

firewall-cmd --permanent --new-ipset=phones --type=hash:net
for ITEM in ${PHONE_IPS[@]}; do
    echo "firewall-cmd --ipset=phones --add-entry=$ITEM --permanent"
    firewall-cmd --ipset=phones --add-entry=$ITEM --permanent
    echo -e "\tAdded $ITEM to: phones\n"
done

firewall-cmd --permanent --new-ipset=sip-providers --type=hash:net
for ITEM in ${SIP_PROVIDER_IPS[@]}; do
    echo "firewall-cmd --ipset=sip-providers --add-entry=$ITEM --permanent"
    firewall-cmd --ipset=sip-providers --add-entry=$ITEM --permanent
    echo -e "\tAdded $ITEM to: sip-providers\n"
done

for ITEM in ${SIP_PROVIDER_FQDNS[@]}; do
    IP=$(dig +short $ITEM)
    if [[ $IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "firewall-cmd --ipset=sip-providers --add-entry=$IP --permanent"
        firewall-cmd --ipset=sip-providers --add-entry=$IP --permanent
        echo -e "\tAdded $IP to: sip-providers\n"
    else
        echo "Can't resolve $ITEM"
    fi
done

firewall-cmd --permanent --new-ipset=ami-users --type=hash:net
for ITEM in ${AMI_IPS[@]}; do
    echo "firewall-cmd --ipset=ami-users --add-entry=$ITEM --permanent"
    firewall-cmd --ipset=ami-users --add-entry=$ITEM --permanent
    echo -e "\tAdded $ITEM to: ami-users\n"
done

firewall-cmd --permanent --new-ipset=ari-users --type=hash:net
for ITEM in ${ARI_IPS[@]}; do
    echo "firewall-cmd --ipset=ari-users --add-entry=$ITEM --permanent"
    firewall-cmd --ipset=ari-users --add-entry=$ITEM --permanent
    echo -e "\tAdded $ITEM to: ari-users\n"
done

firewall-cmd --permanent --new-ipset=ssh-users --type=hash:net
for ITEM in ${SSH_IPS[@]}; do
    echo "firewall-cmd --ipset=ssh-users --add-entry=$ITEM --permanent"
    firewall-cmd --ipset=ssh-users --add-entry=$ITEM --permanent
    echo -e "\tAdded $ITEM to: ssh-users\n"
done





#SIP-endpoint access
echo "----SIP-endpoints----"
echo "firewall-cmd --add-rich-rule='rule source ipset=phones-mac port protocol="tcp" port="8088" accept' --permanent"
firewall-cmd --add-rich-rule='rule source ipset=phones-mac port protocol="tcp" port="8088" accept' --permanent
echo "firewall-cmd --add-rich-rule='rule source ipset=phones-mac port protocol="udp" port="69" accept' --permanent"
firewall-cmd --add-rich-rule='rule source ipset=phones-mac port protocol="udp" port="69" accept' --permanent
echo "firewall-cmd --add-rich-rule='rule source ipset=phones port protocol="udp" port="5060" accept' --permanent"
firewall-cmd --add-rich-rule='rule source ipset=phones port protocol="udp" port="5060" accept' --permanent
echo "firewall-cmd --add-rich-rule='rule source ipset=phones port protocol="udp" port="10000-20000" accept' --permanent"
firewall-cmd --add-rich-rule='rule source ipset=phones port protocol="udp" port="10000-20000" accept' --permanent
echo "firewall-cmd --add-rich-rule='rule source ipset=phones port protocol="udp" port="123" accept' --permanent"
firewall-cmd --add-rich-rule='rule source ipset=phones port protocol="udp" port="123" accept' --permanent

#SIP-provides aceess
echo "----SIP-providers----"
echo "firewall-cmd --add-rich-rule='rule source ipset=sip-providers port protocol="udp" port="5060" accept' --permanent"
firewall-cmd --add-rich-rule='rule source ipset=sip-providers port protocol="udp" port="5060" accept' --permanent
echo "firewall-cmd --add-rich-rule='rule source ipset=sip-providers port protocol="udp" port="10000-20000" accept' --permanent"
firewall-cmd --add-rich-rule='rule source ipset=sip-providers port protocol="udp" port="10000-20000" accept' --permanent

#AMI
echo "----AMI----"
echo "firewall-cmd --add-rich-rule='rule source ipset=ami-users port protocol="tcp" port="5038" accept' --permanent"
firewall-cmd --add-rich-rule='rule source ipset=ami-users port protocol="tcp" port="5038" accept' --permanent

#ARI
echo "----ARI----"
echo "firewall-cmd --add-rich-rule='rule source ipset=ari-users port protocol="tcp" port="8088" accept' --permanent"
firewall-cmd --add-rich-rule='rule source ipset=ari-users port protocol="tcp" port="8088" accept' --permanent

#SSH
echo "firewall-cmd --add-rich-rule='rule source ipset=ssh-users port protocol="tcp" port="22" accept' --permanent"
firewall-cmd --add-rich-rule='rule source ipset=ssh-users port protocol="tcp" port="22" accept' --permanent

echo "
+---------------------------------------+
|   DON'T FOGET firewall-cmd --reload   |
|       to apply new rules              |
+---------------------------------------+
"
