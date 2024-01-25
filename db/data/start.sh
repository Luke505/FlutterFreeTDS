#!/bin/sh

# delete old database and certificate files
rm -f /db/test.db /db/test.log /db/cert.i || exit 1

# create database files (test.db, test.log)
/opt/sqlanywhere17/bin64s/dbinit -dba DBA,sql -mpl 3 /db/test.db || exit 1
/opt/sqlanywhere17/bin64s/dbspawn -q -f /opt/sqlanywhere17/bin64s/dbeng17 -n test /db/test.db || exit 1
/opt/sqlanywhere17/bin64s/dbstop -c "UID=DBA;PWD=sql;SERVERNAME=test" -q || exit 1

if [ "$USE_CERT" -eq '1' ]; then
	# create certificate file (cert.i)
	/opt/sqlanywhere17/bin64s/createcert -b 4096 -x -ca 0 -io /db/cert.i -co '' -ko '' -sa sha256 \
		-kp ''  -m '' -sc 'US' -scn ' ' -sl ' ' -so ' ' -sou ' ' -sst ' ' \
		-u 1,2,3,4,5,6,7 -v 100 || exit 1

	# start database with certificate file
	/opt/sqlanywhere17/bin64s/dbsrv17 -pc -ec 'tls(identity=/db/cert.i)' -x 'tcpip' -tdsl 'RSA' /db/test.db || exit 1
else
	# start database
	/opt/sqlanywhere17/bin64s/dbsrv17 -pc /db/test.db || exit 1
fi
