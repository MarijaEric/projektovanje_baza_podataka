# Jednostavna skripta koja inicijalizuje bazu podataka
# Potencijalno je potrebno izmeniti podatke u mysql connect komandi
import mysql.connector
from datetime import datetime, timedelta
import random
from tqdm import tqdm

def create_database(cursor):
    cursor.execute("drop database if exists office")
    cursor.execute("create database office")
    cursor.execute("use office")
    cursor.execute("""
    create table if not exists emps(
        emp_id int auto_increment primary key,
        name varchar(30) not null,
        surname varchar(40) not null,
        job varchar(30) not null,
        hire_date datetime,
        salary int unsigned not null
    )
    """)

def ingest_data(cursor, seed):
    s_names = [
        'Shirley', 'Florence', 'Rachel', 'Rhonda', 'Caitlyn', 'Nella', 'Annabelle', 'Charlotte',
        'Leroy', 'Mohamed', 'Umar', 'Ronan', 'Theodore', 'Floyd', 'Bruce', 'John'
    ]

    s_surnames = ['Reid', 'Wagner', 'Hardy', 'Peterson', 'Munoz', 'Miles', 'Sharma', 'Clarke']
    
    s_job = [
        'Actor', 'Medical student', 'Cleric', 'Massage therapist', 'Computer engineer', 'Community worker', 
        'Pest controller', 'Flower arranger', 'Fisherman/woman', 'Musician', 'Lecturer', 'Butler'
    ]
    
    min_hire_date, max_hire_date = datetime(2000, 1, 1), datetime(2020, 12, 31)
    delta_date = max_hire_date - min_hire_date
    int_delta = (delta_date.days * 24 * 60 * 60) + delta_date.seconds

    min_salary, max_salary = 1000, 10000

    def get_random_person():
        name = random.choice(s_names)
        surname = random.choice(s_surnames)
        job = random.choice(s_job)
        hire_date = min_hire_date + timedelta(seconds=random.randrange(int_delta))
        salary = min_salary + random.randrange(max_salary - min_salary)
        return name, surname, job, hire_date, salary

    query = f"insert into emps (name, surname, job, hire_date, salary) values\n"
    for _ in tqdm(range(1000000)):
        name, surname, job, hire_date, salary = get_random_person()
        query += f"('{name}', '{surname}', '{job}', '{hire_date}', {salary}),\n"
    query = query[:-2] # brise se ',\n' sa kraja
    cursor.execute(query)


def run():
    seed = 42
    random.seed(seed)

    db = mysql.connector.connect(
        host="127.0.0.1",
        user="root",
        password="",
        port="3306",
        auth_plugin='mysql_native_password',
        autocommit=True
    )
    cursor = db.cursor()

    create_database(cursor)
    ingest_data(cursor, seed)
    db.close()
    

if __name__ == '__main__':
    run()

