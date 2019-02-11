# How to use:
Simply deploy this script on the primary host that will act as the master and configure the slave IP.

You will need to configure passwordless ssh key authentication for the master to login to the slave.

Depending on your SSH port, you may way to configure ~/.ssh/config with the host port information for lsyncd.

# Install Requirements:
```
yum install lsyncd -y
systemctl enable lsyncd
```


# Database:
Currently no database replication is supported.  The initial copy of the cPanel account will include databases and if you wish to support replication you will need to modify the pkgacct to not include database.

# Cron:
> /etc/cron.d/cpsync

```
# cpsync 5 minute cron
*/5 * * * /usr/local/beyondhosting/cpsync/sync.sh > /dev/null 2>&1
```