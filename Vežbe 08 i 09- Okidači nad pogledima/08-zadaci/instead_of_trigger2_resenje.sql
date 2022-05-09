-- Menadzer moze videti plate svojih zaposlenih, 
-- ali ne i zaposlenih ostalih menadzera, kao ni njihove plate. 
-- Napravimo shemu i okidace koji omogucavaju menadzerima 
-- da menjaju plate zaposlenima za koje su zaduzeni

-- Priprema:
create table profiles(
  empid int, 
  name varchar(20), 
  sqlid varchar(18),
  mgrid int, 
  salary decimal(9,2), 
  ismgr char(1));
  
insert into profiles values
  (0001, 'SuperBoss', 'sboss', NULL, 500000, 'Y'),
  (1001, 'BigBoss', 'bboss', 0001, 200000, 'Y'),
  (1002, 'MySelf', USER, 0001, 250000, 'Y'),
  (2001, 'FirstLine', 'fline', 1001, 100000, 'Y'),
  (2002, 'MiddleMen', 'mmen', 1001, 110000, 'Y'),
  (2003, 'Yeti', 'yeti', 1002, 90000, 'Y'),
  (2004, 'BigFoot', 'bfoot', 1002, 80000, 'N'),
  (3001, 'TinyToon', 'ttoon', 2001, 50000, 'N'),
  (3002, 'Mouse', 'Mouse', 2001, 40000, 'N'),
  (3003, 'Whatsisname','wname', 2002, 45000, 'N'),
  (3004, 'Hasnoclue', 'hclue', 2002, 38000, 'N'),
  (3005, 'Doesallwork','dwork', 2003, 15000, 'N');
  
select * from profiles;

-- Zadatak1: Mi smo menadzer drugog nivoa:
-- (1002, 'MySelf', USER, 0001, 250000, 'Y')
-- Napraviti pogled koji nam omogucava da vidimo 
-- plate svojih zaposlenih (kao i svoju).
-- Pomoc: Potrebno je koristiti rekurzivni upit.

create view my_emps(empid, level, salary) as
with rec(empid, level, salary) as (
  -- Inicijalizacija - Dodajemo sebe u tabelu
  select P.empid, 0, P.salary
  from profiles as P
  where P.sqlid = USER
  
  union all
  
  -- Rekurzivno dodajemo ostale koji su nam podredjeni
  select P.empid, level-1, P.salary
  from profiles as P, rec as R
  where R.empid = P.mgrid
    and level > -100
)
select empid, level, salary from rec;

select * from my_emps;

-- Zadatak2: Napraviti pogled koji nam omogucava
-- da vidimo sledece: 
-- empid, neposredno iz PROFILES
-- name, neposredno iz PROFILES
-- mgrname, ime neposredno nadredjenog
-- salary, plata ako je nas zaposleni, inace NULL
-- sqlid, neposredno iz PROFILES
-- ismgr, neposredno iz PROFILES

create view emps(empid, name, mgrname, salary, sqlid, ismgr) as
select P.empid, P.name, M.name, ME.salary, P.sqlid, P.ismgr
from profiles as P left outer join my_emps as ME
  on P.empid = ME.empid
left outer join profiles as M
  on P.mgrid = M.empid;

select * from emps;

-- Zadatak3: Napraviti okidac koji nam omogucava
-- da dodajemo nove radnike (koji su nam podredjeni)

--#SET TERMINATOR @

create trigger emps_insert instead of insert on emps
referencing new as n
for each row mode db2sql
begin atomic
  -- Treba sledece da uradimo:
  -- 1) Na osnovu imena menadzera (mgrname) treba da zakljucimo
  -- 	ID nadredjenog naseg novog zaposlenog;
  declare mgrid int;
  declare ismgr char(1);
  set (mgrid, ismgr) = (
	select P.empid, P.ismgr
	from profiles as P
	where n.mgrname = P.name
  );
  -- 2) Treba da proverimo da li je taj nadredjeni naseg novog zaposlenog
  --    jedan od nasih zaposlenih (mgrid in my_emps);
  -- 3) Treba da proverimo da li je taj nadredjeni naseg novog zaposlenog
  --    menadzer (ismgr = 'Y');
    if mgrid not in (select empid from my_emps) -- (2)
    or ismgr <> 'Y' -- (3)
    then
	  signal sqlstate '70000' set message_text = 'Not Authorized!';
    end if;
  -- 4) Ako je sve dobro, treba da dodajmo u tabelu profiles
  --    novog zaposlenog.
  insert into profiles values
	(n.empid, n.name, n.sqlid, mgrid, n.salary, n.ismgr);
