
proc sort data=cars(drop=AR) OUT=X7; by eventmo formport; run;
/* 累加sum_car列 */
data x7;
	set x7;
	if formport=lag(formport) then do;
		sum_car+car;
	end;
	else do;
		sum_car=car;
	end;
run;

data x8;
	set x7;
	avg_car=sum_car/15;
	if N=2011;
run;

proc sort data=x7;by eventmo formport;run;
proc sort data=x8;by eventmo formport;run;
data x9;
	merge x7 x8(keep=eventmo formport avg_car);
	by eventmo formport;
	drop sum_car;
run;
/* 经过计算得方差fc */
data x9;
	set x9;
	fc=(car-avg_car)**2;
run;
/* 对同一eventmo累加方差得sum_fc */
data x9;
	set x9;
	if eventmo=lag(eventmo) then do;
		sum_fc+fc;
	end;
	else do;
		sum_fc=fc;
	end;
run;
/* 11年计算得分母 */
data x10;
	set x9;
	if N=2011;
	cf=sqrt(2*(sum_fc/(2*(15-1)))/15);
	drop N car fc sum_fc;
run;
/* 计算t值 */
proc sort data=x10;by eventmo formport;run;
data x10;
	set x10;
	by eventmo;
	retain t;
	if last.eventmo then t=((t-avg_car)/cf);
	else t=avg_car;
run;

data x11;
	set x10;	
	if formport=10;
	keep eventmo t;
run;
	