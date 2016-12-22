#!/bin/bash

# Make links for persistent storage
mkdir /opt/etc

mv /etc/aliases.lmdb /opt/etc
ln -s /opt/etc/aliases.lmdb /etc/aliases.lmdb

mv /etc/logrotate.d /opt
ln -s /opt/etc/logrotate.d /etc/logrotate.d

mv /etc/rsyslog.d /opt
ln -s /opt/etc/rsyslog.d /etc/rsyslog.d

mv /var/spool/cron/crontabs /opt
ln -s /opt/var/spool/cron/crontabs /var/spool/cron/crontabs
