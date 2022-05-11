/*
4. Klasterovanje.

U mysql-u se klasteruje samo primarni kljuc, ili prvi definisani
unique ukoliko ne postoji primarni kljuc a postoji unique, svi ostali 
indeksi su neklasterovani. To objasnjava zasto nije efikasan indeks (ili 
se ne aktivira) koji nije primarni kljuc nad atributom selekcije (u 
nasim primerima prilikom intervalne selekcije) kada selekcija nije velika.

Ukoliko atribut po kome se vrsi selekcija nije jedinstven ili dozvoljava 
null vrednosti, onda se moze dodati nova posebno napravljena kolona 
(sintenticka) koja ima jedinstvene i not null vrednosti koja ce 
predstavljati jedinstveni idektifikator, i upotrebiti za pravljenje unique 
kljuca sa posmatranim atributom. U nasem primeru takva kolona prirodno vec 
postoji (id) tako da cemo nju iskoristiti.

Primer izdvajanje po tacnoj vrednosti
    - kada je selekcija mala
    - kada je selekcija velika
Primer izdvajanja po intervalu
    - kada je selekcija mala
    - kada je selekcija velika

Cak iako su podaci sortirani, indeks se ne smatra klasterovanim
ukoliko nije u pitanju primarni kljuc ili prvo definisani unique.
*/

use office;
set profiling = 1;

/*
Pokretanje upita bez postojanja indeksa.
*/

/*
Izdvajanje po tacnoj vrednosti kada je selekcija velika.
*/

explain analyze
select e.id, e.name, e.surname
from Employees as e
where e.salary = 49000;

/*
Izdvajanje po intervalu kada je selekcija velika.
*/

explain analyze
select e.id, e.name, e.surname
from Employees as e
where e.salary > 49000;

/*
Izdvajanje po intervalu kada je selekcija manja.
*/

explain analyze
select e.id, e.name, e.surname
from Employees as e
where e.salary > 40000;

/*
Izdvajanje po intervalu kada je selekcija jos manja.
*/

explain analyze
select e.id, e.name, e.surname
from Employees as e
where e.salary < 40000;

/*
Kreiranje klasterovanog indeksa po atributu selekcije uz pomoc
kolone sa idektifikatorom.
*/

alter table Employees add constraint unique_salary_id unique (salary, id);

/*
Pokretanje upita sa postojanjem klasterovanog indeksa.
*/

explain analyze
select e.id, e.name, e.surname
from Employees as e
where e.salary = 49000;

explain analyze
select e.id, e.name, e.surname
from Employees as e
where e.salary > 49000;

explain analyze
select e.id, e.name, e.surname
from Employees as e
where e.salary > 40000;

explain analyze
select e.id, e.name, e.surname
from Employees as e
where e.salary < 40000;

/*
Brise se indeks.
*/

alter table Employees drop constraint unique_salary_id;

/*
Zakljucak: sve selekcije iz primera su ubrzane klasterovanjem.
*/

show profiles;

/*
*************************** 1. row ***************************
EXPLAIN: -> Filter: (e.salary = 49000)  (cost=103223.55 rows=99612) (actual time=16.673..495.629 rows=23 loops=1)
    -> Table scan on e  (cost=103223.55 rows=996123) (actual time=0.062..449.103 rows=1000000 loops=1)

*************************** 1. row ***************************
EXPLAIN: -> Filter: (e.salary > 49000)  (cost=103223.55 rows=332008) (actual time=0.052..471.782 rows=20457 loops=1)
    -> Table scan on e  (cost=103223.55 rows=996123) (actual time=0.012..429.406 rows=1000000 loops=1)

*************************** 1. row ***************************
EXPLAIN: -> Filter: (e.salary > 40000)  (cost=103223.55 rows=332008) (actual time=0.011..473.952 rows=204172 loops=1)
    -> Table scan on e  (cost=103223.55 rows=996123) (actual time=0.010..427.250 rows=1000000 loops=1)

*************************** 1. row ***************************
EXPLAIN: -> Filter: (e.salary < 40000)  (cost=103223.55 rows=332008) (actual time=0.012..491.504 rows=795810 loops=1)
    -> Table scan on e  (cost=103223.55 rows=996123) (actual time=0.010..432.267 rows=1000000 loops=1)

*************************** 1. row ***************************
EXPLAIN: -> Index lookup on e using unique_salary_id (salary=49000)  (cost=3.33 rows=23) (actual time=0.014..0.018 rows=23 loops=1)

*************************** 1. row ***************************
EXPLAIN: -> Filter: (e.salary > 49000)  (cost=8530.08 rows=42332) (actual time=0.025..7.235 rows=20457 loops=1)
    -> Index range scan on e using unique_salary_id  (cost=8530.08 rows=42332) (actual time=0.024..5.980 rows=20457 loops=1)

*************************** 1. row ***************************
EXPLAIN: -> Filter: (e.salary > 40000)  (cost=86764.51 rows=430630) (actual time=0.025..59.742 rows=204172 loops=1)
    -> Index range scan on e using unique_salary_id  (cost=86764.51 rows=430630) (actual time=0.024..49.167 rows=204172 loops=1)

*************************** 1. row ***************************
EXPLAIN: -> Filter: (e.salary < 40000)  (cost=100510.71 rows=498856) (actual time=0.022..242.099 rows=795810 loops=1)
    -> Index range scan on e using unique_salary_id  (cost=100510.71 rows=498856) (actual time=0.022..201.477 rows=795810 loops=1)

*************************** 1. row ***************************
Query_ID: 1
Duration: 0.49644200
   Query: explain analyze
select e.id, e.name, e.surname
from Employees as e
where e.salary = 49000
*************************** 2. row ***************************
Query_ID: 2
Duration: 0.47340125
   Query: explain analyze
select e.id, e.name, e.surname
from Employees as e
where e.salary > 49000
*************************** 3. row ***************************
Query_ID: 3
Duration: 0.48734850
   Query: explain analyze
select e.id, e.name, e.surname
from Employees as e
where e.salary > 40000
*************************** 4. row ***************************
Query_ID: 4
Duration: 0.53981750
   Query: explain analyze
select e.id, e.name, e.surname
from Employees as e
where e.salary < 40000
*************************** 5. row ***************************
Query_ID: 5
Duration: 6.77932225
   Query: alter table Employees add constraint unique_salary_id unique (salary, id)
*************************** 6. row ***************************
Query_ID: 6
Duration: 0.00027275
   Query: explain analyze
select e.id, e.name, e.surname
from Employees as e
where e.salary = 49000
*************************** 7. row ***************************
Query_ID: 7
Duration: 0.00897650
   Query: explain analyze
select e.id, e.name, e.surname
from Employees as e
where e.salary > 49000
*************************** 8. row ***************************
Query_ID: 8
Duration: 0.07243275
   Query: explain analyze
select e.id, e.name, e.surname
from Employees as e
where e.salary > 40000
*************************** 9. row ***************************
Query_ID: 9
Duration: 0.28947725
   Query: explain analyze
select e.id, e.name, e.surname
from Employees as e
where e.salary < 40000
*************************** 10. row ***************************
Query_ID: 10
Duration: 3.25873425
   Query: alter table Employees drop constraint unique_salary_id

*/