--------------------------------------------------------
--  DDL for Package Body GHR_AGENCY_CHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_AGENCY_CHECK" AS
/* $Header: ghragncy.pkb 120.2.12010000.2 2008/08/05 15:11:06 ubhat ship $ */


procedure AGENCY_CHECK
(
 p_pa_request_rec             in 	ghr_pa_requests%rowtype,
 p_asg_sf52                   in 	ghr_api.asg_sf52_type,
 p_asg_non_sf52               in	ghr_api.asg_non_sf52_type,
 p_asg_nte_dates              in	ghr_api.asg_nte_dates_type,
 p_per_sf52                   in 	ghr_api.per_sf52_type,
 p_per_group1                 in 	ghr_api.per_group1_type,
 p_per_group2                 in 	ghr_api.per_group2_type,
 p_per_scd_info               in 	ghr_api.per_scd_info_type,
 p_per_retained_grade         in 	ghr_api.per_retained_grade_type,
 p_per_probations             in	ghr_api.per_probations_type,
 p_per_sep_retire             in	ghr_api.per_sep_retire_type,
 p_per_security		      in 	ghr_api.per_security_type,
 p_per_conversions            in 	ghr_api.per_conversions_type,
 p_per_uniformed_services     in	ghr_api.per_uniformed_services_type,
 p_pos_oblig                  in 	ghr_api.pos_oblig_type,
 p_pos_grp2                   in 	ghr_api.pos_grp2_type,
 p_pos_grp1                   in 	ghr_api.pos_grp1_type,
 p_pos_valid_grade            in 	ghr_api.pos_valid_grade_type,
 p_pos_car_prog               in	ghr_api.pos_car_prog_type,
 p_loc_info                   in 	ghr_api.loc_info_type,
 p_wgi  	              in	ghr_api.within_grade_increase_type ,
 p_recruitment_bonus	      in 	ghr_api.recruitment_bonus_type ,
 p_relocation_bonus 	      in	ghr_api.relocation_bonus_type,
 p_sf52_from_data             in 	ghr_api.prior_sf52_data_type,
 p_personal_info   	      in 	ghr_api.personal_info_type,
 p_gov_awards_type            in    ghr_api.government_awards_type,
 p_perf_appraisal_type        in    ghr_api.performance_appraisal_type,
 p_payroll_type               in    ghr_api.government_payroll_type,
 p_conduct_perf_type          in    ghr_api.conduct_performance_type,
 p_agency_sf52                in    ghr_api.agency_sf52_type,
 p_agency_code		      in    varchar2,
 p_health_plan                in    varchar2,
 p_entitlement                in    ghr_api.entitlement_type,
 p_foreign_lang_prof_pay      in    ghr_api.foreign_lang_prof_pay_type,
 p_edp_pay                    in    ghr_api.edp_pay_type,
 p_hazard_pay                 in    ghr_api.hazard_pay_type,
 p_health_benefits            in    ghr_api.health_benefits_type,
 p_danger_pay                 in    ghr_api.danger_pay_type,
 p_imminent_danger_pay        in    ghr_api.imminent_danger_pay_type,
 p_living_quarters_allow      in    ghr_api.living_quarters_allow_type,
 p_post_diff_amt              in    ghr_api.post_diff_amt_type,
 p_post_diff_percent          in    ghr_api.post_diff_percent_type,
 p_sep_maintenance_allow      in    ghr_api.sep_maintenance_allow_type,
 p_supplemental_post_allow    in    ghr_api.supplemental_post_allow_type,
 p_temp_lodge_allow           in    ghr_api.temp_lodge_allow_type,
 p_premium_pay                in    ghr_api.premium_pay_type,
 p_retirement_annuity         in    ghr_api.retirement_annuity_type,
 p_severance_pay              in    ghr_api.severance_pay_type,
 p_thrift_saving_plan         in    ghr_api.thrift_saving_plan,
 p_retention_allow_review     in    ghr_api.retention_allow_review_type,
 p_health_ben_pre_tax         in    ghr_api.health_ben_pre_tax_type,
 p_per_benefit_info           in    ghr_api.per_benefit_info_type, -- TAR 4646592.993
 p_imm_retirement_info        in    ghr_api.per_retirement_info_type --Bug# 7131104
 )
IS
l_test number;

Begin
  Null;
end AGENCY_CHECK;

procedure open_events_check
(p_pa_request_id               in       ghr_pa_requests.pa_request_id%type,
 p_message_set                 in out  NOCOPY boolean
)
is

Begin
  Null;
End open_events_check;

function print_sf50
(p_pa_request_id               in       ghr_pa_requests.pa_request_id%type,
 p_pa_notification_id          in       ghr_pa_requests.pa_notification_id%type
) return boolean
is
Begin
  return true;
