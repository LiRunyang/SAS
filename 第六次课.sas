proc datasets kill nolist; run;
DATA SPT_Trdchg (Label="特殊处理变动文件");
Infile '/folders/myshortcuts/data/SPT_Trdchg/SPT_Trdchg.txt' encoding="utf-8" delimiter = '09'x Missover Dsd lrecl=32767 firstobs=2;
Format Stkcd $6.;
Format Stknmebc $10.;
Format Stknmeac $10.;
Format Chgtype $6.;
Format Annoudt yymmdd10.;
Format Chgreas $50.;
Format Chgrsdis $50.;
Format Execudt $10.;
Informat Stkcd $6.;
Informat Stknmebc $10.;
Informat Stknmeac $10.;
Informat Chgtype $6.;
Informat Annoudt yymmdd10.;
Informat Chgreas $50.;
Informat Chgrsdis $50.;
Informat Execudt $10.;
Label Stkcd="证券代码";
Label Stknmebc="变动前的证券简称";
Label Stknmeac="变动后的证券简称";
Label Chgtype="变动类型";
Label Annoudt="变动公布日期";
Label Chgreas="变动原因编码";
Label Chgrsdis="变动原因";
Label Execudt="执行日期";
Input Stkcd $ Stknmebc $ Stknmeac $ Chgtype $ Annoudt  Chgreas $ Chgrsdis $ Execudt $ ;
Run;

/* 剔除B股，保留代码，时间 */
data st;
set spt_trdchg;
type=substr(Stkcd,1,1)*1;
if type not in (2,9);
if Chgtype in ('AB','AD');
keep Stkcd Annoudt;
run;

/* 只保留两个公司 */
data st1;
set st;
/* if stkcd in ('000013','600538'); */
run;

/* 生成序号 */
data st1;
set st1;
tag=_N_;
run;

DATA CER_Dalyr (Label="日个股回报率文件");
Infile '/folders/myshortcuts/data/CER_Dalyr/CER_Dalyr.txt' encoding="utf-8" delimiter = '09'x Missover Dsd lrecl=32767 firstobs=2;
Format Stkcd $6.;
Format Trddt yymmdd10.;
Format Daywk 1.;
Format Dsmvtll 16.2;
Format Dretwd 10.6;
Format Dretnd 10.6;
Informat Stkcd $6.;
Informat Trddt yymmdd10.;
Informat Daywk 1.;
Informat Dsmvtll 16.2;
Informat Dretwd 10.6;
Informat Dretnd 10.6;
Label Stkcd="证券代码";
Label Trddt="交易日期";
Label Daywk="星期";
Label Dsmvtll="日个股总市值";
Label Dretwd="考虑现金红利再投资的日个股回报率";
Label Dretnd="不考虑现金红利再投资的日个股回报率";
Input Stkcd $ Trddt  Daywk Dsmvtll Dretwd Dretnd ;
Run;

