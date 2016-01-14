# docker-pg-bench

## Goals

Use `pgbench` to compare 2 methods of PostgreSQL container deployment :

**multi-pg** each client is deployed with a dedicated PGSQL container

    [clientA container]  -> [clientA pg container -> database_A]
     
    [clientB container]  -> [clientB pg container -> database_B] 

NB: *This method seems ideal in terms of simplifying the deployment on Swarm/Rancher*

**shared-pg** each client is deployed pointing to a shared PGSQL container
 
                             _                               _
    [clientA container]  -> |                    -> database_A|
                            |shared pg container              |
    [clientB container]  -> |                    -> database_B|
                             -                               -

NB: *This method seems ideal for sharing PGSQL resources*


