-- Pravimo dve tabele za demonstraciju
create table t1(c1 int, c2 float not null);
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

-- Demonstracija
create view v2(c1, c2) as 
select c1, c2*c2 
from t1;

select * from v2;

-- Ogranicenja:
-- INSERT: Ne mozemo vrsiti dodavanje (c2 je 'NOT NULL' u t1)!

-- Problem: Ne mozemo dodati 'c2*c2'.
insert into v2(c1, c2) values (7, 14);

-- Problem: c2 je 'NOT NULL' u t1.
insert into v2(c1) values (7);

-- DELETE: Uslov brisanja moze da bude samo po 
-- vidljivim kolonama
delete from v2
where c1 = 36;
-- UPDATE: Uslov azuriranja moze da bude samo po
-- vidljivima kolonama i mogu da se azuriraju
-- samo vidjive kolone
update v2
set c1 = c1 + 5
where c1 = 5;
-- Ciscenje:
drop view v2;
drop table t1;
drop table t2;
