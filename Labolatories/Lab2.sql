--1
select title, title_no from title
select * from title where title_no = 10
select member_no, fine_assessed from loanhist where fine_assessed between 8.00 and 9.00
select title_no,author from title where author in ('Charles Dickens', 'Jane Austen')
select title_no, title from title where title like '%adventures%'
select member_no, fine_paid from loanhist
select distinct city, state from adult
--2 
select title from title order by title
select member_no,isbn,fine_assessed, fine_assessed*2 as 'double fine' from loanhist where fine_assessed is not NULL  
select lower(firstname +  middleinitial + substring(lastname,0,2)) as 'email_name' from member where lastname like 'Anderson'
select 'The title is: ' + title +'title number ' + convert(varchar(10),title_no) as 'Book' from title 
