proc format;
value basepop
	0="Excluded"
	1="Included"
	;
run; 

data msm23_weighted_analysis;
	set "/home/u63767119/MSM2023/data/indy_complete.sas7bdat"; 
	
	if el_msm=1 & consenta=1 & complete=1 & validity in (1,2) then basepop=1;
	else basepop=0;
	format basepop basepop.;
	label basepop = "Included in analysis";
	
	if el_msm=1 & consenta=1 & complete=1 & validity in (1,2) & _HIVtestresult in (0,1) then basepop_hiv=1;
	else basepop_hiv=0;
	format basepop_hiv basepop.;
	label basepop_hiv = "Included in analysis - valid HIV test result";
	
	if el_msm=1 & consenta=1 & complete=1 & validity in (1,2) & _HIVtestresult=0 then basepop_hivneg=1;
	else basepop_hivneg=0;
	format basepop_hivneg basepop.;
	label basepop_hivneg = "Included in analysis - HIV-negative MSM";
	
	if el_msm=1 & consenta=1 & complete=1 & validity in (1,2) & _HIVtestresult=1 then basepop_hivpos=1;
	else basepop_hivpos=0;
	format basepop_hivpos basepop.;
	label basepop_hivpos = "Included in analysis - HIV-positive MSM";
run;
	
	proc freq data=msm23_weighted_analysis;
tables basepop * el_msm * consenta * complete * validity/ list missing;
run;

/*Race ethnicity.*/
proc surveyfreq data=indy2023.msm23_weighted_analysis NOMCAR order=formatted; 
	strata stratum_n;
	cluster cluster_n;
	weight site_interview_weight;
	tables basepop * _raceomb / row cl chisq cv;
run;

/*Age group of MSM.*/
proc format;
value agefmt  
      18-24='18 - 24'
			25-29='25 - 29'
			30-39='30 - 39'
			40-49='40 - 49'
			50-99='>=50';
run;

proc surveyfreq data=indy2023.msm23_weighted_analysis NOMCAR order=formatted; 
	strata stratum_n;
	cluster cluster_n;
	weight site_interview_weight;
	format age AgeFmt.; 
	tables basepop * age / row cl chisq cv;
run; 

/*Sex/gender.*/
proc surveyfreq data=indy2023.msm23_weighted_analysis NOMCAR order=formatted; 
	strata stratum_n;
	cluster cluster_n;
	weight site_interview_weight;
	tables basepop * GNDRR7 * BIRTHSEX / row cl chisq cv;
run; 

/*SDOH analysis.*/
proc surveyfreq data=indy2023.msm23_weighted_analysis NOMCAR order=formatted; 
	strata stratum_n;
	cluster cluster_n;
	weight site_interview_weight;
	tables basepop * school / row cl chisq cv;
	tables basepop * empstat / row cl chisq cv; 
	tables basepop * HHINCR6 * DEPENDR6 / row cl chisq cv;
	tables basepop * currhlth / row cl chisq cv; 
	tables basepop * EVRHOMLS / row cl chisq cv; 
	tables basepop * vsitmd12 / row cl chisq cv;
	tables basepop * held12m / row cl chisq cv;
run; 

/*HIV status (by test result), currently taking antiretrovirals (among those 
who said they were HIV positive), visit MD in past 6 months (among those 
who said they were HIV positive), viral load (among those who said they were HIV
positive).*/
title 'HIV positive patients - medical tendencies';
proc surveyfreq data=indy2023.msm23_weighted_analysis NOMCAR order=formatted; 
	strata stratum_n;
	cluster cluster_n;
	weight site_interview_weight;
	tables basepop * TD_HIVRSLT * _raceomb / row cl chisq cv;
	tables basepop * RCNTRST / row cl chisq cv;
	tables basepop * C_LASTMD / row cl chisq cv; 
	tables basepop * CURRAMED / row cl chisq cv;
	tables basepop * EVERPOS * VLRSLTR7 / row cl chisq cv; 
run;

/*Ever tested for HIV.*/
proc surveyfreq data=indy2023.msm23_weighted_analysis NOMCAR order=formatted; 
	strata stratum_n;
	cluster cluster_n;
	weight site_interview_weight;
	tables basepop * EVERTEST * _raceomb / row cl chisq cv;
run;

/*PrEP awareness.*/
title 'PrEP Awareness';
proc surveyfreq data=indy2023.msm23_weighted_analysis NOMCAR order=formatted; 
	strata stratum_n;
	cluster cluster_n;
	weight site_interview_weight;
	tables basepop * PRPAWRR7 / row cl chisq cv;
run;

