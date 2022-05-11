drop database if exists vezbe;
create database vezbe character set = utf8;
use vezbe;

-- tipovi okidaci
-- before - izvrsavaju se pre operacije
-- after - izvrsavaju posle operacije

-- operacije za okidanje
-- insert
-- delete
-- update

-- tabela racuna: 
-- acc_num ~ broj racuna
-- amount ~ kolicina
create table account(
    acc_num int not null primary key,
    amount dec(10, 2)
);

-- globalna promenljiva: suma svih racuna
set @sum = 0;

-- Sablon sintakse za okidace:
--
-- create trigger [IME] [before|after] [insert|delete|update] on [IME_TABELE]
-- for each row
-- begin
--      [OPERACIJA_1];
--      [OPERACIJA_2];
--      ...
--      [OPERACIJA_K];
-- end$$

delimiter $$

create trigger ukupna_suma_novca after insert on account
for each row
begin
    set @sum = @sum + new.amount;
end$$

delimiter ;

insert into account values
    (111, 123),
    (112, 321),
    (113, 512);

select @sum as 'total amount inserted';

