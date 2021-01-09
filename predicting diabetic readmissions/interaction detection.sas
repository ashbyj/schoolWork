libname capstone '/folders/myfolders/capstone/';
filename fwd '/folders/myfolders/capstone/fwd.xlsx';

proc import datafile=fwd
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

%global sl;
proc sql;
	select 1-probchi(log(sum(readmitted > 0)),1) into :sl
	from dTrain;
quit;

proc logistic data=dTrain;
	class race gender age admitType dischargeDisp admitSource admitSpecialty
	      primDxClus a1cVal insulin;
	model readmitted(event='1') = race gender age admitType dischargeDisp admitSource
	                              los admitSpecialty opVis ipEnc edEnc primDxClus a1cVal 
	                              metformin glimepiride glyburide pioglitazone 
	                              rosiglitazone insulin medChanged dmRx primDxClus
	                              race|gender|age|admitType|dischargeDisp|admitSource|
	                              los|admitSpecialty|opVis|ipEnc|edEnc|primDxClus|a1cVal|
                                  metformin|glimepiride|glyburide|pioglitazone|
                                  rosiglitazone|insulin|medChanged|dmRx|primDxClus @2 /
                                  include=23 clodds=pl selection=forward slentry=&sl;
run;

proc logistic data=dTrain;
	class primDxClus race age dischargeDisp admitSpecialty;
	model readmitted(event='1') = los ipEnc edEnc primDxClus metformin dmRx race age
	                              dischargeDisp admitSpecialty race*age age*dischargeDisp
	                              dischargeDisp*admitSpecialty ipEnc*age los*ipEnc /
	                              slstay=&sl hier=single fast;
run;

	                              