#!/bin/bash

__create_user() {
# Create a user to SSH into as.
USER=deployer
useradd $USER
SSH_USERPASS=$USER
SSH_USER_PUB_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDW04B/yzGbuNuRbvqVaZAPUojNjqjgq1r47KfYxgTw/rJ6SkyyuqXSQgVg4+wgvQEmrklVDvAR4ZLzbNx3vBTwMAiXTGW2GeGCUIArIMy0qCnHva0BzYHQyhJlC819UH5qRfI5fyAFCi3n2yxFQYwmxysjb13bmqMg7mV9gGlYMKkS+qJStda+gZZpC5TDbW6yYm/DQmGYTdfGjeyjxjqHbsfcE3IThyA8O3D7nle2FD8+7rkReX0b9r7vK7ZE30fGiB3bG78b0b3GCOzi+sHEOffg7nXt8VUHu/TLgrD8S2EgJvbC5JDfHxzS45pU3R6dapukwlKbw6Unn0pb/a4G6SdMb8z22isvcxlgEr1tWJyXPU6QncAazWYTEYVtFOT75C8Igg42no122bM6qt2YMR5SfgYNIteNe8kv0opqckXVtKxHrI8Qv1qqIJ63jZL7OCgdhh/Lq3wJ0XCsQ9cA4gQGjvZnLgF9Vd4rMzLJ0tvkU53svgpQQEuqp3wHXu9BAMqWQSMTVo/aojdUGBbWCDis4gP9IB/p8HEDYjl0eaWvGoVYOcKqNxXvjI5AH3+N8KziE9pwrEmgPjXP5l2UTnEuetLY91VpKfRZgfLcYZ6r9SUH5H4d1a4aqqeK6BvcB3mFpc6sDkw57TdtCQ+DEHHA3yVMQY3nLuKiTLoo6Q== kenta@sherpaconsulting.no"

# Add user to sudoers group
usermod -aG wheel $USER

# Add user public key
mkdir /home/$USER/.ssh
echo $SSH_USER_PUB_KEY > /home/$USER/.ssh/authorized_keys
chown $USER:$USER -R /home/$USER/.ssh
chmod 700 /home/$USER/.ssh
chmod 600 /home/$USER/.ssh/authorized_keys

echo -e "$SSH_USERPASS\n$SSH_USERPASS" | (passwd --stdin $USER)
echo ssh user password: $SSH_USERPASS
}

# Call all functions
__create_user
