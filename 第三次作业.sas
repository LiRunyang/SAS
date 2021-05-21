proc datasets kill nolist; run;
 libname home '/folders/myshortcuts/data';
data employee_donations;
	set home.employee_donations;
run;
proc sql;
select Employee_ID, Recipients,
sum(Qtr1,Qtr2,Qtr3,Qtr4) as Total
from employee_donations 
having Total ge 90;
quit;

proc datasets kill nolist; run;
libname home '/folders/myshortcuts/data';
data employee_information;
	set home.employee_information;
		if Employee_Gender='F';
		keep Employee_ID Salary;
run;

proc means data=employee_information sum noprint;
	var Salary;
	output out=sq sum=;
run;

data g1;
	set employee_information;
	by Employee_ID;
	perc=(Salary/6797940)*100;
run;

Proc sort data=g1; by descending perc; run;

