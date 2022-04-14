drop database if exists vezbe;
create database vezbe character set = utf8;
use vezbe;

set @bar = '-------------------------------------------------------------------';

create table P (
    P_SIF int unsigned not null primary key auto_increment, 
    IME varchar(50) not null, 
    BR_NASLOVA int unsigned not null default 0, 
    DRZAVA varchar(50) not null
);

create table I (
    I_SIF int unsigned not null primary key auto_increment, 
    NAZIV varchar(50) not null, 
    STATUS varchar(10) not null, 
    DRZAVA varchar(50) not null
);

create table K (
    K_SIF int unsigned not null primary key auto_increment, 
    NASLOV varchar(50) not null, 
    OBLAST varchar(50) not null
);

create table KP (
    K_SIF int unsigned not null, 
    P_SIF int unsigned not null, 
    R_BROJ int unsigned not null,
    primary key (K_SIF, P_SIF, R_BROJ),
    constraint fk_KP_K_SIF foreign key (K_SIF)
        references K(K_SIF)
        on delete cascade
        on update cascade,
    constraint fk_P_SIF foreign key (P_SIF)
        references P(P_SIF)
        on delete cascade
        on update cascade
);

create table KI (
    K_SIF int unsigned not null, 
    I_SIF int unsigned not null, 
    IZDANJE int unsigned not null, 
    GODINA int unsigned not null, 
    TIRAZ int unsigned not null,
    primary key (K_SIF, I_SIF, IZDANJE),
    constraint fk_KI_K_SIF foreign key (K_SIF)
        references K(K_SIF)
        on delete cascade
        on update cascade,
    constraint fk_I_SIF foreign key (I_SIF)
        references I(I_SIF)
        on delete cascade
        on update cascade
);

delimiter $

create trigger kp_unos after insert on KP
for each row
begin 
    update P
    set P.BR_NASLOVA = P.BR_NASLOVA + 1
    where new.P_SIF = P.P_SIF;
end$

create trigger kp_obris after delete on KP
for each row
begin 
    update P
    set P.BR_NASLOVA = P.BR_NASLOVA - 1
    where old.P_SIF = P.P_SIF;
end$

create trigger kp_azuriranje after update on KP
for each row
begin 
    update P
    set P.BR_NASLOVA = P.BR_NASLOVA - 1
    where old.P_SIF = P.P_SIF;

    update P
    set P.BR_NASLOVA = P.BR_NASLOVA + 1
    where new.P_SIF = P.P_SIF;
end$

delimiter ;

insert into P (IME, DRZAVA) values
    ('Borko', 'Srbija'),
    ('Dzon', 'Engleska');

insert into I (NAZIV, STATUS, DRZAVA) values
    ('RSIzdavac', 'aktivan', 'Srbija'),
    ('KK', 'neaktivan', 'Srbija');

insert into K (NASLOV, OBLAST) values
    ('Biologija za sedmake', 'Obrazovanje'),
    ('Matematika za osmi razred osnovne skole', 'Obrazovanje'),
    ('English for Slavs', 'Obrazovanje - Education');

-- Testiranje trigera kp_unos
insert into KP values
    (1, 1, 1),
    (2, 1, 2),
    (3, 2, 1);

select * from P\G

-- Testiranje trigera kp_obris
delete from KP
where K_SIF = 2;

select @bar;
select * from P\G

-- Testiranje trigera kp_azuriranje
update KP
set P_SIF = 1
where K_SIF = 3;

select @bar;    
select * from P\G