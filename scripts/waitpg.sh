#!/bin/bash

while ! PGPASSWORD=nuxeo psql -h $INSTANCE"_db_1" -U nuxeo -c "select 1;" $DB_INSTANCE
do
	echo "$(date) - still trying"
    sleep 1
done

echo "$(date) - PG is now up"

if [ ! -z "$CREATE_DB" ]; then  
  echo "Creating DB for the bench"
  CREATE_DB="nxbench_"`hostname`;
  echo "Creating DB for the bench: $CREATE_DB"	
  PGPASSWORD=nuxeo psql -h $INSTANCE"_db_1" -U nuxeo -c "CREATE DATABASE $CREATE_DB OWNER  nuxeo;" $DB_INSTANCE  
  export DB_INSTANCE=$CREATE_DB;
fi;
