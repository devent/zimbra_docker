#!/bin/bash
set -e

# Fixes /etc/hosts.
function update_hosts() {
    sleep 2
    DOCKER_HOST=$(hostname -s)
    DOCKER_IP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
    echo "127.0.0.1       localhost" > /etc/hosts
    echo "::1     localhost ip6-localhost ip6-loopback" >> /etc/hosts
    echo "fe00::0 ip6-localnet" >> /etc/hosts
    echo "ff00::0 ip6-mcastprefix" >> /etc/hosts
    echo "ff02::1 ip6-allnodes" >> /etc/hosts
    echo "ff02::2 ip6-allrouters" >> /etc/hosts
    echo "$DOCKER_IP $ZIMBRA_FQDN $DOCKER_HOST" >> /etc/hosts
}

# Fix sudo.
chown root.root /etc/sudoers.d

# Fix sshd.
mkdir -p /var/run/sshd

# Fixes /etc/hosts.
update_hosts

# Run command.
exec "$@"
