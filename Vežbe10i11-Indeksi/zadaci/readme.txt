Inicijalizacija baze podataka (jedno od sledecih opcija):
    - `python3 create_database.py`
    - `mysql -u root -p < create_database.sql`

Baza `office` sadrzi samo jednu tabelu `emps` koja sadrzi informacije o 
ljudima nekog grada:
    - `emp_id`: identifikator
    - `name`: ime
    - `surname`: prezime
    - `job`: ime posla
    - `hire_date`: datum i vreme zaposljavanja
    - `salaray: plata
