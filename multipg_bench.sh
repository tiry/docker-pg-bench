#/bin/bash

case "$1" in
        start)
            export TESTID=$(date +%s);
            for i in `seq 1 ${2:-10}`;
        	do
        		export INSTANCE="nxbench"$i;
        		export DB_INSTANCE="nxbench"$i;

                PGDIR="pgdata/"$TESTID"__"$DB_INSTANCE; 
                mkdir -p $PGDIR

                docker-compose -f compose/pgbenc-compose.yml --x-networking -p $INSTANCE up -d --force-recreate;     
        	done  
            docker ps;         
            ;;         
        stop)
            docker-compose -f compose/pgbenc-compose.yml stop
            ;;
        kill)
            for cid in `docker ps --filter "label=org.nuxeo.usage=pgbench" --format "{{.ID}}"`;
            do
            	echo "kill "$cid
            	docker stop $cid
            done
            docker ps;
            ;;
        wait)
			while ! "2" eq `docker ps --filter "label=org.nuxeo.usage=pgbench" --format "{{.ID}}" | wc -l`
			do
				echo "$(date) - injectors still running"
			    sleep 1
			done
            ;;
        *)
            echo $"Usage: $0 {start|stop|kill}"
            exit 1
esac

