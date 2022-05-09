/*
10. Agregatne funkcije, grupisanje.
*/

use office;
set profiling = 1;

/*
Pokretanje upita bez koriscenja indeksa.
*/

explain analyze
select e.did, count(*)
from Employees as e
group by e.did;

explain analyze
select e.did, count(*)
from Employees as e
where e.salary = 10000
group by e.did;

explain analyze
select e.did, min(e.salary)
from Employees as e
group by e.did;

explain analyze
select avg(e.salary)
from Employees as e
where e.age = 25 and e.salary between 3000 and 5000;

/*
Pravi se klasterovani indeks po atributu did.
*/

alter table Employees add constraint unique_did_salary_id unique (did, salary, id);

/*
Prave se indeksi nad age i salary.
*/

create index Employees_salary_index on Employees (salary) using btree;

create index Employees_age_index on Employees (age) using btree;

/*
Pokrecu se upiti ponovo uz mogucnost koriscenja indeksa.
*/

explain analyze
select e.did, count(*)
from Employees as e
group by e.did;

explain analyze
select e.did, count(*)
from Employees as e
where e.salary = 10000
group by e.did;

explain analyze
select e.did, min(e.salary)
from Employees as e
group by e.did;

explain analyze
select avg(e.salary)
from Employees as e
where e.age = 25 and e.salary between 3000 and 5000;

/*
Brisemo indekse.
*/

alter table Employees drop constraint unique_did_salary_id;

drop index Employees_salary_index on Employees;

drop index Employees_age_index on Employees;

/*
Zakljucak: gde postoji selekcija koristi se indeks da se
prvo izvrsi selekcija, pa se onda izracunava agregirana
funkcija.

U prvom upitu se koristi indeks nad did, u drugom upitu 
se koristi indeks nad salary a zatim se sekvencijalno 
prebrojava, u trecem upitu koristi se indeks nad (did, salary)
i u cetvrtom upitu koristi se indeks nad age, ostalo
se izracunava u hodu.
*/

show profiles;

/*
*************************** 1. row ***************************
EXPLAIN: -> Table scan on <temporary>  (actual time=0.001..0.030 rows=999 loops=1)
    -> Aggregate using temporary table  (actual time=679.738..679.806 rows=999 loops=1)
        -> Table scan on e  (cost=103170.55 rows=995593) (actual time=0.153..437.703 rows=1000000 loops=1)

*************************** 1. row ***************************
EXPLAIN: -> Table scan on <temporary>  (actual time=0.001..0.001 rows=20 loops=1)
    -> Aggregate using temporary table  (actual time=465.334..465.335 rows=20 loops=1)
        -> Filter: (e.salary = 10000)  (cost=103170.55 rows=99559) (actual time=9.273..465.189 rows=22 loops=1)
            -> Table scan on e  (cost=103170.55 rows=995593) (actual time=0.010..419.624 rows=1000000 loops=1)

*************************** 1. row ***************************
EXPLAIN: -> Table scan on <temporary>  (actual time=0.001..0.047 rows=999 loops=1)
    -> Aggregate using temporary table  (actual time=795.524..795.625 rows=999 loops=1)
        -> Table scan on e  (cost=103170.55 rows=995593) (actual time=0.012..496.631 rows=1000000 loops=1)

*************************** 1. row ***************************
EXPLAIN: -> Aggregate: avg(e.salary)  (actual time=460.947..460.947 rows=1 loops=1)
    -> Filter: ((e.age = 25) and (e.salary between 3000 and 5000))  (cost=103170.54 rows=11061) (actual time=0.230..460.744 rows=892 loops=1)
        -> Table scan on e  (cost=103170.54 rows=995593) (actual time=0.018..411.354 rows=1000000 loops=1)

*************************** 1. row ***************************
EXPLAIN: -> Group aggregate: count(0)  (actual time=0.518..322.545 rows=999 loops=1)
    -> Index scan on e using unique_did_salary_id  (cost=105221.33 rows=995502) (actual time=0.043..269.231 rows=1000000 loops=1)

*************************** 1. row ***************************
EXPLAIN: -> Group aggregate: count(0)  (actual time=0.013..0.018 rows=20 loops=1)
    -> Index lookup on e using Employees_salary_index (salary=10000)  (cost=3.24 rows=22) (actual time=0.011..0.015 rows=22 loops=1)

*************************** 1. row ***************************
EXPLAIN: -> Index range scan on e using index_for_group_by(unique_did_salary_id)  (cost=1351.20 rows=1001) (actual time=0.014..2.535 rows=999 loops=1)

*************************** 1. row ***************************
EXPLAIN: -> Aggregate: avg(e.salary)  (actual time=4.397..4.397 rows=1 loops=1)
    -> Filter: (e.salary between 3000 and 5000)  (cost=436.15 rows=3505) (actual time=0.017..4.328 rows=892 loops=1)
        -> Index lookup on e using Employees_age_index (age=25)  (cost=436.15 rows=43404) (actual time=0.015..3.480 rows=22097 loops=1)

*************************** 1. row ***************************
Query_ID: 1
Duration: 0.68072425
   Query: explain analyze
select e.did, count(*)
from Employees as e
group by e.did
*************************** 2. row ***************************
Query_ID: 2
Duration: 0.46562025
   Query: explain analyze
select e.did, count(*)
from Employees as e
where e.salary = 10000
group by e.did
*************************** 3. row ***************************
Query_ID: 3
Duration: 0.79603725
   Query: explain analyze
select e.did, min(e.salary)
from Employees as e
group by e.did
*************************** 4. row ***************************
Query_ID: 4
Duration: 0.46129225
   Query: explain analyze
select avg(e.salary)
from Employees as e
where e.age = 25 and e.salary between 3000 and 5000
*************************** 5. row ***************************
Query_ID: 5
Duration: 5.31912525
   Query: alter table Employees add constraint unique_did_salary_id unique (did, salary, id)
*************************** 6. row ***************************
Query_ID: 6
Duration: 2.06066100
   Query: create index Employees_salary_index on Employees (salary) using btree
*************************** 7. row ***************************
Query_ID: 7
Duration: 2.42600075
   Query: create index Employees_age_index on Employees (age) using btree
*************************** 8. row ***************************
Query_ID: 8
Duration: 0.32326500
   Query: explain analyze
select e.did, count(*)
from Employees as e
group by e.did
*************************** 9. row ***************************
Query_ID: 9
Duration: 0.00031525
   Query: explain analyze
select e.did, count(*)
from Employees as e
where e.salary = 10000
group by e.did
*************************** 10. row ***************************
Query_ID: 10
Duration: 0.00275900
   Query: explain analyze
select e.did, min(e.salary)
from Employees as e
group by e.did
*************************** 11. row ***************************
Query_ID: 11
Duration: 0.00472375
   Query: explain analyze
select avg(e.salary)
from Employees as e
where e.age = 25 and e.salary between 3000 and 5000
*************************** 12. row ***************************
Query_ID: 12
Duration: 6.79179300
   Query: alter table Employees drop constraint unique_did_salary_id
*************************** 13. row ***************************
Query_ID: 13
Duration: 0.04016450
   Query: drop index Employees_salary_index on Employees
*************************** 14. row ***************************
Query_ID: 14
Duration: 0.02970800
   Query: drop index Employees_age_index on Employees
*/