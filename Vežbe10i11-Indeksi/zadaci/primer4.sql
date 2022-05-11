use office;
SET profiling = 1;

-- Treba da prebrojimo koliko se kojih kombinacija ime+prezime pojavljuje

explain analyze 
select e.name, e.surname, count(*)
from emps as e
group by e.name, e.surname\G

-- EXPLAIN: 
-- -> Table scan on <temporary>  (actual time=0.001..0.009 rows=128 loops=1)
--     -> Aggregate using temporary table  (actual time=1245.019..1245.033 rows=128 loops=1)
--         -> Table scan on e  (cost=103959.40 rows=994424) (actual time=0.208..315.726 rows=1000000 loops=1)

-- Ako napravimo kompozitni B-stablo indeks nad <name, surname>, mozemo da koristimo
-- index-only strategiju

create index btree_name_surname on emps (name, surname) using btree;

explain analyze 
select e.name, e.surname, count(*)
from emps as e
group by e.name, e.surname\G

-- EXPLAIN: 
-- -> Group aggregate: count(0)  (actual time=4.671..445.245 rows=128 loops=1)
--     -> Index scan on e using btree_name_surname  (cost=100571.65 rows=994424) (actual time=0.027..231.168 rows=1000000 loops=1)

drop index btree_name_surname on emps;

SHOW PROFILES;
-- Query_ID        Duration        Query
-- 1       1.24576000      explain analyze select e.name, e.surname, count(*)\nfrom emps as e\ngroup by e.name, e.surname
-- 2       5.66955375      create index btree_name_surname on emps (name, surname) using btree
-- 3       0.44614075      explain analyze select e.name, e.surname, count(*)\nfrom emps as e\ngroup by e.name, e.surname
-- 4       0.00901350      drop index btree_name_surname on emps

-- index-only strategija se pokazuje kao efikasnije resenje od naivnog pristupa u ovom slucaju
