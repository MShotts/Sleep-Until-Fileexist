/* Example SAS code from e-Poster 2562-2018 presented at SAS Global Conference 2018 in Denver, Colorado		*/
/* Files Arriving at an Inconvenient Time? Let SAS® Process Your Files with FILEEXIST While You Sleep 		*/
/* Author: Matthew Shotts	Email: mattshotts@gmail.com														*/

%let example_input=SGC2018_Example_Input.xlsx;

%let MaxAttempt=12;	/*Define the number of desired search attempts	  										*/
%let Interval=5;	/*Define Interval (seconds) between attempts	  										*/
%let filehere=N;/*DON'T CHANGE, Remains 'N' until the file is found after which it is switched to 'Y'		*/
%let count=0;	/*DON'T CHANGE, Set to 0 and +1 is added after each attempt to locate the file				*/

%macro find;
%do %until ("&filehere."="Y" or &count.=&MaxAttempt.); /* These are the criteria for the loop to close 		*/

%if %sysfunc(fileexist("C:\Users\mshotts\Documents\example_input.dat"))
	%then %do; /* If file is found then the &filehere is updated to Y to close the %do %until loop			*/
		%let filehere=Y;
	%end;

	%else %do; /* If file is not found then SAS goes to sleep and the &count of the attempts has 1 added	*/
		%let count=%eval(&count.+1); /* &count is the number of search attempts for the file				*/

		data _null_;
			slept=sleep(&Interval.);
		run;
	%end;
%end;

%if &count.=&MaxAttempt. %then %do; /* Ends process if file is not found after specified number of attempts	*/
	%let waittime=%eval((&MaxAttempt.*&Interval.)/60); /* This transforms the search time into minutes 		*/
	%put WARNING: The file has not yet appeared after &waittime. minute(s), Contact your data provider;
	%abort cancel; /* %abort cancel ensures that SAS stops here after reaching the max attempt threshold	*/
%end;

%mend find;
%find;
/* Insert the code for processing the file here, SAS will proceed to this line once the file is found		*/

/* Example of a SAS code for processing an Excel input file													*/
libname InputDat "C:\Users\mshotts\Documents\&example_input.";

proc means data=InputDat."Input$"n;
var Total_Score;
class Region;
output out=InputDat.Report;
run;

libname InputDat clear;
