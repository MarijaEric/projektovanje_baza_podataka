drop database if exists vezbe;
create database vezbe character set = utf8;
use vezbe;

create table student_mast(
    student_id int not null primary key,
    name varchar(50),
    st_class int unsigned default 0 
);

create table student_marks(
    STUDENT_ID int not null primary key, 
    SUB1 int check(SUB1 >= 0 and SUB1 <= 100), 
    SUB2 int check(SUB2 >= 0 and SUB2 <= 100), 
    SUB3 int check(SUB3 >= 0 and SUB3 <= 100), 
    SUB4 int check(SUB4 >= 0 and SUB4 <= 100), 
    SUB5 int check(SUB5 >= 0 and SUB5 <= 100), 
    TOTAL int check(TOTAL >= 0 and TOTAL <= 500), 
    PER_MARKS int check(PER_MARKS >= 0 and PER_MARKS <= 100),
    GRADE varchar(10),
    constraint fk_student_id foreign key (STUDENT_ID)
        references student_mast(student_id)
        on delete cascade
        on update cascade
);

delimiter $

create trigger update_stats before insert on student_marks
for each row
begin 
    set new.TOTAL = new.SUB1 + new.SUB2 + new.SUB3 + new.SUB4 + new.SUB5;
    set new.PER_MARKS = new.TOTAL/5;
    set new.GRADE = case
        when new.PER_MARKS >= 90 then 'EXCELLENT'
        when new.PER_MARKS >= 75 then 'VERY GOOD'
        when new.PER_MARKS >= 60 then 'GOOD'
        when new.PER_MARKS >= 40 then 'AVERAGE'
        else 'NOT PROMOTED'
    end;
end$

delimiter ;

insert into student_mast(student_id, name) values
    (1, 'Darko'),
    (2, 'Jovan');

insert into student_marks (STUDENT_ID, SUB1, SUB2, SUB3, SUB4, SUB5) values
    (1, 70, 80, 20, 50, 100),
    (2, 80, 100, 100, 100, 30);

select * from student_mast\G
select * from student_marks\G