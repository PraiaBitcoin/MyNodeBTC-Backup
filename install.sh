#!/bin/bash
chmod 755 backupmynode.sh
mv .config /mnt/hdd/BACKUP/.config
cp config/backupmynode.service /etc/systemd/system/backupmynode.service
cp config/backupmynode.timer /etc/systemd/system/backupmynode.timer
systemctl enable backupmynode.timer
systemctl start backupmynode.timer