end@

--#SET TERMINATOR ;

-- Zadatak4: Napraviti okidac koji nam omogucava
-- da azuriramo informacije o radnicima koji su
-- nam podredjeni

--#SET TERMINATOR @

create trigger emps_update instead of update on emps
referencing new as n old as o
for each row mode db2sql
begin atomic
  -- Treba da proverimo sledece (za radnika kojeg menjamo):
  -- 1) Da li po starim podacima radnik pripada skupu nasih radnika?
  -- 2) Da li po novim podaicma radnik pripada skupu nasih radnika?
  -- 3) Da li menjamo radnika koji nismo mi?
  -- Sta jos moze da bude problematicno?
  -- 4) Da li je neko ko ima podredjene dobio vrednost za ismgr = 'N'?
  -- 5) Da li je novi nadredjeni naseg radnika menadzer?
  
  declare new_mgrid int;
  declare old_mgrid int;
  
  set old_mgrid = (
	select P.empid
	from profiles as P
	where o.name = P.name
  );
  
  set new_mgrid = (
	select P.empid
	from profiles as P
	where n.name = P.name
  );
  
  if old_mgrid not in (select empid from my_emps) -- (1)
  or new_mgrid not in (select empid from my_emps) -- (2)
  or o.sqlid = USER -- (3)
  or (
	0 < (
	  select count(*) 
	  from profiles as P 
	  where P.mgrid = n.empid
	)
	and n.ismgr = 'N'
  ) 
  or new_mgrid in (select P.empid from profiles as P where P.ismgr = 'Y')
  then
	signal sqlstate '70000' set message_text = 'Not Authorized!';
  end if;

  update profiles
  set 
	empid = n.empid,
	mgrid = new_mgrid,
	salary = n.salary,
	sqlid = n.sqlid,
	name = n.name,
	ismgr = n.ismgr
  where empid = o.empid;
end@

--#SET TERMINATOR ;

-- Zadatak5: Napraviti okidac koji nam omogucava
-- da brisemo radnike koji su nam podredjeni (ali ne i samog sebe)
  
--#SET TERMINATOR @

create trigger emps_delete instead of delete on emps
referencing old as o
for each row mode db2sql
begin atomic
  -- Treba da proverimo sledece:
  -- 1) Da li brisemo nekog naseg zaposlenog?
  -- 2) Da li brisemo sebe?
  -- 3) Da li je taj koga brisemo ima podredjene?
  declare mgrid int;
  set mgrid = (
	select P.empid
	from profiles as P
	where o.name = P.name
  );
  
  if o.empid not in (select empid from my_emps)
  or o.sqlid = USER
  or 0 < (
	  select count(*) 
	  from profiles as P 
	  where P.mgrid = o.empid)
  then
	signal sqlstate '70000' set message_text = 'Not Authorized!';
  end if;
	  
  delete from profiles where empid = o.empid;
end@

--#SET TERMINATOR ;
  
-- Testiranje

-- INSERT (validan)
insert into emps values
  (4005, 'New Guy', 'Yeti', 35000, 'nguy', 'N');
  
-- INSERT (nevalidan)
insert into emps values
  (4005, 'New Guy', 'SuperBoss', 12000, 'nguy', 'Y');
  
-- UPDATE (validan)
update emps
set 
  ismgr = 'Y',
  salary = salary * 1.3,
  mgrname = 'MySelf'
where name = 'Doesallwork';
  
-- UPDATE (nevalidan)
update emps
set 
  ismgr = 'Y',
  salary = 1000000,
  mgrname = 'MySelf'
where name = 'MySelf';

-- DELETE (validan)
delete from emps
where name = 'Yeti';

-- DELETE (validan)
delete from emps
where name = 'MySelf';

select * from emps;
select * from profiles;
  
-- Ciscenje:
drop trigger emps_insert;
drop trigger emps_update;
drop trigger emps_delete;
drop view my_emps;
drop view emps;
drop table profiles;