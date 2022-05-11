drop database if exists vezbe;
create database vezbe character set = utf8;
use vezbe;

create table student_mast(
    student_id int not null primary key,
    name varchar(50),
    st_class int unsigned default 0 
);

create table student_log(
    log_id int not null primary key auto_increment,
    USER_ID varchar(50) not null, 
    DESCRIPTION text
);

delimiter $

-- Studentski kod -- 

delimiter ;

insert into student_mast values
    (1, 'Darko', 6),
    (2, 'Jovan', 7);

-- Radi...
update student_mast
set st_class = 7
where name = 'Darko';

-- Ne radi...
-- update student_mast
-- set st_class = 6
-- where name = 'Jovan';

delete from student_mast
where name = 'Jovan';

select * from student_mast\G

select * from student_log\G

