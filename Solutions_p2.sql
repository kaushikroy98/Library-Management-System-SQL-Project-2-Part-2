-- SQL Project - Library Management System Advanced Problem Solutions


-- ### Advanced SQL Operations

/*Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's name, book title, issue date, and days overdue.*/


-- Approach to Solve this challenge
-- 1. Left Join issued_status and return_status to filter out the books which were not returned
-- 2. Left join with members table to get members name
-- 3. use CURRENT_DATE to calculate the days

select member_name, issued_book_name, issued_date,CURRENT_DATE - issued_date total_days, 
((CURRENT_DATE - i.issued_date)-30) overdue_by  from issued_status i
left join return_status r on i.issued_id=r.issued_id
left join members m on  i.issued_member_id=m.member_id
where return_id is null and CURRENT_DATE - issued_date > 30;


/*Task 14: Update Book Status on Return
Write a query to update the status of books in the books table 
to "available" when they are returned (based on entries in the return_status table).*/

select * from books;
select * from return_status;

select * from issued_status
where issued_book_isbn = '978-0-451-52994-2';

select * from books
 where isbn= '978-0-451-52994-2';

update books
set status='no'
where isbn= '978-0-451-52994-2';

select * from return_status
where issued_id = 'IS130'

-- Manual Solution 

insert into return_status(return_id,issued_id,return_date,book_quality)
values('Rs125','IS130',CURRENT_DATE,'Good');
select * from return_status
where issued_id = 'IS130';

update books
set status='yes'
where isbn= '978-0-451-52994-2';

select * from books
where isbn= '978-0-451-52994-2';

-- Solving using stored precedures


CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10), p_issued_id VARCHAR(10), p_book_quality VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
    v_isbn VARCHAR(50);
    v_book_name VARCHAR(80);
    
BEGIN
    -- all logic and code here
    -- inserting into returns based on users input
    INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
    VALUES
    (p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);

    SELECT 
        issued_book_isbn,
        issued_book_name
        INTO
        v_isbn,
        v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;


	-- Printing message
    RAISE NOTICE 'Thank you for returning the book: %', v_book_name;
    
END;
$$

-- Testing stored procedure add_return_records

call add_return_records('RS139','IS135','Good');



/*Task 15: Branch Performance Report
Create a query that generates a performance report for each branch,
showing the number of books issued, the number of books returned,
and the total revenue generated from book rentals.*/


-- cnt of books issued
select b.branch_id, count(*) cnt_books_issued from branch b
left join employees e on b.branch_id = e.branch_id
left join issued_status i on e.emp_id = i.issued_emp_id
where i.issued_id is not null
group by b.branch_id
order by 1;


-- count of books returned
select b.branch_id,count(*) cnt_books_returned from branch b
left join employees e on b.branch_id = e.branch_id
left join issued_status i on e.emp_id = i.issued_emp_id
left join return_status r on i.issued_id = r.issued_id
where r.return_id is not null
group by b.branch_id
order by 1;

-- total revenue

select b.branch_id, sum(bk.rental_price) total_revenue from branch b
left join employees e on b.branch_id = e.branch_id
left join issued_status i on e.emp_id = i.issued_emp_id
left join books bk on bk.isbn = i.issued_book_isbn
where bk.rental_price is not null
group by b.branch_id
order by 1;


-- All combined, final solution

create table branch_report
as
select b.branch_id,count(i.issued_id) cnt_books_issued ,
count(r.return_id) cnt_books_returned, sum(bk.rental_price) total_revenue
from branch b
left join employees e on b.branch_id = e.branch_id
left join issued_status i on e.emp_id = i.issued_emp_id
left join return_status r on i.issued_id = r.issued_id
left join books bk on bk.isbn = i.issued_book_isbn
where i.issued_id is not null or r.return_id is not null or bk.rental_price is not null
group by b.branch_id
order by 1;

select * from branch_report;



/*Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create 
a new table active_members containing members 
who have issued at least two book in the last 16 months.*/

create table active_members
as
select m.*,count(issued_id) issued_books from issued_status i
join members m on i.issued_member_id=m.member_id
where issued_date >= current_date - interval '16 months'
group by 1
having count(issued_id)>=2
order by issued_books;

select * from active_members;


/*Task 17: Find Employees with the Most Book Issues Processed

Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name,number of books processed, and their branch.*/


select e.emp_name, b.*,count(i.issued_id) books_processed from issued_status i
join employees e on e.emp_id = i.issued_emp_id
join branch b on b.branch_id = e.branch_id
group by 1,2
order by books_processed desc
limit 3;



/* Task 18: Stored Procedure
Objective: Create a stored procedure to manage the status of books in a library system.

    Description: Write a stored procedure that updates the status of a book based on its issuance or return.
	Specifically:
    If a book is issued, the status should change to 'no'.
    If a book is returned, the status should change to 'yes'.*/


create or replace procedure issue_book(p_issued_id varchar(10),p_issued_member_id varchar(30),
p_issued_book_isbn varchar(50), p_issued_emp_id varchar(10))

language plpgsql
as $$

DECLARE

	v_status varchar(10);

begin
	-- write logic & code here
	-- check if book is available or NOT
	select status
	into v_status
	from books
	where isbn = p_issued_book_isbn ;

	if v_status = 'yes' then
	
	insert into issued_status(issued_id,issued_member_id,issued_date,issued_book_isbn,issued_emp_id)
	values(p_issued_id,p_issued_member_id,current_date,p_issued_book_isbn, p_issued_emp_id);

	UPDATE books
	SET status = 'no'
	where isbn= p_issued_book_isbn;

	raise notice 'Book records added successfully for book isbn : %', p_issued_book_isbn;

	else
	raise notice 'Sorry to inform you the book you have requested is unavailable book_isbn: %', p_issued_book_isbn;
    END IF;

end;
$$

-- Test stored proceedures

CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');
	

/* Task 19: Create Table As Select (CTAS)
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and 
the books they have issued but not returned within 30 days. 

The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at Rs 5.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines
*/

select i.issued_member_id,count(i.issued_member_id) total_books_issued ,
sum(((CURRENT_DATE - i.issued_date)-30))*5 total_fine from issued_status i
left join return_status r on i.issued_id=r.issued_id
where return_id is null and CURRENT_DATE - issued_date > 30
group by 1
order by 3 desc;













