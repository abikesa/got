
use $data, clear
g years=permth_exm/12
stset years, fail(mortstat)
stcox i.$subgroup if inlist(${subgroup},1,2,3,4,6,7), basesurv(s0)
matrix define m=r(table)
matrix list m
matrix b = e(b)
matrix V = e(V)
matrix SV = (0, 0, 0, 1, 0, 0)
matrix risk_score = SV * b'
matrix list risk_score
di exp(risk_score[1,1])
matrix var_prediction = SV * V * SV'
matrix se_prediction = sqrt(var_prediction[1,1])
matrix list se_prediction
di exp(se_prediction[1,1])
g f0=(1-s0)*100
g f1=f0*exp(risk_score[1,1])
drop if _t>10
line f1 _t, sort connect(step step) ylab(0(5)20) xlab(0(2)10)
	// Calculate the baseline survival function at 10 years
	sts generate S0 = s(10)

	// Calculate the log hazard ratio for the scenario
	matrix risk_score = SV * b'

	// Calculate the hazard ratio for the scenario
	scalar HR = exp(risk_score[1,1])

	// Calculate the 10-year survival probability for the scenario
	gen S_scenario = S0^HR

	// Calculate the 10-year mortality risk for the scenario
	gen risk_10year = 1 - S_scenario

	// Display the result
	summarize risk_10year

