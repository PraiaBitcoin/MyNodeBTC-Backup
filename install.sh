#!/bin/bash
chmod 755 backupmynode.sh
if [ ! -f /mnt/hdd/mynode/backup/.config ]
then
    echo copiando Config
    cp .config /mnt/hdd/mynode/backup/.config
fi
cp config/backupmynode.service /etc/systemd/system/backupmynode.service
cp config/backupmynode.timer /etc/systemd/system/backupmynode.timer
systemctl enable backupmynode.timer
systemctl start backupmynode.timer
