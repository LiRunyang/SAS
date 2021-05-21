proc datasets kill nolist;
	run;
	libname home '/folders/myshortcuts/data';

data data_full;
	set home.data_full;
run;

/* Step1:要求每只股票有连续的84月的交易记录 */
%macro getformstocks;
	%do y=1997 %to 2011;

		data x;
			set data_full;

			if &y-6 le year le &y;
		run;

		proc sql;
			create table f&y as select * from x group by stkcd having count(Mretwd)=84 
				order by stkcd, ymonth;
		quit;

	%end;
%mend;

%getformstocks

/* Step2:构建Winner，Loser组合 */
%macro formports;
	%do y=1997 %to 2011;

		proc sql;
			create table x2 as select * from data_full where stkcd in (select unique 
				stkcd from f&y) order by stkcd, ymonth;
		quit;

		data x2;
			set x2;

			if &y-2 le year le &y;
		run;

		proc means data=x2 noprint;
			by stkcd;
			var AR;
			output out=x3 sum=CU;

			/*CU:累计异常收益率*/
		run;

		/* 生成winner投资组合 */
		PROC sort data=x3;
			by descending CU;
		run;

		data win;
			set x3;

			if _N_<=3;
			formport=10;
			keep stkcd formport;
		run;

		/* loser组合生成 */
		proc sort data=x3;
			by CU;
		run;

		data lose;
			set x3;

			if _N_<=3;
			formport=1;
			keep stkcd formport;
		run;

		DATA wl&y;
			set win lose;
		run;

%end;
%mend;

%formports

/* step3:检验数据区间*/
proc datasets;
delete cars nolist run;
%macro testcars;
	%do y=1997 %TO 2011;
	proc sort data=wl&y;
	by stkcd;
	run;
	
	data x4;
	merge data_full wl&y(in=good);
	by stkcd;
	if good=1;
	if &y+1 le year le &y+3;
	N=&y;
	rename AR=CU;
	run;
/* 	标注相对事件日期 */
	proc sort data=x4;
	by stkcd ymonth;
	run;
	data x4;
	set x4;
	by stkcd;
	if first.stkcd then eventmo=1;
	else eventmo+1;
	run; 

	proc sort data=x4;
	by formport eventmo;
	run;
	proc means data=x4 noprint;
	by formport eventmo N;
	var CU;
	output out=x5 mean=AR;
	run;
	 
	data x6;
	set x5(drop=_freq_ _TYPE_);
	if formport=lag(formport) then do;
		car+ar;
	end;
	else do;
		car=ar;
	end;
	proc append base=cars
	data=x6;
	run;
%end;
%mend;

%testcars


/* step4:将winner组和loser组资产组合CAR进行检验 */

proc sort data=cars;
by eventmo formport;
run;

proc ttest data=cars;
by eventmo;
class formport;
var car;
ods output statistics=t;
run;

