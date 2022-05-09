-- Date su tabele PERSONS, EMPLOYEES i STUDENTS

create table persons(
  ssn int not null primary key,
  name varchar(20) not null
);

create table employees(
  ssn int not null primary key,
  company varchar(20) not null,
  salary decimal(9, 2),
  foreign key (ssn)
	references persons(ssn)
	on delete cascade
	on update restrict
);

create table students(
  ssn int not null primary key,
  university varchar(20) not null,
  major varchar(20),
  foreign key (ssn)
	references persons(ssn)
	on delete cascade
	on update restrict
);

-- Zadatak1: Napraviti pogled `info` koji spaja ove podatke u jedno
-- Motivacija: Spajanje ovih tabela u jedno moze biti zahtevno, 
-- tako da pravimo pogled

-- Svaka osoba se nalazi u tabeli `persons`
-- Mozemo da prilepimo informacije o poslu i studiranju
-- preko 'left join'. To znaci da ako osoba nije student,
-- ona ce za te kolone imate nedostajuce vrednosti.
-- Isto vazi i ako nije zaposlena.
create view info as
select P.ssn, P.name, E.company, E.salary, S.university, S.major
from persons as P left outer join employees as E
  on P.ssn = E.ssn
left outer join students as S
  on P.ssn = S.ssn;

-- Zadatak2: Ne mozemo brisati iz prethodno definisanog pogleda
-- Napraviti okidac `info_delete` koji omogucava brisanje iz pogleda
-- preko kolone `ssn`

--#SET TERMINATOR @

create trigger info_delete instead of delete on info
referencing old as o
for each row mode db2sql
begin atomic
  -- Dovoljno je da obrisemo osobu iz tabele `persons`,
  -- a u ostalim tabelam ce biti obrisani kaskadno
  delete from persons
  where ssn = o.ssn;
end@

--#SET TERMINATOR ;

-- Zadatak3: Ne mozemo da dodajemo nove redove 
-- u prethodno definisanom pogledu
-- Napraviti okidac `info insert` koji omogucava dodavanje redova u pogled,
-- a samim tim i indirektno dodavanje u tabele

--#SET TERMINATOR @

create trigger info_insert instead of insert on info
referencing new as n
for each row mode db2sql
begin atomic 
  -- Neophodno je da prvo dodamu osobu u `persons`
  -- Ako ta osoba vec postoji, onda cela `atomic` operacija propada
  insert into persons values
	(n.ssn, n.name);
	
  -- Da li osoba ima posao?
  -- Napomena: Treba razmisliti sta da radimo u slucaju
  --           da je n.company NULL, a n.salary nije NULL.
  if n.company is not null
  then
	insert into employees values
	  (n.ssn, n.company, n.salary);
  end if;
  
  -- Da li je osoba student?
  if n.university is not null
  then
	insert into students values
	  (n.ssn, n.university, n.major);
  end if;
end@

--#SET TERMINATOR ;

-- Zadatak4: Ne mozemo da menjamo vrednosti redova
-- u prethodno definisanom pogledu
-- Napraviti okidac `info update` koji omogucava azuriranje redova u pogled,
-- a smim tim i indirektno azuriranje u tabelama

--#SET TERMINATOR @

create trigger info_update instead of update on info
referencing old as o new as n
for each row mode db2sql
begin atomic
  -- Problem: Ako se menja kolona 'ssn' u baznoj tabeli 'persons'
  --          onda narusavamo integritet stranog kljuca (ako
  --          u tabelama students ili employees postoji strani
  --          kljuc koji referise na taj 'ssn')
  -- Resenje:
  -- 1) Ako se 'ssn' menja, onda prvo dodamo novu vrednost,
  --    izvrsimo sve sto treba i na kraju obrisemo staru
  --    vrednost za 'ssn'.
  -- 2) Skinemo integritet preko 'alter table', odradimo sta treba
  --    i onda vratimo integritet (opet na isti nacin)
  if o.ssn <> n.ssn
  then
	  insert into persons values
	    (n.ssn, n.name);
  end if;
  
  -- 1) nije student --> nije student 
  --    (nema promena)
  -- 2) nije student --> jeste student
  --    (treba da ga dodamo)
  -- 3) jeste student --> nije student
  --    (treba da ga obrisemo)
  -- 4) jeste student --> jeste student
  --    (treba da ga azuriramo)
  if o.university is null
  then
	  -- 1/2) nije student --> nesto
	  if n.university is not null
	  then
	    insert into students values
		    (n.ssn, n.university, n.major);
	  end if;
  else
	  -- 3/4) jeste student --> nesto
	  if n.university is null
	  then
	    -- 3) jeste student --> nije student
	    delete from students
	    where ssn = n.ssn;
	  else
	    -- 4) jeste student --> jeste student
	    update students
	    set
		    ssn = n.ssn,
		    university = n.university,
		    major = n.major
	    where ssn = o.ssn;
	  end if;
  end if;
  
  if o.company is null
  then
	  -- 1/2) nije zaposlen --> nesto
	  if n.company is not null
	  then
	    insert into employees values
		    (n.ssn, n.company, n.salary);
	  end if;
  else
	  -- 3/4) jeste zaposlen --> nesto
	  if n.company is null
	  then
	    -- 3) jeste zaposlen --> nije zaposlen
	    delete from employees
	    where ssn = n.ssn;
	  else
	    -- 4) jeste zaposlen --> jeste zaposlen
	    update employees
	    set
		    ssn = n.ssn,
		    company = n.company,
		    salary = n.salary
	    where ssn = o.ssn;
	  end if;
  end if;
  
  -- Brisemo stari `ssn` osobe, ako je dodat novi
  if o.ssn <> n.ssn
  then
	  delete from persons
	  where ssn = o.ssn;
  end if;
end@

--#SET TERMINATOR ;

-- Testiranje
-- INSERT:
insert into info values
  (123456, 'Smith', NULL, NULL, NULL, NULL),
  (234567, 'Jones', 'Wmart', 20000, NULL, NULL),
  (345678, 'Miller', NULL, NULL, 'Harvard', 'Math'),
  (456789, 'McNuts', 'SelfEmp', 60000, 'UCLA', 'CS');
  
select * from info;

-- DELETE
delete from info
where ssn = 456789;

select * from info;

-- UPDATE
update info
set 
  ssn = 654321,
  name = 'Smith', 
  company = 'SamSvojGazda', 
  salary = 100000, 
  university = 'Gigatrend', 
  major = 'Menadzment'
where ssn = 234567;

select * from info;

select * from persons;
select * from employees;
select * from students;

-- Ciscenje
drop view info;
drop trigger info_delete;
drop trigger info_insert;
drop trigger info_update;
drop table persons;
drop table employees;
drop table students;