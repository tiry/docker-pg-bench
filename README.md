# docker-pg-bench

Use `pgbench` to compare 2 methods of PostgreSQL container deployment :

**multi-pg:** each client is deployed with a dedciated PGSQL container

    clientA container  -> clientA pg container -> database_A
     
    clientB container  -> clientB pg container -> database_B 

 - shared-pg: each client is deployed pointing to a shared PGSQL container 

    clientA container  ->                     -> database_A
                          shared pg container 
    clientB container  ->                     -> database_B


