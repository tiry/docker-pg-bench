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
	    sleep 1
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

function startContainers {
    export TESTID=$(date +%s);
    for i in `seq 1 ${1:-10}`;
	do
		export INSTANCE="nxbench"$i;
		export DB_INSTANCE="nxbench"$i;

        PGDIR="pgdata/"$TESTID"__"$DB_INSTANCE; 
        mkdir -p $PGDIR

        docker-compose -f compose/pgbenc-compose.yml --x-networking -p $INSTANCE up -d --force-recreate;     
	done      
}

case "$1" in
        start)
            startContainers $2
            docker ps;         
            ;;         
        stop)
            docker-compose -f compose/pgbenc-compose.yml stop
            ;;
        kill)
			killContainers
            ;;
        wait)
            waitInjectors
	        ;;
        *)
            echo $"Usage: $0 {start|stop|kill}"
            exit 1
esac