End print_sf50;

procedure mass_salary_lacs_remarks
(p_pa_request_id    in       ghr_pa_requests.pa_request_id%TYPE,
 p_prd              in       ghr_pa_requests.pay_rate_determinant%TYPE,
 p_eo_number        in       ghr_mass_salaries.executive_order_number%TYPE,
 p_eo_date          in       ghr_mass_salaries.executive_order_date%TYPE,
 p_opm_number       in       ghr_mass_salaries.opm_issuance_number%TYPE,
 p_opm_date         in       ghr_mass_salaries.opm_issuance_date%TYPE,
 p_retcode          in out NOCOPY  NUMBER,
 p_errbuf           in out NOCOPY  VARCHAR2
) is
Begin
  NULL;
End;

procedure CANCEL_HIRE_CAO
(
 p_pa_request_rec             in 	ghr_pa_requests%rowtype,
 p_asg_sf52                   in 	ghr_api.asg_sf52_type,
 p_asg_non_sf52               in	ghr_api.asg_non_sf52_type,
 p_asg_nte_dates              in	ghr_api.asg_nte_dates_type,
 p_per_sf52                   in 	ghr_api.per_sf52_type,
 p_per_group1                 in 	ghr_api.per_group1_type,
 p_per_group2                 in 	ghr_api.per_group2_type,
 p_per_scd_info               in 	ghr_api.per_scd_info_type,
 p_per_retained_grade         in 	ghr_api.per_retained_grade_type,
 p_per_probations             in	ghr_api.per_probations_type,
 p_per_sep_retire             in	ghr_api.per_sep_retire_type,
 p_per_security		      in 	ghr_api.per_security_type,
 p_per_conversions            in 	ghr_api.per_conversions_type,
 p_per_uniformed_services     in	ghr_api.per_uniformed_services_type,
 p_pos_oblig                  in 	ghr_api.pos_oblig_type,
 p_pos_grp2                   in 	ghr_api.pos_grp2_type,
 p_pos_grp1                   in 	ghr_api.pos_grp1_type,
 p_pos_valid_grade            in 	ghr_api.pos_valid_grade_type,
 p_pos_car_prog               in	ghr_api.pos_car_prog_type,
 p_loc_info                   in 	ghr_api.loc_info_type,
 p_wgi     	                  in	ghr_api.within_grade_increase_type ,
 p_recruitment_bonus	      in 	ghr_api.recruitment_bonus_type ,
 p_relocation_bonus 	      in	ghr_api.relocation_bonus_type,
 p_sf52_from_data             in 	ghr_api.prior_sf52_data_type,
 p_personal_info   	      in 	ghr_api.personal_info_type,
 p_gov_awards_type            in    ghr_api.government_awards_type,
 p_perf_appraisal_type        in    ghr_api.performance_appraisal_type,
 p_payroll_type               in    ghr_api.government_payroll_type,
 p_conduct_perf_type          in    ghr_api.conduct_performance_type,
 p_agency_sf52                in    ghr_api.agency_sf52_type,
 p_agency_code		      in    varchar2,
 p_health_plan                in    varchar2,
 p_entitlement                in    ghr_api.entitlement_type,
 p_foreign_lang_prof_pay      in    ghr_api.foreign_lang_prof_pay_type,
 p_edp_pay                    in    ghr_api.edp_pay_type,
 p_hazard_pay                 in    ghr_api.hazard_pay_type,
 p_health_benefits            in    ghr_api.health_benefits_type,
 p_danger_pay                 in    ghr_api.danger_pay_type,
 p_imminent_danger_pay        in    ghr_api.imminent_danger_pay_type,
 p_living_quarters_allow      in    ghr_api.living_quarters_allow_type,
 p_post_diff_amt              in    ghr_api.post_diff_amt_type,
 p_post_diff_percent          in    ghr_api.post_diff_percent_type,
 p_sep_maintenance_allow      in    ghr_api.sep_maintenance_allow_type,
 p_supplemental_post_allow    in    ghr_api.supplemental_post_allow_type,
 p_temp_lodge_allow           in    ghr_api.temp_lodge_allow_type,
 p_premium_pay                in    ghr_api.premium_pay_type,
 p_retirement_annuity         in    ghr_api.retirement_annuity_type,
 p_severance_pay              in    ghr_api.severance_pay_type,
 p_thrift_saving_plan         in    ghr_api.thrift_saving_plan,
 p_retention_allow_review     in    ghr_api.retention_allow_review_type,
 p_health_ben_pre_tax         in    ghr_api.health_ben_pre_tax_type,
 p_cao_effective_date         out NOCOPY date
 )
IS

Begin
  NULL;
End CANCEL_HIRE_CAO;


end GHR_AGENCY_CHECK;

/
