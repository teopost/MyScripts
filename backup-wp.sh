!/bin/sh

#export filename=$(date +%Y%m%d-%H%M%S)
export filename=backup-website

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Start backup
# -----------.
echo "Backup mysql..."
mysqldump -uroot -pXXXX wpdb > /tmp/${filename}-mysql.sql

echo "Compress wordpress folder..."
cd /var/www/html && tar czf /tmp/${filename}-wp.tar.gz wordpress/

# Start remote copy
# -----------------
echo "Copy wordpress backup to nas01..."
scp /tmp/${filename}-wp.tar.gz root@nas01.apex-net.it:/raid0/data/rilasci/Raspberry/raspb03-wp

echo "Copy mysql dump to nas01..."
scp /tmp/${filename}-mysql.sql root@nas01.apex-net.it:/raid0/data/rilasci/Raspberry/raspb03-wp

# copia backup su wedoit remoto (cloudatcost)
echo "Copy wordpress backup to nas01..."
scp /tmp/${filename}-wp.tar.gz user@45.62.227.200:/home/user

echo "Copy mysql dump to nas01..."
scp /tmp/${filename}-mysql.sql user@45.62.227.200:/home/user

echo "Copy myself to nas01..."
scp ${0} root@nas01.apex-net.it:/raid0/data/rilasci/Raspberry/raspb03-wp

# Finish
echo "Done!"
