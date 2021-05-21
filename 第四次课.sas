proc datasets kill nolist; run;
 libname home '/folders/myshortcuts/data';
/*  4.1 */
/*  笛卡尔积 */
/* 一个查询在FROM子句中列出多张表，而这个语句没有包含WHERE子句， */
/* 结果视图中生成了所有表中的行的全部可能组合。生成的结果就叫做笛卡尔积 。 */

/* 4.2 内连接 */
/* 内连接（Inner joins）只返回匹配的行。 */
data customers;
	set home.customers;
run;
data transactions;
	set home.transactions;
run;
proc sql;
select *
from customers,transactions
where customers.ID=
transactions.ID ;
quit;

/* 限定列名称 */
/* 从多个表中指定具有相同名称的列时，必须限定列名称。 */
proc sql;
select *
from customers, transactions
where customers.ID=
transactions.ID ;
quit;


/* 等值连接是连接标准指定标识变量相等的内连接。
自然连接是一个等值链，SQL将比较两个表中所有同名列的值， */
/* 并生成包含源列表中同名列的结果的只有一列的输出。 */
/* 表中的行根据同名列中的匹配值进行连接。 */
proc sql;
select *
from customers natural join transactions;
quit;


/* 缩写代码 */
/* 表的别名是一张表暂时的且可替代的名称。使用表的可以使查询语句更易阅读。 */
/* AS关键字在表别名语法中是可选的。 */
proc sql;
SELECT alias-1.object-item<, …alias-2.object-item>
FROM table-name <AS> alias-1,
table-name <AS> alias-2
WHERE join condition(s)
<other clauses>;

/* 例： */
proc sql;
select c.ID，Name,Action,Amount
from customers as c,transactions as t
where c.ID=t.ID ;
quit;


/* 连接语句替代语法 */
/* 替代语法包含了连接类型和ON语句。 */
proc sql;
select c.ID，Name,Action,Amount
from customer as c
inner join
transactions as t
on c.ID=t.ID ;


SELECT object-item <, …object-item>
FROM table-name <<AS> alias>
INNER JOIN
table-name <<AS> alias>
ON join condition(s)
WHERE sql-expression
<other clauses>;

/* 4.3 外连接 */
/* 外连接 */
/* 使用外连接，您可以提取匹配行和不匹配行。 */
/* 外连接包括左、全和右外连接。外连接一次只能处理两个表。 */
/* 外连接语法与可替代内连接语法相似。 */
proc sql;
title 'All Customers';
select *
from customers as c
left join
transactions as t
on c.ID=t.ID;
quit; 
proc sql;
SELECT object-item <, …object-item>
FROM table-name <<AS> alias>
LEFT|RIGHT|FULL JOIN
table-name <<AS> alias>
ON join condition(s)
WHERE sql-expression
<other clauses>;
/* ON语句为外连接指定了条件 */

/* 确定左和右 */
/* 考虑在FROM子句中表的位置。 */
/* ◼ 左连接包括第一个表（左表）中匹配和未匹配的所有
行，以及在第二个表（右表）中匹配的行。 */
/* ◼ 右连接包括第二个表（右表）中匹配和未匹配的所有
的行，以及在第一个表（左表）中匹配的行。 */
/* ◼ 全连接包括两个表中匹配和未匹配的所有的行 */

/* 左连接 */
proc sql;
select *
from customers c left join transactions t
on c.ID = t.ID;
quit;

/* 右连接 */
select *
from customers c right join transactions t
on c.ID = t.ID;

/* 全连接 */
select *
from customers c full join transactions t
on c.ID = t.ID;

/* 报表 3 */
/* 管理层正在考虑配偶的捐赠计划。 需要一份报告显示已 */
/* 婚的员工，并为公司赞助的慈善机构捐款。 */
data employee_donations;
	set home.employee_donations;
run;
data employee_payroll;
	set home.employee_payroll;
run;
proc sql;
select d.Employee_ID, Recipients
from employee_donations as d
left join
employee_payroll as p
on d.Employee_ID=
p.Employee_ID
where Marital_Status="M";
quit;

/* SQL外连接 VS DATA步Merge */
proc sql;
select *
from customers c full join transactions t
on c.ID=t.ID;
quit;
/* 全连接与merge带来同样结果 */

/* COALESCE 函数 */
/* 您可以使用COALESCE函数来叠加列。COALESCE函数返回第一个非缺失参数的值。（不显示重复列） */
proc sql;
select coalesce(c.ID,t.ID) as ID,
Name, Action, Amount
from customers c full join transactions t
on c.ID=t.ID;
quit;

