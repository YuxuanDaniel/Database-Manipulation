/* Fall 2023 STSCI 5060 Final Project  */
/* Student Name: Yuxuan Chen */
/* NewID: yc2763             */

title '******** Step 4 ********';
libname Final 'C:\Users\22815\Desktop\5060_FP';
/* Connect oracle database user we created earlier by creating a oracle libref myoracle*/
libname myoracle oracle user = 'Chen_Yuxuan_STSCI5060FP' password = 123456;
/* Create an oracle database table school_finance_2010_t*/
proc sql;
   drop table myoracle.School_Finance_2010_t;
   create table myoracle.School_Finance_2010_t as
   select * from Final.School_Finance_2010;
quit;

title '******** Step 12 ********';
libname myoracle clear;
libname myoracle oracle user = 'Chen_Yuxuan_STSCI5060FP' password = 123456; 
/* Use merge to combine data from three views*/
data mfslr_t;
merge myoracle.mlf_v myoracle.msr_v myoracle.mlr_v;
run;
/* Create mfslr_t table in oracle use combined_views we created earlier*/
proc sql;
drop table myoracle.mfslr_t;
create table myoracle.mfslr_t
as select *
from
mfslr_t
order by stcode;

title '******** Step 20 ********';
libname SASUER 'C:\Users\22815\Desktop\5060_FP';
/* Create a dataset Total_Rev by querying the Total_Rev_v in Oracle*/
proc sql;
create table sasuser.Total_Rev
as select * from myoracle.Total_Rev_v;
quit;

title '******** Step 21 ********';
/* Correlation analysis*/
proc corr data= sasuser.Total_Rev
plots(maxpoints=NONE)= matrix(histogram);
var tfedrev tstrev tlocrev;
run;

title '******** Step 22 ********';
/* Regression analysis*/
proc reg data= sasuser.Total_Rev;
model tfedrev = tstrev tlocrev;
run;

title '******** Step 23 ********';
/* Correlation analysis by using data from the Total_Rev_v in Oracle*/
proc corr data= myoracle.Total_Rev_v
plots(maxpoints=NONE)= matrix(histogram);
var tfedrev tstrev tlocrev;
run;

/* Regression analysis by using data from the Total_Rev_v in Oracle*/
proc reg data= myoracle.Total_Rev_v;
model tfedrev = tstrev tlocrev;
run;

title '******** Step 24 ********';
/*Create School_Finance_2015_t table*/
proc sql;
drop table myoracle.School_Finance_2015_t;
create table myoracle.School_Finance_2015_t
as select * from Final.School_Finance_2015;
quit;

