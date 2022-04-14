drop database if exists vezbe;
create database vezbe character set = utf8;
use vezbe;

create table emp_details(
    EMPLOYEE_ID int not null primary key auto_increment, 
    FIRST_NAME varchar(50), 
    LAST_NAME varchar(50), 
    EMAIL varchar(30), 
    PHONE_NUMBER varchar(15),
    HIRE_DATE date, 
    JOB_ID int, 
    SALARY int unsigned, 
    COMMISSION_PCT dec(5, 2) check(COMMISSION_PCT >= 0.0 and COMMISSION_PCT <= 100.0)
);

delimiter $

create trigger calc_commission_pct before insert on emp_details
for each row
begin
    set new.COMMISSION_PCT = (case when new.SALARY >= 20000 then 0.1 else 0.5 end);
end$

delimiter ;

insert into emp_details (FIRST_NAME, LAST_NAME, EMAIL, PHONE_NUMBER, HIRE_DATE, JOB_ID, SALARY) values
    ('Darko', 'Jovanovic', 'darko.jovanovic@hotmail.com', '123-456', '2020-03-01', 1000, 15000),
    ('Janko', 'Bozic', 'janko1993@hotmail.com', '113-496', '2018-08-12', 1000, 25000);

select * from emp_details\G