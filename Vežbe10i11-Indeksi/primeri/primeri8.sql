/*
8. Vise selekcija nad jednom tabelom.

Ne moraju se obe izvrsiti, optimizator bira da li ce se izvrsiti obe 
ili je dovoljno izvrsiti samo onu cija je selektivnost veca.

Primer kada optimizator bira da koristi indeks za samo jednu 
selekciju, dok za drugu koristi sekvencijalni prolaz.
*/

use office;
set profiling = 1;

/*
Pokretanje upita bez indeksa. Oba izdvajanja su intervalna.
*/

explain analyze
select e.id
from Employees as e
where e.age between 20 and 30
and e.salary between 3000 and 5000;

/*
Primer kada je jedno izdvajanje intervalno, a drugo po tacnoj 
vrednosti.
*/

explain analyze
select e.id
from Employees as e
where e.age = 30
and e.salary between 3000 and 5000;

/*
Kreiramo neklasterovane indekse.
*/

create index Employees_salary_index on Employees (salary) using btree;

create index Employees_age_index on Employees (age) using btree;

/*
Pokrecu se upiti uz postojanje indeksa nad atributima selekcije.
*/

explain analyze
select e.id
from Employees as e
where e.age between 20 and 30
and e.salary between 3000 and 5000;

explain analyze
select e.id
from Employees as e
where e.age = 30
and e.salary between 3000 and 5000;

/*
Brisu se indeksi.
*/

drop index Employees_salary_index on Employees;

drop index Employees_age_index on Employees;

/*
Zakljucak: u zavisnosti od upita, optimizator bira odgovarajuci
indeks. U privom slucaju bira da koristi indeks nad salary, dok
u drugom slucaju bira da koristi indeks nad age.
*/

show profiles;

/*
*************************** 1. row ***************************
EXPLAIN: -> Filter: ((e.age between 20 and 30) and (e.salary between 3000 and 5000))  (cost=103090.95 rows=12279) (actual time=0.378..535.479 rows=9940 loops=1)
    -> Table scan on e  (cost=103090.95 rows=994797) (actual time=0.081..470.078 rows=1000000 loops=1)

*************************** 1. row ***************************
EXPLAIN: -> Filter: ((e.age = 30) and (e.salary between 3000 and 5000))  (cost=103090.95 rows=11052) (actual time=2.099..532.526 rows=903 loops=1)
    -> Table scan on e  (cost=103090.95 rows=994797) (actual time=0.013..470.924 rows=1000000 loops=1)

*************************** 1. row ***************************
EXPLAIN: -> Filter: (e.age between 20 and 30)  (cost=69875.07 rows=39934) (actual time=0.040..127.156 rows=9940 loops=1)
    -> Index range scan on e using Employees_salary_index, with index condition: (e.salary between 3000 and 5000)  (cost=69875.07 rows=79868) (actual time=0.019..124.804 rows=40902 loops=1)

*************************** 1. row ***************************
EXPLAIN: -> Filter: (e.salary between 3000 and 5000)  (cost=11173.22 rows=3395) (actual time=0.306..301.357 rows=903 loops=1)
    -> Index lookup on e using Employees_age_index (age=30)  (cost=11173.22 rows=42284) (actual time=0.011..299.368 rows=22100 loops=1)

*************************** 1. row ***************************
Query_ID: 1
Duration: 0.53668500
   Query: explain analyze
select e.id
from Employees as e
where e.age between 20 and 30
and e.salary between 3000 and 5000
*************************** 2. row ***************************
Query_ID: 2
Duration: 0.53294900
   Query: explain analyze
select e.id
from Employees as e
where e.age = 30
and e.salary between 3000 and 5000
*************************** 3. row ***************************
Query_ID: 3
Duration: 2.08912600
   Query: create index Employees_salary_index on Employees (salary) using btree
*************************** 4. row ***************************
Query_ID: 4
Duration: 2.15776875
   Query: create index Employees_age_index on Employees (age) using btree
*************************** 5. row ***************************
Query_ID: 5
Duration: 0.12825125
   Query: explain analyze
select e.id
from Employees as e
where e.age between 20 and 30
and e.salary between 3000 and 5000
*************************** 6. row ***************************
Query_ID: 6
Duration: 0.30194175
   Query: explain analyze
select e.id
from Employees as e
where e.age = 30
and e.salary between 3000 and 5000
*************************** 7. row ***************************
Query_ID: 7
Duration: 0.01275575
   Query: drop index Employees_salary_index on Employees
*************************** 8. row ***************************
Query_ID: 8
Duration: 0.00774200
   Query: drop index Employees_age_index on Employees
*/