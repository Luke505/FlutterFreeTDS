#!/bin/sh

# delete old database and certificate files
rm -f /db/test.db /db/test.log /db/cert.i

# create database files (test.db, test.log)
/opt/sqlanywhere17/bin64s/dbinit -dba DBA,sql -mpl 3 /db/test.db
/opt/sqlanywhere17/bin64s/dbspawn -q -f /opt/sqlanywhere17/bin64s/dbeng17 -n test /db/test.db
/opt/sqlanywhere17/bin64s/dbstop -c "UID=DBA;PWD=sql;SERVERNAME=test" -q

# create certificate file (cert.i)
openssl req -x509 -nodes -days 36500 -newkey rsa:4096 -keyout /db/cert.i -out /db/cert.i -subj "/"

# start database with certificate file
/opt/sqlanywhere17/bin64s/dbsrv17 -pc -ec 'tls(identity=/db/cert.i)' -x 'tcpip' -tdsl 'RSA' /db/test.db