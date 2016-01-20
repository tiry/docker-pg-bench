#/bin/bash


for i in `seq 1 ${1:-10}`;
do
    echo "running bench with $i nodes";
    ./bench.sh run-single $i;
    sleep 4;
    ./bench.sh run-multi $i;          
done      