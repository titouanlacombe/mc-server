#!/bin/bash

# TCP tunnel for mincraft server
exec ssh -nNT -R 25565:localhost:25565 smoll

# UDP tunnel:
# On the server:
# socat UDP-LISTEN:udp_port,fork TCP:localhost:tcp_port
# On the client:
# ssh -nNT -R tcp_port:localhost:tcp_port smoll
# socat TCP-LISTEN:tcp_port,fork UDP:localhost:udp_port
