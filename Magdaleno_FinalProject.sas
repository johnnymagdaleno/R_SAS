/*1.	Clean the data in SAS
a. Identify and print the duplicate records. Based on the records in 
other data sets, make educated guesses as to which of the duplicate 
records is likely correct and eliminate or modify the others. This guess 
should be based off the visit dates of the records.  Document your 
actions in the dataset cover sheet (see #4 below).*/

/*No duplicates detected*/
proc sort data=fp.apgar_fp;
by famno intdate; 
run;
data dupapgar;
set fp.apgar_fp;
by famno intdate;
if first.intdate=0 or last.intdate=0;
run;

proc sort data=fp.catis_fp;
by famno intdate; 
run;
data dupcatis;
set fp.catis_fp;
by famno intdate;
if first.intdate=0 or last.intdate=0;
run;

proc sort data=fp.icq_fp;
by famno intdate; 
run;
data dupicq;
set fp.icq_fp;
by famno intdate;
if first.intdate=0 or last.intdate=0;
run;

/*Duplicates detected.*/
proc sort data=fp.demog_fp;
by famno enroldate; 
run;
data dupdemog;
set fp.demog_fp;
by famno enroldate;
if first.enroldate=0 or last.enroldate=0;
run;

proc sort data=fp.famres_fp;
by famno intdate; 
run;
data dupfamres;
set fp.famres_fp;
by famno intdate;
if first.intdate=0 or last.intdate=0;
run;

/**/

title "DEMOG Duplicates";
proc print data=dupdemog;
run;
title "FAMRES Duplicates";
proc print data=dupfamres;
run;

data famres_nodup;
set fp.famres_fp;
if FAMNO = 203 and RES4 = . then delete;
run;

proc sort data = famres_nodup
out = fp.famres_nodup_final nodup;
by _ALL_;
run;

proc sort data = fp.demog_fp
out = fp.demog_nodup_final nodup;
by _ALL_;
run;

/*b. In the CATIS and Family Resources data files, 
identify and print records with values that are out of 
range such as RES1=5 in the FAMRES_FP dataset.  Determine 
how best to deal with these values.  Document your decisions 
in the dataset cover sheet (see #4 below). */

data fp.famres_outliers;
set fp.famres_nodup_final;
if max(of RES1-RES26) gt 4 then outlier=1; 
run;

proc print data=fp.famres_outliers;
where outlier=1;
run;

data fp.famres_outliers_fixed;
set fp.famres_outliers;
array qlist{30} RES1-RES30;
do i=1 to 30;
if qlist{i} gt 4 then qlist{i}=. ;
end;
drop i;
run;

proc print data=fp.famres_outliers_fixed;
where outlier=1;
run;

data fp.catis_outliers;
set fp.catis_fp;
if max(FAULT, FROMLIKE, FEELSICK, FEELHAP, FEELDIFF, 
FEELBAD, SADSICK, STARTNEW, FEELGOOD, YOUHAVE, 
FAIR, SADHAPPY, TOHAVE) gt 5 then outlier=1; 
run;

proc print data=fp.catis_outliers;
where outlier=1;
run;

data fp.catis_outliers_fixed;
set fp.catis_outliers;
array qlist{13} FAULT FROMLIKE FEELSICK FEELHAP FEELDIFF 
FEELBAD SADSICK STARTNEW FEELGOOD YOUHAVE 
FAIR SADHAPPY TOHAVE;
do i=1 to 13;
if qlist{i} gt 5 then qlist{i}=. ;
end;
drop i;
run;

proc print data=fp.catis_outliers_fixed;
where outlier=1;
run;

/*c. For the Family Resources questionnaire, ignoring visit number: 
i.	Calculate the number of days between visits
ii.	Generate frequencies grouping the days into 3 categories: 
< 1 year, 1-2 years and >=2 years
iii. Generate a clean-up query list, displaying all FAMRES records, 
for participants who have less than one year or more than 2 years 
between visits.  Provide a meaningful title for this list.*/

proc sort data=fp.famres_outliers_fixed;
by famno intdate;
run;

data fp.famres_visitcode;
set fp.famres_outliers_fixed;
if visit = 'B' then newvisit = 1;
if visit = 'M18' then newvisit = 2;
if visit = 'M36' then newvisit = 3;
run;

data fp.famres_oneobs;
set fp.famres_visitcode;
by famno newvisit;
array visitdate{3};
retain visitdate1-visitdate3;
if first.famno then call missing(of visitdate1-visitdate3);
visitdate{newvisit} = intdate;
if last.famno then output;
run;

data fp.famres_daysbtwn;
set fp.famres_oneobs;
if visitdate3 ne . then days_btwn_visits = visitdate3 - visitdate1;
else if visitdate3 eq . and visitdate2 ne . then days_btwn_visits = visitdate2 - visitdate1;
else if visitdate2 eq . and visitdate3 eq . and visitdate1 ne . then days_btwn_visits=0;
run;