/*Receptive anal sex w/o condom. */
title 'Receptive anal sex without condom';
proc surveyfreq data=indy2023.msm23_weighted_analysis NOMCAR order=formatted; 
	strata stratum_n;
	cluster cluster_n;
	weight site_interview_weight;
	tables basepop * TM_URAS / row cl chisq cv;
	tables basepop * lptmrasc / row cl chisq cv;
	tables basepop * lptmiasc / row cl chisq cv;
run;

/*PrEP use in past 12 months, on-demand PrEP use, any missed dose in past 30 days, 
why not using PrEP, injectable PrEP.*/
title 'prep use and other details';
proc surveyfreq data=indy2023.msm23_weighted_analysis NOMCAR order=formatted; 
	strata stratum_n;
	cluster cluster_n;
	weight site_interview_weight;
	tables basepop * PRPUS12R7 / row cl chisq cv;
	tables basepop * PRPDMND / row cl chisq cv;
	tables basepop * PRPDM30 / row cl chisq cv;
	tables basepop * L_PREPSTOP_IND_1 / row cl chisq cv;
	tables basepop * L_PREPSTOP_IND_2 / row cl chisq cv;
	tables basepop * L_PREPSTOP_IND_3 / row cl chisq cv;
	tables basepop * L_PREPSTOP_IND_4 / row cl chisq cv;
	tables basepop * L_PREPSTOP_IND_5 / row cl chisq cv;
	tables basepop * L_PREPSTOP_IND_6 / row cl chisq cv;
	tables basepop * L_PREPSTOP_IND_7 / row cl chisq cv;
	tables basepop * L_PREPSTOP_IND_8 / row cl chisq cv;
	tables basepop * L_PREPSTOP_IND_9 / row cl chisq cv;
	tables basepop * L_PREPSTOP_IND_10 / row cl chisq cv;
	tables basepop * L_PREPSTOP_IND_99 / row cl chisq cv;
	tables basepop * L_PREPSTOP_IND_77 / row cl chisq cv;
	tables basepop * L_INJPREP2 / row cl chisq cv; 
	tables basepop * L_INJPREP6 / row cl chisq cv; 
run;

/*PEP use in past 12 months.*/
title 'PEP use in past 12 months';
proc surveyfreq data=indy2023.msm23_weighted_analysis NOMCAR order=formatted; 
	strata stratum_n;
	cluster cluster_n;
	weight site_interview_weight;
	tables basepop * PEPUSE / row cl chisq cv;
run;

/*STIs.*/
title 'STIs';
proc surveyfreq data=indy2023.msm23_weighted_analysis NOMCAR order=formatted; 
	strata stratum_n;
	cluster cluster_n;
	weight site_interview_weight;
	tables basepop * RSTDTEST / row cl chisq cv;
	tables basepop * GONORR / row cl chisq cv;
	tables basepop * CHLAMYD / row cl chisq cv; 
	tables basepop * SYPHILIS / row cl chisq cv; 
	tables basepop * EVRHERP / row cl chisq cv; 
run;

/*HPV vaccination.*/
title 'HPV vaccination';
proc surveyfreq data=indy2023.msm23_weighted_analysis NOMCAR order=formatted; 
	strata stratum_n;
	cluster cluster_n;
	weight site_interview_weight;
	tables basepop * HPVVAC * _raceomb / row cl chisq cv;
run;

/*Unable to afford medical care due to cost.*/
proc surveyfreq data=indy2023.msm23_weighted_analysis NOMCAR order=formatted; 
	strata stratum_n;
	cluster cluster_n;
	weight site_interview_weight;
	tables basepop * HCAFF * _raceomb / row cl chisq cv;
run;

/*Used drugs (other than marijuana) during sex.*/
proc surveyfreq data=indy2023.msm23_weighted_analysis NOMCAR order=formatted; 
	strata stratum_n;
	cluster cluster_n;
	weight site_interview_weight;
	tables basepop * l_pnp / row cl chisq cv;
run;

/* Withheld sexual orientation from healthcare provider out of fear of stigma.*/
proc surveyfreq data=indy2023.msm23_weighted_analysis NOMCAR order=formatted; 
	strata stratum_n;
	cluster cluster_n;
	weight site_interview_weight;
	tables basepop * l_wthprov / row cl chisq cv;
run;

/*Attended sex party.*/
proc surveyfreq data=indy2023.msm23_weighted_analysis NOMCAR order=formatted; 
	strata stratum_n;
	cluster cluster_n;
	weight site_interview_weight;
	tables basepop * l_venatt_9 / row cl chisq cv;
run;

