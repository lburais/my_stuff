#!/bin/vbash
#
# Script created on: https://www.l9.fr/usg-config-generator.php by ChoiZ aka François LASSERRE
#
# Do not publish the following lines:
# - vif 832 dhcp-options client-option "send rfc3118-auth …" « It's your Fti user.
# - vif 838 dhcp-options client-option "send dhcp-client-identifier 1:…" < It' your MAC Address.
#

source /opt/vyatta/etc/functions/script-template

configure

# configure eth0

set interfaces ethernet eth0 description ISP
set interfaces ethernet eth0 vif 832 address dhcp
set interfaces ethernet eth0 vif 832 description ISP_DATA
set interfaces ethernet eth0 vif 832 dhcp-options client-option "send vendor-class-identifier &quot;sagem&quot;;"
set interfaces ethernet eth0 vif 832 dhcp-options client-option "send user-class &quot;+FSVDSL_livebox.Internet.softathome.Livebox4&quot;;"
set interfaces ethernet eth0 vif 832 dhcp-options client-option "send rfc3118-auth 00:00:00:00:00:00:00:00:00:00:00:1a:09:00:00:05:58:01:03:41:01:0d:66:74:69:2f:62:36:77:74:39:67:37;"
set interfaces ethernet eth0 vif 832 dhcp-options client-option "request subnet-mask, routers, domain-name-servers, domain-name, broadcast-address, dhcp-lease-time, dhcp-renewal-time, dhcp-rebinding-time, rfc3118-auth;"
set interfaces ethernet eth0 vif 832 dhcp-options default-route update
set interfaces ethernet eth0 vif 832 dhcp-options default-route-distance 210
set interfaces ethernet eth0 vif 832 dhcp-options name-server update
set interfaces ethernet eth0 vif 832 egress-qos "0:0 1:0 2:0 3:0 4:0 5:0 6:6 7:0"
set interfaces ethernet eth0 vif 832 firewall in name WAN_IN
set interfaces ethernet eth0 vif 832 firewall local name WAN_LOCAL

set interfaces ethernet eth0 vif 838 address dhcp
set interfaces ethernet eth0 vif 838 description ISP_TV_VOD
set interfaces ethernet eth0 vif 838 dhcp-options client-option "send vendor-class-identifier &quot;sagem&quot;;"
set interfaces ethernet eth0 vif 838 dhcp-options client-option "send user-class &quot;'FSVDSL_livebox.MLTV.softathome.Livebox4&quot;;"
set interfaces ethernet eth0 vif 838 dhcp-options client-option "send dhcp-client-identifier 1:B8:26:6C:F2:B3:26;"
set interfaces ethernet eth0 vif 838 dhcp-options client-option "request subnet-mask, routers, rfc3442-classless-static-routes;"
set interfaces ethernet eth0 vif 838 dhcp-options default-route no-update
set interfaces ethernet eth0 vif 838 dhcp-options default-route-distance 210
set interfaces ethernet eth0 vif 838 dhcp-options name-server update
set interfaces ethernet eth0 vif 838 egress-qos "0:4 1:4 2:4 3:4 4:4 5:4 6:4 7:4"

set interfaces ethernet eth0 vif 840 address 192.168.255.254/24
set interfaces ethernet eth0 vif 840 description ISP_TV_STREAM
set interfaces ethernet eth0 vif 840 egress-qos "0:5 1:5 2:5 3:5 4:5 5:5 6:5 7:5"

commit

# configure eth1

delete interfaces ethernet eth1 firewall
set interfaces ethernet eth1 description LAN_ETH1
set interfaces ethernet eth1 address 192.168.40.1/24

commit

# configure eth2

delete interfaces ethernet eth2 disable
set interfaces ethernet eth2 description LAN_ETH2
set interfaces ethernet eth2 address 192.168.50.1/24

commit

# configure ipv6

set firewall ipv6-name WAN_IN-6 default-action drop
set firewall ipv6-name WAN_IN-6 description "packets from internet to intranet"