proc format;
value years
low-364 = "Less than a year"
365-730 = "1 - 2 years"
730-high = "2 or more years";
run;

data fp.famres_daysbtwn_format;
set fp.famres_daysbtwn;
format days_btwn_visits years.;
run;

data fp.famres_daysbtwn_1year2plus;
merge fp.famres_daysbtwn_format fp.famres_outliers_fixed;
by famno;
run;

data fp.famres_1year2plus;
set fp.famres_daysbtwn_1year2plus;
if 364 < days_btwn_visits < 731 then delete;
run;

title 'List Of Families With <1 Year or 2+ Years Since Last Visit';
proc print data=fp.famres_1year2plus;
run;

/*2. Generate a permanent cross-sectional analysis data set. 
a.	Using PUT, SCAN and LEFT functions, extract the state from the 
formatted site code. Hint: to get started, see Program 11.14 in textbook.*/

proc format;
value siteF 1='Indianapolis, Indiana' 2='Cincinnati, Ohio'
3='Peoria, Illinois' 4='Lexington, Kentucky' 5='Lincoln, Illinois'
6='Frankfort, Kentucky';
run;

data fp.masterfile;
merge fp.catis_outliers_fixed 
fp.famres_outliers_fixed 
fp.apgar_fp 
fp.icq_fp 
fp.demog_nodup_final;
by famno;
run;

data fp.masterfile_states;
set fp.masterfile;
site2 = put(site, sitef.);
state_site = left(scan(site2, 2));
drop site2;
run;

/*b.	Label and format (as needed) all variables.*/
proc format;
value raceF 1='African-American' 2='Caucasian'
3='Hispanic' 4='Asian' 5='Native American'
6='Bi-Racial' 7='Other'; 
run;

data fp.masterfile_crosssec;
set fp.masterfile_states;
format race racef.;
label famno = "Family Identifier Number"
enroldate = "Date of Baseline Demographic Interview"
educ = "Current school grade of child"
site = "Site where interview occurred"
state_site = "State where interview occurred";
keep  Famno enroldate sex race dob educ site state_site;
run;

proc print data=fp.masterfile_crosssec label;
run;

/*c.	Generate frequencies for demographic data where appropriate.*/
title "Frequencies for Race, Education, Site and Sex";
proc freq data=fp.masterfile_crosssec;
table race;
table educ;
table site;
table sex;
run;

/*d.	Run PROC Contents on this analysis data set.*/
proc contents data=fp.masterfile_crosssec;
run;

/*3.	Generate permanent longitudinal analysis data set(s).  
a.	Calculate child’s age at each encounter.*/

data fp.masterfile_long;
set fp.masterfile_states; 
child_age_yrs = yrdif(dob, intdate);
format child_age_yrs 4.1;
drop enroldate sex race dob educ site state_site;
run;

/*b. Generate summary scores for the data collection instruments 
CATIS, Family Resources, and Infant Characteristics Questionnaire 
(ICQ) based on the criteria in score_notesSZ_FP.doc.
c.	Label and format (if needed) all derived variables such 
as summary scores.  You do not need to label or format the 
individual questionnaire variables such as RES1-RES30.*/

/*CATIS*/
data fp.catis_sumscore;
set fp.catis_outliers_fixed;
array items {13} FAULT FROMLIKE FEELSICK FEELHAP FEELDIFF FEELBAD 
SADSICK STARTNEW FEELGOOD YOUHAVE FAIR SADHAPPY TOHAVE;
array itemsR {13} FAULTr FROMLIKEr FEELSICKr FEELHAPr FEELDIFFr FEELBADr 
SADSICKr STARTNEWr FEELGOODr YOUHAVEr FAIRr SADHAPPYr TOHAVEr;
amiss = nmiss(of FAULT FROMLIKE FEELSICK FEELHAP FEELDIFF FEELBAD 
SADSICK STARTNEW FEELGOOD YOUHAVE FAIR SADHAPPY TOHAVE);
if amiss lt 6 then do;
do i=1 to 13;
itemsR{i} = 6-items{i};
end;
CATIS=mean(FAULTr,FROMLIKEr,FEELSICKr,FEELHAPr,FEELDIFFr,FEELBADr,
SADSICKr,STARTNEWr,FEELGOODr,YOUHAVEr,FAIRr,SADHAPPYr,TOHAVEr);
end;
drop i amiss FAULTr FROMLIKEr FEELSICKr FEELHAPr FEELDIFFr FEELBADr 
SADSICKr STARTNEWr FEELGOODr YOUHAVEr FAIRr SADHAPPYr TOHAVEr;
label CATIS='CATIS Score';
run;

