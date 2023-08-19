use donor_live, clear
ds, varwidth(32)
foreach var of varlist _all {
    display "`var'"
}
keep ///
don_recov_dt ///
pers_ssa_death_dt ///
pers_id ///
donor_id ///
don_ty ///
don_age_in_months ///
don_age ///
don_gender ///
don_home_state ///
don_race ///
don_race_srtr ///
don_ethnicity_srtr ///
don_citizenship ///
don_year_entry_us ///
don_abo ///
don_hgt_cm ///
don_wgt_kg ///
don_recov_dt ///
don_marital_stat ///
don_relationship_ty ///
don_education ///
don_health_insur ///
don_primary_pay ///
don_medicare ///
don_medicaid ///
don_other_govt ///
don_priv_insur ///
don_hmo_ppo ///
don_self ///
don_donation ///
don_free ///
don_functn_stat ///
don_physc_capacity ///
don_work_income ///
don_work_no_stat ///
don_work_yes_stat ///
don_diab* ///
don_hist_hyp* ///
don_hyper* ///
don_ki_crea* ///
don_bp* ///
don_urine* ///
don_ki_biopsy ///
don_hist_cig* ///
don_living_do* ///
don_lu_compl* 

if 0 {
	lookfor dt 
    keep *_dt
	ds, varwidth(32)
}
save donor_live_keep, replace 
di c(k) " " c(N)

```bash
# do in terminal, not cluster!
scp amuzaal1@jhpce01.jhsph.edu:/users/amuzaal1/donors2303/donor_live_keep.dta ~dropbox/1f.ἡἔρις,κ/1.ontology
```
