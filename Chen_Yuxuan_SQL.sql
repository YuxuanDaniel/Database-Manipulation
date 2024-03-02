/* Fall 2023 STSCI 5060 Final Project */
/* Name: Yuxuan Chen                  */
/* NetID: yc2763                      */
ttitle '******** Step 2 ********' skip 2
-- show data from state_t
select * from state_t;
describe state_t;

ttitle '******** Step 3 ********' skip 2
-- change stcode single digit to double digit start with 0
update State_t set stcode = '0' || substr(stcode, 1, 1)
where cast(stcode as integer) between 1 and 9;
-- display the 9 rows which has stcode less than 10 
select * from State_t where stcode < 10;

ttitle '******** Step 4 ********' skip 2
-- look at school_finance_2010_t property and display the first 10 rows.
describe school_finance_2010_t;
SELECT * FROM school_finance_2010_t where rownum <= 10;

ttitle '******** Step 5 ********' skip 2
-- change school_finance_2010_t datatype
alter table school_finance_2010_t modify idcensus varchar2(15);
alter table school_finance_2010_t modify name varchar2(60);

ttitle '******** Step 6 ********' skip 2
-- rename column name
alter table school_finance_2010_t rename column name to SD_NAME;
alter table school_finance_2010_t rename column State to STCODE;

ttitle '******** Step 7 ********' skip 2
/* A */
-- create table fedrev_t. drop clause to prevent error occur in the output
drop table Fedrev_t;
create table Fedrev_t as
select idcensus,stcode,
(c14 + c15 + c16 + c17 + c18 + c19 + b11 + 
c20 + c25 + c36 + b10 + b12 + b13) as fed_rev
from School_Finance_2010_t;

/* B */
-- create table strev_t. drop clause to prevent error occur
drop table strev_t;
create table Strev_t as
select idcensus,stcode,
(c01 + c04 + c05 + c06 + c07 + c08 + c09 + 
c10 + c11 + c12 + c13 + c24 + c35 + c38 + c39) as st_rev
from School_Finance_2010_t;

/* C */
-- create table Locrev_t. drop clause to prevent error occur
drop table Locrev_t;
create table Locrev_t as
select idcensus,stcode,
(t02 + t06 + t09 + t15 + t40 + t99 + d11 + d23 + a07 + a08 + a09 
+ a11 + a13 + a15 + a20 + a40 + u11 + u22 + u30 + u50 + u97) as loc_rev
from School_Finance_2010_t;

/* D */
-- create table school_t. drop clause to prevent error occur
drop table school_t;
create table School_t as
select idcensus,stcode,sd_name FROM School_Finance_2010_t;

ttitle '******** Step 8 ********' skip 2
/* A */
-- set up primary key for state_t
alter table state_t add constraint pk_state primary key (stcode);
/* B */
-- set up primary key for the four table we created previously
alter table fedrev_t add constraint pk_fedrev primary key (idcensus);
alter table strev_t add constraint pk_strev primary key (idcensus);
alter table locrev_t add constraint pk_locrev primary key (idcensus);
alter table school_t add constraint pk_school primary key (idcensus);

/* C */
-- set up foreign key for the three table we created previously
alter table fedrev_t add constraint fk_fedrev foreign key (idcensus) references school_t (idcensus);
alter table strev_t add constraint fk_strev foreign key (idcensus) references school_t (idcensus);
alter table locrev_t add constraint fk_locrev foreign key (idcensus) references school_t (idcensus);

/* D */
-- set up foreign key for the school_t we created previously
alter table school_t add constraint fk_school_state foreign key (stcode) references state_t (stcode);

ttitle '******** Step 10 ********' skip 2
-- selet id,stcode,federal revenue from fed_revenue table whose revenue is greater than 1000000
select idcensus,stcode,to_char(fed_rev,'999999999.9') as fed_revenue
from fedrev_t where fed_rev > 1000000;
-- selet id,stcode,state revenue from st_revenue table whose revenue is greater than 1000000
select idcensus,stcode,to_char(st_rev,'999999999.9') as st_revenue
from strev_t where st_rev > 1000000;
-- selet id,stcode,local revenue from loc_revenue table whose revenue is greater than 1000000
select idcensus,stcode,to_char(loc_rev,'999999999.9') as loc_revenue
from locrev_t where loc_rev > 1000000;

ttitle '******** Step 11 ********' skip 2
-- create view sd#_v
create or replace view sd#_v as select count(*  as SD#,stcode
from school_t group by stcode;
/* A */
-- find states with the highest number of district 
select v.stcode,s.stname,v.SD#
from sd#_v v join state_t s on v.stcode = s.stcode
where v.SD# = (select max(SD#) from sd#_v);
/* B */
-- find states with the lowest number of district
select v.stcode,s.stname,v.SD#
from sd#_v v join state_t s on v.stcode = s.stcode
where v.SD# = (select min(SD#) from sd#_v);

ttitle '******** Step 12 ********' skip 2
/* A */
-- create three views mfr_v, msr_v, mlr_v
create or replace view mlf_v as select stcode, max(fed_rev) as MAX_FED_REV
from fedrev_t group by stcode;