/*FAMRES*/
data fp.famres_sumscore_mast;
set fp.famres_nodup_final;
array items {18} RES1-RES18;
array itemsR {18} RESr1-RESr18;
amiss = nmiss(of RES1-RES18);
if amiss lt 7 then do;
do i=1 to 18;
itemsR{i} = 4-items{i};
end;
FRMAST=mean(of RESr1-RESr18);
end;
drop i amiss RESr1-RESr18;
label FRMAST='FAMRES - Master Score';
run;

data fp.famres_sumscore_esteem;
set fp.famres_nodup_final;
array items {12} RES19-RES30;
array itemsR {12} RESr19-RESr30;
amiss = nmiss(of RES19-RES30);
if amiss lt 5 then do;
do i=1 to 12;
itemsR{i} = items{1}-1;
end;
FRESTEEM=mean(of RESr19-RESr30);
end;
drop i amiss RESr19-RESr30;
label FRESTEEM='FAMRES - Esteem Score';
run;

/* ICQ */
data fp.icq_sumscore_diff;
set fp.icq_fp;
amiss = nmiss(of TIMFUS CRYGEN UPSET LOUD MOOD 
ATTENT PLAYALON ATTBUS OVDIFF);
if amiss lt 4 then do;
ICQDIFF=mean(of TIMFUS CRYGEN UPSET LOUD MOOD 
ATTENT PLAYALON ATTBUS OVDIFF)*9;
end;
drop amiss;
label ICQDIFF='ICQ - Difficultness Score';
run;

data fp.icq_sumscore_unadp;
set fp.icq_fp;
amiss = nmiss(of RESPERS, RESPLAC, ADAPT);
if amiss lt 2 then do;
ICQUNADP=mean(of RESPERS, RESPLAC, ADAPT)*3;
end;
drop amiss;
label ICQUNADP='ICQ - Unadaptability Score';
run;

data fp.icq_sumscore_resis;
set fp.icq_fp;
amiss = nmiss(of LEAVE, GOSTOP, REMOVE);
if amiss lt 2 then do;
ICQRESIS=mean(of LEAVE, GOSTOP, REMOVE)*3;
end;
drop amiss;
label ICQRESIS='ICQ - Resistance To Control Score';
run;

/*d. Run PROC Contents on this/these analysis data set(s).*/

proc contents data=fp.icq_sumscore_resis;
proc contents data=fp.icq_sumscore_unadp;
proc contents data=fp.icq_sumscore_diff;
proc contents data=fp.famres_sumscore_esteem;
proc contents data=fp.famres_sumscore_mast;
proc contents data=fp.catis_sumscore;

data fp.magdaleno_long;
merge fp.catis_sumscore fp.famres_sumscore_mast fp.famres_sumscore_esteem
fp.icq_sumscore_diff fp.icq_sumscore_unadp fp.icq_sumscore_resis fp.demog_nodup_final fp.masterfile_long;
by famno;
drop sex race dob outlier educ site enroldate;
label child_age_yrs="Child Age At Visit";
run;

/*4. Create a dataset cover sheet describing your analysis datasets.*/
/*See attached dataset cover sheet.*/
/*5. For each of the summary score variables, generate the following 
statistics: number of missing values, number of nonmissing values, 
mean, standard deviation, minimum, first quartile (Q1), median, 
third quartile (Q3) and maximum.  Report these statistics overall and
 broken down by sex.*/

data fp.summaryscores;
merge fp.catis_sumscore fp.famres_sumscore_mast fp.famres_sumscore_esteem
fp.icq_sumscore_diff fp.icq_sumscore_unadp fp.icq_sumscore_resis fp.demog_nodup_final;
by famno;
keep FAMNO SEX VISIT ICQRESIS ICQUNADP ICQDIFF FRESTEEM FRMAST CATIS;
run;

proc means data=fp.summaryscores nmiss n mean std min q1 median q3 max;
class SEX;
var ICQRESIS ICQUNADP ICQDIFF FRESTEEM FRMAST CATIS;
output out=sumscoranalysis_sex;
run;

proc means data=fp.summaryscores nmiss n mean std min q1 median q3 max;
var ICQRESIS ICQUNADP ICQDIFF FRESTEEM FRMAST CATIS;
output out=sumscoranalysis_overall;
run;

/*6. Produce a horizontal bar chart showing a frequency distribution of race.  
Within each bar, show the distribution of sex.*/

proc format;
value raceF 1='African-American' 2='Caucasian'
3='Hispanic' 4='Asian' 5='Native American'
6='Bi-Racial' 7='Other'; 
run;

title "Sex By Race Of Study Participants";
proc sgplot data=fp.demog_nodup_final;
hbar race / group=sex;
format race racef.;
run;


