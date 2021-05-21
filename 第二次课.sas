/* 组合收益 */
 proc datasets kill nolist; run;
 libname home '/folders/myshortcuts/data';
 
 data dierke;
 	set home.trd_mnth98;
 	year=substr(Trdmnt,1,4)*1;
 	month=substr(Trdmnt,6,2)*1;
 	ymonth=year*100+month;
 	if markettype in (1,4,16);
 	if year>2000;
 run;
 
/*  每年多少观测数 */

/* 方法一 */
proc freq data=dierke;
	table year;
run;

/* 方法二 */
proc sql;
	select year,count(stkcd) as n
	from dierke
	group by year
	order by year;
quit;

/* 每年有多少股票数 */

/* 方法一 */
proc sort data=dierke out=t2 nodupkey;
/* （基于by后面的关键词不重复得只保留一条记录） */
	by stkcd year;run;
proc freq data=t2;
	table year;
run;
/* 方法二 */
proc sql;
	select year,count(unique stkcd)as n
	from dierke
	group by year
	order by year;
quit;

/* 以股票一月份的市值为基准，将股票分为十组，并将股票分别放在这十组中 */
proc sort data=dierke(where=(month=1)) out=t2; by year Msmvttl;
run;

/* 每年分成10组，每年都调整投资组合 */
proc rank data=t2 out=t3 groups=10;
	by year;
	ranks portfolio;
	var Msmvttl;
run;

data t3;
	set t3;
	portfolio=portfolio+1;
run;
 
/* 将分组数据合并到原始数据中 */
proc sort data=dierke;by stkcd year; run;

Proc sort data=t3; by stkcd year;run;

data t4;
	merge dierke t3(keep=stkcd year portfolio);
	by stkcd year;
run;

data t4;
	set t4;
	if missing(portfolio)=0;
run;

/* 计算每月资产组合的收益 */

proc sort data=t4;by portfolio ymonth;run;

proc means data=t4 noprint;
	by portfolio ymonth;
	var Mretwd;
	output out=portret mean=;
run;

/* 计算每个资产组合平均月收益（算术平均） */
proc means data=portret noprint;
	by portfolio;
	var Mretwd;
	output out=totret mean=;
run;

/* 计算每个资产组合平均月收益（几何平均） */

data portret;
	set portret;
	lnret=log(1+Mretwd);
run;
proc sort data=portret;by portfolio ymonth;run;

data g1;
	set portret;
	by portfolio;
	retain sum_ret flag1;
	if first.portfolio then do;
		sum_ret=lnret;
		flag1=1;
		end;
	else do;
		sum_ret=sum_ret+lnret;
		flag1=flag1+1;
		end;
run;

proc sort data=g1; by portfolio ymonth;run;

data g2;
	set g1;
	by portfolio;
	if last.portfolio;
	geomean=exp(sum_ret/flag1)-1;
run;