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

-- Studentski kod

-- Zadatak2: Ne mozemo brisati iz prethodno definisanog pogleda
-- Napraviti okidac `info_delete` koji omogucava brisanje iz pogleda
-- preko kolone `ssn`

-- Studentski kod

-- Zadatak3: Ne mozemo da dodajemo nove redove 
-- u prethodno definisanom pogledu
-- Napraviti okidac `info insert` koji omogucava dodavanje redova u pogled,
-- a samim tim i indirektno dodavanje u tabele

-- Studentski kod

-- Zadatak4: Ne mozemo da menjamo vrednosti redova
-- u prethodno definisanom pogledu
-- Napraviti okidac `info update` koji omogucava azuriranje redova u pogled,
-- a smim tim i indirektno azuriranje u tabelama

-- Studentski kod

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