set firewall ipv6-name WAN_IN-6 rule 3001 action accept
set firewall ipv6-name WAN_IN-6 rule 3001 state established enable
set firewall ipv6-name WAN_IN-6 rule 3001 state related enable
set firewall ipv6-name WAN_IN-6 rule 3001 description "allow established/related sessions"

set firewall ipv6-name WAN_IN-6 rule 3002 action drop
set firewall ipv6-name WAN_IN-6 rule 3002 state invalid enable
set firewall ipv6-name WAN_IN-6 rule 3002 description "drop Invalid state"

set firewall ipv6-name WAN_IN-6 rule 3003 action accept
set firewall ipv6-name WAN_IN-6 rule 3003 protocol icmpv6
set firewall ipv6-name WAN_IN-6 rule 3003 description "allow ICMPv6"

set firewall ipv6-name WAN_LOCAL-6 default-action drop
set firewall ipv6-name WAN_LOCAL-6 description "packets from internet to gateway"

set firewall ipv6-name WAN_LOCAL-6 rule 3001 action accept
set firewall ipv6-name WAN_LOCAL-6 rule 3001 state established enable
set firewall ipv6-name WAN_LOCAL-6 rule 3001 state related enable
set firewall ipv6-name WAN_LOCAL-6 rule 3001 description "allow established/related sessions"

set firewall ipv6-name WAN_LOCAL-6 rule 3002 action drop
set firewall ipv6-name WAN_LOCAL-6 rule 3002 state invalid enable
set firewall ipv6-name WAN_LOCAL-6 rule 3002 description "drop Invalid state"

set firewall ipv6-name WAN_LOCAL-6 rule 3003 action accept
set firewall ipv6-name WAN_LOCAL-6 rule 3003 protocol icmpv6
set firewall ipv6-name WAN_LOCAL-6 rule 3003 description "allow ICMPv6"

set firewall ipv6-name WAN_LOCAL-6 rule 3004 description "allow DHCPv6 client/server"
set firewall ipv6-name WAN_LOCAL-6 rule 3004 action accept
set firewall ipv6-name WAN_LOCAL-6 rule 3004 destination port 546
set firewall ipv6-name WAN_LOCAL-6 rule 3004 protocol udp
set firewall ipv6-name WAN_LOCAL-6 rule 3004 source port 547

set firewall ipv6-name WAN_OUT-6 default-action accept
set firewall ipv6-name WAN_OUT-6 description "packets to internet"

set interfaces ethernet eth0 vif 832 firewall in ipv6-name WAN_IN-6
set interfaces ethernet eth0 vif 832 firewall local ipv6-name WAN_LOCAL-6
set interfaces ethernet eth0 vif 832 firewall out ipv6-name WAN_OUT-6
set interfaces ethernet eth0 vif 832 ipv6 address autoconf
set interfaces ethernet eth0 vif 832 ipv6 dup-addr-detect-transmits 1

set interfaces ethernet eth1 ipv6 dup-addr-detect-transmits 1
set interfaces ethernet eth1 ipv6 router-advert cur-hop-limit 64
set interfaces ethernet eth1 ipv6 router-advert link-mtu 0
set interfaces ethernet eth1 ipv6 router-advert managed-flag false
set interfaces ethernet eth1 ipv6 router-advert max-interval 600
set interfaces ethernet eth1 ipv6 router-advert other-config-flag false
set interfaces ethernet eth1 ipv6 router-advert prefix ::/64 autonomous-flag true
set interfaces ethernet eth1 ipv6 router-advert prefix ::/64 on-link-flag true
set interfaces ethernet eth1 ipv6 router-advert prefix ::/64 valid-lifetime 2592000
set interfaces ethernet eth1 ipv6 router-advert reachable-time 0
set interfaces ethernet eth1 ipv6 router-advert retrans-timer 0
set interfaces ethernet eth1 ipv6 router-advert send-advert true

commit

# configure IGMP

set protocols igmp-proxy interface eth0 role disabled
set protocols igmp-proxy interface eth0 threshold 1

set protocols igmp-proxy interface eth0.832 role disabled
set protocols igmp-proxy interface eth0.832 threshold 1

