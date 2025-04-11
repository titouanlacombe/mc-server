#!/usr/bin/env bash

MC_PORT=25565
VOICE_PORT=24454

# Allow forwarding of packets between the VPN interface and the public interface
sudo iptables -A FORWARD -i $TUNNEL_INTERFACE_PUB -o $TUNNEL_INTERFACE_VPN -j ACCEPT
sudo iptables -A FORWARD -i $TUNNEL_INTERFACE_VPN -o $TUNNEL_INTERFACE_PUB -j ACCEPT

# Setup NAT for translating packets from the VPN interface to the public interface
sudo iptables -t nat -A PREROUTING -p tcp -m tcp --dport $MC_PORT -i $TUNNEL_INTERFACE_PUB -j DNAT --to-destination $TUNNEL_LOCAL_IP:$MC_PORT
sudo iptables -t nat -A PREROUTING -p udp -m udp --dport $VOICE_PORT -i $TUNNEL_INTERFACE_PUB -j DNAT --to-destination $TUNNEL_LOCAL_IP:$VOICE_PORT

# Setup reverse NAT
sudo iptables -t nat -A POSTROUTING -p tcp -m tcp --dport $MC_PORT -d $TUNNEL_LOCAL_IP -j SNAT --to-source $TUNNEL_VPN_IP
sudo iptables -t nat -A POSTROUTING -p udp -m udp --dport $VOICE_PORT -d $TUNNEL_LOCAL_IP -j SNAT --to-source $TUNNEL_VPN_IP
