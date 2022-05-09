/*
1. Primarni kljuc.

Da bi se nad nekim atributom ili grupom atributa napravio primarni 
kljuc, potrebno je da vrednosti koje moze uzeti taj atribut budu 
jedinstvene i da nisu dozvoljene null vrednosti.

Primer: selekcija po tacnoj vrednosti.
*/

use office;
set profiling = 1;

/*
Pokretanje upita bez postojanja kljuca nad atributom selekcije.
*/

explain analyze
select e.id, e.name, e.surname
from Employees as e
where e.id = 500000;

/*
Kreiranje primarnog kljuca nad atributom nad kojim se vrsi 
selekcija, e.id. To mozemo da uradimo zato sto je e.id
atribut jedinstven i ne dozvoljava null vrednosti. 
*/

alter table Employees add constraint primary key (id);

/*
Pokretanje upita sa postojanjem primarnog kljuca.
*/

explain analyze
select e.id, e.name, e.surname
from Employees as e
where e.id = 500000;

/*
Brisanje kljuca.
*/

alter table Employees drop primary key; 

/*
Zakljucak je da primarni kljuc znatno ubrzava pretragu.
*/

show profiles;

/*
*************************** 1. row ***************************
EXPLAIN: -> Filter: (e.id = 500000)  (cost=103064.35 rows=99453) (actual time=241.469..462.576 rows=1 loops=1)
    -> Table scan on e  (cost=103064.35 rows=994531) (actual time=0.028..420.555 rows=1000000 loops=1)

*************************** 1. row ***************************
EXPLAIN: -> Rows fetched before execution  (cost=0.00..0.00 rows=1) (actual time=0.000..0.000 rows=1 loops=1)

*************************** 1. row ***************************
Query_ID: 1
Duration: 0.46290475
   Query: explain analyze
select e.id, e.name, e.surname
from Employees as e
where e.id = 500000
*************************** 2. row ***************************
Query_ID: 2
Duration: 5.84539525
   Query: alter table Employees add constraint primary key (id)
*************************** 3. row ***************************
Query_ID: 3
Duration: 0.00021075
   Query: explain analyze
select e.id, e.name, e.surname
from Employees as e
where e.id = 500000
*************************** 4. row ***************************
Query_ID: 4
Duration: 2.95238100
   Query: alter table Employees drop primary key
*/