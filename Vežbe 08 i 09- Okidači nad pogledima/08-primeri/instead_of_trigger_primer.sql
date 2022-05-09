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
create view v5(c1, c2)
as select distinct c1, c2 
from t1;

select * from v5;

-- Ogranicenja: Ne mozemo da brisemo ili
-- azuriramo, jer ne znamo na koju vrstu se misli.

-- Zelimo da napravimo INSTEAD OF okidac
-- koji brise sve redove koji zadovoljavaju uslove
-- preko napravljenog pogleda

-- Ideja: Precizno definisemo kako funkcionise DELETE
-- operacija tako sto definisemo okidac i umesto
-- da sistem pokusa da izvrsi DELETE na neki nacin,
-- okida se okidac.

-- Sintaksa:
-- create trigger [IME] instead of [insert|delete|update] on [IME_TABELE]
-- referencing [old as [novo_ime_za_old]/new as [novo_ime_za_new]]
-- for each row mode db2sql
-- [OPERACIJA]

-- Resenje
create trigger v5_delete instead of delete on v5
referencing old as o
for each row mode db2sql
delete from t1
where o.c1 = c1
and o.c2 = c2;

delete from v5
where c1 = 5;

select * from v5;
select * from t1;

-- Napomena; INSTEAD OF okidaci se uvek definisu samo nad pogledima,

-- Ciscenje:
drop view v5;
drop table t1;
drop table t2;
