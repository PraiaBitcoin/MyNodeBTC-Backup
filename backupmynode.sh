#! /bin/sh

#set -e
set -x

if [ ! -f /usr/bin/xxd ]
then
   apt-get install xxd
fi

CONFIGDIR=/mnt/hdd/mynode/backup
install -d $CONFIGDIR

if [ -f /dev/hwrng ]
then
   #gerador aleatorio via hardware disponivel	
  RANDOM=/dev/hwrng
else
  RANDOM=/dev/random
fi

if [ -f $CONFIGDIR/.config ]
then
. $CONFIGDIR/.config
fi

if [ -n "$ALT" ]
then
  ALT=\-$ALT
fi

if [ -z "$PORT" ]
then
   PORT=22
fi

if [ -z "$REMOTEUSER" ]
then
   REMOTEUSER=bbb
fi

if [ -z "$PUBKEY" ]
then
    #Se não houver senha especificada
   if [ -z "$PASSWORD" ]
   then
       #Se nã houver senha, gera senha aleatoriamente
      echo Gerando senha aleatória
      PASSWORD=$( dd if=$RANDOM bs=64 count=1|base64 -w256 )
      echo PASSWORD=$PASSWORD >> $CONFIGDIR/.config 
   fi
  ARGS=\-\-pinentry-mode\ loopback\ --passphrase\ $PASSWORD\ -c
else
  ARGS=\-\-pinentry-mode\ loopback\ --passphrase\ $PASSWORD
  if [ -n "$SIGNKEY" ]
  then
    ARGS=$ARGS\ --default-key\ $SIGNKEY
  fi
  for c in $PUBKEY
  do
    ARGS=$ARGS\ --recipient\ $c 
  done
  ARGS=$ARGS\ -e   
  if [ -n "$PASSWORD" ]
  then 	
    ARGS=$ARGS\ -s
  fi
fi

if [ ! -f $CONFIGDIR/.key ]
then
    # se não existe a chave privada, gera uma nova...
    # esta chave será usada para autenticação segura ssh
   echo Gerando chave ssh
   ssh-keygen -b 4096 -t rsa -f $CONFIGDIR/.key -q -N ""
fi

ARGS=$ARGS\ --quiet\ --no-tty\ --yes\ -z\ 9\ -a 
data=$( date "+%Y%m%d-%H%M" )\-$(dd if=$RANDOM count=16 bs=1|xxd -p -c 80)
#data=$( date "+%Y%m%d-%H%M" )\-$(cat /proc/cpuinfo|grep Serial|sha256sum|xxd -p -c 80)


cat /proc/cpuinfo |grep Serial|base64

if [ -z "$DESTINO" ]
then
   DESTINO=/mnt/hdd/BACKUP
fi

OUT=$DESTINO/btcpayserver$ALT-$data.dat

install -d $DESTINO
 
 #Backup do btcpayserver criptografado com a senha ou destinatario informado em PUBKEY, e assinado caso seja fornecida a senha gpg de assinatura 
docker exec -i $(docker ps -a -q -f "name=postgres_1") pg_dump -U postgres -d btcpayservermainnet --create | 
    /usr/bin/gpg --output $OUT.asc $ARGS

OUT=$DESTINO/control$ALT-$data.dat

docker exec -i $(docker ps -a -q -f "name=postgres_1") pg_dump -U postgres -d control --create |
    /usr/bin/gpg --output $OUT.asc $ARGS

OUT=$DESTINO/alldb$ALT-$data.dat

docker exec $(docker ps -a -q -f "name=postgres_1") pg_dumpall -c -U postgres |
    /usr/bin/gpg --output $OUT.asc $ARGS

OUT=$DESTINO/postgres$ALT-$data.dat

sudo -u postgres pg_dumpall -c -U postgres |
    /usr/bin/gpg --output $OUT.asc $ARGS

OUT=$DESTINO/lnbits$ALT-$data.dat

sudo -u postgres pg_dump -U postgres -d lnbits --create |
    /usr/bin/gpg --output $OUT.asc $ARGS

OUT=$DESTINO/diversos$ALT-$data.tar

tar cv /mnt/hdd/mynode/bitcoin/*.dat $CONFIGDIR /home/bitcoin/lnd_backup/ /mnt/hdd/mynode/redis /mnt/hdd/mynode/ln* /etc/lets* /etc/nginx /mnt/hdd/BTCPAYSERVER/conf /mnt/hdd/mynode/MISC |
    /usr/bin/gpg --output $OUT.asc $ARGS 
	
if [ -f /mnt/hdd/mynode/btcpayserver/btcpayserver-docker/btcpay-backup.sh ]
then
  OUT=$DESTINO/btcpayserver-completo$ALT-$data.tar.gz
  bash /mnt/hdd/mynode/btcpayserver/btcpayserver-docker/btcpay-backup.sh
  cat /mnt/hdd/mynode/docker/volumes/backup_datadir/_data/backup.tar.gz |
      /usr/bin/gpg --output $OUT.asc $ARGS
fi
  

echo "SOURCE=$data" > $DESTINO/LAST$ALT

#exit 0

SENT=$DESTINO/SENT
  
if [ -x /usr/bin/gdrive ] 
then

  install -d $SENT
  if [ ! -f $HOME/.gdrive/token_v2.json ]
  then
     echo GDRIVE not authorized... Authorize it first
  else 
     if [ -z "$GDRIVEUID" ]
     then
       GDRIVEUID=$(gdrive list|grep BACKUP-MYNODE|cut -d' ' -f1)
       if [ -z "$GDRIVEUID" ] 
       then
          gdrive mkdir BACKUP-MYNODE
	  GDRIVEUID=$(gdrive list|grep BACKUP-MYNODE|cut -d' ' -f1)
       fi
       #echo "GDRIVEUID=$GDRIVEUID" >> $CONFIGDIR/.config       
     fi
     
     
     if [ -n "$GDRIVEUID" ]
     then
       PARENT=--parent\ "$GDRIVEUID"

     fi
  
     echo Backing up files to gdrive ID $GDRIVEUID
     
     for i in $DESTINO/*
     do 
       if [ -f "$i" ]
       then 
         /usr/bin/gdrive upload $PARENT "$i"
	 mv "$i" "$SENT"
       fi
     done  
  fi  

fi

#exit 0


if [ -n "$HOST" ]
then
   if [ -n "$PROXY" ]
   then
 	 # configura o envio por proxy, via comando nc, usando SOCKS5, com 100 segundos de timeout
	PROXYCMD=-o\ \"ProxyCommand=nc\ -X\ 5\ -x\ $PROXY\ -w\ 100\ %h\ %p\"
   fi
   echo Enviando ao servidor $HOST
    #envia ao servidor, com ou sem proxy
   rsync -e "ssh $PROXYCMD -i $CONFIGDIR/.key -p $PORT -o ConnectTimeout=30" $DESTINO $REMOTEUSER@$HOST:/BACKUP/$REMOTEUSER$ALT -avzP --fuzzy --inplace --remove-source-files
else
   echo Configure a variÃ¡velvel HOST no arquivo $CONFIGDIR/.config
fi

#if [ -z "$( cat /var/spool/cron/crontabs/root|grep backupmynode )" ]
#then
#    # Se nÃ£o existir no cron, adiciona para executar aos 15 minutos de cada hora	
#   echo Adicionando $0 ao crontab
#   echo "15 * * * * $0" >>  /var/spool/cron/crontabs/root 
#fi

#find $DESTINO -type f -mtime +30 -delete   