create or replace view msr_v as select stcode, max(st_rev) as MAX_ST_REV
from strev_t group by stcode;

create or replace view mlr_v as select stcode, max(loc_rev) as MAX_LOC_REV
from locrev_t group by stcode;
/* B */
-- show in sas

/* C */
-- use mfslr_t to show result
select m.stcode,to_char(m.max_fed_rev,'999999999.9') as max_fed_rev,
to_char(m.max_st_rev,'999999999.9') as max_st_rev,
to_char(m.max_loc_rev,'999999999.9') as max_loc_rev,
s.stname as state_name
from mfslr_t m join state_t s on m.stcode = s.stcode order by s.stname;

ttitle '******** Step 13 ********' skip 2
--sorting result by revenue in descending order
select a.stcode as state_code, c.stname as state_name,
to_char(fed_rev,'999999999.9') as max_fed_rev,
b.sd_name from fedrev_t a
join school_t b on a.idcensus=b.idcensus
join state_t  c on a.stcode=c.stcode
where fed_rev >= all(select fed_rev from fedrev_t where stcode=a.stcode )
order by max_fed_rev desc;

ttitle '******** Step 14 ********' skip 2
--create view total_rev_v
create or replace view Total_Rev_v as
select f.idcensus, f.stcode, f.fed_rev as tfedrev, s.st_rev as tstrev, l.loc_rev as tlocrev
from fedrev_t f join strev_t s on f.idcensus = s.idcensus and f.stcode = s.stcode
join locrev_t l on f.idcensus = l.idcensus and f.stcode = l.stcode;

ttitle '******** Step 15 ********' skip 2
-- calculate the total revenue of three sources and diplay first 100 rows by total revenue
select r.stcode, s.stname, r.idcensus, (r.tfedrev + r.tstrev +r.tlocrev) as total_revenue,
sd.sd_name from total_rev_v r join state_t s on r.stcode = s.stcode
join school_t sd on r.idcensus = sd.idcensus where rownum <= 100
order by total_revenue desc;

ttitle '******** Step 16 ********' skip 2
--calculate the total expenditure of school district by state
select sf.stcode, st.stname, sum(sf.TOTALEXP) as total_expenditure
from SCHOOL_FINANCE_2010_T sf join State_t st on sf.stcode = st.stcode
group by sf.stcode, st.stname order by total_expenditure desc;

ttitle '******** Step 17 ********' skip 2
--calculating the total amount us spent on public school in 2010
set heading off
select 
'The total amount that the United States spent on the public school systems in 2010 was $'||cast(to_char(sum(totalexp),'999999999.9') as varchar2(13))||'K.'
from school_finance_2010_T; 
set heading on;

ttitle '******** Step 18 ********' skip 2
/*A*/
--create view fed_contribution_v and find school districts that receive federal revenue greater than total expense
create or replace view fed_contribution_v as
select a.idcensus, a.stcode, c.sd_name, round(a.fed_rev/b.totalexp,4) as fed_pcnt
from fedrev_t a join school_finance_2010_t b on a.idcensus = b.idcensus
and b.totalexp > 0 join school_t c on a.idcensus = c.idcensus
join state_t d on a.stcode = d.stcode;
select * from fed_contribution_v where fed_pcnt > 1 order by fed_pcnt desc;
/*B*/
--create view st_contribution_v and find school districts that receive state revenue greater than total expense
create or replace view st_contribution_v as 
select a.idcensus, a.stcode, d.stname, c.sd_name, round(a.st_rev/b.totalexp,4) as st_pcnt 
from strev_t a join School_Finance_2010_t b on a.idcensus = b.idcensus 
and b.totalexp<>0 join school_t c on a.idcensus = c.idcensus
join state_t  d on a.stcode = d.stcode;
select * from st_contribution_v where st_pcnt > 1 order by st_pcnt desc;
/*C*/
--create view loc_contribution_v and find school districts that receive local revenue greater than total expense
create or replace view loc_contribution_v as 
select a.idcensus, a.stcode, d.stname, c.sd_name, round(a.loc_rev/b.totalexp,4) AS loc_pcnt 
from locrev_t a join School_Finance_2010_t b on a.idcensus = b.idcensus 
and b.totalexp<>0 join school_t c on a.idcensus = c.idcensus
join state_t d on a.stcode = d.stcode;
select * from loc_contribution_v where loc_pcnt > 1 order by  loc_pcnt desc;

ttitle '******** Step 19 ********' skip 2
--create view fsl_contribution
create or replace view fsl_contribution_v as
select fed.idcensus, fed.stcode, fed.sd_name, round(fed_pcnt+ st_pcnt+ loc_pcnt,4) 
as fsl_pcnt from fed_contribution_v fed, st_contribution_v st, loc_contribution_v loc
where fed.idcensus= st.idcensus and fed.idcensus= loc.idcensus;
/*A*/
--select school distyrict that receive total revenue 3 times of what they spent
select * from fsl_contribution_v where fsl_pcnt > 3 order by fsl_pcnt desc;
/*B*/
--select school distyrict that receive total revenue 30% of what they spent
select * from fsl_contribution_v where fsl_pcnt <= 0.3 order by fsl_pcnt desc;

