-- Dokumentacija za EXPLAIN ANALYZE:
-- https://dev.mysql.com/doc/refman/8.0/en/explain.html
-- https://thoughtbot.com/blog/reading-an-explain-analyze-query-plan

-- Ukratko:
-- Prikazuje nam operacije koje se vrse u obliku stabla:
-- Za svaki cvor sadrzi:
--   * ime operacije (primer. 'Filter', 'Table Scan');
--   * cenu operacije
--   * procenjeni broj dohvacenih redova
--   * procenjeno vreme

-- Ovo nam omogucava da uporedjujemo razlicite verzije upita
-- i testiramo potencijalne optimazicije (npr. indeksi)

-- Primer: Zelimo da izlistamo sve muzicare iz baze podataka

use office;

explain analyze
select e.emp_id, e.name, e.surname
from emps as e
where e.job = 'Musician';

-- EXPLAIN: 
-- -> Filter: (e.job = 'Musician')  (cost=100642.25 rows=99657) (actual time=0.076..375.037 rows=83335 loops=1)
--     -> Table scan on e  (cost=100642.25 rows=996570) (actual time=0.065..290.080 rows=1000000 loops=1)

-- Cena je 100642.25, a potrebno vreme za jedan red, odnosno za sve 
-- redove je [0.076, 375.037] milisekundi
-- Vidimo da je ovde bilo neophodno da se procita skoro cela tabela 
-- (996570 procitanih redova od milion)

-- Zelimo da izvrsimo istu operaciju, ali sa indeksom nad kolonom 'e.job'
-- Sintaksa za kreiranje indeksa
-- create index [ime] on [ime_tabele] ([kolone]) 
-- opciono pre `on` moze da se doda: using [BTREE|HASH] za izbor tipa indeksa

-- Testiramo btree index

create index emps_job_index on emps (job) using btree;

explain analyze
select e.emp_id, e.name, e.surname
from emps as e
where e.job = 'Musician';

-- EXPLAIN: 
-- -> Index lookup on e using emps_job_index (job='Musician')  (cost=19319.15 rows=163634) 
--    (actual time=0.479..253.830 rows=83335 loops=1)

-- Sada je znatno manja cena: 19319.15,
-- a vreme za jedan red je 0.479 i za sve redove je 253.830 milisekundi
-- (prvi broj je povecan, a drugi je smanjen)

drop index emps_job_index on emps;