set protocols igmp-proxy interface eth0.838 role disabled
set protocols igmp-proxy interface eth0.838 threshold 1

set protocols igmp-proxy interface eth0.840 alt-subnet 0.0.0.0/0
set protocols igmp-proxy interface eth0.840 role upstream
set protocols igmp-proxy interface eth0.840 threshold 1

set protocols igmp-proxy interface eth1 role disabled
set protocols igmp-proxy interface eth1 threshold 1

set protocols igmp-proxy interface eth2 alt-subnet 0.0.0.0/0
set protocols igmp-proxy interface eth2 role downstream
set protocols igmp-proxy interface eth2 threshold 1

commit

# configure DHCP servers

delete service dhcp-server shared-network-name net_Montaleigne_192.168.40.0-24
delete service dhcp-server shared-network-name net_Livebox_192.168.80.0-24

delete service dhcp-server shared-network-name LAN_ETH1_DHCP
set service dhcp-server shared-network-name LAN_ETH1_DHCP
set service dhcp-server shared-network-name LAN_ETH1_DHCP authoritative enable
set service dhcp-server shared-network-name LAN_ETH1_DHCP subnet 192.168.40.1/24
set service dhcp-server shared-network-name LAN_ETH1_DHCP subnet 192.168.40.1/24 default-router 192.168.40.1
set service dhcp-server shared-network-name LAN_ETH1_DHCP subnet 192.168.40.1/24 dns-server 192.168.40.1
set service dhcp-server shared-network-name LAN_ETH2_DHCP subnet 192.168.40.1/24 dns-server 80.10.246.2
set service dhcp-server shared-network-name LAN_ETH2_DHCP subnet 192.168.40.1/24 dns-server 80.10.246.129
set service dhcp-server shared-network-name LAN_ETH1_DHCP subnet 192.168.40.1/24 lease 86400
set service dhcp-server shared-network-name LAN_ETH1_DHCP subnet 192.168.40.1/24 start 192.168.40.100 stop 192.168.40.200

delete service dhcp-server shared-network-name LAN_ETH2_DHCP
set service dhcp-server shared-network-name LAN_ETH2_DHCP
set service dhcp-server shared-network-name LAN_ETH2_DHCP authoritative enable
set service dhcp-server shared-network-name LAN_ETH2_DHCP subnet 192.168.50.1/24
set service dhcp-server shared-network-name LAN_ETH2_DHCP subnet 192.168.50.1/24 default-router 192.168.50.1
set service dhcp-server shared-network-name LAN_ETH2_DHCP subnet 192.168.50.1/24 dns-server 192.168.50.1
set service dhcp-server shared-network-name LAN_ETH2_DHCP subnet 192.168.50.1/24 dns-server 80.10.246.2
set service dhcp-server shared-network-name LAN_ETH2_DHCP subnet 192.168.50.1/24 dns-server 80.10.246.129
set service dhcp-server shared-network-name LAN_ETH2_DHCP subnet 192.168.50.1/24 lease 86400
set service dhcp-server shared-network-name LAN_ETH2_DHCP subnet 192.168.50.1/24 start 192.168.50.100 stop 192.168.50.200
set service dhcp-server use-dnsmasq disable

commit

# configure GUI and SSH ??

set service gui listen-address 192.168.40.1
set service gui listen-address 192.168.50.1

set service ssh listen-address 192.168.40.1
set service ssh listen-address 192.168.50.1

commit

# configure NAT rules

delete service nat rule 5000
set service nat rule 6010 description "MASQ LAN to WAN"
set service nat rule 6010 log disable
set service nat rule 6010 outbound-interface eth0.832
set service nat rule 6010 protocol all
set service nat rule 6010 type masquerade

set service nat rule 6011 description "MASQ TV to WAN"
set service nat rule 6011 log disable
set service nat rule 6011 outbound-interface eth0.838
set service nat rule 6011 protocol all
set service nat rule 6011 type masquerade

set service upnp2 listen-on eth1
set service upnp2 nat-pmp enable
set service upnp2 secure-mode enable
set service upnp2 wan eth0.832

commit

save
