#!/bin/bash
# From https://github.com/fedora-cloud/Fedora-Dockerfiles/blob/master/ssh/entrypoint.sh - GPLv2

: ${SSH_USERNAME:=user}
: ${SSH_USERPASS:=$(dd if=/dev/urandom bs=1 count=30 | base64)}

__create_rundir() {
mkdir -p /var/run/sshd
}

__create_user() {
# Create a user to SSH into as.
groupadd docker
useradd -m -s /usr/bin/xonsh -G wheel,docker $SSH_USERNAME
echo "%wheel ALL=(ALL) NOPASSWD: ALL" | EDITOR='tee -a' visudo

echo -e "$SSH_USERPASS\n$SSH_USERPASS" | (passwd --stdin $SSH_USERNAME)
echo ssh user password: $SSH_USERPASS

mkdir -p /home/$SSH_USERNAME/.ssh
echo $SSH_USERKEY >> /home/$SSH_USERNAME/.ssh/authorized_keys
chown -R $SSH_USERNAME:$SSH_USERNAME /home/$SSH_USERNAME/.ssh

}

__create_hostkeys() {
if [ -z "$SSH_NO_KEYGEN" ]; then
  ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' 
  ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' 
  ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N '' 
fi
}

# Call all functions
__create_rundir
__create_hostkeys
__create_user

rm -f /run/nologin

exec /usr/sbin/sshd -D
