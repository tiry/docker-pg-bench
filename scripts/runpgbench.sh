#/bin/bash

## include test configuration
source $(dirname $0)/config.sh

echo "waiting for PG to be started"

source $(dirname $0)/waitpg.sh

echo "Run Init";
PGPASSWORD=nuxeo pgbench -i -s $SCALE -h $INSTANCE"_db_1" -U nuxeo $DB_INSTANCE;

echo "Run PGBench";
## -l --aggregate-interval=1
PGPASSWORD=nuxeo pgbench -c $CLIENTS -j $THREADS -T $DURATION  -h $INSTANCE"_db_1" -U nuxeo $DB_INSTANCE > pgresult;

cp pgresult /var/results/$TESTID"__"`hostname`.result

## dummy parsing
line=`tail -1 pgresult` && parts=($line) && res=${parts[2]} && echo $res

## make the result available at host level (low tech I know)
echo $res > /var/results/$TESTID"__"`hostname`.tps

chmod a+rw /var/results/$TESTID"__"`hostname`.*

#sleep 5000;
