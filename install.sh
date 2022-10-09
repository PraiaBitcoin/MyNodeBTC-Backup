#!/bin/bash
chmod 755 /home/admin/MyNodeBTC-Backup/backupmynode.sh
if [ ! -f /mnt/hdd/mynode/backup/.config ]
then
    echo Criando diretório de backup
    mkdir /mnt/hdd/mynode/backup
    echo copiando Config
    cp /home/admin/MyNodeBTC-Backup/.config /mnt/hdd/mynode/backup/.config
fi

if [ ! -f /usr/bin/gdrive ]
then
  echo Instalando Google Drive Helper
  curl -sSL https://github.com/prasmussen/gdrive/releases/download/2.1.1/gdrive_2.1.1_linux_386.tar.gz |tar xfzv - -C /usr/bin/
  chmod 555 /usr/bin/gdrive
  gdrive list
fi

cp /home/admin/MyNodeBTC-Backup/config/backupmynode.service /etc/systemd/system/backupmynode.service
cp /home/admin/MyNodeBTC-Backup/config/backupmynode.timer /etc/systemd/system/backupmynode.timer
systemctl enable backupmynode.service
systemctl start backupmynode.service
systemctl enable backupmynode.timer
systemctl start backupmynode.timer
