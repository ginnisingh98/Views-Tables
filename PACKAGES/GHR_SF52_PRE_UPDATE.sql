--------------------------------------------------------
--  DDL for Package GHR_SF52_PRE_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_SF52_PRE_UPDATE" AUTHID CURRENT_USER AS
/* $Header: gh52prup.pkh 120.3.12010000.1 2008/07/28 10:21:14 appldev ship $ */
--

Procedure populate_record_groups
(p_pa_request_rec             in out nocopy ghr_pa_requests%rowtype,
 p_generic_ei_rec             in     ghr_pa_request_extra_info%rowtype,
 p_imm_asg_sf52                  out nocopy ghr_api.asg_sf52_type,
 p_imm_asg_non_sf52              out nocopy ghr_api.asg_non_sf52_type,
 p_imm_asg_nte_dates             out nocopy ghr_api.asg_nte_dates_type,
 p_imm_per_sf52                  out nocopy ghr_api.per_sf52_type,
 p_imm_per_group1                out nocopy ghr_api.per_group1_type,
 p_imm_per_group2                out nocopy ghr_api.per_group2_type,
 p_imm_per_scd_info              out nocopy ghr_api.per_scd_info_type,
 p_imm_per_retained_grade        out nocopy ghr_api.per_retained_grade_type,
 p_imm_per_probations            out nocopy ghr_api.per_probations_type,
 p_imm_per_sep_retire            out nocopy ghr_api.per_sep_retire_type,
 p_imm_per_security		   		 out nocopy ghr_api.per_security_type,
  --Bug#4486823 RRR Changes
 p_imm_per_service_oblig         out nocopy ghr_api.per_service_oblig_type,
 p_imm_per_conversions		   	 out nocopy ghr_api.per_conversions_type,
 -- BEN_EIT Changes
 p_imm_per_benefit_info	         out nocopy ghr_api.per_benefit_info_type,
 p_imm_per_uniformed_services    out nocopy ghr_api.per_uniformed_services_type,
 p_imm_pos_oblig                 out nocopy ghr_api.pos_oblig_type,
 p_imm_pos_grp2                  out nocopy ghr_api.pos_grp2_type,
 p_imm_pos_grp1                  out nocopy ghr_api.pos_grp1_type,
 p_imm_pos_valid_grade           out nocopy ghr_api.pos_valid_grade_type,
 p_imm_pos_car_prog              out nocopy ghr_api.pos_car_prog_type,
 p_imm_loc_info                  out nocopy ghr_api.loc_info_type,
 p_imm_wgi     	               out nocopy ghr_api.within_grade_increase_type,
 p_imm_gov_awards                out nocopy ghr_api.government_awards_type,
 p_imm_recruitment_bonus         out nocopy ghr_api.recruitment_bonus_type,
 p_imm_relocation_bonus		   out nocopy ghr_api.relocation_bonus_type,
 p_imm_student_loan_repay        out nocopy ghr_api.student_loan_repay_type,
 --Pradeep
 p_imm_per_race_ethnic_info      out nocopy ghr_api.per_race_ethnic_type, -- Bug 4724337 Race or National Origin changes
 p_imm_mddds_special_pay             out nocopy ghr_api.mddds_special_pay_type,
 p_imm_premium_pay_ind             out nocopy ghr_api.premium_pay_ind_type,

 p_imm_payroll_type              out nocopy ghr_api.government_payroll_type,
 p_imm_perf_appraisal            out nocopy ghr_api.performance_appraisal_type,
 p_imm_conduct_performance       out nocopy ghr_api.conduct_performance_type,
 p_imm_extra_info_rec	 	   out nocopy ghr_api.extra_info_rec_type,
 p_imm_sf52_from_data            out nocopy ghr_api.prior_sf52_data_type,
 p_imm_personal_info		   out nocopy ghr_api.personal_info_type,
 p_imm_generic_extra_info_rec    out nocopy ghr_api.generic_extra_info_rec_type,
 p_imm_agency_sf52		   out nocopy ghr_api.agency_sf52_type,
 p_imm_par_term_retained_grade   out nocopy ghr_api.par_term_retained_grade_type,
 p_imm_entitlement               out nocopy ghr_api.entitlement_type,
 --Bug#2759379 Added fegli record
 p_imm_fegli                      out nocopy ghr_api.fegli_type,
 p_imm_foreign_lang_prof_pay      out nocopy ghr_api.foreign_lang_prof_pay_type,
 -- Bug#3385386 Added FTA record
 p_imm_fta                        out nocopy ghr_api.fta_type,
 p_imm_edp_pay                    out nocopy ghr_api.edp_pay_type,
 p_imm_hazard_pay                 out nocopy ghr_api.hazard_pay_type,
 p_imm_health_benefits            out nocopy ghr_api.health_benefits_type,
 p_imm_danger_pay                 out nocopy ghr_api.danger_pay_type,
 p_imm_imminent_danger_pay        out nocopy ghr_api.imminent_danger_pay_type,
 p_imm_living_quarters_allow     out nocopy ghr_api.living_quarters_allow_type,
 p_imm_post_diff_amt             out nocopy ghr_api.post_diff_amt_type,
 p_imm_post_diff_percent         out nocopy ghr_api.post_diff_percent_type,
 p_imm_sep_maintenance_allow     out nocopy ghr_api.sep_maintenance_allow_type,
 p_imm_supplemental_post_allow   out nocopy ghr_api.supplemental_post_allow_type,
 p_imm_temp_lodge_allow          out nocopy ghr_api.temp_lodge_allow_type,
 p_imm_premium_pay               out nocopy ghr_api.premium_pay_type,
 p_imm_retirement_annuity        out nocopy ghr_api.retirement_annuity_type,
 p_imm_severance_pay             out nocopy ghr_api.severance_pay_type,
 p_imm_thrift_saving_plan        out nocopy ghr_api.thrift_saving_plan,
 p_imm_retention_allow_review    out nocopy ghr_api.retention_allow_review_type,
 p_imm_health_ben_pre_tax        out nocopy ghr_api.health_ben_pre_tax_type,
 p_agency_code		         out nocopy varchar2,
 --Bug #6312144 RPA EIT Benefits
 p_imm_ipa_benefits_cont         out nocopy ghr_api.per_ipa_ben_cont_info_type,
 p_imm_retirement_info           out nocopy ghr_api.per_retirement_info_type
 );

 procedure retrieve_all_extra_info
 (p_pa_request_rec                  in      ghr_pa_requests%rowtype,
  p_asg_sf52                        in out  nocopy ghr_api.asg_sf52_type,
  p_per_sf52                        in out  nocopy ghr_api.per_sf52_type,
  p_per_group1                      in out  nocopy ghr_api.per_group1_type,
  p_per_scd_info                    in out  nocopy ghr_api.per_scd_info_type,
  p_pos_grp1                        in out  nocopy ghr_api.pos_grp1_type,
  p_pos_grp2                        in out  nocopy ghr_api.pos_grp2_type,
  p_loc_info                        in out  nocopy ghr_api.loc_info_type,
  p_per_uniformed_services          in out  nocopy ghr_api.per_uniformed_services_type,
  p_per_conversions                 in out  nocopy ghr_api.per_conversions_type,
  -- BEN_EIT Changes
  p_per_benefit_info	            in out nocopy ghr_api.per_benefit_info_type,
  p_asg_non_sf52		            in out  nocopy ghr_api.asg_non_sf52_type,
  p_per_separate_Retire 	      	in out  nocopy ghr_api.per_sep_retire_type,
  p_asg_nte_dates		            in out  nocopy ghr_api.asg_nte_dates_type,
  p_per_probations		      		in out  nocopy ghr_api.per_probations_type,
  p_per_retained_grade		      	in out  nocopy ghr_api.per_retained_grade_type,
  --Bug#4486823 RRR Changes
  p_per_service_oblig               in out nocopy ghr_api.per_service_oblig_type,
  p_within_grade_increase	      	in out  nocopy ghr_api.within_grade_increase_type,
  p_valid_grade                     in out  nocopy ghr_api.pos_valid_grade_type,
  p_pos_oblig                       in out  nocopy ghr_api.pos_oblig_type,
  p_race_ethnic_info				in out nocopy  ghr_api.per_race_ethnic_type, -- Bug 4724337 Race or National Origin changes
  --Bug #6312144 RPA EIT Benefits
  p_ipa_benefits_cont               in out nocopy  ghr_api.per_ipa_ben_cont_info_type,
  p_retirement_info                 in out nocopy  ghr_api.per_retirement_info_type
  );

