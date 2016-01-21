# docker-pg-bench

## Goals

Use `pgbench` to compare 2 methods of PostgreSQL container deployment :

**multi-pg** each client is deployed with a dedicated PGSQL container

    [clientA container]  -> [clientA pg container -> database_A]
     
    [clientB container]  -> [clientB pg container -> database_B] 

*This method seems ideal in terms of simplifying the deployment on Swarm/Rancher*

For this scenario, the test will create couple of containers for each "instance": so running the test with 10 instances will technically create 20 containers.


**shared-pg** each client is deployed pointing to a shared PGSQL container
 
                             _                               _
    [clientA container]  -> |                    -> database_A|
                            |shared pg container              |
    [clientB container]  -> |                    -> database_B|
                             -                               -

*This method seems ideal for sharing PGSQL resources*

For this scenario, the test create only one shared PG container, but one new pgbench container will be created for each instance: so running the test with 10 instances will technically create 11 containers.

## About the test variables

### PG Configuration

The PG Configuration is different between the shared and the dedicated PG.

**Shared :**

    export PG_SHARED_BUFFERS=500MB;
    export PG_PREPARED_TRANSACTIONS=100;
    export PG_EFFECTIVE_CACHE=1GB;
    export PG_WORK_MEM=64MB;
    export PG_WAL_BUFFERS=16MB;   

**Dedicated :**

    export PG_SHARED_BUFFERS=5MB;
    export PG_PREPARED_TRANSACTIONS=8;
    export PG_EFFECTIVE_CACHE=100MB;
    export PG_WORK_MEM=5MB;
    export PG_WAL_BUFFERS=1MB;  

### PGBench

The pgbench configuration can be tweaked by editing `config.sh`;


## Running the test

    bench.sh run-single 10 

Will start the shared PG test with 10 instances.

    bench.sh run-multi 10 

Will start the dedicated PG test with 10 instances.

    bench.sh kill 

Will kill all running test containers.


Results are available in :`results/aggregated_log`




