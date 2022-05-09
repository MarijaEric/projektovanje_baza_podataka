use office;

-- Primer: Zelimo da prebrojimo koliko ljudi ima platu izmedju 3000 i 4000

-- Sledecom komandom ukljucujemo profajliranje upita, gde na kraju mozemo
-- da vidimo vreme izvrsavanje svih upita sesija komandom `SHOW PROFILES`
-- Napomena: EXPLAIN ANALYZE izvrsava upit, sto znaci da ako koristimo `drop table`,
-- tabela ce biti obrisana.
SET profiling = 1;

explain analyze
select count(*)
from emps as e
where e.salary >= 1000 
  and e.salary <= 1100\G

-- EXPLAIN: 
-- -> Aggregate: count(0)  (actual time=434.886..434.887 rows=1 loops=1)
--     -> Filter: ((e.salary <= 1000) and (e.salary >= 1100))  (cost=103237.92 rows=110469) (actual time=434.884..434.884 rows=0 loops=1)
--         -> Table scan on e  (cost=103237.92 rows=994424) (actual time=0.085..364.097 rows=1000000 loops=1)

-- Testiramo B-stablo indeks

create index btree_salary on emps (salary) using btree;

explain analyze
select count(*)
from emps as e
where e.salary <= 1100 
  and e.salary >= 1000\G

drop index btree_salary on emps;

-- EXPLAIN: 
-- -> Aggregate: count(0)  (actual time=7.500..7.501 rows=1 loops=1)
--     -> Filter: ((e.salary <= 1100) and (e.salary >= 1000))  (cost=2253.14 rows=11206) (actual time=0.030..6.505 rows=11206 loops=1)
--         -> Index range scan on e using btree_salary  (cost=2253.14 rows=11206) (actual time=0.028..4.513 rows=11206 loops=1)

-- Dobili smo znatno bolje rezultate. Glavna razlika je što nam indeks u ovom slučaju omogućava
-- index-only plan tj. možemo da zaključimo count(*) rezultat bez da dohvatamo konkretne redove.

-- Testiramo hes indeks

create index hash_salary on emps (salary) using hash;

explain analyze
select count(*)
from emps as e
where e.salary <= 1100 
  and e.salary >= 1000\G

drop index hash_salary on emps;

-- EXPLAIN: 
-- -> Aggregate: count(0)  (actual time=4.060..4.060 rows=1 loops=1)
--     -> Filter: ((e.salary <= 1100) and (e.salary >= 1000))  (cost=2253.14 rows=11206) (actual time=0.025..3.546 rows=11206 loops=1)
--         -> Index range scan on e using hash_salary  (cost=2253.14 rows=11206) (actual time=0.023..2.417 rows=11206 loops=1)

-- Rezultat i performanse su slicne. To je zato sto mysql tiho promeni 'hash' u 'btree'.
-- U mysql-u na innodb masini za skladistenje, koja je
-- podrazumevana, moguci su samo btree indeksi. Memory masina za skladistenje
-- dozvoljava oba tipa indeksa.
-- https://dev.mysql.com/doc/refman/8.0/en/index-btree-hash.html
-- https://dev.mysql.com/doc/refman/8.0/en/optimization-indexes.html
-- https://dev.mysql.com/doc/refman/8.0/en/create-index.html

SHOW PROFILES;
-- Query_ID        Duration        Query
-- 1       0.44594075      explain analyze\nselect count(*)\nfrom emps as e\nwhere e.salary <= 1000 \n  and e.salary >= 1100
-- 2       3.44473100      create index btree_salary on emps (salary) using btree
-- 3       0.00864275      explain analyze\nselect count(*)\nfrom emps as e\nwhere e.salary <= 1100 \n  and e.salary >= 1000
-- 4       0.02130975      drop index btree_salary on emps
-- 5       2.47925825      create index hash_salary on emps (salary) using hash
-- 6       0.00459325      explain analyze\nselect count(*)\nfrom emps as e\nwhere e.salary <= 1100 \n  and e.salary >= 1000
-- 7       0.01093050      drop index hash_salary on emps

-- Zakljucak Performanse su u ovom slucaju dosta bolje sa indeksima, jer moze da se koristi
-- index-only plan.