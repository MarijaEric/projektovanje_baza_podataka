use office;
SET profiling = 1;

-- Primer: Zelimo da pronadjemo sve parove identifikatora osoba koja imaju isto ime, a
--         ime im je iz skupa {'Shirley', 'Florence', 'Rachel'}.

-- Tabela je ogromna za spajanje, pa se uzima uzorak (10%)

create or replace view emps_sample as
select * from emps
limit 100000;

explain analyze
select e1.emp_id, e2.emp_id
from emps_sample as e1 join emps_sample as e2
    on e1.name = e2.name and e1.emp_id < e2.emp_id
where e1.name in ('Shirley', 'Florence', 'Rachel')\G

-- EXPLAIN: 
-- -> Filter: (e1.emp_id < e2.emp_id)  (cost=1200263900.62 rows=399960027) (actual time=457.366..70599.257 rows=236649440 loops=1)
--     -> Inner hash join (e2.`name` = e1.`name`)  (cost=1200263900.62 rows=399960027) (actual time=456.392..43594.251 rows=473336576 loops=1)
--         -> Table scan on e2  (cost=4.03 rows=200000) (actual time=0.001..20.884 rows=200000 loops=1)
--             -> Materialize  (cost=103958.53 rows=200000) (actual time=190.506..222.238 rows=200000 loops=1)
--                 -> Limit: 200000 row(s)  (cost=103958.53 rows=200000) (actual time=0.070..79.919 rows=200000 loops=1)
--                     -> Table scan on emps  (cost=103958.53 rows=994424) (actual time=0.069..70.325 rows=200000 loops=1)
--         -> Hash
--             -> Filter: (e1.`name` in ('Shirley','Florence','Rachel'))  (cost=22502.50 rows=60000) (actual time=195.996..254.231 rows=37683 loops=1)
--                 -> Table scan on e1  (cost=22502.50 rows=200000) (actual time=0.001..18.223 rows=200000 loops=1)
--                     -> Materialize  (cost=103958.53 rows=200000) (actual time=195.991..224.159 rows=200000 loops=1)
--                         -> Limit: 200000 row(s)  (cost=103958.53 rows=200000) (actual time=0.042..82.636 rows=200000 loops=1)
--                             -> Table scan on emps  (cost=103958.53 rows=994424) (actual time=0.042..72.633 rows=200000 loops=1)

-- Oba puta je neophodno da se vrši izračunavanje pogleda, pa se dva puta vrši ista operacija.

create index btree_name on emps (name) using btree;

explain analyze
select e1.emp_id, e2.emp_id
from emps_sample as e1 join emps_sample as e2
    on e1.name = e2.name and e1.emp_id < e2.emp_id
where e1.name in ('Shirley', 'Florence', 'Rachel')\G

drop index btree_name on emps;

-- EXPLAIN: 
-- -> Filter: (e1.emp_id < e2.emp_id)  (cost=1200263900.62 rows=399960027) (actual time=451.981..70674.938 rows=236649440 loops=1)
--     -> Inner hash join (e2.`name` = e1.`name`)  (cost=1200263900.62 rows=399960027) (actual time=451.108..44085.347 rows=473336576 loops=1)
--         -> Table scan on e2  (cost=4.03 rows=200000) (actual time=0.001..20.210 rows=200000 loops=1)
--             -> Materialize  (cost=103958.53 rows=200000) (actual time=190.677..221.673 rows=200000 loops=1)
--                 -> Limit: 200000 row(s)  (cost=103958.53 rows=200000) (actual time=0.053..80.116 rows=200000 loops=1)
--                     -> Table scan on emps  (cost=103958.53 rows=994424) (actual time=0.052..70.296 rows=200000 loops=1)
--         -> Hash
--             -> Filter: (e1.`name` in ('Shirley','Florence','Rachel'))  (cost=22502.50 rows=60000) (actual time=192.581..248.906 rows=37683 loops=1)
--                 -> Table scan on e1  (cost=22502.50 rows=200000) (actual time=0.002..17.804 rows=200000 loops=1)
--                     -> Materialize  (cost=103958.53 rows=200000) (actual time=192.576..220.152 rows=200000 loops=1)
--                         -> Limit: 200000 row(s)  (cost=103958.53 rows=200000) (actual time=0.049..80.869 rows=200000 loops=1)
--                             -> Table scan on emps  (cost=103958.53 rows=994424) (actual time=0.048..71.115 rows=200000 loops=1)

-- Iako su uključeni indeksi, i dalje se koristi isti algoritam.
-- Ako bismo mogli da navedemo sistem da prvo dohvati poskup imena, pa da to koristi
-- u inner join, potencijalno smanjili bismo broj potrebnih operacija.

create view emps_sample_names as
select * from emps_sample as e
where e.name in ('Shirley', 'Florence', 'Rachel');

explain analyze
select e1.emp_id, e2.emp_id
from emps_sample_names as e1 join emps_sample_names as e2
    on e1.name = e2.name and e1.emp_id < e2.emp_id\G

