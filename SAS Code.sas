/******************** Homework 1 - Reshaping Data ********************/
libname homework "C:/Irene Hsueh's Documents\MS Applied Biostatistics/BS 803 - Statistical Programming for Biostatisticians/Class 1 - Reshaping Data/Homework 1";
data naac;
	set homework.exercise1;
	keep naccid vnumber sex naccudsd naccageb nacczmms nacczlmi nacczlmd nacczdft;
	rename naccid=id vnumber=visit naccudsd=cognitive_status naccageb=age_baseline
		   nacczmms=mmse_score nacczlmi=immediate_score nacczlmd=delayed_score nacczdft=digit_forward;
run;

proc sort data=naac;
by id visit;
run;

title "NACC Dataset";
proc print data=naac (obs=50)
	style(header) = {just=center verticalalign=middle};
run;
title;




title "Long to Wide Format";
proc transpose data=naac out=mmse prefix=mmse;
	by id;
	id visit;
	var mmse_score;
run;
proc print data=mmse (obs=50);
run;

proc transpose data=naac out=immediate prefix=immediate;
	by id;
	id visit;
	var immediate_score;
run;
proc print data=immediate (obs=50);
run;

proc transpose data=naac out=delayed prefix=delayed;
	by id;
	id visit;
	var delayed_score;
run;
proc print data=delayed (obs=50);
run;

proc transpose data=naac out=digit prefix=digit;
	by id;
	id visit;
	var digit_forward;
run;
proc print data=digit(obs=50);
run;
title;




%macro transpose_macro (dataset_name=, psych_prefix=, psych_measure=);
proc transpose data=naac out=&dataset_name prefix=&psych_prefix;
	by id;
	id visit;
	var &psych_measure; 
run;
proc print data=&dataset_name (obs=50);
run;
%mend transpose_macro;

title "Long to Wide Format";
%transpose_macro (dataset_name=mmse, psych_prefix=mmse, psych_measure=mmse_score);
%transpose_macro (dataset_name=immediate, psych_prefix=immediate, psych_measure=immediate_score);
%transpose_macro (dataset_name=delayed, psych_prefix=delayed, psych_measure=delayed_score);
%transpose_macro (dataset_name=digit, psych_prefix=digit, psych_measure=digit_forward);
title;




ODS HTML close;
ODS HTML;




proc format;
	value cognitive_format 1="Normal Cognition" 2="Impaired not MCI" 3="MCI" 4="Dementia";
	value sex_format 1="Male" 2="Female";
run;

title "Baseline Demographics";
data demographics;
	set naac;
	by id;
	if first.id then output;
	keep id visit sex cognitive_status age_baseline;
	format sex sex_format. cognitive_status cognitive_format.;
run;

proc print data=demographics (obs=50)
	style(header) = {just=center verticalalign=middle};
run;
title;




title "Merging Wide Datasets";
data wide;
	merge demographics mmse immediate delayed digit;
	by id;
	drop _name_ _label_;
run;

proc print data=wide (obs=50)
	style(header) = {just=center verticalalign=middle};
run;
title;




title "Replacing Missing Values using Arrays";
data wide_recode;
	set wide;
		array miss(40) mmse1-mmse10 immediate1-immediate10 delayed1-delayed10 digit1-digit10;
			do i=1 to 40;
				if miss(i) in (-99,99) then miss(i)=.;
			end;
run;

proc print data=wide_recode (obs=50)
	style(header) = {just=center verticalalign=middle};
run;
title;
