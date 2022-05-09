-- Menadzer moze videti plate svojih zaposlenih, 
-- ali ne i zaposlenih ostalih menadzera, kao ni njihove plate. 
-- Napravimo shemu i okidace koji omogucavaju menadzerima 
-- da menjaju plate zaposlenima za koje su zaduzen

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

-- Studentski kod

-- Zadatak2: Napraviti pogled koji nam omogucava
-- da vidimo sledece: 
-- empid, neposredno iz PROFILES
-- name, neposredno iz PROFILES
-- mgrname, ime neposredno nadredjenog
-- salary, plata ako je nas zaposleni, inace NULL
-- sqlid, neposredno iz PROFILES
-- ismgr, neposredno iz PROFILES

-- Studentski kod

-- Zadatak3: Napraviti okidac koji nam omogucava
-- da dodajemo nove radnike (koji su nam podredjeni)

-- Studentski kod

-- Zadatak4: Napraviti okidac koji nam omogucava
-- da azuriramo informacije o radnicima koji su
-- nam podredjeni

-- Studentski kod

-- Zadatak5: Napraviti okidaac koji nam omogucava
-- da brisemo radnike koji su nam podredjeni (ali ne i samog sebe)
  
-- Studentski kod
  
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
  
-- Ciscenje:
drop trigger emps_insert;
drop trigger emps_update;
drop trigger emps_delete;
drop view my_emps;
drop view emps;
drop table profiles;