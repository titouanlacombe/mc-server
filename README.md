# MC Server

Simple Minecraft server deployement with Docker.

## Dependencies

### Minecraft server (required)

- [Docker](https://www.docker.com/)

### Backup tools (optional)

Allow you to backup your server and restore backups (see Makefile backup targets).

- [tar](https://www.gnu.org/software/tar/)
- [zstd](https://github.com/facebook/zstd) 

### Tunneling tools (optional)

Allow you to expose your local machine to the internet by using a remote server and a tunnel between the two.
If your remote server is behind a DNS domain, you can even use your domain name to connect to your minecraft server.
This is useful if you want to easily play with your friends without having to tweak your router and without having to pay for an expensive server.

- [ssh](https://www.openssh.com/)
- [envsubst](https://github.com/a8m/envsubst)
- An ssh connection to the remote server
  - Authenticate with ssh key (not user password)
  - sudo privileges
  - Direct connection from server to local machine (use vpn for example)

## Quick start

### Configure server

Copy `mc-server.example.env` to `mc-server.env` and edit it.
[See variables documentation](https://docker-minecraft-server.readthedocs.io/en/latest/variables/#server)

### Start server

`make`

## Tips

Look at the Makefile for more useful commands/tools.