procedure SF52_br_extra_info
(
 P_PA_REQUEST_REC  		IN       GHR_PA_REQUESTS%ROWTYPE
,p_agency_code			out      nocopy varchar2
 );

procedure Process_Sf52_Extra_Info
(p_pa_request_rec             in     ghr_pa_requests%rowtype,
 p_asg_sf52                   in out nocopy ghr_api.asg_sf52_type,
 p_per_sf52                   in out nocopy ghr_api.per_sf52_type,
 p_per_group1                 in out nocopy ghr_api.per_group1_type,
 p_per_scd_info               in out nocopy ghr_api.per_scd_info_type,
 p_pos_grp2                   in out nocopy ghr_api.pos_grp2_type,
 p_pos_grp1                   in out nocopy ghr_api.pos_grp1_type,
 p_loc_info                   in out nocopy ghr_api.loc_info_type,
 p_recruitment_bonus 	      in out nocopy ghr_api.recruitment_bonus_type ,
 p_relocation_bonus	      in out nocopy ghr_api.relocation_bonus_type,
 p_student_loan_repay         in out nocopy ghr_api.student_loan_repay_type,
 p_extra_info_rec	            in out nocopy ghr_api.extra_info_rec_type,
 p_valid_grade  in out  nocopy ghr_api.pos_valid_grade_type);

