/*
3. Obican indeks (koji nije primarni kljuc).

Primer: izdvajanje po intervalu sa i bez indeksa
    - kada je selekcija velika
    - kada je selekcija mala
*/

use office;
set profiling = 1;

/*
Izdvajanje po intervalu bez indeksa kada je selekcija velika.
*/

explain analyze
select e.id, e.name, e.surname
from Employees as e
where e.salary > 49000;

/*
Kreira se indeks nad atributom selekcije.
*/

create index Employees_salary_index on Employees (salary) using btree;

/*
Pokrece se upit sa postojanjem indeksa nad atributom selekcije.
*/

explain analyze
select e.id, e.name, e.surname
from Employees as e
where e.salary > 49000;

/*
Brisanje indeksa.
*/

drop index Employees_salary_index on Employees;

/*
Zakljucak: kada je selekcija velika indeks se koristi i 
ubrzava pretragu.
*/

/*
Primer izdvajanja po intervalu kada je selekcija manja.
*/

explain analyze
select e.id, e.name, e.surname
from Employees as e
where e.salary > 40000;

/*
Primer izdvajanja po intervalu kada je selekcija jos manja.
*/

explain analyze
select e.id, e.name, e.surname
from Employees as e
where e.salary < 40000;

/*
Kreira se indeks nad atributom selekcije.
*/

create index Employees_salary_index on Employees (salary) using btree;

/*
Pokretanje sa postojanjem indeksa.
*/

explain analyze
select e.id, e.name, e.surname
from Employees as e
where e.salary > 40000;

explain analyze
select e.id, e.name, e.surname
from Employees as e
where e.salary < 40000;

/*
Brisanje indeksa.
*/

drop index Employees_salary_index on Employees;

/*
Zakljucak: u slucaju da je selektivnost mala, optimizator moze
izabrati da ne aktivira indeks. U slucaju da ga iskoriti, moze
se desiti da bude losije nego da ga ne iskoristi.
*/

show profiles;

/*
*************************** 1. row ***************************
EXPLAIN: -> Filter: (e.salary > 49000)  (cost=103143.94 rows=331742) (actual time=494.203..507.259 rows=20457 loops=1)
    -> Table scan on e  (cost=103143.94 rows=995327) (actual time=0.029..463.195 rows=1000000 loops=1)

*************************** 1. row ***************************
EXPLAIN: -> Index range scan on e using Employees_salary_index, with index condition: (e.salary > 49000)  (cost=33165.38 rows=37908) (actual time=0.021..90.063 rows=20457 loops=1)

*************************** 1. row ***************************
EXPLAIN: -> Filter: (e.salary > 40000)  (cost=103143.94 rows=331742) (actual time=507.753..634.116 rows=204172 loops=1)
    -> Table scan on e  (cost=103143.94 rows=995327) (actual time=0.049..574.463 rows=1000000 loops=1)

*************************** 1. row ***************************
EXPLAIN: -> Filter: (e.salary < 40000)  (cost=103143.94 rows=331742) (actual time=0.012..520.551 rows=795810 loops=1)
    -> Table scan on e  (cost=103143.94 rows=995327) (actual time=0.012..462.426 rows=1000000 loops=1)

*************************** 1. row ***************************
EXPLAIN: -> Filter: (e.salary > 40000)  (cost=103143.95 rows=399290) (actual time=379.740..479.711 rows=204172 loops=1)
    -> Table scan on e  (cost=103143.95 rows=995327) (actual time=0.028..436.929 rows=1000000 loops=1)

*************************** 1. row ***************************
EXPLAIN: -> Filter: (e.salary < 40000)  (cost=103143.95 rows=497663) (actual time=0.008..492.049 rows=795810 loops=1)
    -> Table scan on e  (cost=103143.95 rows=995327) (actual time=0.008..439.613 rows=1000000 loops=1)

*************************** 1. row ***************************
Query_ID: 1
Duration: 0.50926225
   Query: explain analyze
select e.id, e.name, e.surname
from Employees as e
where e.salary > 49000
*************************** 2. row ***************************
Query_ID: 2
Duration: 1.68814975
   Query: create index Employees_salary_index on Employees (salary) using btree
*************************** 3. row ***************************
Query_ID: 3
Duration: 0.09306950
   Query: explain analyze
select e.id, e.name, e.surname
from Employees as e
where e.salary > 49000
*************************** 4. row ***************************
Query_ID: 4
Duration: 0.00957975
   Query: drop index Employees_salary_index on Employees
*************************** 5. row ***************************
Query_ID: 5
Duration: 0.65074100
   Query: explain analyze
select e.id, e.name, e.surname
from Employees as e
where e.salary > 40000
*************************** 6. row ***************************
Query_ID: 6
Duration: 0.57395100
   Query: explain analyze
select e.id, e.name, e.surname
from Employees as e
where e.salary < 40000
*************************** 7. row ***************************
Query_ID: 7
Duration: 1.68848175
   Query: create index Employees_salary_index on Employees (salary) using btree
*************************** 8. row ***************************
Query_ID: 8
Duration: 0.49299550
   Query: explain analyze
select e.id, e.name, e.surname
from Employees as e
where e.salary > 40000
*************************** 9. row ***************************
Query_ID: 9
Duration: 0.54348075
   Query: explain analyze
select e.id, e.name, e.surname
from Employees as e
where e.salary < 40000
*************************** 10. row ***************************
Query_ID: 10
Duration: 0.00617425
   Query: drop index Employees_salary_index on Employees

*/