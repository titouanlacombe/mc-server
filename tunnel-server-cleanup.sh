#!/usr/bin/env bash

# Remove forwarding rules
sudo iptables -D FORWARD -i $TUNNEL_INTERFACE_PUB -o $TUNNEL_INTERFACE_VPN -j ACCEPT
sudo iptables -D FORWARD -i $TUNNEL_INTERFACE_VPN -o $TUNNEL_INTERFACE_PUB -j ACCEPT

# Remove NAT rules for translating packets
sudo iptables -t nat -D PREROUTING -p tcp -m tcp --dport $MC_PORT -i $TUNNEL_INTERFACE_PUB -j DNAT --to-destination $TUNNEL_LOCAL_IP:$MC_PORT
sudo iptables -t nat -D PREROUTING -p udp -m udp --dport $VOICE_PORT -i $TUNNEL_INTERFACE_PUB -j DNAT --to-destination $TUNNEL_LOCAL_IP:$VOICE_PORT

# Remove reverse NAT rules
sudo iptables -t nat -D POSTROUTING -p tcp -m tcp --dport $MC_PORT -d $TUNNEL_LOCAL_IP -j SNAT --to-source $TUNNEL_VPN_IP
sudo iptables -t nat -D POSTROUTING -p udp -m udp --dport $VOICE_PORT -d $TUNNEL_LOCAL_IP -j SNAT --to-source $TUNNEL_VPN_IP
