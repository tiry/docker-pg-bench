#/bin/bash

source $(dirname $0)/scripts/config.sh

SUITE_ID=$(date +%s);

mkdir results/suite_$SUITE_ID 

echo "pgbench settings" >> results/suite_$SUITE_ID/result.csv
echo " , Duration , $DURATION" >> results/suite_$SUITE_ID/result.csv
echo " , Clients , $CLIENTS" >> results/suite_$SUITE_ID/result.csv
echo " , Threads , $THREADS" >> results/suite_$SUITE_ID/result.csv

echo "" >> results/suite_$SUITE_ID/result.csv

echo "test results" >> results/suite_$SUITE_ID/result.csv

echo "NB_INSTANCES , SinglePG , MultiplePG " >> results/suite_$SUITE_ID/result.csv

for i in `seq 1 ${1:-10}`;
do

    echo "running bench with $i nodes";

    echo "start monitoring"
    sar -d -o /tmp/sar_single_$i 1 3600 >/dev/null 2>&1 &
    echo $! > /tmp/sar_pid
    disown

    echo "running bench with single PG";
    ./bench.sh run-single $i;

    SINGLE_TPS=`cat results/lastresult`

    echo "stop monitoring"
    kill -9 `cat /tmp/sar_pid`
    sleep 1
    sar -Ap -f /tmp/sar_single_$i > results/suite_$SUITE_ID/sar_single_log_$i

    sleep 4;

    echo "start monitoring"
    sar -d -o /tmp/sar_multi_$i 1 3600 >/dev/null 2>&1 &
    echo $! > /tmp/sar_pid
    disown

    echo "running bench with multi PG";
    ./bench.sh run-multi $i;          

    MULTI_TPS=`cat results/lastresult`

    echo "stop monitoring"
    kill -9 `cat /tmp/sar_pid`
    sleep 1
    sar -Ap -f /tmp/sar_multi_$i > results/suite_$SUITE_ID/sar_multi_log_$i

    echo "$i , $SINGLE_TPS , $MULTI_TPS " >> results/suite_$SUITE_ID/result.csv

done      

zip -r results/suite_$SUITE_ID.zip results/suite_$SUITE_ID

