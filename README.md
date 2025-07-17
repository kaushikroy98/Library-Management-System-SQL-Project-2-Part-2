# Begginer-Library-Management-System-Projet2-Part1-using-PostgreSQL_&_MySQL_Workbench

# 📚 Library Management System (Beginner Level – Q1 to Q12)

Welcome to **Part 1** of my SQL-based **Library Management System Project**, focused on beginner-friendly database tasks using both **MySQL Workbench** and **PostgreSQL**. This section (Q1–Q12) covers fundamental SQL operations including database setup, data manipulation, CTAS, and simple analytical queries.

---

## 🗂️ Project Overview

- 🔰 **Level**: Beginner
- 🛠 **Tech Stack**: SQL, MySQL Workbench, PostgreSQL
- 🗃 **Database Name**: `project_2_library`
- 📌 **Scope**: Tasks 1–12 covering foundational SQL use cases
- 🎯 **Objective**: Learn and demonstrate key SQL operations in a real-world scenario

---

## 📁 File Structure

```sql
Library-Management-System-Beginner/
│
├── 📄 Schema.sql → Contains CREATE TABLE statements for all entities
├── 📄 insert_data.sql → Inserts sample data into tables (members, books, employees, etc.)
├── 📄 solution.sql → SQL solutions to Tasks 1–12
├── 📄 README.md → Project overview and task explanations (this file)
```


---

### Project Structure

##1. Database Setup

## 🧱 Database Schema

The schema consists of the following tables and relationships:

- **branch**: Branch details (ID, manager, address)
- **employees**: Library employees (FK to branch)
- **members**: Registered library members
- **books**: Book inventory and metadata
- **issued_status**: Issued book transactions (FK to books, members, employees)
- **return_status**: Returned book transactions (FK to issued_status)

![ER Diagram](https://github.com/kaushikroy98/Library-Management-System-SQL-Project-2-Part-1/blob/main/Library_ERD.png)

- **Database Creation**: Created a database named `project_2_library`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.
- **Defining Foreign Keys**

```sql
-- DROP DATABASE IF EXISTS project_2_library;

CREATE DATABASE project_2_library;

-- Creating tables
drop table if exists branch;
CREATE TABLE branch (
    branch_id VARCHAR(20) PRIMARY KEY,
    manager_id VARCHAR(20),
    branch_address VARCHAR(100),
    contact_no VARCHAR(100)
);

drop table if exists employees;
CREATE TABLE employees (
    emp_id VARCHAR(20) PRIMARY KEY,
    emp_name VARCHAR(50),
    position VARCHAR(50),
    salary INT,
    branch_id VARCHAR(20) --FK
);

drop table if exists books;
CREATE TABLE books (
    isbn VARCHAR(50) PRIMARY KEY,
    book_title VARCHAR(100),
    category VARCHAR(20),
    rental_price FLOAT,
    status VARCHAR(15),
    author VARCHAR(50),
    publisher VARCHAR(60)
);

drop table if exists members;
create table members(
member_id varchar(10) primary key,
member_name varchar(30),
member_address varchar(50),
reg_date date
);

drop table if exists issued_status;
create table issued_status(
issued_id varchar(10) primary key,
issued_member_id varchar(10), -- FK
issued_book_name varchar(100),
issued_date date,
issued_book_isbn varchar(50), --FK
issued_emp_id varchar(10) --FK
);

drop table if exists return_status;
create table return_status(
return_id varchar(10) primary key,
issued_id varchar(10),
return_book_name varchar(10),
return_date date,
return_book_isbn varchar(50)
)


-- FOREIGN KEY

alter TABLE issued_status
add constraint fk_members
FOREIGN key (issued_member_id) 
REFERENCES members(member_id);


alter TABLE issued_status
add constraint fk_books
FOREIGN key (issued_book_isbn) 
REFERENCES books(isbn);


alter TABLE issued_status
add constraint fk_employees
FOREIGN key (issued_emp_id) 
REFERENCES employees(emp_id);

alter TABLE employees
add constraint fk_branch
FOREIGN key (branch_id) 
REFERENCES branch(branch_id);


alter TABLE return_status
add constraint fk_issued_status
FOREIGN key (issued_id) 
REFERENCES issued_status(issued_id);
```

## ✅ Tasks Covered (Q1–Q12)

##2 🔧 CRUD & Data Operations**

1. **Create a New Book Record**  
   
```sql
insert into books(isbn,book_title,category,rental_price,status,author,publisher)
values('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')
```

2. **Update a Member's Address**  

```sql
update members
set member_address='125 Main St'
where member_id='C101'
```

3. **Delete an Issued Book Record**

```sql
delete from issued_status
where issued_id='IS121';
```

4. **Retrieve Books Issued by a Specific Employee**  

```sql
select * from issued_status
where issued_emp_id='E101';
```

5. **List Employees Who Issued More Than One Book**  

```sql
select issued_emp_id from issued_status
group by 1
having count(*)>1 ;
```
---

-- ### 3. CTAS (Create Table As Select)

6. **Create Book Issue Count Summary Table**  

```sql
CREATE TABLE book_counts
as 
select b.isbn,b.book_title as book_name, count(*) book_issued_count from books b
join issued_status i
on b.isbn=i.issued_book_isbn
group by 1,2;
```
---

-- ##4. Data Exploration & Insights

7. **List All Books in a Specific Category**

```sql
select book_title from books
where category = 'Fantasy';
```

8. **Find Total Rental Income by Category**  

```sql
select category, sum(b.rental_price) as total_rental_income,
count(*) issued_count from issued_status s
inner join books b
on s.issued_book_isbn = b.isbn
group by 1
order by total_rental_income desc;
```

9. **List Members Registered in the Last 180 Days**  

-- This code works on postgre SQL

```sql
select member_name from members
where reg_date>=current_date - interval '180 days';
```

-- This code works on MySQL Workbench

```sql
select member_name from members
where reg_date>=date_sub(current_date(),  interval 180 day);
```

10. **List Employees Along With Their Branch Manager and Branch Details**  

```sql
select e2.*,b.manager_id,e1.emp_name as Manager_name  from branch b
inner join employees e1 on b.manager_id=e1.emp_id
inner join employees e2 on b.branch_id=e2.branch_id;
```

11. **Create a Table of Expensive Books (Price > 7.00)**  

```sql
create table book_price_greaterthan_7
AS
select book_title, rental_price from books
where rental_price>7;
```

12. **Retrieve List of Books Not Yet Returned**  

```sql
select distinct i.issued_book_name from issued_status i
left join return_status r
on r.issued_id = i.issued_id
where return_date is null;
```

---

## 💻 Technologies Used

- **MySQL Workbench** (for SQL scripting and testing)
- **PostgreSQL** (for syntax validation and compatibility)
- **SQL**: Joins, Group By, CRUD, CTAS, Date Filtering, Aggregates

---

## 📌 How to Use

1. **Clone the Repository**
2. **Set Up the Database**
3. **Run the Queries**
4. **Explore and Modify**

## Contact

Kaushik Roy
- **Email**: 1998kaushik.roy@gmail.com
- **LinkedIn**: [https://www.linkedin.com/in/kaushikroy98/](https://www.linkedin.com/in/kaushikroy98/)
