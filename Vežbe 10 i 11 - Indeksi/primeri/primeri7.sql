/*
7. Spajanje dve tabele.

Ako postoji selekcija onda se prvo ona izracunava pa se vrsi 
spajanje.
*/

/*
Izdvajanje redova bez koriscenja indeksa.
*/

use office;
set profiling = 1;

explain analyze
select e.name, d.mgr
from Employees as e, Departments as d
where d.budget > 990000 and e.did = d.id and e.salary > 49000;

/*
Kreiraju se indeksi nad atributima selekcije.
*/

create index Employees_salary_index on Employees (salary) using btree;

create index Departments_budget_index on Departments (budget) using btree;

/*
Pokrece se upit sa postojecim indeksima.
*/

explain analyze
select e.name, d.mgr
from Employees as e, Departments as d
where d.budget > 990000 and e.did = d.id and e.salary > 49000;

/*
Zakljucak: oba indeksa nad atributima selekcije su iskoriscena
i ubrzala su pretragu.
*/

/*
Pravimo unique kljuceve kad atributima spajanja.
*/

alter table Departments add constraint primary key (id);

alter table Employees add constraint unique_did_id unique(did, id);

/*
Ponavljamo upit uz postojanje indeksa nad svim atributima selekcije
i spajanja.
*/

explain analyze
select e.name, d.mgr
from Employees as e, Departments as d
where d.budget > 990000 and e.did = d.id and e.salary > 49000;

/*
Zakljucak: unique indeks nad atributom spajanja znatno ubrzavaju 
pretragu.
*/

/*
Brisu se indeksi.
*/

drop index Employees_salary_index on Employees;

drop index Departments_budget_index on Departments;

/*
Ponavljamo upit uz postojanje samo unique indeksa nad atribtima
spajanja.
*/

explain analyze
select e.name, d.mgr
from Employees as e, Departments as d
where d.budget > 990000 and e.did = d.id and e.salary > 49000;

/*
Zakljucak: unique indeks nad atributom spajanja je dovoljno unapredio
upit, tako da indeksi nad ostalim atributima koji ucestvuju u 
drugim selekcijama ne prave veliku razliku.
*/

/*
Brise se unique indeksi.
*/

alter table Departments drop primary key;

alter table Employees drop constraint unique_did_id;


show profiles;

/*
*************************** 1. row ***************************
EXPLAIN: -> Inner hash join (e.did = d.id)  (cost=1178712.77 rows=369119) (actual time=20.184..474.953 rows=157 loops=1)
    -> Filter: (e.salary > 49000)  (cost=223.43 rows=33227) (actual time=0.044..472.498 rows=20457 loops=1)
        -> Table scan on e  (cost=223.43 rows=996919) (actual time=0.042..432.313 rows=1000000 loops=1)
    -> Hash
        -> Filter: (d.budget > 990000)  (cost=101.50 rows=333) (actual time=0.047..0.666 rows=7 loops=1)
            -> Table scan on d  (cost=101.50 rows=1000) (actual time=0.024..0.608 rows=1000 loops=1)

*************************** 1. row ***************************
EXPLAIN: -> Inner hash join (e.did = d.id)  (cost=232161.10 rows=26536) (actual time=0.894..74.964 rows=157 loops=1)
    -> Index range scan on e using Employees_salary_index, with index condition: (e.salary > 49000)  (cost=29428.74 rows=37908) (actual time=0.014..72.636 rows=20457 loops=1)
    -> Hash
        -> Index range scan on d using Departments_budget_index, with index condition: (d.budget > 990000)  (cost=3.41 rows=7) (actual time=0.016..0.033 rows=7 loops=1)

*************************** 1. row ***************************
EXPLAIN: -> Nested loop inner join  (cost=722.01 rows=274) (actual time=0.139..3.220 rows=157 loops=1)
    -> Index range scan on d using Departments_budget_index, with index condition: (d.budget > 990000)  (cost=9.41 rows=7) (actual time=0.092..0.102 rows=7 loops=1)
    -> Filter: (e.salary > 49000)  (cost=3.03 rows=39) (actual time=0.048..0.443 rows=22 loops=7)
        -> Index lookup on e using unique_did_id (did=d.id)  (cost=3.03 rows=993) (actual time=0.040..0.384 rows=997 loops=7)

*************************** 1. row ***************************
EXPLAIN: -> Nested loop inner join  (cost=34033.78 rows=110344) (actual time=0.119..3.325 rows=157 loops=1)
    -> Filter: (d.budget > 990000)  (cost=104.06 rows=333) (actual time=0.054..0.442 rows=7 loops=1)
        -> Table scan on d  (cost=104.06 rows=1000) (actual time=0.043..0.380 rows=1000 loops=1)
    -> Filter: (e.salary > 49000)  (cost=2.57 rows=331) (actual time=0.042..0.410 rows=22 loops=7)
        -> Index lookup on e using unique_did_id (did=d.id)  (cost=2.57 rows=993) (actual time=0.032..0.356 rows=997 loops=7)

*************************** 1. row ***************************
Query_ID: 1
Duration: 0.47546100
   Query: explain analyze
select e.name, d.mgr
from Employees as e, Departments as d
where d.budget > 990000 and e.did = d.id and e.salary > 49000
*************************** 2. row ***************************
Query_ID: 2
Duration: 1.84243625
   Query: create index Employees_salary_index on Employees (salary) using btree
*************************** 3. row ***************************
Query_ID: 3
Duration: 0.01100300
   Query: create index Departments_budget_index on Departments (budget) using btree
*************************** 4. row ***************************
Query_ID: 4
Duration: 0.07552975
   Query: explain analyze
select e.name, d.mgr
from Employees as e, Departments as d
where d.budget > 990000 and e.did = d.id and e.salary > 49000
*************************** 5. row ***************************
Query_ID: 5
Duration: 0.02939275
   Query: alter table Departments add constraint primary key (id)
*************************** 6. row ***************************
Query_ID: 6
Duration: 8.00135925
   Query: alter table Employees add constraint unique_did_id unique(did, id)
*************************** 7. row ***************************
Query_ID: 7
Duration: 0.00386300
   Query: explain analyze
select e.name, d.mgr
from Employees as e, Departments as d
where d.budget > 990000 and e.did = d.id and e.salary > 49000
*************************** 8. row ***************************
Query_ID: 8
Duration: 0.00844375
   Query: drop index Employees_salary_index on Employees
*************************** 9. row ***************************
Query_ID: 9
Duration: 0.00642475
   Query: drop index Departments_budget_index on Departments
*************************** 10. row ***************************
Query_ID: 10
Duration: 0.00387650
   Query: explain analyze
select e.name, d.mgr
from Employees as e, Departments as d
where d.budget > 990000 and e.did = d.id and e.salary > 49000
*************************** 11. row ***************************
Query_ID: 11
Duration: 0.02646550
   Query: alter table Departments drop primary key
*************************** 12. row ***************************
Query_ID: 12
Duration: 3.70134625
   Query: alter table Employees drop constraint unique_did_id
*/