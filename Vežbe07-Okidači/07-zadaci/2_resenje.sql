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

create trigger cant_downgrade before update on student_mast
for each row
begin
    declare msg varchar(255);
    set msg = 'Greska: Novi razred je manji od starog!';

    if new.st_class < old.st_class 
        then signal sqlstate '45000' set message_text=msg;
    end if;
end$

create trigger log_update after update on student_mast
for each row
begin
    insert into student_log (USER_ID, DESCRIPTION) values
    (
        user(),
        concat(
            'Izmena podataka o studentu "',
            old.name, ' (', old.student_id, ')", promena: ',
            old.st_class, ' -> ', new.st_class
        )
    );
end$

create trigger log_delete after delete on student_mast
for each row
begin
    insert into student_log (USER_ID, DESCRIPTION) values
    (
        user(),
        concat(
            'Obrisani su podaci o studentu "',
            old.name, ' (', old.student_id, ')"'
        )
    );
end$

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

