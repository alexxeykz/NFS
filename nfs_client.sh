#! /usr/bin/env bash
sudo su -
yum install nfs-utils
systemctl enable firewalld --now
echo "192.168.56.120:/srv/share/ /mnt nfs vers=3,proto=udp,noauto,x-systemd.automount 0 0" >> /etc/fstab
systemctl daemon-reload
systemctl restart remote-fs.target
