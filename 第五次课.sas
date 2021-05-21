proc datasets kill nolist; run;
libname work '/folders/myshortcuts/data';
data train_a;
	set work.train_a;
run;

data train_b;
	set work.train_b;
run;

data staff;
	set orion.staff;
run;

data staff;
	set orion.staff;
run;

/* 修饰符ALL和CORR可以改变集合运算符的默认行为。 */
/* ALL改变行的默认行为 */
/* CORR改变列的默认行为 */

/* UNION运算符 */
title 'Which Employees Have Completed';
title2 'Training A or B?';
proc sql;
select ID, Name from work.train_a
union
select ID, Name from work.train_b
where EDate is not missing;
quit; 

title 'Union with Defaults';
proc sql;
select * from work.train_a
union
select * from work.train_b
where EDate is not missing;
quit;

title 'UNION with CORR Modifier';
proc sql;
select * from work.train_a
union corr
select * from work.train_b
where EDate is not missing;
quit;


/* 使用All修饰符的情况 */
title 'UNION with CORR Modifier';
proc sql number;
select ID, Name from work.train_a
union all
select ID, Name from work.train_b
where EDate is not missing;
quit;

/* 主管团队想要一份所有级别1到级别3的Orion Star员工的工资单报表。 */
title 'Payroll Report for Level I, II,';
title2 'and III Employees';
proc sql;
select 'Total Paid to ALL Level I Staff',
sum(Salary) format=comma12.
from orion.staff
where scan(Job_Title,-1,' ')='I'
union
select 'Total Paid to ALL Level II Staff',
sum(Salary) format=comma12.
from orion.staff
where scan(Job_Title,-1,' ')='II'
union
select 'Total Paid to ALL Level III Staff',
sum(Salary) format=comma12.
from orion.staff
where scan(Job_Title,-1,' ')='III';
quit;


/* OUTER UNION运算符 */
/* 教育主管想要一份列出哪些员工完成了培训A和/或B，以及完成时间的报表。 */
proc sql;
select * from train_a
outer union
select * from train_b
where EDate is not missing;
quit;

/* 以下程序可以生成相同的报表 */
data trained;
set train_a train_b;
run;
proc print data=trained label noobs;
run;
proc sql;
select * from train_a
outer union corr
select * from train_b;
quit;

/* EXCEPT运算符 */
/* 教育主管想要一份列出完成了培训A但是没有完成培训B的员工的名单。 */
title 'Which Employees Have Completed';
title2 'Training A, But Not Training B';
proc sql;
select ID, Name from train_a
except
select ID, Name from train_b
where Edate is not missing;
quit; 

/* 带有ALL修饰符的行 */
/* ◼ 重复的行不会被从中间结果集中去除 */
/* ◼ 包含于中间结果集1但不包含于中间结果集2的行被选中 */
/* 带有CORR修饰符的列 */
/* ◼ 列通过名字配对，无法配对的列被从中间结果集中去除 */


/* INTERSECT运算符 */

/* 教育主管想要一份完成了培训A和培训B的员工的名单。 */
title 'Employees Who Have Completed';
title2 'Both Training Classes';
proc sql;
select ID, Name from train_a
intersect
select ID, Name from train_b
where EDate is not missing;
quit; 


/* 组合集合运算符 */
/* Bob是一个团队经理，他需要你的帮助。他想知道他的团队中是否有人两个培训都没有开始进行。他给你提供了 */
/* 一张他团队成员的表格 */
title "Who on Bob's Team Has Not";
title2 'Started Any Training';
proc sql;
select ID, Name from team
except
(select ID, Name from train_a
union
select ID, Name from train_b);
quit;


proc datasets kill nolist; run;
libname orion '/folders/myshortcuts/data';
/* 7.1 用SQL过程创建表 */
/* 主管想要知道员工的生日。你需要写一段代码生成一张包含每名员工出生月份的表格。现有的表格包含你所需要的行和列。 */
proc sql;
create table orion.birthmonths as
select Employee_Name as Name format=$25.,
City format=$25.,
month(Birth_Date) as BirthMonth
'Birth Month' format=3.
from orion.employee_payroll as p,
orion.employee_addresses as a
where p.Employee_ID=a.Employee_ID
and Employee_Term_Date is missing
order by BirthMonth,City,Name;
quit;

/* 审核新表格 */
/* DESCRIBE语句将表格的信息写进SAS日志中。 */
proc sql;
describe table orion.birthmonths;
select * from orion.birthmonths;
quit;

/* PROC CONTENTS可以提供与PROC SQL DESCRIBE语句相似的信息。 */
/* PROC PRINT可以生成与PROC SQL SELECT语句相似的报表。 */
/* 结构类似表格 */
/* 主管想要一张与表orion.sales结构一样的新销售人员的表格。 */
proc sql;
create table work.new_sales_staff
like orion.sales;
quit;

/* 创建一张新表 */
/* 你需要创建一张包含折扣信息的新表。表格的结构与数据都不包含于现有的表格。 */
proc sql;
create table discounts
(Product_ID num format=z12.,
Start_Date date,
End_Date date,
Discount num format=percent.);
quit;



/* 7.2 用SQL过程创建视图 */
/* Tom Zhou需要的数据包括：姓名、职称、工资以及工作年数。以上数据储存在三张表格中 */

proc sql;
create view orion.tom_zhou as
select Employee_Name as Name format=$25.0,
Job_Title as Title format=$15.0,
Salary 'Annual Salary' format=comma10.2,
int((today()-Employee_Hire_Date)/365.25)
as YOS 'Years of Service'
from employee_addresses as a,
employee_payroll as p,
employee_organization as o
where a.Employee_ID=p.Employee_ID and
o.Employee_ID=p.Employee_ID and
Manager_ID=120102;
quit;


/* 在PROC SQL中，FROM子句中引用的表格的默认逻辑库是 */
/* 视图所在的逻辑库。如果视图和数据来源在同一位置， */
/* 你只需要在FROM子句中使用一级表名。 */
proc sql;
create view orion.tom_zhou as
…
from employee_addresses as a,
employee_payroll as p,
employee_organization as o

/* Tom可以使用这个视图生成简单报表。 */
title "Tom Zhou's Direct Reports";
title2 "By Title and Years of Service";
proc sql;
select *
from orion.tom_zhou
order by Title desc, YOS desc;

/* Tom也可以使用这个视图生成简单的描述性统计帮助他更好地管理团队。 */
title "Tom Zhou's Group - Salary Statistics";
proc means data=orion.tom_zhou min mean max;
var salary;
class title;
run;
