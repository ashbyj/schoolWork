* Greenacre's method implementation in SAS adapted from the;
* SAS virtual learning environment.  Predictive Modeling;
* Using Logistic Regression (15.1) by Mike Patetta;
* https://vle.sas.com/course/view.php?id=3472;

libname capstone '/folders/myfolders/capstone/';

filename dx '/folders/myfolders/capstone/dxForGreenacres.xlsx';

proc import datafile=dx
	dbms=xlsx
	out=capstone.collapseDx
	replace;
	getNames=yes;
run;


proc means data=capstone.collapsedx noprint nway;
	class primDx;
	var readmitted;
	output out=capstone.dxLevel mean=meanReadmit;
run;

ods output clusterhistory=capstone.dxCluster;
proc cluster data=capstone.dxLevel method=ward outtree=capstone.forTree;
	freq _freq_;
	var meanReadmit;
	id primDx;
run;

proc freq data=capstone.collapseDx noprint;
	tables primDx*readmitted / chisq;
	output out=capstone.chi(keep=_pchi_) chisq;
run;

data capstone.chiCutoff;
	if _n_ = 1 then set capstone.chi;
	set capstone.dxCluster;
	chisquare=_pchi_*rsquared;
	degfree=numberOfClusters-1;
	logpvalue=logsdf('chisq', chisquare, degfree);
run;

proc sql;
	select numberOfClusters into :ncl
	from capstone.chiCutoff
	having logpvalue=min(logpvalue);
quit;

proc tree data=capstone.forTree nclusters=&ncl out=capstone.clus noprint;
	id primDx;
run;

proc sort data=capstone.clus;
	by clusname;
run;

proc print data=capstone.clus;
	by clusname;
	id clusname;
run;

%global capstoneFolder;
%let capstoneFolder=/folders/myfolders/capstone; 

filename dxClus "&capstoneFolder/primDx_clus.sas";

data _null_;
	file dxClus;
	set capstone.clus end=last;
	if _n_=1 then put "select (primDx);";
	put " when ('" primDx +(-1) "') primDxClus = '" cluster +(-1) "';";
	if last then do;
		put "  otherwise primDxClus = 'U';" / "end;";
	end;
run;

data capstone.dxGreenAcre;
	set capstone.collapsedx;
	%include dxClus / source2;
run;

proc export 
  data=capstone.dxGreenAcre
  dbms=xlsx 
  outfile="&capstoneFolder/dxClusters.xlsx" 
  replace;
run;


