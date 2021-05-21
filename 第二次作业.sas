/* 组合收益 */
 proc datasets kill nolist; run;
 libname home '/folders/myshortcuts/data';
 
 data dierke;
 	set home.trd_mnth98;
 	year=substr(Trdmnt,1,4)*1;
 	month=substr(Trdmnt,6,2)*1;
 	ymonth=year*100+monthfd;
 	if markettype in (1,4,16);
 	if year>2000;
 run;


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

proc sort data=t4;by portfolio ymonth;run;

data t4;
	set t4;
	if missing(Mretwd)=0;
run;


data t4;
	set t4;
	year=input(substr(Trdmnt,1,4),4.);
	month=input(substr(Trdmnt,6,7),2.);
run;

proc means data=t4 noprint;
	by portfolio ymonth;
	var Mretwd;
	output out=portret mean=;
run;


data totret;
	set t4;
	ret=Mretwd+1;
run;

proc sort data=totret;by portfolio year month;run;

data yearret;
	Set totret;
	by year;
	retain r;
	If first.year then do;
		r=ret; 
	end;
	else do;
		r=r*ret;
	end;
Run;

data yearret2;
	set yearret;
	by portfolio year;
	if last.year;
		geomean=time_ret-1;
run;