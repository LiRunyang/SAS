 proc datasets kill nolist; run;
 libname home '/folders/myshortcuts/data';
data employee_information;
	set home.employee_information;
run;
/* 查询所有列 */
proc sql;
select *
	from employee_information;
quit;
/* FEEDBACK选项 */
/* 当在SELECT子句中使用星号时，添加FEEDBACK选项可以 */
/* 将扩展的SELECT语句写入到SAS日志中。 */
proc sql feedback;
select *
from employee_information;
quit;
/* 查看日志 */
/* 列名称前面是表的名称。 */
proc sql feedback;
select *
from;
quit;
/* DESCRIBE 语句 */
/* 使用DESCRIBE语句可以查看表的列名以及他们对SAS日志的贡献。 */
proc sql;
describe table
employee_information;
quit;
/* 例1：修改前面的报表，添加一个新列Bonus，其数值为员工工资的10%。 */
proc sql;
select Employee_ID, Salary,
Salary*.10 as Bonus
from employee_information;
quit;
/* 例2：你被要求修改前面奖金报表，新的奖金要根据职务等级计算。 */
/* SCAN函数根据字符串中的分隔符，返回其中的第n个词或部分。 */
/* SCAN(string,count<,charlist><,modifier(s)>) */
/* string 字符常量、变量或表达式 */
/* count 一个用于规定您要选择第几个词或部分的整数 */
/* charlist 作为分隔符用来分隔词的字符 */
/* modifier 一个用来修改SCAN函数行为的字符 */

/* CASE表达式 */
/* 在SELECT语句中添加CASE表达式，可以有条件地创建新列。 */
/* SELECT object-item< , ...object-item>, */
/* CASE <case-operand> */
/* WHEN when-condition THEN result-expression */
/* <WHEN when-condition THEN result-expression> */
/* <ELSE result-expression> */
/* END <AS column> */
/* FROM table; */
/* CASE表达式有两种格式。CASE表达式对表的每一行进行比较并返回单个值。 */
proc sql;
select Job_Title, Salary,
case
when scan(Job_Title,-1,' ')='I’
then Salary*.05
when scan(Job_Title,-1,' ')='II’
then Salary*.07
when scan(Job_Title,-1,' ')='III’
then Salary*.10
when scan(Job_Title,-1,' ')='IV’
then Salary*.12
else Salary*.08
end as Bonus
from employee_information;
quit;
/* 法二： */
proc sql;
select Job_Title, Salary,
	case scan(Job_Title,-1,' ')
		when 'I' then Salary*.05
		when 'II' then Salary*.07
		when 'III' then Salary*.10
		when 'IV' then Salary*.12
		else Salary*.08
	end as Bonus
from employee_information;
quit;
/* 在这种CASE语法中，您只能通过判断条件成立确定返回的值 */

/* 创建，填充表 */
/* SELECT语句可以定义work.birth_months表的结构。 */
proc sql;
create table work.birth_months as
select Employee_ID, Birth_Date,
month(Birth_Date) as Birth_Month,
Employee_Gender
from employee_information;
describe table work.birth_months;
select * from work.birth_months;
quit;
/* CREATE TABLE table-name AS query-expression; */

/* 展示所有行 */
proc sql;
select Department
from employee_information;
quit;

/* 删除重复行 */
/* 使用DISTINCT关键字删除查询结果中重复的行。 */
proc sql;
select distinct Department
from employee_information;
quit;
/* DISTINCT关键字作用于SELECT语句中的所有列。每一个 */
/* 唯一的值的组合只显示一行。 */

/* 使用WHERE子句筛选 */
/* WHERE子句可以指定一个条件，使得只有满足条件的数据才会被选中。 */
proc sql;
select Employee_ID, Job_Title, Salary
from employee_information
where Salary > 112000;
quit;

/* order by子句 */
/* 1：员工编号及第一季度捐款金额（捐款金额降序排列） */
proc sql;
select Employee_ID, Qtr1
from orion.employee_donations
order by Qtr1 desc;
quit;

/* 2：员工编号及最高季度捐款金额（首先按捐款金额降序排列，然后按员工编号升序排列） */
proc sql;
select Employee_ID,
max(Qtr1,Qtr2,Qtr3,Qtr4)
from orion.employee_donations
where Paid_By="Cash or Check"
order by 2 desc, Employee_ID;
quit;

