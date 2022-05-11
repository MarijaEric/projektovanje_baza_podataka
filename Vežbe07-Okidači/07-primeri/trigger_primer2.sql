drop database if exists vezbe;
create database vezbe character set = utf8;
use vezbe;

-- original
create table test1(a1 int);

-- kopija (realizuje se preko okidaca)
create table test2(a2 int); 

-- nesto skupovna_razlika original (realizuje se preko okidaca)
create table test3(a3 int not null primary key auto_increment); 

-- nesto nalik na brojac pojavljivanja za original (realizuje se preko okidaca)
create table test4(
    a4 int not null primary key,
    b4 int default 0
);

delimiter $$

create trigger testref before insert on test1
for each row
begin
    insert into test2 set a2 = new.a1;
    delete from test3 where a3 = new.a1;
    update test4 set b4 = b4 + 1 where a4 = new.a1;
end$$

delimiter ;

-- Inicijalizacija
insert into test3 values (1), (2), (4), (5);
insert into test4 (a4) values (1), (2), (3), (5);

-- Testiranje okidaca
insert into test1 values (1), (3), (4), (5);

select * from test1;
select * from test2;
select * from test3;
select * from test4;
