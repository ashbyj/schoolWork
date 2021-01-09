libname capstone '/folders/myfolders/capstone/';

%macro assess(data=, inputs=, index=);

	proc sql;
		create table cart as
		select o.readmitted as reA
			, t.readmitted as reB
			, o.p_1 as p1a
			, t.p_1 as p1b
		from &data as o
			, &data as t
		where reA ^= reB;
	quit;
			
	data assess;
		retain den 0 num 0;
		keep score inputs index;
		format inputs $char2000.;
		set cart end=last;
		
		den + 1;
		if reA = 1 and p1a > p1b then num + 1;
		if reB = 1 and p1b > p1a then num + 1;

        if last then do;
			index = &index;
			inputs = "&inputs";
			score = num / den;
			output;
		end;
	run;
	
	proc append base=results data=assess force;
	run;

%mend assess;

%macro fitAndScore();

	ods select none;
	ods output bestsubsets=score;
	proc logistic data=dTrain;
		model readmitted(event='1')=&diabeticVars / selection=score best=1;
	run;
	
	%global nmodels;
	proc sql;
		select count(*)
		into :nmodels 
		from score;
	quit;
		
	%do i=1 %to &nmodels;
		%global inputs&i;
		%global ic&i;
	%end;
	
	proc sql noprint;
		select variablesInModel 
		into :inputs1 -
		from score;
		
		select numberOfVariables
		into :ic1 -
		from score;
	quit;

	proc datasets
		library=work
		nodetails
		nolist;
		delete results;
	run;

	%do model_indx=1 %to &nmodels;
	
		* list of the variables included in the model at this index;
		%let im=&&inputs&model_indx;
		* number of variables included in the model at this index;
		%let ic=&&ic&model_indx;
	
		proc logistic data=dTrain;
			model readmitted(event='1')=&im;
			score data=dTest
				out=scoredDvalid(keep=readmitted p_1 p_0) fitstat;
		run;
		
		%assess(data=scoredDvalid, inputs=&im, index=&model_indx);

	%end;

	ods select all;

%mend fitAndScore;

* import and stratified sampling;
/*
filename reffile '/folders/myfolders/capstone/modelImport.xlsx';

proc import datafile=reffile
    dbms=xlsx
    replace
    out=diabeticData;
    getNames=yes;
run; 

proc sort data=diabeticData out=dSorted;
	by readmitted;
run;

proc surveySelect noprint data=dSorted samprate=0.7
                  out=dStrat seed=2020 outall;
	strata readmitted;
run;

data dTrain(drop=selected selectionProb samplingWeight)
     dValid(drop=selected selectionProb samplingWeight);
	set dStrat;
	if selected then output dTrain;
	else output dValid;
run;
*/

/*
* cluster summary for variable selection;
%global diabeticVars;
%let diabeticVars = los opVis edVis ipVis metformin glimepiride glyburide pioglitazone
                    rosiglitazone medChanged dmRx raceAA raceW genderF admitTypeElective
                    admitTypeEd admittingSpecSurg admittingSpecEd admittingSpecPcp admittingSpecOther 
                    insulinUp insulinSteady insulinDown primDx3 primDx4 primDx5 primDx6 
                    primDx7 primDx8 age4050 age5060 age6070 age7080 age8090 age90100 
                    dischargeDispHome dischargeDispTransfer admitSourceReferral admitSourceTransfer 
                    a1cValNorm a1cVal7 a1cVal8;
             
ods select none;
ods output clusterQuality = dSummary
           rsquare = dClusters;
           
proc varclus data = dTrain maxeigen = .7 hi;
	var &diabeticVars;
run;
ods select all;

%global diabeticNvar;
data _null_;
	set dSummary;
	call symput('diabeticNvar', compress(numberOfClusters));
run;

proc print data=dClusters noobs label split='*';
	where numberOfClusters = &diabeticNvar;
	var cluster variable rSquareRatio;
	label rSquareRatio='1 - rSquare*ratio';
run;
*/

filename dum '/folders/myfolders/capstone/cleanDummies.xlsx';

proc import datafile=dum
    dbms=xlsx
    replace
    out=diabeticData;
    getNames=yes;
run; 

proc sort data=diabeticData out=dSorted;
	by readmitted encId;
run;

proc surveySelect noprint data=dSorted samprate=0.7
                  out=dStrat seed=2020 outall;
	strata readmitted;
run;

data dTrain(drop=selected selectionProb samplingWeight)
     dTest(drop=selected selectionProb samplingWeight);
	set dStrat;
	if selected then output dTrain;
	else output dTest;
run;

%let diabeticVars = ipEnc edEnc metformin dmRx dx2 dx5 dx6 dx7 dx8 
                    raceC raceA dischHome dischTrans admitEmerg admitOther
                    admitPcp admitSurg age040 age4050 age5060 age6070 age7080
                    age8090 age90100 raceAage040 raceAage4050 raceAage5060
                    raceAage6070 raceAage7080 raceAage8090 raceAage90100 raceCage040
                    raceCage4050 raceCage5060 raceCage6070 raceCage7080 raceCage8090
                    raceCage90100 discHomeAge040 discHomeAge4050 discHomeAge5060
                    discHomeAge6070 discHomeAge7080 discHomeAge8090 discHomeAge90100
                    discTransAge040 discTransAge4050 discTransAge5060 discTransAge6070
                    discTransAge7080 discTransAge8090 discTransAge90100 discHomeAdmitEmerg
                    discHomeAdmitOther discHomeAdmitPcp discHomeAdmitSurg discTransAdmitEmerg
                    discTransAdmitOther discTransAdmitPcp discTransAdmitSurg;

%fitAndScore();

proc copy in=work out=capstone memtype=data;
	select results;
run;

proc sgplot data=capstone.results;
	where index >= 10;
	series y=score x=index / markers;
	xaxis values=(10 to 60 by 2);
run;


	
	
