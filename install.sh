#!/bin/bash
chmod 755 /home/admin/MyNodeBTC-Backup/backupmynode.sh
if [ ! -f /mnt/hdd/mynode/backup/.config ]
then
    echo Criando diretório de backup
    mkdir /mnt/hdd/mynode/backup
    echo copiando Config
    cp /home/admin/MyNodeBTC-Backup/.config /mnt/hdd/mynode/backup/.config
fi

cp /home/admin/MyNodeBTC-Backup/config/backupmynode.service /etc/systemd/system/backupmynode.service
cp /home/admin/MyNodeBTC-Backup/config/backupmynode.timer /etc/systemd/system/backupmynode.timer
systemctl enable backupmynode.service
systemctl start backupmynode.service
systemctl enable backupmynode.timer
systemctl start backupmynode.timer
