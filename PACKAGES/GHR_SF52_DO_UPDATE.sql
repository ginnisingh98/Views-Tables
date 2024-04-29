--------------------------------------------------------
--  DDL for Package GHR_SF52_DO_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_SF52_DO_UPDATE" AUTHID CURRENT_USER AS
/* $Header: gh52doup.pkh 120.4.12010000.1 2008/07/28 10:21:05 appldev ship $ */
--
g_retained_grade_info             ghr_pay_calc.retained_grade_rec_type;
--
--
procedure  Process_Family
(P_PA_REQUEST_REC                 in out nocopy    ghr_pa_requests%rowtype,
 P_AGENCY_CODE                    in        varchar2
 );

Procedure  call_extra_info_api
(P_PA_REQUEST_REC                 in     ghr_pa_requests%rowtype,
 P_Asg_Sf52                       in out nocopy ghr_api.asg_Sf52_TYPE,
 P_Asg_non_Sf52                   in out nocopy ghr_api.asg_non_Sf52_TYPE,
 P_Asg_nte_dates                  in out nocopy ghr_api.asg_nte_dates_TYPE,
 P_Per_Sf52                       in out nocopy ghr_api.per_Sf52_TYPE,
 P_Per_Group1                	  in out nocopy ghr_api.per_Group1_TYPE,
 P_Per_Group2                	  in out nocopy ghr_api.per_Group2_TYPE,
 P_Per_scd_info                   in out nocopy ghr_api.per_scd_info_TYPE,
 P_Per_retained_grade             in out nocopy ghr_api.per_retained_grade_TYPE,
 P_Per_probations                 in out nocopy ghr_api.per_probations_TYPE,
 P_Per_sep_retire                 in out nocopy ghr_api.per_sep_retire_TYPE,
 P_Per_security		 	    	  in out nocopy ghr_api.per_security_TYPE,
 --Bug#4486823 RRR Changes
 p_per_service_oblig              IN OUT NOCOPY GHR_API.Per_service_oblig_TYPE,
 P_Per_conversions		    	  in out nocopy ghr_api.per_conversions_TYPE,
 -- BEN_EIT Changes
 p_per_benefit_info		  		  in out nocopy ghr_api.per_benefit_info_type,
 P_Per_uniformed_services   	  in out nocopy ghr_api.per_uniformed_services_TYPE,
 P_Pos_oblig                      in out nocopy ghr_api.pos_oblig_TYPE,
 P_Pos_Grp2                       in out nocopy ghr_api.pos_Grp2_TYPE,
 P_Pos_Grp1                       in out nocopy ghr_api.pos_Grp1_TYPE,
 P_Pos_valid_grade                in out nocopy ghr_api.pos_valid_grade_TYPE,
 P_Pos_car_prog                   in out nocopy ghr_api.pos_car_prog_TYPE,
 p_perf_appraisal                 in out nocopy ghr_api.performance_appraisal_type,
 p_conduct_performance            in out nocopy ghr_api.conduct_performance_type,
 P_Loc_Info                       in out nocopy ghr_api.Loc_Info_TYPE,
 P_generic_Extra_Info_Rec         in out nocopy ghr_api.generic_Extra_Info_Rec_Type,
 P_par_term_retained_grade        IN out nocopy GHR_api.par_term_retained_grade_type,
 p_per_race_ethnic_info      	  IN out nocopy ghr_api.per_race_ethnic_type,
 --6312144 added new parameters for RPA EIT Benefits.
 p_ipa_benefits_cont              IN out nocopy ghr_api.per_ipa_ben_cont_info_type,
 p_retirement_info                IN out nocopy ghr_api.per_retirement_info_type
);

Procedure Process_salary_Info
(p_pa_request_rec	        in     ghr_pa_requests%rowtype
 ,p_wgi     	        in out nocopy ghr_api.within_grade_increase_type
,p_retention_allow_review         in out nocopy ghr_api.retention_allow_review_type
 ,p_capped_other_pay    in number default null
);

Procedure Process_non_salary_Info
(p_pa_request_rec	                in     ghr_pa_requests%rowtype
,p_recruitment_bonus	          in out nocopy ghr_api.recruitment_bonus_type
,p_relocation_bonus               in out nocopy ghr_api.relocation_bonus_type
,p_student_loan_repay             in out nocopy ghr_api.student_loan_repay_type
--Pradeep
,p_mddds_special_pay              in out nocopy ghr_api.mddds_special_pay_type
,p_premium_pay_ind              in out nocopy ghr_api.premium_pay_ind_type

,p_gov_award                      in out nocopy ghr_api.government_awards_type
,p_entitlement                    in out nocopy ghr_api.entitlement_type
-- Bug#2759379 Added extra parameter p_fegli
,p_fegli                          in out nocopy ghr_api.fegli_type
,p_foreign_lang_prof_pay          in out nocopy ghr_api.foreign_lang_prof_pay_type
-- Bug#3385386 Added extra parameter p_fta
,p_fta                            in out nocopy ghr_api.fta_type
,p_edp_pay                        in out nocopy ghr_api.edp_pay_type
,p_hazard_pay                     in out nocopy ghr_api.hazard_pay_type
,p_health_benefits                in out nocopy ghr_api.health_benefits_type
,p_danger_pay                     in out nocopy ghr_api.danger_pay_type
,p_imminent_danger_pay            in out nocopy ghr_api.imminent_danger_pay_type
,p_living_quarters_allow          in out nocopy ghr_api.living_quarters_allow_type
,p_post_diff_amt                  in out nocopy ghr_api.post_diff_amt_type
,p_post_diff_percent              in out nocopy ghr_api.post_diff_percent_type
,p_sep_maintenance_allow          in out nocopy ghr_api.sep_maintenance_allow_type
,p_supplemental_post_allow        in out nocopy ghr_api.supplemental_post_allow_type
,p_temp_lodge_allow               in out nocopy ghr_api.temp_lodge_allow_type
,p_premium_pay                    in out nocopy ghr_api.premium_pay_type
,p_retirement_annuity             in out nocopy ghr_api.retirement_annuity_type
,p_severance_pay                  in out nocopy ghr_api.severance_pay_type
,p_thrift_saving_plan             in out nocopy ghr_api.thrift_saving_plan
,p_health_ben_pre_tax                in out nocopy ghr_api.health_ben_pre_tax_type
);

Procedure get_wgi_dates
(p_pa_request_rec    	          in      ghr_pa_requests%rowtype,
 p_wgi_due_date                   in out nocopy  date,
 p_wgi_pay_date                      out nocopy  date,
 p_retained_grade_rec                out nocopy  ghr_pay_calc.retained_grade_rec_type,
 p_dlei			 in date
);

Procedure generic_update_sit
(p_pa_request_rec                 in      ghr_pa_requests%rowtype,
 p_special_information_type       in      fnd_id_flex_structures_tl.id_flex_structure_name%type,
 p_segment_rec                    in      ghr_api.special_information_type
);

end GHR_SF52_DO_UPDATE;

/
