
filename sas_test '/home/u49317956/Udemy_SAS/sas_test.xlsx';
proc import datafile = sas_test
  dbms = xlsx
  out = hist1 replace;
  getnames = yes;
run;
filename stat '/home/u49317956/Udemy_SAS/STAT.xlsx';
proc import datafile = stat
  dbms = xlsx
  out = stat1 replace;
  getnames = yes;
run;
filename studht '/home/u49317956/Udemy_SAS/STUDHT.xlsx';
proc import datafile = studht
  dbms = xlsx
  out = studht1 replace;
  getnames = yes;
run;

data both;
 set stat1 hist1;
run;

proc sort data = both nodup;
by name;
run;
proc sort data = studht1 nodup;
by name;
run;

data merged;
merge both studht1;
by name;
run;

data result;
  set merged;
  weightkg = weight * 0.454;
  heightm = height * 2.54/100;
  bmi = weightkg/(heightm * heightm);
  if bmi ne . then do;
  if bmi lt 18 then status = 'Underweight';
  else if bmi lt 20 and bmi ge 18 then status = 'Healthy';
  else if bmi lt 22 and bmi ge 20 then status = 'Overweight';
  else if bmi ge 22 then status ='Obese';
  end;
run;

proc chart data = result;
pie status;
run; 


proc freq data = result;
tables gender*status / out = new1;
run;


data new;
	set new1;
	value = cat(count, '(' , round(percent,0.1),'%',')');
	drop count percent;
run;
proc sort data = new;
by status;
run;

proc transpose data = new out = new_t;
var value;
id gender;
by status;
run;

proc print data = new_t(drop = _name_);
title'Report of Frequency Table';
run;

%macro mystat(var1,var2);
proc freq data = result;
tables &var1*&var2 / out = new1;
run;
data new;
	set new1;
	value = cat(count, '(' , round(percent,0.1),'%',')');
	drop count percent;
run;
proc sort data = new;
by &var2;
run;

proc transpose data = new out = new_t;
var value;
id &var1;
by &var2;
run;

proc print data = new_t(drop = _name_);
title'Report of Frequency Table';
run;
%mend;
%mystat(gender,status);

