proc datasets kill nolist; run;
 libname home '/folders/myshortcuts/data';
data order_fact;
	set home.order_fact;
run;
data product_dim;
	set home.product_dim;
run;

proc sql;
select Product_ID 
from product_dim 
where Product_ID not in (select product_dim.Product_ID 
from product_dim, order_fact
where product_dim.Product_ID=order_fact.Product_ID)
order by Product_ID;
quit;


proc datasets kill nolist; run;
 libname home '/folders/myshortcuts/data';
data employee_addresses;
	set home.employee_addresses;
run;

data employee_payroll;
	set home.employee_payroll;
run;

data employee_organization;
	set home.employee_organization;
run;

proc sql;
title 'Employees with more than 30 years of service as of February 1 ,2013';
select a.Employee_Name'Employee Name',d.Employee_Name 'Manager name',
int(('01FEB2013'd-employee_payroll.Employee_Hire_Date)/365.25) as ag 'Years of Service'
from employee_addresses as a,
employee_addresses as d,
employee_payroll as p,
employee_organization as o
where calculated ag>30 and a.Employee_ID=p.Employee_ID
and a.Employee_ID=o.Employee_ID
and o.Manager_ID=d.Employee_ID
order by 2,3 desc,1;
quit;


proc datasets kill nolist; run;
 libname home '/folders/myshortcuts/data';
data order_fact;
	set home.order_fact;
run;
proc sql;
title 'Customers whose average retail price exceeds the average retail price for all customers';
select Customer_ID,avg(Total_Retail_Price) 'MeanSales'
from order_fact
where Order_Type=1 
group by Customer_ID
having(select avg(Total_Retail_Price) from order_fact where Order_Type=1)<avg(Total_Retail_Price);
quit;

proc datasets kill nolist; run;
 libname home '/folders/myshortcuts/data';
data order_fact;
	set home.order_fact;
run;
data sales;
	set home.sales;
run;
proc sql;
title '2011 sales force sales statistics for employees with $20000 or more in sales';
select sales.Country,sales.First_Name,sales.Last_Name,o.Value_Sold,o.Orders,o.Avg_Order
from sales as sales
right join
(select Employee_ID,sum(Total_Retail_Price)as Value_Sold,
sum(Total_Retail_Price)/count(distinct Order_ID) as Avg_Order,
count(distinct Order_ID) as Orders
from order_fact
where year(Order_Date)=2011
group by Employee_ID
having Value_Sold > 200)as o
on sales.Employee_ID=
o.Employee_ID
where o.Employee_ID=sales.Employee_ID;
order by 1,4 desc,5 desc;
quit;