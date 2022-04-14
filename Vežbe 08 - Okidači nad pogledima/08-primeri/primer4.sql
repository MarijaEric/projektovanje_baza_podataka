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

-- Primer:
create view v4(c1, c2)
as select c1, c2
from t1

union all

select c1, c2
from t2;

select * from v4;

-- Ogranicenja: Preko ovo pogleda se mogu brisati vrste,
-- jer svaka vrsta potice iz tacno jedne tabele,
-- ali nije moguce dodavati, jer nije jasno u
-- u koju tabelu se dodaje vrsta.
update v4
set c1 = c1 + 1
where c1 = 5;

select * from v4;

select * from t1;
select * from t2;

-- Ciscenje:
drop view v4;
drop table t1;
drop table t2;
