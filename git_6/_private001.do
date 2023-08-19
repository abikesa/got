
//fsgsHIV/fsgsHIVoutput/fsgsHIVanalysis/
//https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5489376/
use cleanHIVsmk+, clear
mkspline age1 50 age2=na_age
mkspline age1_sat 40 age2_sat 50 age3_sat 65 age4_sat=na_age 
mkspline egfr45 45 egfr60 60 egfr90=na_egfr_baseline
mkspline egfr1_min 60 egfr2_min 90 egfr3_min=na_egfr_baseline
mkspline egfr1_mod 90 egfr2_mod=na_egfr_baseline
mkspline egfr1 60 egfr2 90 egfr3 120 egfr4=na_egfr_baseline
mkspline egfr1_sat 60 egfr2_sat 90 egfr3_sat 120 egfr4_sat=na_egfr_baseline
mkspline bmi_1 25 bmi_2 30 bmi_3 35 bmi_4=na_bmi
mkspline bmi25_1 25 bmi25_2=na_bmi
mkspline vl1 4 vl2 5 vl3=log10vl
mkspline vl1_sat 3 vl2_sat 4 vl3_sat 5 vl4_sat=log10vl
mkspline vl1_min 4 vl2_min=log10vl
mkspline vl1_detect 3 vl2_detect=log10vl
mkspline cd4_1_sat 200 cd4_2_sat 350 cd4_3_sat 500 cd4_4_sat=cd4baseline
mkspline cd4_1_min 350 cd4_2_min=cd4baseline
mkspline cd4_1 500 cd4_2=cd4baseline
mkspline cd4_1_mod 300 cd4_2_mod=cd4baseline
mkspline cd4_1_splines 200 cd4_2_splines 500 cd4_3_splines=cd4baseline
gen     vl400onRx=1 if inrange(art_years,0,25)&inrange(vlbaseline,0,400)
replace vl400onRx=2 if inrange(art_years,0,25)&inrange(vlbaseline,400.1,300000)
replace vl400onRx=3 if vl400onRx==.
replace art_years=0 if vl400onRx==3
mkspline art_y1 9 art_y2=art_years  
mkspline art_y1_max .1 art_y2_max 9 art_y3_max=art_years
mkspline tdf_y1 6 tdf_y2=tdf_years
stset na_t,fail(na_fail==1)
stcox age1 age2 i.na_race female na_dm na_ht egfr1_mod egfr2_mod smoking hcv vl1_min vl2_min art_y1 art_y2 i.art_timing tdf_years cd4baseline aids,basesurv(s0)
matrix define m1=r(table)
matrix define b=e(b) //1x22
matrix define V=e(V) //22x22
matrix SV=(40, 0, 1, 0, 0, 0, 0, 0, 90, 5, 0, 0, 0, 0, 0, 0, 1, 1, 1, 7, 600, 0) //40yo white eGFR=95 no HTN HIV+ 
matrix list b
matrix define risk_score=SV*b'
gen f0 = (1 - s0) * 10000
gen f1 = f0 * exp(risk_score[1,1])
line f1 _t, sort connect(step step) ylab(0(5)20) xlab(0(2)10)
save h1, replace 



