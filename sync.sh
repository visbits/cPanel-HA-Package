# !/bin/bash
# MIT License

# Copyright (c) 2019 Beyond Hosting LLC

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

#Configurables
DST_HOST='0.0.0.0'
DST_PORT='2202'

#Not implemented yet.
REMOTE_USER='root'

#Clear Vars
unset HA_USERS

# Grab cPanel accounts with a package that begins with 'HASYNC_'
for i in `ls /var/cpanel/users/*`;
do
	if grep -Fiq  "HASYNC_" $i;
	then 
		# Successfully identified this account requiring HASYNC.
		HA_USERS=$HA_USERS$(basename $i);
	fi
done

# Loop over users and copy new cPanel CPMOVE files and restore them
for i in $HA_USERS; do
  if ssh root@$DST_HOST -p $DST_PORT '[ ! -d /home/$i ]'
    then
    echo "User '$i' does not exists, transferring cPanel"
    /scripts/pkgacct $i
    scp -P $DST_PORT /home/cpmove-$i.tar.gz root@$DST_HOST:/home
    ssh root@$DST_HOST -p $DST_PORT "/scripts/restorepkg --force /home/cpmove-$i.tar.gz; rm -f /home/cpmove-$i.tar.gz"
    rm /home/cpmove-$i.tar.gz -f
  fi
done;

# Update lsyncd
echo "" > /etc/lsyncd.conf
for i in $HA_USERS; do
  echo "sync{default.rsyncssh, source=\"/home/$i\", host=\"$DST_HOST\", targetdir=\"/home/$i\"}" >> /etc/lsyncd.conf
done;

# Restart lsyncd
systemctl restart lsyncd