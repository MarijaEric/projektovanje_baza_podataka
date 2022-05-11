use office;
SET profiling = 1;

-- U nastavku se nalaze upiti koji se cesto koriste
-- Neophodno je da se smisli nacin optimizacije ovih upita
-- Pretpostavimo da su svi upiti jednako bitni

-- Broj ljudi koji su dobili posao u poslednjih 42 nedelje i koji imaju platu vecu od 5000
explain analyze 
select count(*) as 'New Employees'
from emps as e
where e.salary >= 5000
  and e.hire_date >= date_add(curdate(), INTERVAL -42*7 DAY)\G

-- Broj ljudi po svakoj profesiji, prosecna plata i std plate
explain analyze 
select 
    e.job, 
    count(*) as 'count', 
    avg(e.salary) as 'average salary', 
    stddev(e.salary) as 'salary stdev'
from emps as e
group by e.job
order by 3 desc\G

-- Koliko se kojih kombinacija ime+prezime pojavljuje
explain analyze 
select e.name, e.surname, count(*)
from emps as e
group by e.name, e.surname\G


-- Koliko se pojavljuje osoba sa navedenim imenom
explain analyze 
select count(*)
from emps as e
where e.name = 'Annabelle'\G

-- Napomena: 
-- Mysql postavlja implicitno klasterovane indekse nad kljucevima tabele,
-- a svi indeksi koje mi napravimo su neklasterovani

-- Komentari:
-- 1) Koriste se svi atributi sem 'emp_id' tj. kandidati za indekse 
--    (sa indeksima upita) su 
--    name (3), surname (3), job (2), hire_date (1) i salary (1, 2)
-- 2) Mozemo da napravimo kompozitni indeks <name, surname> za index-only
--    strategiju u trecem upitu
-- 3) U drugom upitu nije lose da se napravi indeks nad <job>, 
--    a indeks <salary> ne znaci puno, jer moramo proci skroz kroz svaku grupu
-- 4) U prvom upitu su opcije <salary>, <hire_date>, <salary, hire_date>
--    Znamo da uslov 'e.salary >= 5000' obuhvata oko 50% tabele 
--    tj. nije idealna selektivnost,
--    a 'e.hire_date >= date_add(curdate(), INTERVAL -42*7 DAY)' 
--    verovatno ima dobru selektivnost

create index i_emps_name_surname on emps (name, surname) using btree;

create index i_emps_job on emps (job) using btree;

create index i_emps_hire_date on emps (hire_date) using btree;

-- Broj ljudi koji su dobili posao u poslednjih 42 nedelje i koji imaju platu vecu od 5000
explain analyze 
select count(*) as 'New Employees'
from emps as e
where e.salary >= 5000
  and e.hire_date >= date_add(curdate(), INTERVAL -42*7 DAY)\G

-- Broj ljudi po svakoj profesiji, prosecna plata i std plate
explain analyze 
select 
    e.job, 
    count(*) as 'count', 
    avg(e.salary) as 'average salary', 
    stddev(e.salary) as 'salary stdev'
from emps as e
group by e.job
order by 3 desc\G

-- Koliko se kojih kombinacija ime+prezime pojavljuje
explain analyze 
select e.name, e.surname, count(*)
from emps as e
group by e.name, e.surname\G

-- Koliko se pojavljuje osoba sa navedenim imenom
explain analyze 
select count(*)
from emps as e
where e.name = 'Annabelle'\G

drop index i_emps_name_surname on emps;

drop index i_emps_job on emps;

drop index i_emps_hire_date on emps;

SHOW PROFILES;

-- PRVI UPIT (1)

-- Bez Indeksa, vreme: 0.46987675
-- EXPLAIN: 
-- -> Aggregate: count(0)  (actual time=468.682..468.683 rows=1 loops=1)
--     -> Filter: ((e.salary >= 5000) and (e.hire_date >= <cache>((curdate() + interval (-(42) * 7) day))))  (cost=78474.44 rows=110469) (actual time=0.139..467.388 rows=13225 loops=1)
--         -> Table scan on e  (cost=78474.44 rows=994424) (actual time=0.083..332.242 rows=1000000 loops=1)
-- Vreme: 

-- 

-- Sa indeksom, vreme: 0.09092425
-- EXPLAIN: 
-- -> Aggregate: count(0)  (actual time=90.254..90.255 rows=1 loops=1)
--     -> Filter: (e.salary >= 5000)  (cost=19874.96 rows=14721) (actual time=0.377..89.450 rows=13225 loops=1)
--         -> Index range scan on e using i_emps_hire_date, with index condition: (e.hire_date >= <cache>((curdate() + interval (-(42) * 7) day)))  (cost=19874.96 rows=44166) (actual time=0.376..87.463 rows=23663 loops=1)

--
--
--

-- DRUGI UPIT (2)

-- Bez Indeksa, vreme: 1.33717475
-- EXPLAIN: 
-- -> Sort: average salary DESC  (actual time=1336.570..1336.572 rows=12 loops=1)
--     -> Table scan on <temporary>  (actual time=0.001..0.002 rows=12 loops=1)
--         -> Aggregate using temporary table  (actual time=1336.539..1336.541 rows=12 loops=1)
--             -> Table scan on e  (cost=100571.65 rows=994424) (actual time=0.040..347.072 rows=1000000 loops=1)

--

-- Sa indeksom, vreme: 3.26188550
-- EXPLAIN: 
-- -> Sort: `average salary` DESC  (actual time=3261.391..3261.392 rows=12 loops=1)
--     -> Stream results  (actual time=294.266..3261.326 rows=12 loops=1)
--         -> Group aggregate: count(0), avg(e.salary), std(e.salary)  (actual time=294.248..3261.212 rows=12 loops=1)
--             -> Index scan on e using i_emps_job  (cost=100571.65 rows=994424) (actual time=0.165..2934.461 rows=1000000 loops=1)

--
--
--

-- TRECI UPIT (3)

-- Bez indeksa, vreme: 1.26375650
-- EXPLAIN:
-- -> Table scan on <temporary>  (actual time=0.001..0.009 rows=128 loops=1)
--     -> Aggregate using temporary table  (actual time=1263.233..1263.247 rows=128 loops=1)
--         -> Table scan on e  (cost=100571.65 rows=994424) (actual time=0.043..298.889 rows=1000000 loops=1)

-- Sa indeksom, vreme: 0.48782900
-- EXPLAIN: 
-- -> Group aggregate: count(0)  (actual time=3.946..487.221 rows=128 loops=1)
--     -> Index scan on e using i_emps_name_surname  (cost=100571.65 rows=994424) (actual time=0.034..262.230 rows=1000000 loops=1)

-- U prvom i trecem upitu smo dobili optimizaciju novim indeksima, medjutim na drugom upitu
-- se ne isplati praviti indeks. Primetimo da je 'Table Scan' jeftiniji od 'Index Scan'

-- Za domaci: Testirati alternative...

