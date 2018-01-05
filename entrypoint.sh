#!/bin/bash

cp /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Admin User
MONGODB_ADMIN_USER=${MONGODB_ADMIN_USER:-"mongoadmin"}
MONGODB_ADMIN_PASS=${MONGODB_ADMIN_PASS:-"50meP4s5w0rd"}

# Application Database User
MONGODB_APPLICATION_DATABASE=${MONGODB_APPLICATION_DATABASE:-"admin"}
MONGODB_APPLICATION_USER=${MONGODB_APPLICATION_USER:-"dbuser"}
MONGODB_APPLICATION_PASS=${MONGODB_APPLICATION_PASS:-"50meP4s5w0rd"}

# start without authentication
docker-entrypoint.sh mongod >/dev/null &

# Wait for MongoDB to boot
RET=1
while [[ RET -ne 0 ]]; do
    sleep 2
    mongo admin --eval "help" >/dev/null 2>&1
    RET=$?
done

# Create the admin user
mongo admin --eval "\
    db.dropAllUsers();\
    db.createUser({user: '$MONGODB_ADMIN_USER', pwd: '$MONGODB_ADMIN_PASS', roles:[{role:'root',db:'admin'}]});"
# Create the database and dbuser
if [ "$MONGODB_APPLICATION_DATABASE" != "admin" ]; then
	mongo $MONGODB_APPLICATION_DATABASE --eval "\
	    db.createUser({user: '$MONGODB_APPLICATION_USER', pwd: '$MONGODB_APPLICATION_PASS', roles:[{role:'dbOwner', db:'$MONGODB_APPLICATION_DATABASE'}]});"
fi
# shut down unauth instance
mongo admin --eval "db.shutdownServer()"

exec docker-entrypoint.sh "$@"
