/*
6. Spajanje dve tabele.

Primer vece selektovnosti po atributu spajanja, e.id je
jedinstven, tako da ce selektivnost biti veca u odnosu
na spajanje po e.did, pa ce korist od indeksa biti
izrazenija.
*/

use office;
set profiling = 1;

/*
Pokretanje upita bez koriscenja indeksa.
*/

explain analyze
select e.name, d.name
from Employees as e, Departments as d
where e.id = d.mgr;

/*
Kreira se indeks. Ukoliko postoji indeks nad atributom spajanja
onda se za spajanje koristi taj indeks.
*/

create index Employees_id_index on Employees (id) using btree;

/*
Pokrece se upit uz koriscenje indeksa.
*/

explain analyze
select e.name, d.name
from Employees as e, Departments as d
where e.id = d.mgr;

/*
Brise se indeks.
*/

drop index Employees_id_index on Employees;

/*
Kreira se klasterovani indeks.
*/

alter table Employees add constraint primary key (id);

/*
Pokrece se upit uz koriscenje indeksa.
*/

explain analyze
select e.name, d.name
from Employees as e, Departments as d
where e.id = d.mgr;

/*
Brise se indeks.
*/

alter table Employees drop primary key;

/*
Zakljucak: kada je veca selekcija, indeks vise ubrzava upit.
Klasterovani indeks je bolji od neklasterovanog indeksa nad
atributom spajanja u unutrasnjoj petlji.
*/

show profiles;

/*
*************************** 1. row ***************************
EXPLAIN: -> Inner hash join (e.id = d.mgr)  (cost=99538134.72 rows=99532701) (actual time=2.974..501.633 rows=1000 loops=1)
    -> Table scan on e  (cost=15.29 rows=995327) (actual time=0.034..428.531 rows=1000000 loops=1)
    -> Hash
        -> Table scan on d  (cost=101.50 rows=1000) (actual time=0.024..0.662 rows=1000 loops=1)

*************************** 1. row ***************************
EXPLAIN: -> Nested loop inner join  (cost=876.37 rows=1000) (actual time=0.073..13.689 rows=1000 loops=1)
    -> Table scan on d  (cost=101.50 rows=1000) (actual time=0.013..0.682 rows=1000 loops=1)
    -> Index lookup on e using Employees_id_index (id=d.mgr)  (cost=0.67 rows=1) (actual time=0.012..0.013 rows=1 loops=1000)

*************************** 1. row ***************************
EXPLAIN: -> Nested loop inner join  (cost=1201.50 rows=1000) (actual time=0.054..8.256 rows=1000 loops=1)
    -> Table scan on d  (cost=101.50 rows=1000) (actual time=0.035..0.668 rows=1000 loops=1)
    -> Single-row index lookup on e using PRIMARY (id=d.mgr)  (cost=1.00 rows=1) (actual time=0.007..0.007 rows=1 loops=1000)

*************************** 1. row ***************************
Query_ID: 1
Duration: 0.50216925
   Query: explain analyze
select e.name, d.name
from Employees as e, Departments as d
where e.id = d.mgr
*************************** 2. row ***************************
Query_ID: 2
Duration: 1.77876800
   Query: create index Employees_id_index on Employees (id) using btree
*************************** 3. row ***************************
Query_ID: 3
Duration: 0.01416425
   Query: explain analyze
select e.name, d.name
from Employees as e, Departments as d
where e.id = d.mgr
*************************** 4. row ***************************
Query_ID: 4
Duration: 0.00782925
   Query: drop index Employees_id_index on Employees
*************************** 5. row ***************************
Query_ID: 5
Duration: 6.10898375
   Query: alter table Employees add constraint primary key (id)
*************************** 6. row ***************************
Query_ID: 6
Duration: 0.00864900
   Query: explain analyze
select e.name, d.name
from Employees as e, Departments as d
where e.id = d.mgr
*************************** 7. row ***************************
Query_ID: 7
Duration: 3.13236475
   Query: alter table Employees drop primary key
*/
