# MyNodeBTC-Backup
Script to run a backup on BTC Pay Server running on MyNodeBTC

Run script to create config and add it to crontab

After that, configure VARS REMOTEUSER, HOST, PORT, PASSWORD and PUBKEY, as needed

# PUBLIC KEY ENCRYPTION

If you own a gpg/pgp key, import your public key on gpg at your node.
After that edit config file /mnt/hdd/mynode/backup/.config and set 
PUBKEY=YOURKEYID for example

PUBKEY=00022F67

That will encrypt content to that key.
If you like, you can create a local private key with GPG to sign that encrypted file, so you will know that the file is not changed.
This is optional. If you generate that gpg key, informe the password for your local private key
PASSWORD=123456

# PASSWORD ENCRYPTION

If you dont´t have a private gpg key, you can inform a strong PASSWORD to encrypt content.
Leave it blank so scripts can generate one for you.
SAVE THAT PASSWORD. Only that PASSWORD can decrypt those content


# REMOTE BACKUP SERVER

The script uses rsync over ssh to send files. After send, it removes local files. It creates a local ssh key.
Send the /mnt/hdd/mynode/backup/.key.pub for the remote server administrator, so ssh can auth with that key.

Set HOST, PORT and REMOTEUSER vars

HOST=someserver.com or some.onion address
PORT=30000
REMOTEUSER=username

# PROXY

if you want to connect to the remote host thru a proxy or your remote server is a onion address, you have to configure a PROXY VAR.
PROXY=127.0.0.1:9050


Have fun!!!



