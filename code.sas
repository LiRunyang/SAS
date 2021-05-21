libname tmp "C:\Users\xiaoh\Desktop\0512";

%macro fun(year=);

data _null_;
	call symputx('tot',&year.*12);
run;

proc sort data=tmp.trd_mnth out=tmp;by Stkcd Trdmnt;run;

%do i= 1 %to &tot.;

data tmp;
	set tmp;
	by Stkcd Trdmnt;
	Stkcd=compress(Stkcd,' ');
	lag_Stkcd=lag&i.(Stkcd);
    lag_Mretwd=lag&i.(Mretwd);
	if Stkcd=lag_Stkcd then lag_&i.=lag_Mretwd;
		else lag_&i.=.;
	drop lag_Stkcd lag_Mretwd;
run;

%end;

data tmp1;
   set tmp;
run;

%do j= 1 %to &tot.;
data tmp1;
   set tmp1;
   if lag_&j.=. then delete;
run;

%end;

data result;
   set tmp1;
   avg=sum(of lag_:)/&tot.;
   keep Stkcd Trdmnt avg;
run;

%mend;
%fun(year=5);
