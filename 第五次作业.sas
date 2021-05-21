proc datasets kill nolist; run;
libname home '/folders/myshortcuts/data';
data employee_addresses;
set home.employee_addresses;
run;
data employee_phones;
set home.employee_phones;
run;
data qtr2;
set home.qtr2;
run;
data qtr1;
set home.qtr1;
run;
data employee_organization;
set home.employee_organization;
run;
data employee_donations;
set home.employee_donations;
run;
data sales;
set home.sales;
run;
data order_fact;
set home.order_fact;
run;
title 'Employee IDs with Phone numbers but not address info';
proc sql;
select Employee_ID from home.employee_phones
except
select Employee_ID from home.employee_addresses;
quit;


title 'customers who placed orders';
proc sql;
select distinct Customer_ID from home.order_fact;
quit;


title 'first and second quarter 2011 sales';
proc sql;
select * from home.qtr1
union
select * from home.qtr2;
quit;

title 'No. employees w/no charitable donations';
proc sql;
select count(Employee_ID)
from (select Employee_ID from employee_organization
except
select Employee_ID from employee_donations);
quit;


title 'sales reps who made no sales in 2011';
proc sql number;
select a.Employee_ID,a.Employee_Name
from employee_addresses as a
where a.Employee_ID in
(select Employee_ID from home.sales as s
where scan(s.job_title,1,'.')='Sales Rep'
and s.job_title like 'Sales Rep%'
/* 模糊匹配 */
except corr
/* 删除2011id */
select  Employee_ID from home.order_fact as of
where year(of.Order_Date)=2011);
quit;