/* 3：请通过列标签、美元符号、报表标题、字符常量和行号来进一步美化报表 */
proc sql number/*行号*/;
title 'Maximum Quarterly Donation';/*标题*/
select Employee_ID 'Employee ID',/*格式*/
'Maximum Donation is:',/*字符常量*/
max(Qtr1,Qtr2,Qtr3,Qtr4)
label='Maximum' format=dollar5./*列标签*/
from employee_donations
where Paid_By="Cash or Check"
order by 2 desc, Employee_ID;
quit;

/* 要一份包含所有员工员工编号和年度总捐款金额的报表。 */
proc sql;
select Employee_ID
label='Employee Identifier’,Qtr1,Qtr2,Qtr3,Qtr4,
sum(Qtr1,Qtr2,Qtr3,Qtr4)
label='Annual Donation’ format=dollar5.
from orion.employee_donations
where Paid_By="Cash or Check"
order by 6 desc;
quit;

proc sql;
select Employee_ID
label='Employee Identifier’,Qtr1,Qtr2,Qtr3,Qtr4,
sum(Qtr1,Qtr2,Qtr3,Qtr4)
label='Annual Donation’ format=dollar5.
from orion.employee_donations
where Paid_By="Cash or Check"
order by 6 desc;
quit;

/* 每个员工的年度总捐款金额。 */
proc sql;
select Employee_ID
label='Employee Identifier’,Qtr1,Qtr2,Qtr3,Qtr4,
sum(Qtr1,Qtr2,Qtr3,Qtr4)
label='Annual Donation’ format=dollar5.
from orion.employee_donations
where Paid_By="Cash or Check"
order by 6 desc;
quit;

/* 法二 */
select sum(Qtr1,Qtr2,Qtr3,Qtr4)
from orion.employee_donations;
法三
select Qtr1+Qtr2+Qtr3+Qtr4
from orion.employee_donations;

/* 一份包含所有员工第一季度总贡献的报表。 */
/* 汇总函数：纵跨一列 */
/* 对于一个只含一个自变量的汇总函数，非缺失值是按列加总的。 */
proc sql;
select sum(Qtr1)
'Total Quarter 1 Donations'
from orion.employee_donations;
quit;
/* 汇总函数：COUNT函数 */
/* COUNT函数返回查询中规定项的计数。 */
proc sql;
select count(*) as Count
from orion.employee_information
where Employee_Term_Date is missing;
quit;
/* 自变量可以是： */
/* * （星号），计算所有行数 */
/* 列名称，计算该列中所有非缺失值的行数 */

/* 查看输出 */
/* COUNT函数返回查询中规定的Manager_ID的非缺失值的数量。 */
proc sql;
select count(distinct Manager_ID) as Count /*distinct只选择不重复的id*/
from orion.employee_information
where Employee_Term_Date is missing;
quit;

/* 使用重新合并的汇总统计量 */
/* 计算每个男性员工的工资所占所有男性员工工资的百分比。请按百分比降序的顺序展示Employee_ID, Salary和百分比。 */
proc sql;
title "Male Employee Salaries";
select Employee_ID, Salary format=comma12.,
Salary / sum(Salary)
'PCT of Total' format=percent6.2
from orion.employee_information
where Employee_Gender="M"
and Employee_Term_Date is missing
order by 3 desc;
quit;
title;
/* 使用重新合并的汇总统计量 */
/* 计算每个男性员工的工资所占所有男性员工工资的百分比。请按百分比降序的顺序展示Employee_ID, Salary和百分比。 */
proc sql;
title "Male Employee Salaries";
select Employee_ID, Salary format=comma12.,
Salary / sum(Salary)
'PCT of Total' format=percent6.2
from orion.employee_information
where Employee_Gender="M"
and Employee_Term_Date is missing
order by 3 desc;
quit;
title;

/* 一份按性别计算平均工资的报表。 */
proc sql;
title "Average Salary by Gender";
select Employee_Gender as Gender,
avg(Salary) as Average
from orion.employee_information
where Employee_Term_Date is missing
group by Employee_Gender;
quit;

/* 生成一份报表，展示部门人数大于等于25人的部门员工数。结果以员工数的降序排序。 */
proc sql;
select Department, count(*) as Count
from orion.employee_information
group by Department
having Count ge 25
order by Count desc;
quit;

/* 创建一份报表，列出各部门的以下信息： */
/*  总管理者人数 */
/*  总非管理者员工人数 */
/*  管理者和员工人数的比率（M/E） */
