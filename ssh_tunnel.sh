#!/bin/bash

# TCP tunnel for mincraft server
exec ssh -nNT -R 25565:localhost:25565 smoll
