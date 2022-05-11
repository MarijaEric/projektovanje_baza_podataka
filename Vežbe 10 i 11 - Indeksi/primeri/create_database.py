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
        create table if not exists Departments(
        id int not null,
        name varchar(30) not null,
        budget int unsigned not null,
        floor int unsigned not null,
        mgr int not null,
        location varchar(20) not null
    );\n
    """)
    cursor.execute("""
        create table if not exists Employees(
        id int not null,
        name varchar(30) not null,
        surname varchar(30) not null,
        salary int unsigned not null,
        age int unsigned not null,
        did int not null,
        job varchar(30) not null,
        location varchar(20) not null,
        years int not null
    );\n
    """)

def ingest_data(cursor):

    s_ename = ['Shirley', 'Florence', 'Rachel', 'Rhonda', 'Caitlyn', 'Nella', 'Annabelle', 
        'Charlotte', 'Leroy', 'Mohamed', 'Umar', 'Ronan', 'Theodore', 'Floyd', 'Bruce', 
        'John']
    s_esurname = ['Reid', 'Wagner', 'Hardy', 'Peterson', 'Munoz', 'Miles', 'Sharma', 'Clarke']
    s_job = ['Stamps', 'Actor', 'Medical student', 'Cleric', 'Massage therapist', 
        'Computer engineer', 'Community worker', 'Pest controller', 'Flower arranger', 
        'Fisherman/woman', 'Musician', 'Lecturer', 'Butler']
    s_dname = ['Toy', 'Furniture', 'Appliance', 'School', 'Economy', 'Hospital', 
        'Development', 'Gardening']
    s_location = ['United States', 'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California',
    'Colorado', 'Connecticut', 'Delaware', 'District of Columbia', 'Florida', 'Georgia',
    'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana',
    'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi', 'Missouri',
    'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York',
    'North Carolina', 'North Dakota', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania',
    'Rhode Island', 'South Carolina', 'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont',
    'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming']
    min_salary, max_salary = 1000, 50000
    min_age, max_age = 20, 65
    min_years, max_years = 0, 5
    min_floor, max_floor = 1, 10
    min_budget, max_budget = 100000, 1000000
    min_did, max_did = 1, 10000 #parametar koji utice na broj odeljenja
    min_eid, max_eid = 1, 10000 #parametar koji utice na broj zaposlenih

    def get_random_person():
        salary = min_salary + random.randrange(max_salary - min_salary)
        age = min_age + random.randrange(max_age - min_age)
        years = min_years + random.randrange(max_years - min_years)
        ename = s_ename[random.randrange(len(s_ename))]
        esurname = s_esurname[random.randrange(len(s_esurname))]
        job = s_job[random.randrange(len(s_job))]
        did = min_did + random.randrange(max_did - min_did)
        location = s_location[random.randrange(len(s_location))]

        return ename, esurname, salary, age, years, did, job, location
        
    def get_random_department():
        floor = min_floor + random.randrange(max_floor - min_floor)
        budget = min_budget + random.randrange(max_budget - min_budget)
        dname = s_dname[random.randrange(len(s_dname))]
        eid = min_eid + random.randrange(max_eid - min_eid)
        location = s_location[random.randrange(len(s_location))]

        return dname, budget, floor, eid, location

    def get_employees(sort_employees='id'):
        employees = list()
        for i in tqdm(range(1, max_eid - min_eid + 2)):
            ename, esurname, salary, age, years, did, job, location = get_random_person()
            employees.append({'id': i, 'name': ename, 'surname': esurname, 'salary': salary, 'age': age, 'years': years, 'did': did, 'job': job, 'location': location})
        employees = sorted(employees, key = lambda x: x[sort_employees])

        query = "insert into Employees (id, name, surname, salary, age, years, did, job, location) values\n"
        for e in employees:
            query += f"('{e['id']}', '{e['name']}', '{e['surname']}', '{e['salary']}', '{e['age']}', '{e['years']}', '{e['did']}', '{e['job']}', '{e['location']}'),"
        query = query[:-1] + ";\n"

        return query
            
    def get_departments(sort_departments='id'):
        departments = list()
        for i in tqdm(range(1, max_did - min_did + 2)):
            dname, budget, floor, mgr, location = get_random_department()
            departments.append({'id': i, 'name': dname, 'budget': budget, 'floor': floor, 'mgr': mgr, 'location': location})
        departments = sorted(departments, key = lambda x: x[sort_departments])

        query = "insert into Departments (id, name, budget, floor, mgr, location) values\n"
        for d in departments:
            query += f"('{d['id']}', '{d['name']}', '{d['budget']}', '{d['floor']}', {d['mgr']}, '{d['location']}'),\n"
        query = query[:-2] + ";\n"
        return query

    query = get_employees('id')
    query += get_departments('id')
    cursor.execute(query)

def run():
    seed = 42
    random.seed(seed)

    /*Potrebno je promeniti vrednosti za user i password*/
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
    ingest_data(cursor)
    db.close()
    
    

if __name__ == '__main__':
    run()

