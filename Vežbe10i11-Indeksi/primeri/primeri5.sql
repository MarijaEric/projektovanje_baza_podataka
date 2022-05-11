/*
5. Spajanje dve tabele.

Spajanje dve tabele se izvrsava tako sto se za svaki red iz jedne 
tabele dohvataju odgovarajuci redovi iz druge tabele na osnovu uslova
po kome se spajaju tabele. Posto postoje unutrasnja i spoljasnja petlja
spajanja, treba obratiti posebnu paznju na efikasnost, jer se unutrasnja
petlja pokrece za svaki rezultujuci red iz spoljasnje petlje.

Optimizator bira iz koje ce se tabele prvo dohvatati redovi, odnosno 
sta ce biti spoljasnja, a sta unutrasnja petlja spajanja.
*/

use office;
set profiling = 1;

/*
Primer navodjenja razlicitih redosleda tabela.
*/

explain analyze
select e.name, d.mgr
from Employees as e, Departments as d
where e.did = d.id;

explain analyze
select e.name, d.mgr
from Departments as d, Employees as e
where e.did = d.id;

explain analyze
select e.name, d.mgr
from Departments as d, Employees as e
where d.id = e.did;

explain analyze
select e.name, d.mgr
from Employees as e, Departments as d
where d.id = e.did;

/*
Zakljucak: plan pregleda tabela je uvek isti, bez obzira
na raspored navodjenja u upitu.
*/

/*
Kreiraju se indeksi nad atributima spajanja.
*/

create index Departments_id_index on Departments (id) using btree;

explain analyze
select e.name, d.mgr
from Employees as e, Departments as d
where e.did = d.id;

/*
Brise se indeks.
*/

drop index Departments_id_index on Departments;

create index Employees_did_index on Employees (did) using btree;

explain analyze
select e.name, d.mgr
from Employees as e, Departments as d
where e.did = d.id;

/*
Brise se indeks.
*/

drop index Employees_did_index on Employees;

/*
Zakljucak: indeksi su znatno usporili spajanje tabela.
*/

/*
Kreiraju se klasterovani indeksi nad atributima spajanja.
*/

alter table Departments add constraint unique_id unique (id);

explain analyze
select e.name, d.mgr
from Employees as e, Departments as d
where e.did = d.id;

/*
Brise se indeks.
*/

alter table Departments drop constraint unique_id;

alter table Employees add constraint unique_did_id unique (did, id);

explain analyze
select e.name, d.mgr
from Employees as e, Departments as d
where e.did = d.id;

/*
Brise se indeks.
*/

alter table Employees drop constraint unique_did_id;

/*
Zakljucak: najbolje je napraviti klasterovani indeks nad atributom
spajanja e.did relacije Employees.
*/

show profiles;

