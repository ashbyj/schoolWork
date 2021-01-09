%let dVars=ipEnc edEnc metformin dmRx dx2 dx5 dx6 dx8 age8090 
    raceCage5060 discHomeAge5060 discHomeAge8090 discTransAge6070 
    discTransAge7080 discHomeAdmitOther discTransAdmitPcp 
    discTransAdmitSurg;
    
proc logistic data=dTrain;
	model readmitted(event='1')=&dvars /outroc=dRoc;
run;

proc gplot data=dRoc;
	plot _sensit_*_1mspec_;
run;