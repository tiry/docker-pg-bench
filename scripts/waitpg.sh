#!/bin/bash

while ! PGPASSWORD=nuxeo psql -h $INSTANCE"_db_1" -U nuxeo -c "select 1;" $DB_INSTANCE
do
	echo "$(date) - still trying"
    sleep 1
done