/*
*************************** 1. row ***************************
EXPLAIN: -> Inner hash join (e.did = d.id)  (cost=99536522.95 rows=99532701) (actual time=1.299..536.184 rows=1000000 loops=1)
    -> Table scan on e  (cost=13.67 rows=995327) (actual time=0.014..415.120 rows=1000000 loops=1)
    -> Hash
        -> Table scan on d  (cost=101.50 rows=1000) (actual time=0.069..0.997 rows=1000 loops=1)

*************************** 1. row ***************************
EXPLAIN: -> Inner hash join (e.did = d.id)  (cost=99536522.95 rows=99532701) (actual time=0.534..506.527 rows=1000000 loops=1)
    -> Table scan on e  (cost=13.67 rows=995327) (actual time=0.005..393.035 rows=1000000 loops=1)
    -> Hash
        -> Table scan on d  (cost=101.50 rows=1000) (actual time=0.012..0.398 rows=1000 loops=1)

*************************** 1. row ***************************
EXPLAIN: -> Inner hash join (e.did = d.id)  (cost=99536522.95 rows=99532701) (actual time=0.519..507.408 rows=1000000 loops=1)
    -> Table scan on e  (cost=13.67 rows=995327) (actual time=0.004..393.707 rows=1000000 loops=1)
    -> Hash
        -> Table scan on d  (cost=101.50 rows=1000) (actual time=0.011..0.385 rows=1000 loops=1)

*************************** 1. row ***************************
EXPLAIN: -> Inner hash join (e.did = d.id)  (cost=99536522.95 rows=99532701) (actual time=0.511..521.803 rows=1000000 loops=1)
    -> Table scan on e  (cost=13.67 rows=995327) (actual time=0.005..404.553 rows=1000000 loops=1)
    -> Hash
        -> Table scan on d  (cost=101.50 rows=1000) (actual time=0.012..0.376 rows=1000 loops=1)

*************************** 1. row ***************************
EXPLAIN: -> Nested loop inner join  (cost=451508.40 rows=995327) (actual time=0.017..1959.885 rows=1000000 loops=1)
    -> Table scan on e  (cost=103143.95 rows=995327) (actual time=0.008..430.180 rows=1000000 loops=1)
    -> Index lookup on d using Departments_id_index (id=e.did)  (cost=0.25 rows=1) (actual time=0.001..0.001 rows=1 loops=1000000)

*************************** 1. row ***************************
EXPLAIN: -> Nested loop inner join  (cost=771353.89 rows=995327) (actual time=0.133..3994.024 rows=1000000 loops=1)
    -> Table scan on d  (cost=101.50 rows=1000) (actual time=0.068..2.923 rows=1000 loops=1)
    -> Index lookup on e using Employees_did_index (did=d.id)  (cost=671.82 rows=995) (actual time=0.016..3.923 rows=1000 loops=1000)

*************************** 1. row ***************************
EXPLAIN: -> Nested loop inner join  (cost=1011379.83 rows=995327) (actual time=0.029..3489.958 rows=1000000 loops=1)
    -> Table scan on e  (cost=103143.95 rows=995327) (actual time=0.017..659.362 rows=1000000 loops=1)
    -> Single-row index lookup on d using unique_id (id=e.did)  (cost=0.81 rows=1) (actual time=0.003..0.003 rows=1 loops=1000000)

*************************** 1. row ***************************
EXPLAIN: -> Nested loop inner join  (cost=101900.83 rows=993293) (actual time=0.074..246.629 rows=1000000 loops=1)
    -> Table scan on d  (cost=101.50 rows=1000) (actual time=0.043..0.644 rows=1000 loops=1)
    -> Index lookup on e using unique_did_id (did=d.id)  (cost=2.57 rows=993) (actual time=0.015..0.208 rows=1000 loops=1000)

*************************** 1. row ***************************
Query_ID: 2
Duration: 0.56174675
   Query: explain analyze
select e.name, d.mgr
from Departments as d, Employees as e
where e.did = d.id
*************************** 2. row ***************************
Query_ID: 3
Duration: 0.56267050
   Query: explain analyze
select e.name, d.mgr
from Departments as d, Employees as e
where d.id = e.did
*************************** 3. row ***************************
Query_ID: 4
Duration: 0.57856475
   Query: explain analyze
select e.name, d.mgr
from Employees as e, Departments as d
where d.id = e.did
*************************** 4. row ***************************
Query_ID: 5
Duration: 0.01149575
   Query: create index Departments_id_index on Departments (id) using btree
*************************** 5. row ***************************
Query_ID: 6
Duration: 2.03202950
   Query: explain analyze
select e.name, d.mgr
from Employees as e, Departments as d
where e.did = d.id
*************************** 6. row ***************************
Query_ID: 7
Duration: 0.01789800
   Query: drop index Departments_id_index on Departments
*************************** 7. row ***************************
Query_ID: 8
Duration: 2.01648225
   Query: create index Employees_did_index on Employees (did) using btree
*************************** 8. row ***************************
Query_ID: 9
Duration: 4.12389525
   Query: explain analyze
select e.name, d.mgr
from Employees as e, Departments as d
where e.did = d.id
*************************** 9. row ***************************
Query_ID: 10
Duration: 0.02250150
   Query: drop index Employees_did_index on Employees
*************************** 10. row ***************************
Query_ID: 11
Duration: 0.03145950
   Query: alter table Departments add constraint unique_id unique (id)
*************************** 11. row ***************************
Query_ID: 12
Duration: 3.60496375
   Query: explain analyze
select e.name, d.mgr
from Employees as e, Departments as d
where e.did = d.id
*************************** 12. row ***************************
Query_ID: 13
Duration: 0.03351275
   Query: alter table Departments drop constraint unique_id
*************************** 13. row ***************************
Query_ID: 14
Duration: 7.27614275
   Query: alter table Employees add constraint unique_did_id unique (did, id)
*************************** 14. row ***************************
Query_ID: 15
Duration: 0.30040725
   Query: explain analyze
select e.name, d.mgr
from Employees as e, Departments as d
where e.did = d.id
*************************** 15. row ***************************
Query_ID: 16
Duration: 2.98958150
   Query: alter table Employees drop constraint unique_did_id

*/
