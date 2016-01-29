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

## Running Tests

### Running a single test

    ./bench.sh run-single 10 

Will start the shared PG test with 10 instances.

    ./bench.sh run-multi 10 

Will start the dedicated PG test with 10 instances.

    ./bench.sh kill 

Will kill all running test containers.

Results are available in :`results/aggregated_log`

### Running a benchmark

The `suite.sh` can be used to run alternatively `bench.sh run-single` and `bench.sh run-multi` in a loop with progressively 1, 2, 3, ... 10 instances.

In addition, `suite.sh` will :

 - aggregate bench results in `results/suite_xxx/result.csv`
 - gather monitoring information using `sar`
     + log stored in `results/suite_xxx/sar_<single|multi>_<instanceId>`
 - build a result zip in `results/suite_xxx.zip`

Running the suite is done using:

    ./suite.sh 10 

NB: `suite.sh` require `sar` to be installed on the host

    apt-get install sysstats

## Install

Being able to configure CPU sharing in `docker-compose` requires correction of Issue # 2730 (associated PR is https://github.com/docker/compose/pull/2759).

This means you have to use the 1.6-dev version of Compose forker in :

https://github.com/tiry/compose

Become of an issue that was corrected after the PR, you have to update docker-py

    sudo pip install docker-py==1.7.0rc3

Since 1.6, Docker-Compose networking is no longer activated by the --x-networking, so the v2 of compose yml descriptor format must be used.

But Docker-Engine needs to be upgraded to at least 1.10-rc1 if you do not want to end up with (see issue [2715](https://github.com/docker/compose/issues/2715)):

    ERROR: client is newer than server (client API version: 1.22, server API version: 1.21)

If you run ubuntu you may need to upgrade to wily (15.10) in order to get docker-engine 1.10-rc2 running.







