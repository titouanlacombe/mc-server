#!/usr/bin/env bash

# Ensure all necessary environment variables are set
if [[ -z "$ACTION" || -z "$MC_PORT" || -z "$VOICE_PORT" || -z "$TUNNEL_INTERFACE_PUB" || -z "$TUNNEL_INTERFACE_VPN" || -z "$TUNNEL_LOCAL_IP" || -z "$TUNNEL_VPN_IP" ]]; then
    echo "Error: One or more required environment variables are not set."
    echo "Please set ACTION, MC_PORT, VOICE_PORT, TUNNEL_INTERFACE_PUB, TUNNEL_INTERFACE_VPN, TUNNEL_LOCAL_IP, and TUNNEL_VPN_IP."
    exit 1
fi

# Allow or disallow forwarding of packets between the VPN interface and the public interface
iptables $ACTION FORWARD -i $TUNNEL_INTERFACE_PUB -o $TUNNEL_INTERFACE_VPN -j ACCEPT
iptables $ACTION FORWARD -i $TUNNEL_INTERFACE_VPN -o $TUNNEL_INTERFACE_PUB -j ACCEPT

# Setup or teardown NAT for translating packets from the VPN interface to the public interface
iptables -t nat $ACTION PREROUTING -p tcp -m tcp --dport $MC_PORT -i $TUNNEL_INTERFACE_PUB -j DNAT --to-destination $TUNNEL_LOCAL_IP:$MC_PORT
iptables -t nat $ACTION PREROUTING -p udp -m udp --dport $VOICE_PORT -i $TUNNEL_INTERFACE_PUB -j DNAT --to-destination $TUNNEL_LOCAL_IP:$VOICE_PORT

# Setup or teardown reverse NAT
iptables -t nat $ACTION POSTROUTING -p tcp -m tcp --dport $MC_PORT -d $TUNNEL_LOCAL_IP -j SNAT --to-source $TUNNEL_VPN_IP
iptables -t nat $ACTION POSTROUTING -p udp -m udp --dport $VOICE_PORT -d $TUNNEL_LOCAL_IP -j SNAT --to-source $TUNNEL_VPN_IP