PROCEDURE  Process_Non_Sf52_Extra_Info
(p_pa_request_rec		                IN OUT nocopy ghr_pa_requests%rowtype,
 p_generic_ei_rec                       IN     ghr_pa_request_extra_info%rowtype,
 p_per_group1				            IN OUT nocopy ghr_api.per_group1_type,
 p_per_scd_info                         IN OUT nocopy ghr_api.per_scd_info_type,
 p_pos_grp2                   	        IN OUT nocopy ghr_api.pos_grp2_type,
 p_pos_grp1                   	        IN OUT nocopy ghr_api.pos_grp1_type,
 p_per_uniformed_services               IN OUT nocopy ghr_api.per_uniformed_services_type,
 p_per_conversions                      IN OUT nocopy ghr_api.per_conversions_type,
 -- BEN_EIT Changes
 p_per_benefit_info	                    IN OUT nocopy ghr_api.per_benefit_info_type,
 p_asg_non_sf52			                IN OUT nocopy ghr_api.asg_non_sf52_type,
 p_per_separate_Retire 			        IN OUT nocopy ghr_api.per_sep_retire_type,
 p_asg_nte_dates			            IN OUT nocopy ghr_api.asg_nte_dates_type,
 p_per_probations		                IN OUT nocopy ghr_api.per_probations_type,
 p_per_retained_grade			        IN OUT nocopy ghr_api.per_retained_grade_type,
 --Bug#4486823 RRR Changes
 p_per_service_oblig                    IN OUT nocopy ghr_api.per_service_oblig_type,
 p_within_grade_increase		        IN OUT nocopy ghr_api.within_grade_increase_type,
 p_gov_awards                           IN OUT nocopy ghr_api.government_awards_type,
 p_conduct_performance                  in out nocopy ghr_api.conduct_performance_type,
 p_agency_sf52				    IN OUT nocopy ghr_api.agency_sf52_type,
 p_recruitment_bonus                    IN OUT nocopy ghr_apI.recruitment_bonus_type,
 p_relocation_bonus                     IN OUT nocopy ghr_apI.relocation_bonus_type,
 p_student_loan_repay                   IN OUT nocopy ghr_api.student_loan_repay_type,
 --Pradeep
 p_mddds_special_pay                   in out nocopy ghr_api.mddds_special_pay_type,
 p_premium_pay_ind                   in out nocopy ghr_api.premium_pay_ind_type,

 p_par_term_retained_grade              in out nocopy ghr_api.par_term_retained_grade_type,
 p_entitlement                          in out nocopy ghr_api.entitlement_type,
 --Bug#2759379 Added fegli record
 p_fegli                                in out nocopy ghr_api.fegli_type,
 p_foreign_lang_prof_pay                in out nocopy ghr_api.foreign_lang_prof_pay_type,
  -- Bug#3385386 Added FTA record
 p_imm_fta                              in out nocopy ghr_api.fta_type,
 p_edp_pay                              in out nocopy ghr_api.edp_pay_type,
 p_hazard_pay                           in out nocopy ghr_api.hazard_pay_type,
 p_health_benefits                      in out nocopy ghr_api.health_benefits_type,
 p_danger_pay                           in out nocopy ghr_api.danger_pay_type,
 p_imminent_danger_pay                  in out nocopy ghr_api.imminent_danger_pay_type,
 p_living_quarters_allow                in out nocopy ghr_api.living_quarters_allow_type,
 p_post_diff_amt                        in out nocopy ghr_api.post_diff_amt_type,
 p_post_diff_percent                    in out nocopy ghr_api.post_diff_percent_type,
 p_sep_maintenance_allow                in out nocopy ghr_api.sep_maintenance_allow_type,
 p_supplemental_post_allow              in out nocopy ghr_api.supplemental_post_allow_type,
 p_temp_lodge_allow                     in out nocopy ghr_api.temp_lodge_allow_type,
 p_premium_pay                          in out nocopy ghr_api.premium_pay_type,
 p_retirement_annuity                   in out nocopy ghr_api.retirement_annuity_type,
 p_severance_pay                        in out nocopy ghr_api.severance_pay_type,
 p_thrift_saving_plan                   in out nocopy ghr_api.thrift_saving_plan,
 p_retention_allow_review               in out nocopy ghr_api.retention_allow_review_type,
 p_health_ben_pre_tax                   in out nocopy ghr_api.health_ben_pre_tax_type,
 p_race_ethnic_info			in out nocopy ghr_api.per_race_ethnic_type, --Bug 4724337 Race or National Origin changes
 --Bug #6312144 RPA EIT Benefits
 p_ipa_benefits_cont                    in out nocopy  ghr_api.per_ipa_ben_cont_info_type,
 p_retirement_info                      in out nocopy  ghr_api.per_retirement_info_type
 );

PROCEDURE get_auth_codes
(p_pa_req_rec		IN		ghr_pa_requests%rowtype,
 p_pei_auth_code1	IN		per_people_extra_info.pei_information1%type DEFAULT hr_api.g_varchar2,
 p_pei_auth_code2	IN		per_people_extra_info.pei_information1%type DEFAULT hr_api.g_varchar2,
 p_auth_code1		IN OUT	nocopy per_people_extra_info.pei_information1%type,
 p_auth_code2		IN OUT	nocopy per_people_extra_info.pei_information1%type);



end GHR_SF52_PRE_UPDATE;

/
