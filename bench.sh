#/bin/bash

function nbInjectorsRunningFn {
	echo `docker ps --filter "label=org.nuxeo.injector=true" --format "{{.ID}}" | wc -l`
}

function waitInjectors {
	nbInjectorsRunning=$(nbInjectorsRunningFn);
	while [ $nbInjectorsRunning -gt 0 ]
	do
        nbInjectorsRunning=$(nbInjectorsRunningFn);
		echo "$nbInjectorsRunning injectors still running"
	    sleep 2
	done    
}

function killContainers {
    for cid in `docker ps --filter "label=org.nuxeo.usage=pgbench" --format "{{.ID}}"`;
    do
    	echo "kill "$cid
    	docker stop $cid
    done
    docker ps;
}

function startContainersMultiPG {
    export TESTID=$(date +%s);

    export PG_SHARED_BUFFERS=5MB;
    export PG_PREPARED_TRANSACTIONS=8;
    export PG_EFFECTIVE_CACHE=100MB;
    export PG_WORK_MEM=5MB;
    export PG_WAL_BUFFERS=1MB;   

	echo "Running test in multi PG mode with $1 containers" >> results/aggregated_log	

    for i in `seq 1 ${1:-10}`;
	do
		export INSTANCE="nxbench"$i;
		export DB_INSTANCE="nxbench"$i;

        PGDIR="pgdata/"$TESTID"__"$DB_INSTANCE; 
        mkdir -p $PGDIR

        docker-compose -f compose/pgbenc-compose.yml --x-networking -p $INSTANCE up -d --force-recreate;     
	done      
}


function startContainersSinglePG {
    export TESTID=$(date +%s);

	export INSTANCE="nxbenchSinglePG";
	export DB_INSTANCE="nxbench";
	export CREATE_DB="true";

    export PG_SHARED_BUFFERS=500MB;
    export PG_PREPARED_TRANSACTIONS=100;
    export PG_EFFECTIVE_CACHE=1G;
    export PG_WORK_MEM=64MB;
    export PG_WAL_BUFFERS=16MB;   

    PGDIR="pgdata/"$TESTID"__"$DB_INSTANCE; 
    mkdir -p $PGDIR

	echo "Running test in single PG mode with $1 containers" >> results/aggregated_log	

    docker-compose -f compose/pgbenc-compose.yml --x-networking -p $INSTANCE up -d --force-recreate;     

    docker-compose -f compose/pgbenc-compose.yml --x-networking -p $INSTANCE scale injector=${1:-10};

}

function waitAndGetResults {
	waitInjectors;

    echo "total TPS:"
	cat results/$TESTID*.tps | awk '{s+=$1} END {print s}'
	echo "total TPS:" >> results/aggregated_log	
	cat results/$TESTID*.tps | awk '{s+=$1} END {print s}' >> results/aggregated_log
}

case "$1" in
        run-multi)
            startContainersMultiPG $2
            docker ps;    
            waitAndGetResults;
            killContainers;     
            ;;         
        run-single)
            startContainersSinglePG $2
            docker ps;        
            waitAndGetResults; 
            killContainers;
            ;;                                 
        start-multi)
            startContainersMultiPG $2
            docker ps;    
            ;;         
        start-single)
            startContainersSinglePG $2
            docker ps;        
            ;;                                 
        stop)
            docker-compose -f compose/pgbenc-compose.yml stop
            ;;
        kill)
			killContainers
            ;;
        wait)
            waitAndGetResults
	        ;;
        *)
            echo $"Usage: $0 {start-multi|start-single|run-multi|run-single|stop|kill|wait}"
            exit 1
esac