drop view emps_sample_names;

-- EXPLAIN: 
-- -> Filter: (e.emp_id < e.emp_id)  (cost=1201614112.80 rows=119988010) (actual time=466.168..75514.619 rows=236649440 loops=1)
--     -> Inner hash join (e.`name` = e.`name`)  (cost=1201614112.80 rows=119988010) (actual time=465.242..45016.384 rows=473336576 loops=1)
--         -> Table scan on e  (cost=26.53 rows=200000) (actual time=0.001..20.954 rows=200000 loops=1)
--             -> Materialize  (cost=103958.53 rows=200000) (actual time=189.441..221.077 rows=200000 loops=1)
--                 -> Limit: 200000 row(s)  (cost=103958.53 rows=200000) (actual time=0.043..79.425 rows=200000 loops=1)
--                     -> Table scan on emps  (cost=103958.53 rows=994424) (actual time=0.042..69.753 rows=200000 loops=1)
--         -> Hash
--             -> Filter: ((e.`name` in ('Shirley','Florence','Rachel')) and (e.`name` in ('Shirley','Florence','Rachel')))  (cost=22502.50 rows=60000) (actual time=196.683..264.137 rows=37683 loops=1)
--                 -> Table scan on e  (cost=22502.50 rows=200000) (actual time=0.001..18.164 rows=200000 loops=1)
--                     -> Materialize  (cost=103958.53 rows=200000) (actual time=196.676..224.707 rows=200000 loops=1)
--                         -> Limit: 200000 row(s)  (cost=103958.53 rows=200000) (actual time=0.051..82.406 rows=200000 loops=1)
--                             -> Table scan on emps  (cost=103958.53 rows=994424) (actual time=0.050..72.413 rows=200000 loops=1)

-- Pogledom je smanjen broj 'filter' operacija, ali cena je slična kao i pre.
-- Naknadno se pogled pretvara u tabelu tj. "materijalizuje", kako ne bi morao dva puta da se računa.

create table emps_sample_names as
select * from emps_sample as e
where e.name in ('Shirley', 'Florence', 'Rachel');

explain analyze
select e1.emp_id, e2.emp_id
from emps_sample_names as e1 join emps_sample_names as e2
    on e1.name = e2.name and e1.emp_id < e2.emp_id\G

drop table emps_sample_names;

-- EXPLAIN: 
-- -> Filter: (e1.emp_id < e2.emp_id)  (cost=142209304.96 rows=47396731) (actual time=32.199..51829.452 rows=236649440 loops=1)
--     -> Inner hash join (e2.`name` = e1.`name`)  (cost=142209304.96 rows=47396731) (actual time=30.222..25237.648 rows=473336576 loops=1)
--         -> Table scan on e2  (cost=0.03 rows=37710) (actual time=0.018..44.677 rows=37683 loops=1)
--         -> Hash
--             -> Table scan on e1  (cost=3827.25 rows=37710) (actual time=0.011..20.040 rows=37683 loops=1)

-- Poslednja verzija daje najjeftinije rezultate.

drop view emps_sample;

SHOW PROFILES;

-- Query_ID        Duration        Query
-- 1       0.00487600      create or replace view emps_sample as\nselect * from emps\nlimit 200000
-- 2*      90.73444950     explain analyze\nselect e1.emp_id, e2.emp_id\nfrom emps_sample as e1 join emps_sample as e2\n    on e1.name = e2.name and e1.emp_id < e2.emp_id\nwhere e1.name in ('Shirley', 'Florence', 'Rachel')
-- 3       3.54205000      create index btree_name on emps (name) using btree
-- 4*      90.40012750     explain analyze\nselect e1.emp_id, e2.emp_id\nfrom emps_sample as e1 join emps_sample as e2\n    on e1.name = e2.name and e1.emp_id < e2.emp_id\nwhere e1.name in ('Shirley', 'Florence', 'Rachel')
-- 5       0.00896275      drop index btree_name on emps
-- 6       0.00471450      create view emps_sample_names as\nselect * from emps_sample as e\nwhere e.name in ('Shirley', 'Florence', 'Rachel')
-- 7*      96.84183825     explain analyze\nselect e1.emp_id, e2.emp_id\nfrom emps_sample_names as e1 join emps_sample_names as e2\n    on e1.name = e2.name and e1.emp_id < e2.emp_id
-- 8       0.00440300      drop view emps_sample_names
-- 9       0.72813500      create table emps_sample_names as\nselect * from emps_sample as e\nwhere e.name in ('Shirley', 'Florence', 'Rachel')
-- 10*     70.92479400     explain analyze\nselect e1.emp_id, e2.emp_id\nfrom emps_sample_names as e1 join emps_sample_names as e2\n    on e1.name = e2.name and e1.emp_id < e2.emp_id
-- 11      0.00374550      drop view emps_sample
-- 12      0.01192375      drop table emps_sample_names

-- Zaključak: Materijalizacijom upita je dobijeno ubzanje od 20%.