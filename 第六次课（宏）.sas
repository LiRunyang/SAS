proc datasets kill nolist; run;
libname home '/folders/myshortcuts/data';


data t1;
set home.trd_mnth98;
year=substr(Trdmnt,1,4)*1;;
month=substr(Trdmnt,6,2)*1;
ymonth=year*100+month;
if markettype in (1,4,16);
if year>2000;
run;

/* 删除重复 */
proc sort data=t1 nodupkey;
by stkcd Trdmnt;
run;

/* 输出01年1月和10年12月总市值排名前25的股票 */
/* 只保留stkcd ymonth msmvttl mretwd */

/* 01.1 */
data jan2001;
set t1;
if  ymonth=200101;
run;
proc sort data=jan2001;
by descending Msmvttl;
run;
proc print data=jan2001(firstobs=1 obs=25);
var Stkcd ymonth Msmvttl Mretwd;
run;


/* 宏实现 */
%macro top25 (ymonth=);
data t2;
	set t1;
	if  ymonth=&ymonth;

	proc sort data=t2;
	by descending Msmvttl;
	run;
	proc print data=t2(firstobs=1 obs=25);
	title 'top25,&ymonth';
	var Stkcd ymonth Msmvttl Mretwd;
	run;
%mend;

%top25(ymonth=200201);


/* 循环 */
%macro top25bymonth;
	%do y=2001 %to 2002;
		%do m=1 %to 12;
			data t2;
			set t1;
			if year=&y and month=&m;

			proc sort data=t2;
			by descending Msmvttl;
	
			proc print data=t2(firstobs=1 obs=25);
			title 'top25,&ymonth';
			var Stkcd ymonth Msmvttl Mretwd;
		run;
	%end;
%end;
%mend;

%top25bymonth
run;