/* 表可以以不等号连接—— 例如： */
proc sql;
title "List of things I could buy";
select Item_name, Price
from budget, wish_list
where budget.Cash_Available > wish_list.Price;
quit;

/* 4.4 复杂的SQL连接 */
/* 执行自连接 */
/* 例：首席销售员希望报告所有销售员工的姓名和每位员工的直属经理的姓名。 */
/* 要返回员工姓名和经理姓名，您需要阅读地址表两次。 */
/* 1.返回员工的ID和姓名。 */
/* 2.确定员工经理的ID。 */
/* 3.返回经理的姓名。 */
/* 为了从同一个表读两次，它必须在FROM子句中列出两次。 */
/* 在这里，需要使用不同的表别名来区分不同的用途。 */
proc sql;
select e.Employee_ID "Employee ID",
e.Employee_Name "Employee Name",
m.Employee_ID "Manager ID",
m.Employee_Name "Manager Name",
e.Country
from orion.employee_addresses as e,
orion.employee_addresses as m,
orion.employee_organization as o
where e.Employee_ID=o.Employee_ID and
o.Manager_ID=m.Employee_ID and
Department contains 'Sales'
order by Country,4,1;

/* 5.1 非关联子查询 */
/* 人力资源和薪资管理人员要求提供一份报告，显示Job_Title的平均工资大于公司整体平均工资的工作组。 */
/* 第一步 */
/* 计算公司平均工资 */
proc sql;
select avg(Salary) as CompanyMeanSalary
from orion.staff;
quit;

/* 第二步 */
/* 确定平均工资超过公司平均工资的职位。 */
proc sql;
select Job_Title,
avg(Salary) as MeanSalary
from orion.staff
group by Job_Title
having MeanSalary>38041.51;
quit;

/* 第三步 */
/* 使用子查询将程序编写为单个步骤。子查询是驻留在外部查询中的查询。 */
proc sql;
select Job_Title, avg(Salary) as MeanSalary
from orion.staff
group by Job_Title
having avg(Salary) >
(select avg(Salary)
from orion.staff);
quit;

/* 子查询 */
/* ◼ 返回要在外部查询的WHERE或HAVING子句中使用的值 */
/* ◼ 必须只返回一列 */
/* ◼ 可以返回多个值或单个值。 */

/* 有两种类型的子查询： */
/* ◼ 非关联子查询是一个独立的查询。它独立于外部查询执行。 */
proc sql;
select Job_Title, avg(Salary) as MeanSalary
from orion.staff
group by Job_Title
having avg(Salary) >
(select avg(Salary)
from orion.staff);
quit;

/* 子查询：关联 */
/* ◼ 相关子查询需要一个或多个值才能成功解析，然后由外（主）查询传递给它。 */
proc sql;
select Employee_ID, avg(Salary) as MeanSalary
from orion.employee_addresses
where 'AU'=
(select Country
from work.supervisors
where employee_addresses.Employee_ID=
supervisors.Employee_ID);
quit;

/* 例：首席执行官向当月生日的每位员工发送生日卡。 创建一份报告，列出2月份生日的员工姓名，城市和国家。 */
proc sql;
select Employee_Name, City,
Country
from orion.employee_addresses
where Employee_ID in
(select Employee_ID
from orion.employee_payroll
where month(Birth_Date)=2)
order by Employee_ID;
quit;

/* ANY关键字 */
/* 如果任何由子查询返回的值为真，则ANY表达式为真。 */
/* ALL关键字 */
/* 如果对于子查询返回的所有值为真，则ALL表达式为true */

/* 例：高级销售主管问道：“任何四级销售代表的薪水是否低于任何低级销售代表的薪水？” */
/* 方法 1：ANY 关键字 */
proc sql;
select Employee_ID, Salary
from orion.staff
where Job_Title='Sales Rep. IV'
and Salary < any
(select Salary
from orion.staff
where Job_Title in
('Sales Rep. I','Sales Rep. II',
'Sales Rep. III'));
quit;

/* 方法 2：MAX 统计 */
proc sql;
select Employee_ID, Salary
from orion.staff
where Job_Title='Sales Rep. IV'
and Salary <
(select max(Salary)
from orion.staff
where Job_Title in
('Sales Rep. I','Sales Rep. II',
'Sales Rep. III'));
quit;