/*Actions taken before or at sex parties in past 12 months.*/
proc surveyfreq data=indy2023.msm23_weighted_analysis NOMCAR order=formatted; 
	strata stratum_n;
	cluster cluster_n;
	weight site_interview_weight;
	tables basepop * L_DSEPREV_1 / row cl chisq cv;
	tables basepop * L_PSEPREV_2 / row cl chisq cv;
	tables basepop * L_DSEPREV_3 / row cl chisq cv;
	tables basepop * L_PSEPREV_4 / row cl chisq cv;
	tables basepop * L_DSEPREV_5 / row cl chisq cv;
	tables basepop * L_PSEPREV_6 / row cl chisq cv;
	tables basepop * L_PSEPREV_7 / row cl chisq cv;
	tables basepop * L_PSEPREV_77 / row cl chisq cv;
	tables basepop * L_PSEPREV_99 / row cl chisq cv;
run;

/*Actions taken after sex parties in past 12 months.*/
proc surveyfreq data=indy2023.msm23_weighted_analysis NOMCAR order=formatted; 
	strata stratum_n;
	cluster cluster_n;
	weight site_interview_weight;
	tables basepop * L_ASEPREV_1 / row cl chisq cv;
	tables basepop * L_ASEPREV_2 / row cl chisq cv;
	tables basepop * L_ASEPREV_3 / row cl chisq cv;
	tables basepop * L_ASEPREV_7 / row cl chisq cv;
	tables basepop * L_ASEPREV_9 / row cl chisq cv;
run;

/*Number of male partners in past 12 months.*/
proc surveyfreq data=indy2023.msm23_weighted_analysis NOMCAR order=formatted; 
	strata stratum_n;
	cluster cluster_n;
	weight site_interview_weight;
	tables basepop * M_MSX12 / row cl chisq cv;
run;

/*Reason for no HIV test in past 12 months.*/
title 'Reason for no HIV test in past 12 months';
proc surveyfreq data=indy2023.msm23_weighted_analysis NOMCAR order=formatted; 
	strata stratum_n;
	cluster cluster_n;
	weight site_interview_weight;
	tables basepop * RENT12M / row cl chisq cv;
run;

/*Ever seen by medical provider for respondent's HIV infection.*/
title 'Ever seen by medical provider for HIV infection';
proc surveyfreq data=indy2023.msm23_weighted_analysis NOMCAR order=formatted; 
	strata stratum_n;
	cluster cluster_n;
	weight site_interview_weight;
	tables basepop * POSMD / row cl chisq cv;
run;

/*In past 12 months, ever had one-on-one conversation with outreach worker, counselor
or prevention program worker about ways to prevent HIV.*/
title 'Ever spoken with outreach worker, etc. about ways to prevent HIV';
proc surveyfreq data=indy2023.msm23_weighted_analysis NOMCAR order=formatted; 
	strata stratum_n;
	cluster cluster_n;
	weight site_interview_weight;
	tables basepop * TALKHIV / row cl chisq cv;
run;

/*In past 12 months, participated in an organized session(s) involving a small group of 
people to discuss ways to prevent HIV.*/
title 'Participated in organized session to discuss HIV prevention';
proc surveyfreq data=indy2023.msm23_weighted_analysis NOMCAR order=formatted; 
	strata stratum_n;
	cluster cluster_n;
	weight site_interview_weight;
	tables basepop * GROUP12 / row cl chisq cv;
run;

/*Within 30 days after first positive HIV test, someone let them know where they 
could go for outpatient care (among those who said they were HIV positive).*/
title 'Informed about where to go for outpatient care < 30 days after first HIV test';
proc surveyfreq data=indy2023.msm23_weighted_analysis NOMCAR order=formatted; 
	strata stratum_n;
	cluster cluster_n;
	weight site_interview_weight;
	tables basepop * EVERPOS * TLDCARE / row cl chisq cv;
run;

/*Sexual identity; Location of usual care; Disclosed sexuality; Have you disclosed to friends who are not gay, lesbian or bisexual;
Have you disclosed to family; Have you disclosed to health care providers; Verbal discrimination; Service discrimination; 
Work discrimination; Health care discrimination; Physically attacked or injured because of attraction to men*/
proc surveyfreq data=indy2023.msm23_weighted_analysis NOMCAR order=formatted; 
	strata stratum_n;
	cluster cluster_n;
	weight site_interview_weight;
	tables basepop * identr7 / row cl chisq cv;
	tables basepop * srcloc / row cl chisq cv; 
	tables basepop * SRCCAREA / row cl chisq cv;
	tables basepop * out_yn / row cl chisq cv;
	tables basepop * out_fri / row cl chisq cv;
	tables basepop * out_fam / row cl chisq cv; 
	tables basepop * out_hcp / row cl chisq cv;
	tables basepop * disc_ver / row cl chisq cv;
	tables basepop * disc_svc / row cl chisq cv;
	tables basepop * disc_wrk / row cl chisq cv; 
	tables basepop * disc_hc / row cl chisq cv;
	tables basepop * disc_att / row cl chisq cv; 
run; 

