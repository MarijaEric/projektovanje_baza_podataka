/*
9. Indeks nad vise atributa - kompozitni indeks.

Bitan je redosled atributa.

Kompozitni indeks se moze iskoristiti i za pretragu po
pocetnom delu indeksa, ali ne i za proizvoljni atribut
koji se nalazi u indeksu (nije na pocetku).
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
Kreira se klasterovani kompozitni indeks (salary, age)
*/

alter table Employees add constraint unique_sal_age_id unique(salary, age, id);

/*
Pokretanje upita sa postojanjem kompozitnog indksa.
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
Brise se indeks. 
*/

alter table Employees drop constraint unique_sal_age_id;

/*
Kreira se klasterovani kompozitni indeks (age, salary)
*/

alter table Employees add constraint unique_age_sal_id unique(age, salary, id);

/*
Pokretanje upita sa postojanjem kompozitnog indksa.
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
Brise se indeks. 
*/

alter table Employees drop constraint unique_age_sal_id;

/*
Oba kompozitna indeksa ubrzavaju oba upita. Kompozitni indeks (salary, age)
vise odgovara za prvi upit zato sto je selekcija po salary veca, dok 
kompozitni indeks (age, salary) vise odgovara drugom upitu, zato sto je
selekcija u njemu veca po atributu age.
*/

show profiles;

/*
*************************** 1. row ***************************
EXPLAIN: -> Filter: ((e.age between 20 and 30) and (e.salary between 3000 and 5000))  (cost=103090.95 rows=12279) (actual time=0.228..468.533 rows=9940 loops=1)
    -> Table scan on e  (cost=103090.95 rows=994797) (actual time=0.025..409.358 rows=1000000 loops=1)

*************************** 1. row ***************************
EXPLAIN: -> Filter: ((e.age = 30) and (e.salary between 3000 and 5000))  (cost=103090.95 rows=11052) (actual time=1.593..457.866 rows=903 loops=1)
    -> Table scan on e  (cost=103090.95 rows=994797) (actual time=0.010..404.703 rows=1000000 loops=1)

*************************** 1. row ***************************
EXPLAIN: -> Filter: ((e.age between 20 and 30) and (e.salary between 3000 and 5000))  (cost=15966.34 rows=8804) (actual time=0.030..12.906 rows=9940 loops=1)
    -> Index range scan on e using unique_sal_age_id  (cost=15966.34 rows=79240) (actual time=0.028..10.231 rows=40885 loops=1)

*************************** 1. row ***************************
EXPLAIN: -> Filter: ((e.age = 30) and (e.salary between 3000 and 5000))  (cost=15950.22 rows=7916) (actual time=0.035..10.582 rows=903 loops=1)
    -> Index range scan on e using unique_sal_age_id  (cost=15950.22 rows=79160) (actual time=0.022..8.617 rows=40883 loops=1)

*************************** 1. row ***************************
EXPLAIN: -> Filter: ((e.age between 20 and 30) and (e.salary between 3000 and 5000))  (cost=86165.82 rows=47513) (actual time=0.033..102.498 rows=9940 loops=1)
    -> Index range scan on e using unique_age_sal_id  (cost=86165.82 rows=427658) (actual time=0.031..81.365 rows=223371 loops=1)

*************************** 1. row ***************************
EXPLAIN: -> Filter: ((e.age = 30) and (e.salary between 3000 and 5000))  (cost=182.95 rows=903) (actual time=0.046..0.564 rows=903 loops=1)
    -> Index range scan on e using unique_age_sal_id  (cost=182.95 rows=903) (actual time=0.045..0.439 rows=903 loops=1)

*************************** 1. row ***************************
Query_ID: 1
Duration: 0.46949050
   Query: explain analyze
select e.id
from Employees as e
where e.age between 20 and 30
and e.salary between 3000 and 5000
*************************** 2. row ***************************
Query_ID: 2
Duration: 0.45818850
   Query: explain analyze
select e.id
from Employees as e
where e.age = 30
and e.salary between 3000 and 5000
*************************** 3. row ***************************
Query_ID: 3
Duration: 6.20935175
   Query: alter table Employees add constraint unique_sal_age_id unique(salary, age, id)
*************************** 4. row ***************************
Query_ID: 4
Duration: 0.01379700
   Query: explain analyze
select e.id
from Employees as e
where e.age between 20 and 30
and e.salary between 3000 and 5000
*************************** 5. row ***************************
Query_ID: 5
Duration: 0.01081025
   Query: explain analyze
select e.id
from Employees as e
where e.age = 30
and e.salary between 3000 and 5000
*************************** 6. row ***************************
Query_ID: 6
Duration: 2.93918350
   Query: alter table Employees drop constraint unique_sal_age_id
*************************** 7. row ***************************
Query_ID: 7
Duration: 7.15387875
   Query: alter table Employees add constraint unique_age_sal_id unique(age, salary, id)
*************************** 8. row ***************************
Query_ID: 8
Duration: 0.10364450
   Query: explain analyze
select e.id
from Employees as e
where e.age between 20 and 30
and e.salary between 3000 and 5000
*************************** 9. row ***************************
Query_ID: 9
Duration: 0.00094900
   Query: explain analyze
select e.id
from Employees as e
where e.age = 30
and e.salary between 3000 and 5000
*************************** 10. row ***************************
Query_ID: 10
Duration: 3.62096200
   Query: alter table Employees drop constraint unique_age_sal_id
*/

