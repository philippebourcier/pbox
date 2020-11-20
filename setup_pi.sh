#!/bin/bash

# This script is launched only once, during DietPi automated installation.
cd /root/

# disable serial console
sed -i 's/console=serial0,115200 //g' /boot/cmdline.txt
sed -i 's/console=ttyS0,115200 //g' /boot/cmdline.txt

# disable bad or useless things
cat << EOF > /etc/modprobe.d/raspi-blacklist.conf
## FW
blacklist ip_tables
blacklist x_tables
EOF

# Vim VISUAL WTF!
VIMP=`vim --version | grep "Vi IMproved" | sed 's/\.//g' | awk '{ print "/usr/share/vim/vim"$5 }'`
sed -i 's/  set mouse=a//g' $VIMP/defaults.vim

# ll
echo "alias ll='ls $LS_OPTIONS -laF'" >> /root/.bashrc

# my pubkeys... you should use yours here :)
# if you don't want to contribute to the Internet of Shit, don't use passwords for SSH
my_keys="https://raw.githubusercontent.com/philippebourcier/pubkeys/master/authorized_keys"
mkdir /root/.ssh
mkdir /home/dietpi/.ssh
wget -O/root/.ssh/authorized_keys $my_keys
wget -O/home/dietpi/.ssh/authorized_keys $my_keys
chown -R dietpi:dietpi /home/dietpi/.ssh
sed -i 's/^PermitRootLogin/#PermitRootLogin/g' /etc/ssh/sshd_config
echo -e "PasswordAuthentication no\nPermitRootLogin prohibit-password\n" >> /etc/ssh/sshd_config
service sshd restart

# install and runonce zymkey and LUKS setup
/boot/dietpi/func/dietpi-set_hardware i2c enable

# Python 3
apt -y remove python2.7
apt -y autoremove
apt -y install build-essential python3 python3-pip
pip3 install smbus2 serial RPI.GPIO adafruit-circuitpython-ads1x15 adafruit-circuitpython-tca9548a adafruit-circuitpython-vl6180x

exit 0
