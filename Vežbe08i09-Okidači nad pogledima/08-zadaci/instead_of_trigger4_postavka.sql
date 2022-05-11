-- Prilikom unosa podataka u tabelu, BEFORE okidaci i uslovi ogranicenja
-- Proveravaju da li su podaci koji se unose ispravi, ali nemaju nacina
-- da ih isprave, vec samo dozvoljavaju ili odbijaju unos

-- Sledeci zadatak demonstrira preusmeravanje losih podataka u drugu tabelu

create table addresses(
  name varchar(10),
  number int,
  street varchar(10),
  country varchar(10) with default 'CANADA'
);

create table bad_addresses as (
  select cast(NULL as varchar(30)) as reason, A.*
  from addresses as A
) definition only;

-- Zadatak1: Napraviti pogled `adresses_v` identican tabeli addresses

-- Studentski kod

-- Zadatak2: Napraviti okidac `insert_addresses_v` koji proverava
-- da li je adresa koja se unosi u tabelu validna
-- Uslovi
-- 1) `number` ne sme da bude NULL
-- 2) `number` mora da bude veci od 0
-- 3) `name` ne sme da bude NULL
-- 4) duzina niske `name` mora da bude veca od 0
-- 5) `street` ne sme da bude NULL
-- 6) duzina niske `street` mora da bude veca od 0
-- 7) `country` ne sme da bude NULL
-- 8) Dozvoljene vrednosti za `country` su:
--    'CANADA', 'USA', 'GERMANY', 'FRANCE', 'SERBIA'
-- Ukoliko uslov nije ispunjen, onda u tabelu `bad_addresses`
-- Uneti odgovarajuci poruku o gresci u okviru kolone `reason`

-- Studentski kod

-- TESTIRANJE
insert into addresses_v values
  ('Jones', 510, 'Yonge St.', DEFAULT),
  ('Smith', -1, 'Nowhere', 'USA'),
  (NULL, 38, 'Am Feldweg', 'GERMANY'),
  ('Poubelle', 23, 'Rue De Jardin', 'FRANCE');
  
select * from addresses;

select * from bad_addresses;

-- Ciscenje
drop table addresses;
drop table bad_addresses;
drop view addresses_v;
drop trigger insert_addresses_v;
