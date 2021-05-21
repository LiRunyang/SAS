proc datasets kill nolist;run;  /*清内存中数据*/
proc datasets nolist; delete Data;run; 
/* 只清除Data数据集 */

/* 读入硬盘中数据库 */
libname home '/folders/myshortcuts/data';
data trd_mnth;
	set home.trd_mnth;
run;

/* 简单了解你的数据 */
proc contents data=trd_mnth;run;
proc print data=trd_mnth(firstobs=1 obs=50);run;


/* 对数据进行简单分析 */

/* 1.对重要的数值型变量进行统计 */
proc means data=trd_mnth n mean min p1 p50 p99 max;
	var Mnshrtrd Msmvosd Mretwd;
run;

/* 2.频率数据中每只股票有多少个月的数据 */
proc freq data=home.trd_mnth;
	table Stkcd;
run;
/* 3.数据中每个月，每个市场类型的股票数量多少？ */
proc freq data=home.trd_mnth;
	table Trdmnt*Markettype;
run;

/* 4.收益率的分布 */
proc univariate data=home.trd_mnth;
	var Mretwd;
run;

/* 仅保留部分变量 */
data trd_mnth1;
	set trd_mnth;
	keep stkcd trdmnt Mretwd Markettype;
run;

/* 另外一种方法 */
data trd_mnth2;
	set trd_mnth(keep=stkcd trdmnt Mopnprc Mretwd Markettype);
RUN;

/* 将字符型变量转化为数值型 */
data test;
	set trd_mnth1;
	ymth=input(substr(Trdmnt,1,4),4.)*100+input(substr(Trdmnt,6,2),2.);
	drop trdmnt; /*删除变量*/
run; 

/* 另一种 */
data testq;
	set trd_mnth1;
	ymth=substr(Trdmnt,1,4)*100+substr(Trdmnt,6,2); /*数值型与字符型（数字）四则运算结果为数值*/
	drop trdmnt;
run;

/* 删除或保留观测值 */
data test2;
	set test;
		if Markettype=1 or Markettype=16;
	/*其他表示方法 */
/* 		if Markettype ne 2 and Markettype^=8; */
/* 		if Markettype in (1,4,16); */
run;