DATA TRD_Cndalym (Label="综合日市场回报率文件");
Infile '/folders/myshortcuts/data/TRD_Cndalym/TRD_Cndalym.txt' encoding="utf-8" delimiter = '09'x Missover Dsd lrecl=32767 firstobs=2;
Format Markettype 10.;
Format Trddt yymmdd10.;
Format Cnshrtrdtl 12.;
Format Cnvaltrdtl 20.3;
Format Cdretwdeq 11.6;
Format Cdretmdeq 11.6;
Format Cdretwdos 11.6;
Format Cdretmdos 11.6;
Format Cdretwdtl 11.6;
Format Cdretmdtl 11.6;
Format Cdnstkcal 4.;
Informat Markettype 10.;
Informat Trddt yymmdd10.;
Informat Cnshrtrdtl 12.;
Informat Cnvaltrdtl 20.3;
Informat Cdretwdeq 11.6;
Informat Cdretmdeq 11.6;
Informat Cdretwdos 11.6;
Informat Cdretmdos 11.6;
Informat Cdretwdtl 11.6;
Informat Cdretmdtl 11.6;
Informat Cdnstkcal 4.;
Label Markettype="综合市场类型";
Label Trddt="交易日期";
Label Cnshrtrdtl="综合日市场交易总股数";
Label Cnvaltrdtl="综合日市场交易总金额";
Label Cdretwdeq="考虑现金红利再投资的综合日市场回报率(等权平均法)";
Label Cdretmdeq="不考虑现金红利的综合日市场回报率(等权平均法)";
Label Cdretwdos="考虑现金红利再投资的综合日市场回报率(流通市值加权平均法)";
Label Cdretmdos="不考虑现金红利的综合日市场回报率(流通市值加权平均法)";
Label Cdretwdtl="考虑现金红利再投资的综合日市场回报率(总市值加权平均法)";
Label Cdretmdtl="不考虑现金红利的综合日市场回报率(总市值加权平均法)";
Label Cdnstkcal="计算综合日市场回报率的有效公司数量";
Input Markettype Trddt  Cnshrtrdtl Cnvaltrdtl Cdretwdeq Cdretmdeq Cdretwdos Cdretmdos Cdretwdtl Cdretmdtl Cdnstkcal ;
Run;

/* 合并交易日数据 */
proc sql;
create table trd_day as 
select a.*,b.Trddt,b.Cdretwdos
from st1 as a left join trd_cndalym(where=(Markettype=21)) as b
on intnx('day',Annoudt,-20)<=b.trddt<=intnx('day',Annoudt,20)
order by stkcd,Trddt;/*20个自然日保证10个交易日*/
quit;

/* 为什么不直接合并个股交易数据，得出个股回报率？
a：不能体现停牌交易日的回报*/

/* 合并个股交易数据 */
proc sql;
create table stk_trd as 
select a.*,b.Dretwd
from trd_day as a left join CER_Dalyr as b
on a.stkcd=b.stkcd and a.trddt=b.trddt
order by stkcd,Trddt;/*20个自然日保证10个交易日*/
quit;

/* 生成时间窗口计数 */
proc sort data=stk_trd out=temp1;
where Trddt lt Annoudt;
by stkcd Annoudt descending Trddt;
quit;
/* 生成序数 */
data temp1;
set temp1;
by stkcd Annoudt;
if first.Annoudt 
then td_count=0;
td_count=td_count-1;
retain td_count;
run;

proc sort data=stk_trd out=temp2;
where Trddt ge Annoudt;
by stkcd Annoudt trddt;
run;
data temp2;
set temp2;
by stkcd Annoudt;
if first.Annoudt 
then td_count=-1;
td_count+1;
run;

/* 数据合并 */
data event_day;
set temp1 temp2;
run;

/* 计算并检验累计异常收益率 */
proc sort data=event_day;
by stkcd Annoudt td_count;
run;
data t1;
set event_day;
if -10 le td_count le 10;
run;


/* BHAR */
data t2;
set t1;
if missing(Dretwd) then  Dretwd=0;
lnret1=log(1+Dretwd);
lnret2=log(1+Cdretwdos);
run;

proc sort data=t2;
by tag trddt;
run;

/* 累乘 */
data t3;
set t2;
by tag trddt;
retain sum_ret1 sum_ret2;
if first.tag then do;
sum_ret1=lnret1;
sum_ret2=lnret2;
end;
else do;
sum_ret1=sum_ret1+lnret1;
sum_ret2=sum_ret2+lnret2;
end;
run;
/* 排序 */
proc sort data=t3;
by tag trddt;
run;

data t4;
set t3;
by tag;
car=exp(sum_ret1)-exp(sum_ret2);
run;


/* 假设检验 */
proc sort data=t4;
by td_count;
run;
proc means data=t4 noprint;
by td_count;
var car;  /*对该变量求*/
output out=t5 mean=t(car)=t_car prt(car)=p_car;
run;

title1 '累计异常收益率图';
title2 '[-10,10]';
proc sgplot data=t5;
series x=td_count y=car;
run;