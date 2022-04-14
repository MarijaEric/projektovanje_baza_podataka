-- Upustvo za pokretanje db2:
-- * pokretanje db2: db2start 
-- * povezivanje na stude2020 bazu: db2 connect to stud2020;
-- 
-- Prevodjenje skriptova:
-- * db2 < name.sql
--
-- Opcije:
-- * -t ~ postaviti da ';' razdvaja upite.
-- * -f ~ cita upit iz datoteke, cije je ime naredni arg
-- * -v ~ 'echo' upita
-- 
-- Primer:
-- * db2 -tvf name.sql > out.txt

-- Pravimo dve tabele za demonstraciju
create table t1(c1 int, c2 float);
insert into t1 values 
(5, 6.0),
(6, 7.0),
(5, 6.0);

create table t2(c1 int, c2 float);
insert into t2 values 
(5, 9.0),
(5, 4.0),
(7, 5.0);

select * from t1;
select * from t2;

-- Primer
create view v1(c1) as
select c1
from t1
where c2 > 0;

select * from v1;

-- Pogledi se obicno koriste za razdvajanje logicke sheme od fizicke
-- ovakvo razdvajanje ima za posledicu nemogucnosti
-- izvrsavanja delete i insert operacija, osim u slucaju
-- jednostavnih pogleda.
-- U tu svrhu se koriste instead of okidaci kojima se omogucavaju
-- ovakve operacije.

-- Ogranicenja za v1:
-- INSERT: Mogu da se dodaju samo vidljive kolone (c1),
-- dok ostale kolone imaju NULL ili podrazumevanu
-- vrednost. Ako su kolone 'NOT NULL', onda dodavanje
-- ne bi bilo moguce
insert into v1(c1) values
(1), (2), (3), (4), (5);

-- DELETE: Uslov brisanja moze da bude samo po 
-- vidljivim kolonama
delete from v1
where c1 = 6;

-- UPDATE: Uslov azuriranja moze da bude samo po
-- vidljivima kolonama i mogu da se azuriraju
-- samo vidjive kolone
update v1
set c1 = c1 + 5
where c1 = 5;

-- Pogled je izmenjen
select * from v1;
-- I tabela je izmenjena preko pogleda
select * from t1;

-- Napomena: Prethodna ogranicenja nisu losa stvar 
-- ako je to ono sto smo hteli da postignemo!

-- Ciscenje:
drop view v1;
drop table t1;
drop table t2;
