--------------------------------------------------------
--  DDL for Package Body GHR_SF52_PRE_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_SF52_PRE_UPDATE" AS
/* $Header: gh52prup.pkb 120.34.12010000.4 2009/08/07 09:38:01 utokachi ship $ */
g_effective_date      date;
--

PROCEDURE get_auth_codes
(p_pa_req_rec		IN		ghr_pa_requests%rowtype,
 p_pei_auth_code1	IN		per_people_extra_info.pei_information1%type DEFAULT hr_api.g_varchar2,
 p_pei_auth_code2	IN		per_people_extra_info.pei_information1%type DEFAULT hr_api.g_varchar2,
 p_auth_code1		IN OUT	nocopy per_people_extra_info.pei_information1%type,
 p_auth_code2		IN OUT nocopy	per_people_extra_info.pei_information1%type)
IS
l_proc                  varchar2(70) := 'get_auth_codes';
l_pei_extra_info		per_people_extra_info%rowtype;

BEGIN

	hr_utility.set_location('Entering: ' || l_proc, 10);
	if (p_pa_req_rec.noa_family_code not in ('CONV_APP','APP','APPT_TRANS') ) then
		if (p_pei_auth_code1 = hr_api.g_varchar2) then
    			ghr_history_fetch.fetch_peopleei(p_person_id      	=> p_pa_req_rec.person_id
     		                                 	   ,p_information_type 	=> 'GHR_US_PER_GROUP1'
     		                                 	   ,p_date_effective    => p_pa_req_rec.effective_date
           		                           	   ,p_per_ei_data       => l_pei_extra_info);
			p_auth_code1	:= 	l_pei_extra_info.pei_information8;
			p_auth_code2	:= 	l_pei_extra_info.pei_information9;
		else
			p_auth_code1	:= 	p_pei_auth_code1;
			p_auth_code2	:= 	p_pei_auth_code2;
		end if;
	else
		p_auth_code1	:= 	p_pa_req_rec.first_action_la_code1;
		p_auth_code2	:= 	p_pa_req_rec.first_action_la_code2;
	end if;
	hr_utility.set_location('Leaving: ' || l_proc, 20);
END;


-- *************************
--
--	This procedure retrieve data from HR extra information tables and all other data required for CPDF Validations
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
 -- Bug#4486823 RRR Changes Added p_imm_per_service_oblig
 p_imm_per_service_oblig         out nocopy ghr_api.per_service_oblig_type,
 p_imm_per_conversions		     out nocopy ghr_api.per_conversions_type,
 -- 4352589 BEN_EIT Changes
 p_imm_per_benefit_info	         out nocopy ghr_api.per_benefit_info_type,
 p_imm_per_uniformed_services    out nocopy ghr_api.per_uniformed_services_type,
 p_imm_pos_oblig                 out nocopy ghr_api.pos_oblig_type,
 p_imm_pos_grp2                  out nocopy ghr_api.pos_grp2_type,
 p_imm_pos_grp1                  out nocopy ghr_api.pos_grp1_type,
 p_imm_pos_valid_grade           out nocopy ghr_api.pos_valid_grade_type,
 p_imm_pos_car_prog              out nocopy ghr_api.pos_car_prog_type,
 p_imm_loc_info                  out nocopy ghr_api.loc_info_type,
 p_imm_wgi     	                 out nocopy ghr_api.within_grade_increase_type,
 p_imm_gov_awards                out nocopy ghr_api.government_awards_type,
 p_imm_recruitment_bonus         out nocopy ghr_api.recruitment_bonus_type,
 p_imm_relocation_bonus		     out nocopy ghr_api.relocation_bonus_type,
 p_imm_student_loan_repay        out nocopy ghr_api.student_loan_repay_type,
 -- Bug 4724337 Race or National Origin changes
 p_imm_per_race_ethnic_info      out nocopy ghr_api.per_race_ethnic_type,
 -- End race and National Origin changes
 --Pradeep
 p_imm_mddds_special_pay         out nocopy ghr_api.mddds_special_pay_type,
 p_imm_premium_pay_ind           out nocopy ghr_api.premium_pay_ind_type,

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
 -- Bug#2759379 Added Fegli record
 p_imm_fegli                     out nocopy ghr_api.fegli_type,
 p_imm_foreign_lang_prof_pay     out nocopy ghr_api.foreign_lang_prof_pay_type,
  -- Bug#3385386 Added FTA record
 p_imm_fta                        out nocopy ghr_api.fta_type,
 p_imm_edp_pay                   out nocopy ghr_api.edp_pay_type,
 p_imm_hazard_pay                out nocopy ghr_api.hazard_pay_type,
 p_imm_health_benefits           out nocopy ghr_api.health_benefits_type,
 p_imm_danger_pay                out nocopy ghr_api.danger_pay_type,
 p_imm_imminent_danger_pay       out nocopy ghr_api.imminent_danger_pay_type,
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
 p_imm_health_ben_pre_tax           out nocopy ghr_api.health_ben_pre_tax_type,
 p_agency_code			 out nocopy varchar2,
 -- Bug#6312144 Added new RPA Benefit EIT
 p_imm_ipa_benefits_cont         out nocopy ghr_api.per_ipa_ben_cont_info_type,
 p_imm_retirement_info           out nocopy ghr_api.per_retirement_info_type
 )
is

-- Cursor to select the person's sex which is required for CPDF Edits

 cursor      c_person_sex is
   select    per.sex
   from      per_all_people_f per
   where     per.person_id = P_pa_request_rec.person_id
   and       g_effective_date
   between   per.effective_start_date
   and       per.effective_end_date;

-- Cursor to select the Payrollname ,as entered by the user from the SF52 Extra Information.

 Cursor c_payroll_name is
   select rei_information3 payroll_name
   from   ghr_pa_request_extra_info
   where  pa_request_id       =   p_pa_request_rec.pa_request_id
   and    information_type    =   'GHR_US_PAR_PAYROLL_TYPE';

-- Cursor to select the Rating Details of the person, required for CPDFs and for update to HR

 Cursor c_performance_appraisal is
   select rei_information3 rat_rec,
          rei_information4 rec_pattern,
          rei_information5 rec_level,
          rei_information6 app_ends,
          rei_information7 app_type,
          rei_information8 date_init_appr_due,
          rei_information9  date_effective,
          rei_information10 unit,
          rei_information11 org_str_id,
          rei_information12 off_symbol,
          rei_information13 pay_plan,
          rei_information14 grade,
          rei_information15 date_due,
          rei_information16 appr_sys_ident,
          rei_information17 optional_info,
	  rei_information18 performance_rating_points,
	  rei_information19 app_starts
   from   ghr_pa_request_extra_info
   where  pa_request_id       =   p_pa_request_rec.pa_request_id
   and    information_type    =   'GHR_US_PAR_PERF_APPRAISAL';

-- cursor to select the Conduct Performace of the person. (is it required for CPDFs??, sureis required for the reqd_Check)
-- is not reqd. as it is not a generic extra info, rather the extra info associated with a
-- specific NOA and hence should be available already in the passed parameter.

 cursor   c_person_type is
   select  ppt.system_person_type
   from    per_person_types  ppt,
           per_all_people_f      ppf
   where   ppf.person_id       =  p_pa_request_rec.person_id
   and     ppt.person_type_id  =  ppf.person_type_id
   and     p_pa_request_rec.effective_date
   between ppf.effective_start_date
   and     ppf.effective_end_date;

 cursor cur_asg_prior_date is
   Select asg.effective_start_date
   from   per_all_assignments_f asg
   Where  asg.assignment_id = p_pa_request_rec.employee_assignment_id
   order by 1 desc;

 l_imm_asg_sf52                    		ghr_api.asg_sf52_type;
 l_imm_asg_non_sf52                		ghr_api.asg_non_sf52_type;
 l_imm_asg_nte_dates               		ghr_api.asg_nte_dates_type;
 l_imm_per_sf52                   		ghr_api.per_sf52_type;
 l_imm_per_group1                		ghr_api.per_group1_type;
 l_imm_per_group2                		ghr_api.per_group2_type;
 l_imm_per_scd_info                		ghr_api.per_scd_info_type;
 l_imm_per_retained_grade               ghr_api.per_retained_grade_type;
 l_imm_per_probations             		ghr_api.per_probations_type;
 l_imm_per_sep_retire              		ghr_api.per_sep_retire_type;
 l_imm_per_security		         	    ghr_api.per_security_type;
 -- Bug#4486823 RRR changes
 l_imm_per_service_oblig                ghr_api.per_service_oblig_type;
 l_imm_per_conversions		 	        ghr_api.per_conversions_type;
 -- 4352589 BEN_EIT Changes
 l_imm_per_benefit_info	                ghr_api.per_benefit_info_type;
 l_imm_per_uniformed_services   		ghr_api.per_uniformed_services_type;
 l_imm_pos_oblig                   		ghr_api.pos_oblig_type;
 l_imm_pos_grp2                   		ghr_api.pos_grp2_type;
 l_imm_pos_grp1                    		ghr_api.pos_grp1_type;
 l_imm_pos_valid_grade                  ghr_api.pos_valid_grade_type;
 l_imm_pos_car_prog                     ghr_api.pos_car_prog_type;
 l_imm_loc_info                         ghr_api.loc_info_type;
 l_imm_wgi     	                        ghr_api.within_grade_increase_type ;
 l_imm_gov_awards                       ghr_api.government_awards_type;
 l_imm_recruitment_bonus		        ghr_api.recruitment_bonus_type ;
 l_imm_relocation_bonus		            ghr_api.relocation_bonus_type;
  l_imm_student_loan_repay              ghr_api.student_loan_repay_type;

 l_imm_extra_info_rec	 	            ghr_api.extra_info_rec_type;
 l_asg_extra_info_rec                   per_assignment_extra_info%rowtype;
 l_pos_extra_info_rec                   per_position_extra_info%rowtype;
 l_imm_sf52_from_data                   ghr_api.prior_sf52_data_type;
 l_imm_personal_info		            ghr_api.personal_info_type;
 l_imm_generic_extra_info_rec	        ghr_api.generic_extra_info_rec_type;
 l_imm_agency_sf52		                ghr_api.agency_sf52_type;
 l_imm_payroll_type                     ghr_api.government_payroll_type;
 l_imm_perf_appraisal                   ghr_api.performance_appraisal_type;
 l_imm_conduct_performance              ghr_api.conduct_performance_type;
 l_imm_entitlement                      ghr_api.entitlement_type;
 --Bug#2759379 Added Fegli record
 l_imm_fegli                            ghr_api.fegli_type;
 l_imm_foreign_lang_prof_pay            ghr_api.foreign_lang_prof_pay_type;
 -- Bug#3385386 declared FTA record type variable
 l_imm_fta				                ghr_api.fta_type;
 l_imm_edp_pay                          ghr_api.edp_pay_type;
 l_imm_hazard_pay                       ghr_api.hazard_pay_type;
 l_imm_health_benefits                  ghr_api.health_benefits_type;
 l_imm_danger_pay                       ghr_api.danger_pay_type;
 l_imm_imminent_danger_pay              ghr_api.imminent_danger_pay_type;
 l_imm_living_quarters_allow            ghr_api.living_quarters_allow_type;
 l_imm_post_diff_amt                    ghr_api.post_diff_amt_type;
 l_imm_post_diff_percent                ghr_api.post_diff_percent_type;
 l_imm_sep_maintenance_allow            ghr_api.sep_maintenance_allow_type;
 l_imm_supplemental_post_allow          ghr_api.supplemental_post_allow_type;
 l_imm_temp_lodge_allow                 ghr_api.temp_lodge_allow_type;
 l_imm_premium_pay                      ghr_api.premium_pay_type;
 l_imm_retirement_annuity               ghr_api.retirement_annuity_type;
 l_imm_severance_pay                    ghr_api.severance_pay_type;
 l_imm_thrift_saving_plan               ghr_api.thrift_saving_plan;
 l_imm_retention_allow_review           ghr_api.retention_allow_review_type;
 l_imm_health_ben_pre_tax               ghr_api.health_ben_pre_tax_type;
 l_agency_code			                varchar2(50);
 l_special_info_type                    ghr_api.special_information_type;
 l_imm_par_term_retained_grade            ghr_api.par_term_retained_grade_type;
 l_session                                ghr_history_api.g_session_var_type;
 l_asg_ei_data                            per_assignment_extra_info%rowtype;
 l_assignment_data                        per_all_assignments_f%rowtype;
 l_result_code                            varchar2(50);
 l_person_type                            per_person_types.system_person_type%type;
 l_effective_date                         date;
 -- Bug#4054110
 l_temp_rec_level                        varchar2(30);
 --Pradeep
 l_imm_mddds_special_pay			  		ghr_api.mddds_special_pay_type;
 l_imm_premium_pay_ind  			  		ghr_api.premium_pay_ind_type;
 l_imm_per_race_ethnic_info 				ghr_api.per_race_ethnic_type; -- Bug 4724337 Race or National Origin changes
 l_imm_ipa_benefits_cont                  ghr_api.per_ipa_ben_cont_info_type;
 l_imm_retirement_info                    ghr_api.per_retirement_info_type;



Begin

  hr_utility.set_location('PERSON ID  : ' ||to_char(p_pa_request_rec.person_id) ,1);
  hr_utility.set_location('EMP    ID  : ' ||to_char(p_pa_request_rec.employee_assignment_id) ,2);
  hr_utility.set_location('POS    ID  : ' ||to_char(p_pa_request_rec.to_position_id) ,3);


  --  Retrieve all the extra information (required for CPDFs and for update to HR)
  --  from the Core Tables and store them in the respective Record Groups


  -- NOTE :
  -- Should include the foll. 2 statements after changing these 2 parameters as in rather than out
  -- l_imm_extra_info_rec                  :=  p_imm_extra_info_rec;
  -- l_imm_generic_extra_info_rec          :=  p_imm_generic_extra_info_rec;

 Retrieve_all_extra_info
 (
  p_pa_request_rec                     => p_pa_request_rec,
  p_asg_sf52                           => l_imm_asg_sf52,
  p_per_sf52                           => l_imm_per_sf52,
  p_per_group1                         => l_imm_per_group1,
  p_per_scd_info                       => l_imm_per_scd_info,
  p_pos_grp1                           => l_imm_pos_grp1,
  p_pos_grp2                           => l_imm_pos_grp2,
  p_loc_info                           => l_imm_loc_info,
  p_per_uniformed_services             => l_imm_per_uniformed_services,
  p_per_conversions                    => l_imm_per_conversions,
  p_per_benefit_info                   => l_imm_per_benefit_info,
  p_asg_non_sf52		       => l_imm_asg_non_sf52,
  p_per_separate_Retire 	       => l_imm_per_sep_retire,
  p_asg_nte_dates		       => l_imm_asg_nte_dates,
  p_per_probations		       => l_imm_per_probations,
  p_per_retained_grade		       => l_imm_per_retained_grade,
  --Bug#4486823 RRR Changes
  p_per_service_oblig                  => l_imm_per_service_oblig,
  p_within_grade_increase	       => l_imm_wgi,
  p_valid_grade                        => l_imm_pos_valid_grade,
  p_pos_oblig                          => l_imm_pos_oblig,
  p_race_ethnic_info		       => l_imm_per_race_ethnic_info, -- Bug 4724337 Race or National Origin changes
  p_ipa_benefits_cont                  => l_imm_ipa_benefits_cont,  -- Bug #6312144 retreiving benefits information
  p_retirement_info                    => l_imm_retirement_info
  );

 -- Over write the Record Groups populated by the Retrieve_all_extra_info,
 -- with the non-null Data on the SF52 form

 process_sf52_extra_info
 (
 p_pa_request_rec                      => p_pa_request_rec,
 p_asg_sf52                    	   => l_imm_asg_sf52,
 p_per_sf52                            => l_imm_per_sf52,
 p_per_group1                 	   => l_imm_per_group1,
 p_per_scd_info                        => l_imm_per_scd_info,
 p_pos_grp2                            => l_imm_pos_grp2,
 p_pos_grp1                            => l_imm_pos_grp1,
 p_loc_info                            => l_imm_loc_info,
 p_recruitment_bonus	               => l_imm_recruitment_bonus,
 p_relocation_bonus	               => l_imm_relocation_bonus ,
  p_student_loan_repay                  => l_imm_student_loan_repay,
 p_extra_info_rec		               => l_imm_extra_info_rec,
 p_valid_grade                        => l_imm_pos_valid_grade
 );

 -- Over write the Record Groups populated by the Retrieve_all_extra_info,
 -- with the non-null Data on the SF52 Extra Information form
 Process_Non_Sf52_Extra_Info
(
 p_pa_request_rec	          => p_pa_request_rec,
 p_generic_ei_rec             => p_generic_ei_rec,
 p_per_group1	       		  => l_imm_per_group1,
 p_per_scd_info               => l_imm_per_scd_info,
 p_pos_grp2                   => l_imm_pos_grp2,
 p_pos_grp1                   => l_imm_pos_grp1,
 p_per_uniformed_services     => l_imm_per_uniformed_services,
 p_per_conversions            => l_imm_per_conversions,
 -- 4352589 BEN_EIT Changes
 p_per_benefit_info           => l_imm_per_benefit_info,
 p_asg_non_sf52		      	  => l_imm_asg_non_sf52,
 p_per_separate_Retire 	      => l_imm_per_sep_retire,
 p_asg_nte_dates	          => l_imm_asg_nte_dates,
 p_per_probations      	      => l_imm_per_probations,
 p_per_retained_grade 	      => l_imm_per_retained_grade,
 --Bug#4486823 RRR Changes
 p_per_service_oblig          => l_imm_per_service_oblig,
 p_within_grade_increase      => l_imm_wgi,
 p_gov_awards                 => l_imm_gov_awards,
 p_conduct_performance        => l_imm_conduct_performance,
 p_agency_sf52		      	  => l_imm_agency_sf52,
 p_recruitment_bonus	      => l_imm_recruitment_bonus,
 p_relocation_bonus	          => l_imm_relocation_bonus,
 p_student_loan_repay         => l_imm_student_loan_repay,
 --Pradeep
 p_mddds_special_pay      => l_imm_mddds_special_pay,
 p_premium_pay_ind        => l_imm_premium_pay_ind,

 p_par_term_retained_grade    => l_imm_par_term_retained_grade,
 p_entitlement                => l_imm_entitlement,
 -- Bug#2759379 Added Fegli record
 p_fegli                      => l_imm_fegli,
 p_foreign_lang_prof_pay      => l_imm_foreign_lang_prof_pay,
  -- Bug#3385386 Added FTA parameter
 p_imm_fta                    => l_imm_fta,
 p_edp_pay                    => l_imm_edp_pay,
 p_hazard_pay                 => l_imm_hazard_pay,
 p_health_benefits            => l_imm_health_benefits,
 p_danger_pay                 => l_imm_danger_pay,
 p_imminent_danger_pay        => l_imm_imminent_danger_pay,
 p_living_quarters_allow      => l_imm_living_quarters_allow,
 p_post_diff_amt              => l_imm_post_diff_amt,
 p_post_diff_percent          => l_imm_post_diff_percent,
 p_sep_maintenance_allow      => l_imm_sep_maintenance_allow,
 p_supplemental_post_allow    => l_imm_supplemental_post_allow,
 p_temp_lodge_allow           => l_imm_temp_lodge_allow,
 p_premium_pay                => l_imm_premium_pay,
 p_retirement_annuity         => l_imm_retirement_annuity,
 p_severance_pay              => l_imm_severance_pay,
 p_thrift_saving_plan         => l_imm_thrift_saving_plan,
 p_retention_allow_review     => l_imm_retention_allow_review,
 p_health_ben_pre_tax         => l_imm_health_ben_pre_tax,
 p_race_ethnic_info	      => l_imm_per_race_ethnic_info, -- Bug 4724337 Race or National Origin changes
 p_ipa_benefits_cont          => l_imm_ipa_benefits_cont,  -- Bug #6312144 retreiving benefits information
 p_retirement_info            => l_imm_retirement_info
 );

 hr_utility.set_location('Relocation Bonus ' || l_imm_relocation_bonus.p_relocation_bonus,1);
 hr_utility.set_location('Relocation EXP ' || l_imm_relocation_bonus.p_date_reloc_exp,2);
 hr_utility.set_location('Recruitment EXP ' || l_imm_recruitment_bonus.p_date_recruit_exp,3);


 -- With the new ghr_pa_requests table, we just need to fetch the agency_code.
 -- And this info. is required by CPDF edits and later by the SF50 Report

 SF52_br_extra_info
 (P_PA_REQUEST_REC  		=> p_pa_request_rec,
  p_agency_code			=> l_agency_code
 );

  -- Get the from_pay_rate_determinant(aei for the given assignment_id and
  -- information_type = 'GHR_US_ASG_SF52' and the work schedule (poei for
  -- the given assignment_id and information_type = 'GHR_US_ASG_SF52'

 If p_pa_request_rec.from_position_id is not null then

   ghr_history_api.get_g_session_var(l_session);
   Ghr_History_Fetch.Fetch_ASGEI_prior_root_sf50
   (
    p_assignment_id         => p_pa_request_rec.employee_assignment_id,
    p_information_type      => 'GHR_US_ASG_SF52',
    p_date_effective        => p_pa_request_rec.effective_date,
    p_altered_pa_request_id => l_session.altered_pa_request_id,
    p_noa_id_corrected      => l_session.noa_id_correct,
    p_get_ovn_flag          => 'Y',
    p_asgei_data            => l_asg_ei_data
   );

    l_imm_sf52_from_data.work_schedule          :=   l_asg_ei_data.aei_information7;
    l_imm_sf52_from_data.pay_rate_determinant   :=   l_asg_ei_data.aei_information6;


   ghr_history_api.get_g_session_var(l_session);
   for person_type_rec in c_person_type loop
      l_person_type :=   person_type_rec.system_person_type;
      exit;
   end loop;

-- Bug# 1223662 --
   If p_pa_request_rec.noa_family_code = 'CONV_APP' and  l_person_type = 'EX_EMP'
      then
      for  asg_prior_date in cur_asg_prior_date loop
         l_effective_date := asg_prior_date.effective_start_date;
         exit;
      end loop;
   Else
     l_effective_date := p_pa_request_rec.effective_date;
   End if;
   hr_utility.set_location('l_effective_date passed to fetch_assignment '||l_effective_date,3 );

   Ghr_History_Fetch.Fetch_assignment
   (
    p_assignment_id         => p_pa_request_rec.employee_assignment_id,
    p_date_effective        => l_effective_date,
    p_altered_pa_request_id => l_session.altered_pa_request_id,
    p_noa_id_corrected      => l_session.noa_id_correct,
    p_assignment_data       => l_assignment_data,
    p_result_code           => l_result_code
   );
    l_imm_sf52_from_data.duty_station_location_id   :=   l_assignment_data.location_id;

 End if;

 hr_utility.set_location('from_duty_station '||l_imm_sf52_from_data.duty_station_location_id,4 );


-- Should retrieve Employee_sex(per_people_f for the person_id , for a specific date),
--  as it is not stored in the ghr_pa_requests table

 For per_sex in c_person_sex loop
   l_imm_personal_info.p_sex  :=  per_sex.sex;
 End loop;

-- Other person details and from side data required for the CPDFs

l_imm_personal_info.p_national_identifier    := p_pa_request_rec.employee_national_identifier ;
l_imm_personal_info.p_date_of_birth          := p_pa_request_rec.employee_date_of_birth;
--
l_imm_sf52_from_data.position_title          :=  p_pa_request_rec.from_position_title;
l_imm_sf52_from_data.position_number         :=  p_pa_request_rec.from_position_number;
l_imm_sf52_from_data.position_seq_no         :=  p_pa_request_rec.from_position_seq_no;
l_imm_sf52_from_data.pay_plan                :=  p_pa_request_rec.from_pay_plan;
l_imm_sf52_from_data.occ_code                :=  p_pa_request_rec.from_occ_code;
l_imm_sf52_from_data.grade_or_level          :=  p_pa_request_rec.from_grade_or_level;
l_imm_sf52_from_data.step_or_rate            :=  p_pa_request_rec.from_step_or_rate;
l_imm_sf52_from_data.total_salary            :=  p_pa_request_rec.from_total_salary;
l_imm_sf52_from_data.pay_basis               :=  p_pa_request_rec.from_pay_basis;
l_imm_sf52_from_data.basic_pay               :=  p_pa_request_rec.from_basic_pay;
l_imm_sf52_from_data.locality_adj            :=  p_pa_request_rec.from_locality_adj;
l_imm_sf52_from_data.adj_basic_pay           :=  p_pa_request_rec.from_adj_basic_pay;
l_imm_sf52_from_data.other_pay               :=  p_pa_request_rec.from_other_pay_amount;
l_imm_sf52_from_data.position_org_line1      :=  p_pa_request_rec.from_position_org_line1;
l_imm_sf52_from_data.position_org_line2      :=  p_pa_request_rec.from_position_org_line2;
l_imm_sf52_from_data.position_org_line3      :=  p_pa_request_rec.from_position_org_line3;
l_imm_sf52_from_data.position_org_line4      :=  p_pa_request_rec.from_position_org_line4;
l_imm_sf52_from_data.position_org_line5      :=  p_pa_request_rec.from_position_org_line5;
l_imm_sf52_from_data.position_org_line6      :=  p_pa_request_rec.from_position_org_line6;
l_imm_sf52_from_data.position_id             :=  p_pa_request_rec.from_position_id;
--

--location_info
l_imm_loc_info.duty_station_id               :=  p_pa_request_rec.duty_station_id;

-- Populate payroll_type

 for payroll_name in c_payroll_name loop
   l_imm_payroll_type.payroll_type   :=   payroll_name.payroll_name;
 End loop;


 --
 -- Take care of performance appraisal special info. (l_imm_perf_appraisal )
 --
 -- get the session variable
 ghr_history_api.get_g_session_var(l_session);

 If l_session.noa_id_correct is null then
    hr_utility.set_location('populate_record_groups ', 30);

    ghr_api.return_special_information
    (p_person_id         =>  p_pa_request_rec.person_id,
     p_structure_name    =>  'US Fed Perf Appraisal',
     p_effective_date    =>  p_pa_request_rec.effective_date,
     p_special_info      =>  l_special_info_type
     );

 Else -- for update get from history
    hr_utility.set_location('populate_record_groups ', 35);
    ghr_history_fetch.return_special_information
     (p_person_id         =>  p_pa_request_rec.person_id,
      p_structure_name    =>  'US Fed Perf Appraisal',
      p_effective_date    =>  p_pa_request_rec.effective_date,
      p_special_info      =>  l_special_info_type
      );

  --Added the below call for the Bug 3187894

    GHR_NON_SF52_EXTRA_INFO.fetch_generic_extra_info(
     p_pa_request_id       =>  p_pa_request_rec.pa_request_id,
     p_person_id           =>  p_pa_request_rec.person_id,
     p_assignment_id       =>  p_pa_request_rec.employee_assignment_id,
     p_effective_date      =>  p_pa_request_rec.effective_date
     ) ;

 End if;

 l_imm_perf_appraisal.person_analysis_id             := l_special_info_type.person_analysis_id;
 l_imm_perf_appraisal.object_version_number          := l_special_info_type.object_version_number;
 l_imm_perf_appraisal.appraisal_type                 := l_special_info_type.segment1;
 l_imm_perf_appraisal.rating_rec                     := l_special_info_type.segment2;
 l_imm_perf_appraisal.date_effective                 := l_special_info_type.segment3;
 l_imm_perf_appraisal.rating_rec_pattern             := l_special_info_type.segment4;
 l_imm_perf_appraisal.rating_rec_level               := l_special_info_type.segment5;
 l_imm_perf_appraisal.date_appr_ends                 := l_special_info_type.segment6;
 l_imm_perf_appraisal.unit                           := l_special_info_type.segment7;
 l_imm_perf_appraisal.org_structure_id               := l_special_info_type.segment8;
 l_imm_perf_appraisal.office_symbol                  := l_special_info_type.segment9;
 l_imm_perf_appraisal.pay_plan                       := l_special_info_type.segment10;
 l_imm_perf_appraisal.grade                          := l_special_info_type.segment11;
 l_imm_perf_appraisal.date_due                       := l_special_info_type.segment12;
 l_imm_perf_appraisal.appraisal_system_identifier    := l_special_info_type.segment13;
 l_imm_perf_appraisal.date_init_appr_due             := l_special_info_type.segment14;
 l_imm_perf_appraisal.optional_information           := l_special_info_type.segment15;
 l_imm_perf_appraisal.performance_rating_points      := l_special_info_type.segment16;
 --Bug# 4753117 28-Feb-07	Veeramani  assigning appraisal start date
 l_imm_perf_appraisal.date_appr_starts               := l_special_info_type.segment17;

 hr_utility.set_location('performance_rating_points'||l_special_info_type.segment16, 39);
 -- Get user entered details
 hr_utility.set_location('populate_record_groups ', 40);

 for perf_appraisal in c_performance_appraisal loop

  --No need for the IF condition since 'US Fed Perf Appraisal' is a mandatory SIT
  --Bug 3187894 Commented by Ashley

    /* if perf_appraisal.rat_rec is not null            or
        perf_appraisal.rec_pattern is not null        or
        perf_appraisal.rec_level is not null          or
        perf_appraisal.app_ends is not null           or
        perf_appraisal.app_type is not null           or
        perf_appraisal.date_init_appr_due is not null or
        perf_appraisal.date_effective is not null or
        perf_appraisal.unit is not null or
        perf_appraisal.org_str_id is not null or
        perf_appraisal.off_symbol is not null or
        perf_appraisal.pay_plan is not null or
        perf_appraisal.grade is not null or
        perf_appraisal.date_due is not null or
        perf_appraisal.appr_sys_ident is not null or
        perf_appraisal.optional_info is not null  or
	perf_appraisal.performance_rating_points is not null then*/

	  if nvl(perf_appraisal.rat_rec,hr_api.g_varchar2)  <> nvl(l_imm_perf_appraisal.rating_rec,hr_api.g_varchar2) then
        l_imm_perf_appraisal.rating_rec         := perf_appraisal.rat_rec;
        l_imm_perf_appraisal.perf_appr_flag     := 'Y';
     end if;
     if nvl(perf_appraisal.rec_pattern,hr_api.g_varchar2)  <> nvl(l_imm_perf_appraisal.rating_rec_pattern,hr_api.g_varchar2) then
        l_imm_perf_appraisal.rating_rec_pattern := perf_appraisal.rec_pattern;
        l_imm_perf_appraisal.perf_appr_flag := 'Y';
     end if;

     -- Reverted the changes done by Pradeep for bug#4054110.
     if nvl(perf_appraisal.rec_level,hr_api.g_varchar2)       <> nvl(l_imm_perf_appraisal.rating_rec_level,hr_api.g_varchar2) then
	l_imm_perf_appraisal.rating_rec_level   := perf_appraisal.rec_level;
        l_imm_perf_appraisal.perf_appr_flag := 'Y';
     end if;

     if nvl(perf_appraisal.app_ends,hr_api.g_varchar2)        <> nvl(l_imm_perf_appraisal.date_appr_ends,hr_api.g_varchar2) then
        l_imm_perf_appraisal.date_appr_ends     :=  perf_appraisal.app_ends;
        l_imm_perf_appraisal.perf_appr_flag := 'Y';
     end if;
       --Bug# 4753117 28-Feb-07	Veeramani  assigning appraisal start date
     if nvl(perf_appraisal.app_starts,hr_api.g_varchar2)        <> nvl(l_imm_perf_appraisal.date_appr_starts,hr_api.g_varchar2) then
        l_imm_perf_appraisal.date_appr_starts   :=  perf_appraisal.app_starts;
        l_imm_perf_appraisal.perf_appr_flag     := 'Y';
     end if;

   if nvl(perf_appraisal.app_type,hr_api.g_varchar2)        <> nvl(l_imm_perf_appraisal.appraisal_type,hr_api.g_varchar2) then
        l_imm_perf_appraisal.appraisal_type     :=  perf_appraisal.app_type;
        l_imm_perf_appraisal.perf_appr_flag := 'Y';
     end if;
   if nvl(perf_appraisal.date_init_appr_due,hr_api.g_varchar2)  <> nvl(l_imm_perf_appraisal.date_init_appr_due,hr_api.g_varchar2) then
        l_imm_perf_appraisal.date_init_appr_due :=  perf_appraisal.date_init_appr_due;
        l_imm_perf_appraisal.perf_appr_flag     := 'Y';
     end if;
    if nvl(perf_appraisal.date_effective,hr_api.g_varchar2)        <> nvl(l_imm_perf_appraisal.date_effective,hr_api.g_varchar2) then
        l_imm_perf_appraisal.date_effective     :=  perf_appraisal.date_effective;
        l_imm_perf_appraisal.perf_appr_flag := 'Y';
     end if;
     if nvl(perf_appraisal.unit,hr_api.g_varchar2)        <> nvl(l_imm_perf_appraisal.unit,hr_api.g_varchar2) then
        l_imm_perf_appraisal.unit     :=  perf_appraisal.unit;
        l_imm_perf_appraisal.perf_appr_flag := 'Y';
     end if;
     if nvl(perf_appraisal.org_str_id,hr_api.g_varchar2)  <> nvl(l_imm_perf_appraisal.org_structure_id,hr_api.g_varchar2) then
        l_imm_perf_appraisal.org_structure_id :=  perf_appraisal.org_str_id;
        l_imm_perf_appraisal.perf_appr_flag   := 'Y';
     end if;
     if nvl(perf_appraisal.off_symbol,hr_api.g_varchar2)  <> nvl(l_imm_perf_appraisal.office_symbol,hr_api.g_varchar2) then
        l_imm_perf_appraisal.office_symbol :=  perf_appraisal.off_symbol;
        l_imm_perf_appraisal.perf_appr_flag   := 'Y';
     end if;
     if nvl(perf_appraisal.pay_plan,hr_api.g_varchar2)  <> nvl(l_imm_perf_appraisal.pay_plan,hr_api.g_varchar2) then
        l_imm_perf_appraisal.pay_plan :=  perf_appraisal.pay_plan;
        l_imm_perf_appraisal.perf_appr_flag   := 'Y';
     end if;
     if nvl(perf_appraisal.grade,hr_api.g_varchar2)  <> nvl(l_imm_perf_appraisal.grade,hr_api.g_varchar2) then
        l_imm_perf_appraisal.grade :=  perf_appraisal.grade;
        l_imm_perf_appraisal.perf_appr_flag   := 'Y';
     end if;
     if nvl(perf_appraisal.date_due,hr_api.g_varchar2)  <>nvl(l_imm_perf_appraisal.date_due,hr_api.g_varchar2) then
        l_imm_perf_appraisal.date_due :=  perf_appraisal.date_due;
        l_imm_perf_appraisal.perf_appr_flag   := 'Y';
     end if;
     if nvl(perf_appraisal.appr_sys_ident,hr_api.g_varchar2)  <> nvl(l_imm_perf_appraisal.appraisal_system_identifier,hr_api.g_varchar2) then
        l_imm_perf_appraisal.appraisal_system_identifier :=  perf_appraisal.appr_sys_ident;
        l_imm_perf_appraisal.perf_appr_flag   := 'Y';
     end if;
     if nvl(perf_appraisal.optional_info,hr_api.g_varchar2)  <> nvl(l_imm_perf_appraisal.optional_information,hr_api.g_varchar2) then
        l_imm_perf_appraisal.optional_information :=  perf_appraisal.optional_info;
        l_imm_perf_appraisal.perf_appr_flag   := 'Y';
     end if;

     hr_utility.set_location('performance_rating_points'||perf_appraisal.performance_rating_points, 41);

     if nvl(perf_appraisal.performance_rating_points,hr_api.g_varchar2) <> nvl(l_imm_perf_appraisal.performance_rating_points,hr_api.g_varchar2) then
        l_imm_perf_appraisal.performance_rating_points :=  perf_appraisal.performance_rating_points;
        l_imm_perf_appraisal.perf_appr_flag   := 'Y';
     end if;
     l_temp_rec_level   := perf_appraisal.rec_level;
--   end if;
 end loop;
 If l_session.noa_id_correct is null and nvl(l_imm_perf_appraisal.perf_appr_flag ,hr_api.g_varchar2) = 'Y' then
    l_imm_perf_appraisal.person_analysis_id :=  Null;
 end if;
    -- Bug#4054110,4069798
    l_imm_perf_appraisal.rating_rec_level   := l_temp_rec_level;
    l_imm_perf_appraisal.perf_appr_flag := 'Y';

-- bug#2468297
if (p_pa_request_rec.work_schedule in ('B','F','G','I','J')) then
l_imm_asg_non_sf52.parttime_indicator:=NULL;
end if;

--
-- Return values into all out variables
--
 p_imm_asg_sf52                     :=	l_imm_asg_sf52;
 p_imm_asg_non_sf52                 :=	l_imm_asg_non_sf52;
 p_imm_asg_nte_dates                :=	l_imm_asg_nte_dates;
 p_imm_per_sf52                     :=	l_imm_per_sf52;
 p_imm_per_group1                   :=	l_imm_per_group1;
 p_imm_per_group2                   :=	l_imm_per_group2;
 p_imm_per_scd_info                 :=	l_imm_per_scd_info;
 p_imm_per_retained_grade           := 	l_imm_per_retained_grade;
 p_imm_per_probations               :=	l_imm_per_probations;
 p_imm_per_sep_retire               :=	l_imm_per_sep_retire;
 p_imm_per_security                 :=	l_imm_per_security;
 -- Bug#4486823 RRR Changes
 p_imm_per_service_oblig            :=  l_imm_per_service_oblig;
 p_imm_per_conversions              :=    l_imm_per_conversions;
 -- 4352589 BEN_EIT Changes
 p_imm_per_benefit_info             :=  l_imm_per_benefit_info;
 p_imm_per_uniformed_services       :=	l_imm_per_uniformed_services;
 p_imm_pos_oblig                    :=	l_imm_pos_oblig;
 p_imm_pos_grp2                     :=	l_imm_pos_grp2;
 p_imm_pos_grp1                     :=	l_imm_pos_grp1;
 p_imm_pos_valid_grade              :=	l_imm_pos_valid_grade;
 p_imm_pos_car_prog                 :=    l_imm_pos_car_prog;
 p_imm_loc_info                     :=    l_imm_loc_info;
 p_imm_wgi     	                  :=    l_imm_wgi;
 p_imm_gov_awards                   :=    l_imm_gov_awards;
 p_imm_recruitment_bonus            :=    l_imm_recruitment_bonus ;
 p_imm_relocation_bonus		      :=	l_imm_relocation_bonus;
 p_imm_student_loan_repay             := l_imm_student_loan_repay;
 --Pradeep
 p_imm_mddds_special_pay	    :=  l_imm_mddds_special_pay;
 p_imm_premium_pay_ind  	    :=  l_imm_premium_pay_ind;

 p_imm_extra_info_rec	 	      :=	l_imm_extra_info_rec ;
 p_imm_sf52_from_data               :=    l_imm_sf52_from_data;
 p_imm_personal_info		      :=    l_imm_personal_info;
 p_imm_generic_extra_info_rec	      := 	l_imm_generic_extra_info_rec ;
 p_imm_agency_sf52		      :=	l_imm_agency_sf52;
 p_imm_payroll_type                 :=    l_imm_payroll_type;
 p_imm_perf_appraisal               :=    l_imm_perf_appraisal;
 p_imm_conduct_performance          :=    l_imm_conduct_performance;
 p_agency_code			      :=    l_agency_code;
 p_imm_par_term_retained_grade      :=    l_imm_par_term_retained_grade;
 p_imm_entitlement                  :=    l_imm_entitlement;
 -- Bug#2759379
 p_imm_fegli                        :=    l_imm_fegli;
 p_imm_foreign_lang_prof_pay        :=    l_imm_foreign_lang_prof_pay;
  -- Bug#3385386 Added FTA record
 p_imm_fta                          :=    l_imm_fta;
 p_imm_edp_pay                      :=    l_imm_edp_pay;
 p_imm_hazard_pay                   :=    l_imm_hazard_pay;
 p_imm_health_benefits              :=    l_imm_health_benefits;
 p_imm_danger_pay                   :=    l_imm_danger_pay;
 p_imm_imminent_danger_pay          :=    l_imm_imminent_danger_pay;
 p_imm_living_quarters_allow        :=    l_imm_living_quarters_allow;
 p_imm_post_diff_amt                :=    l_imm_post_diff_amt;
 p_imm_post_diff_percent            :=    l_imm_post_diff_percent;
 p_imm_sep_maintenance_allow        :=    l_imm_sep_maintenance_allow;
 p_imm_supplemental_post_allow      :=    l_imm_supplemental_post_allow;
 p_imm_temp_lodge_allow             :=    l_imm_temp_lodge_allow;
 p_imm_premium_pay                  :=    l_imm_premium_pay;
 p_imm_retirement_annuity           :=    l_imm_retirement_annuity;
 p_imm_severance_pay                :=    l_imm_severance_pay;
 p_imm_thrift_saving_plan           :=    l_imm_thrift_saving_plan;
 p_imm_retention_allow_review       :=    l_imm_retention_allow_review;
 p_imm_health_ben_pre_tax           :=    l_imm_health_ben_pre_tax;
 p_imm_per_race_ethnic_info			:= 	  l_imm_per_race_ethnic_info; -- Race or National Origin changes

 --start of bug 6312144
 p_imm_ipa_benefits_cont   :=    l_imm_ipa_benefits_cont;
 p_imm_retirement_info  	  := 	l_imm_retirement_info;
 --end of bug 6312144

End populate_record_groups;


-- *******************************
-- procedure Retrieve_all_extra_info
-- *******************************
--

Procedure retrieve_all_extra_info
 (p_pa_request_rec                  in      ghr_pa_requests%rowtype,
  p_asg_sf52                        in out nocopy  ghr_api.asg_sf52_type,
  p_per_sf52                        in out nocopy  ghr_api.per_sf52_type,
  p_per_group1                      in out nocopy  ghr_api.per_group1_type,
  p_per_scd_info                    in out nocopy  ghr_api.per_scd_info_type,
  p_pos_grp1                        in out nocopy  ghr_api.pos_grp1_type,
  p_pos_grp2                        in out nocopy  ghr_api.pos_grp2_type,
  p_loc_info                        in out nocopy  ghr_api.loc_info_type,
  p_per_uniformed_services          in out nocopy  ghr_api.per_uniformed_services_type,
  p_per_conversions                 in out nocopy  ghr_api.per_conversions_type,
  -- 4352589 BEN_EIT Changes
  p_per_benefit_info                in out nocopy  ghr_api.per_benefit_info_type,
  p_asg_non_sf52	            in out nocopy  ghr_api.asg_non_sf52_type,
  p_per_separate_Retire             in out nocopy  ghr_api.per_sep_retire_type,
  p_asg_nte_dates                   in out nocopy  ghr_api.asg_nte_dates_type,
  p_per_probations	            	in out nocopy  ghr_api.per_probations_type,
  p_per_retained_grade	            in out nocopy  ghr_api.per_retained_grade_type,
  --Bug#4486823 RRR Changes
  p_per_service_oblig               in out nocopy ghr_api.per_service_oblig_type,
  p_within_grade_increase           in out nocopy  ghr_api.within_grade_increase_type,
  p_valid_grade                     in out nocopy  ghr_api.pos_valid_grade_type ,
  p_pos_oblig                       in out nocopy  ghr_api.pos_oblig_type,
  p_race_ethnic_info		    in out nocopy  ghr_api.per_race_ethnic_type, -- Bug 4724337 Race or National Origin changes
  --Bug #6312144 RPA EIT Benefits
  p_ipa_benefits_cont               in out nocopy  ghr_api.per_ipa_ben_cont_info_type,
  p_retirement_info                 in out nocopy  ghr_api.per_retirement_info_type
  )
  is
  l_per_extra_info_rec              per_people_extra_info%rowtype;
  l_asg_extra_info_rec              per_assignment_extra_info%rowtype;
  l_pos_extra_info_rec              per_position_extra_info%rowtype;
  l_proc                            varchar2(70) := 'Retrieve_all_extra_info';
  l_person_type                     per_person_types.system_person_type%type := hr_api.g_varchar2;
  l_position_id                     per_positions.position_id%type;
  l_retained_grade_rec              ghr_pay_calc.retained_grade_rec_type;
  l_session                         ghr_history_api.g_session_var_type;
  l_person_status					per_assignment_status_types.user_status%type;

	-- Bug 3021003
	l_ret_flag BOOLEAN := FALSE;
 -- Cursor to retrieve the Person Type of the Person , as of the effective_date of the Request

  cursor   c_person_type is
   select  ppt.system_person_type
   from    per_person_types  ppt,
           per_all_people_f      ppf
   where   ppf.person_id       =  p_pa_request_rec.person_id
   and     ppt.person_type_id  =  ppf.person_type_id
   and     g_effective_date
   between ppf.effective_start_date
   and     ppf.effective_end_date;


   cursor  c_per_ret_grade is
     select pei_information1 date_from,
            pei_information2 date_to,
            pei_information3 grade_or_level,
            pei_information4 step_or_rate,
            pei_information5 pay_plan,
            pei_information6 pay_table_id,
            pei_information7 locality_percent,
            pei_information8 pay_basis
      from  per_people_Extra_info pei
      where pei.person_Extra_info_id =  p_per_retained_grade.person_extra_info_id;

	-- Bug 3390876 Get User Status
   CURSOR c_user_status(c_assignment_id per_all_assignments_f.assignment_id%type,
                        c_effective_date ghr_pa_requests.effective_date%type) IS
    SELECT
	  ast.user_status,
	  ast.per_system_status,
	  asg.effective_start_date
	FROM
	  per_assignment_status_types ast,
	  per_all_assignments_f asg
	WHERE
	  asg.assignment_id = c_assignment_id AND
	  ast.assignment_status_type_id = asg.assignment_status_type_id  		and
	  c_effective_date between asg.effective_start_date and asg.effective_end_date;
	-- End Bug 3390876

   Procedure get_ret_grade
   (p_pa_request_id in           number,
    p_person_extra_info_id  out nocopy  number
   )
   is
   l_proc           varchar2(72)  :=  'get_ret_grade';
   l_extra_info_id  per_people_extra_info.person_extra_info_id%type;
   l_request_id     ghr_pa_requests.pa_request_id%type;

     CURSOR c1(c_request_id in  number) is
       SELECT  par.altered_pa_request_id
       FROM    ghr_pa_requests  par
       WHERE   par.pa_request_id = c_request_id;

     CURSOR c2 (c_request_id number) is
            SELECT  par.pa_request_id, par.altered_pa_request_id, pei.rei_information3
            FROM    ghr_pa_requests par, ghr_pa_request_extra_info pei
            WHERE   par.pa_request_id     = pei.pa_request_id
              AND   pei.pa_request_id     = c_request_id
              AND   pei.information_type  = 'GHR_US_PAR_TERM_RET_GRADE';

  begin

     l_request_id := p_pa_request_id;
     l_extra_info_id := null;
     for c1_rec in c1(c_request_id => l_request_id) loop
        --dbms_output.put_line('inside fetch extra info id loop1');
        hr_utility.set_location(l_proc,1);
        l_request_id := c1_rec.altered_pa_request_id;
        If l_request_id is not null then
         for c2_rec in c2(l_request_id) loop
           hr_utility.set_location(l_proc,1);
           l_extra_info_id := c2_rec.rei_information3;
         end loop;
           hr_utility.set_location(l_proc ||'Extra info id  is '|| to_char(l_extra_info_id),3);
       End if;
       If l_extra_info_id is not null then
          exit;
       End if;
        hr_utility.set_location(l_proc,4);
     end loop;
     p_person_extra_info_id   := l_extra_info_id;
  end  get_ret_grade;


--   begin


-- Probabally should not retrieve extra info for an  'APPOINTMENT' family, except in case of a 'CORRECTION'.

  Begin
   g_effective_date                :=  nvl(p_pa_request_rec.effective_date,sysdate);
   ghr_history_api.get_g_session_var(l_session); -- Bug 3021003
--  l_extra_info_rec.l_extra_info_id := null;
-- Bug # 1234846 --
	  If p_pa_request_rec.noa_family_code in ('APP','CONV_APP') then
		 hr_utility.set_location(l_proc,12);
		 l_person_type    := null;
		 for per_type in c_person_type loop
		   l_person_type :=  per_type.system_person_type;
		 end loop;
		 if l_person_type is null then
		   hr_utility.set_message(8301,'GHR_38133_INVALID_PERSON');
		   hr_utility.raise_error;
		 end if;
	  End if;

      hr_utility.set_location(' Noa Family Code is ' || p_pa_request_rec.noa_family_code ,13);
      hr_utility.set_location(' Person Type is ' || l_person_type,14);
  -- Bug 3390876 Need to populate record groups even for Conversion of Appointment NTE actions if Suspended
	 IF p_pa_request_rec.employee_assignment_id IS NOT NULL THEN
		FOR l_user_status IN c_user_status(p_pa_request_rec.employee_assignment_id,g_effective_date) LOOP
			l_person_status := l_user_status.per_system_status;
		END LOOP;
	 END IF;

  -- Adding OR condition in the code below.
  -- Need to add all Conv. to app actions NTE. Bug 3390876
  IF (p_pa_request_rec.noa_family_code not in ( 'APP','CONV_APP') and
        l_person_type <> 'EX_EMP') OR
		(p_pa_request_rec.first_noa_code IN ('508','515','517','522','548','549','553','554','571','590')) THEN
--		AND l_person_status = 'SUSP_ASSIGN') THEN
   IF p_pa_request_rec.employee_assignment_id is not null then
      hr_utility.set_location(' asg id ' || to_char(p_pa_request_rec.employee_assignment_id) ,2);
      hr_utility.set_location(' Date ' || to_Char(p_pa_request_rec.effective_date),2);

  -- Retrieve asg_sf52

     ghr_history_fetch.fetch_asgei
    (p_assignment_id              =>  p_pa_request_rec.employee_assignment_id,
     p_information_type           => 'GHR_US_ASG_SF52',
     p_date_effective             =>  p_pa_request_rec.effective_date,
     p_asg_ei_data                =>  l_asg_extra_info_rec
     );

    hr_utility.set_location('retrieved asg extra info 1 ',1);

    p_asg_sf52.assignment_extra_info_id :=  l_asg_extra_info_rec.assignment_extra_info_id;
    p_asg_sf52.object_version_number    :=  l_asg_extra_info_rec.object_version_number;
    p_asg_sf52.step_or_rate             :=  l_asg_extra_info_rec.aei_information3;
    p_asg_sf52.tenure                   :=  l_asg_extra_info_rec.aei_information4;
    p_asg_sf52.annuitant_indicator      :=  l_asg_extra_info_rec.aei_information5;
    p_asg_sf52.pay_rate_determinant     :=  l_asg_extra_info_rec.aei_information6;
    p_asg_sf52.work_schedule            :=  l_asg_extra_info_rec.aei_information7;
    p_asg_sf52.part_time_hours          :=  l_asg_extra_info_rec.aei_information8;
    p_asg_sf52.calc_pay_table           :=  l_asg_extra_info_rec.aei_information9;

    hr_utility.set_location('After Fetch from local var - tenure ' || l_asg_extra_info_rec.aei_information3,2);
    hr_utility.set_location('After Fetch from local var - asextrinfoid ' || to_char(l_asg_extra_info_rec.assignment_extra_info_id) ,2);
    l_asg_extra_info_rec   :=  null;
    hr_utility.set_location('After Fetch - tenure ' || p_asg_sf52.tenure,2);
    hr_utility.set_location('After Fetch - annu indic'  || p_asg_sf52.annuitant_indicator,2);
    hr_utility.set_location('After Fetch- asextrinfoid ' || to_char(p_asg_sf52.assignment_extra_info_id) ,2);


 -- Retrieve asg_non_sf52

  ghr_history_fetch.fetch_asgei
  (p_assignment_id              =>  p_pa_request_rec.employee_assignment_id,
   p_information_type           => 'GHR_US_ASG_NON_SF52',
   p_date_effective             =>  p_pa_request_rec.effective_date,
   p_asg_ei_data                =>  l_asg_extra_info_rec
  );


  hr_utility.set_location('retrieved asg extra info 2 ',2);

  p_asg_non_sf52.assignment_extra_info_id       :=  l_asg_extra_info_rec.assignment_extra_info_id;
  p_asg_non_sf52.object_version_number          :=  l_asg_extra_info_rec.object_version_number;
  p_asg_non_sf52.date_arr_personnel_office      :=  l_asg_extra_info_rec.aei_information3;
  p_asg_non_sf52.duty_status                    :=  l_asg_extra_info_rec.aei_information4;
  p_asg_non_sf52.key_emer_essential_empl        :=  l_asg_extra_info_rec.aei_information5;
  p_asg_non_sf52.non_disc_agmt_status           :=  l_asg_extra_info_rec.aei_information6;
  p_asg_non_sf52.date_wtop_exemp_expires        :=  l_asg_extra_info_rec.aei_information7;
  p_asg_non_sf52.parttime_indicator             :=  l_asg_extra_info_rec.aei_information8;
  p_asg_non_sf52.qualification_standard_waiver  :=  l_asg_extra_info_rec.aei_information9;
  p_asg_non_sf52.trainee_promotion_id           :=  l_asg_extra_info_rec.aei_information10;
  p_asg_non_sf52.date_trainee_promotion_expt    :=  l_asg_extra_info_rec.aei_information11;
  l_asg_extra_info_rec   :=  null;

 -- Retrieve asg_nte_dates

  ghr_history_fetch.fetch_asgei
  (p_assignment_id              =>  p_pa_request_rec.employee_assignment_id,
   p_information_type           => 'GHR_US_ASG_NTE_DATES',
   p_date_effective             =>  p_pa_request_rec.effective_date,
   p_asg_ei_data                =>  l_asg_extra_info_rec
  );

  hr_utility.set_location('retrieved asg extra info 3 ',3);


  p_asg_nte_dates.assignment_extra_info_id       :=  l_asg_extra_info_rec.assignment_extra_info_id;
  p_asg_nte_dates.object_version_number          :=  l_asg_extra_info_rec.object_version_number;
  p_asg_nte_dates.asg_nte_start_date             :=  l_asg_extra_info_rec.aei_information3;
  p_asg_nte_dates.assignment_nte                 :=  l_asg_extra_info_rec.aei_information4;
  p_asg_nte_dates.lwop_nte_start_date            :=  l_asg_extra_info_rec.aei_information5;
  p_asg_nte_dates.lwop_nte                       :=  l_asg_extra_info_rec.aei_information6;
  p_asg_nte_dates.suspension_nte_start_date      :=  l_asg_extra_info_rec.aei_information7;
  p_asg_nte_dates.suspension_nte                 :=  l_asg_extra_info_rec.aei_information8;
  p_asg_nte_dates.furlough_nte_start_date        :=  l_asg_extra_info_rec.aei_information9;
  p_asg_nte_dates.furlough_nte                   :=  l_asg_extra_info_rec.aei_information10;
  p_asg_nte_dates.lwp_nte_start_date             :=  l_asg_extra_info_rec.aei_information11;
  p_asg_nte_dates.lwp_nte                        :=  l_asg_extra_info_rec.aei_information12;
  p_asg_nte_dates.sabatical_nte_start_date       :=  l_asg_extra_info_rec.aei_information13;
  p_asg_nte_dates.sabatical_nte                  :=  l_asg_extra_info_rec.aei_information14;
  p_asg_nte_dates.assignment_number              :=  l_asg_extra_info_rec.aei_information15;
--  p_asg_nte_dates.position_change_nte            :=  l_asg_extra_info_rec.aei_information16;  -- ??
  l_asg_extra_info_rec   :=  null;

  END IF;
END IF;

  -- Retrieve PER SF52

  ghr_history_fetch.fetch_peopleei
  (p_person_id                  =>  p_pa_request_rec.person_id,
   p_information_type           => 'GHR_US_PER_SF52',
   p_date_effective             =>  p_pa_request_rec.effective_date,
   p_per_ei_data                =>  l_per_extra_info_rec
  );

   hr_utility.set_location('retrieved per sf52 ',5);

   p_per_sf52.person_extra_info_id        :=  l_per_extra_info_rec.person_extra_info_id;
   p_per_sf52.object_version_number       :=  l_per_extra_info_rec.object_version_number;
   p_per_sf52.citizenship                 :=  l_per_extra_info_rec.pei_information3;
   p_per_sf52.veterans_preference         :=  l_per_extra_info_rec.pei_information4;
   p_per_sf52.veterans_preference_for_rif :=  l_per_extra_info_rec.pei_information5;
   p_per_sf52.veterans_status             :=  l_per_extra_info_rec.pei_information6;

  l_per_extra_info_rec   :=  null;

-- Retrieve Per_Group1

   ghr_history_fetch.fetch_peopleei
  (p_person_id                  =>  p_pa_request_rec.person_id,
   p_information_type           => 'GHR_US_PER_GROUP1',
   p_date_effective             =>  p_pa_request_rec.effective_date,
   p_per_ei_data                =>  l_per_extra_info_rec
  );

  hr_utility.set_location('After fetch RINO     ' || l_per_extra_info_rec.pei_information5,1);
  hr_utility.set_location('After Fetch HANDICAP ' || l_per_extra_info_rec.pei_information11,2);

  hr_utility.set_location('retrieved per group1 ',6);

   p_per_group1.person_extra_info_id         :=  l_per_extra_info_rec.person_extra_info_id;
   p_per_group1.object_version_number        :=  l_per_extra_info_rec.object_version_number;
   p_per_group1.appointment_type             :=  l_per_extra_info_rec.pei_information3;
   p_per_group1.type_of_employment           :=  l_per_extra_info_rec.pei_information4;
   p_per_group1.race_national_origin         :=  l_per_extra_info_rec.pei_information5;
   p_per_group1.date_last_promotion          :=  l_per_extra_info_rec.pei_information6;
   p_per_group1.agency_code_transfer_from    :=  l_per_extra_info_rec.pei_information7;
   p_per_group1.org_appointment_auth_code1   :=  l_per_extra_info_rec.pei_information8;
   p_per_group1.org_appointment_desc1        :=  l_per_extra_info_rec.pei_information22;--Bug# 4941984(AFHR2)
   p_per_group1.org_appointment_auth_code2   :=  l_per_extra_info_rec.pei_information9;
   p_per_group1.org_appointment_desc2        :=  l_per_extra_info_rec.pei_information23;--Bug# 4941984(AFHR2)
   p_per_group1.country_world_citizenship    :=  l_per_extra_info_rec.pei_information10;
   p_per_group1.handicap_code                :=  l_per_extra_info_rec.pei_information11;
   p_per_group1.consent_id                   :=  l_per_extra_info_rec.pei_information12;
   p_per_group1.date_fehb_eligibility_expires :=  l_per_extra_info_rec.pei_information13;
   p_per_group1.date_temp_eligibility_fehb   :=  l_per_extra_info_rec.pei_information14;
   p_per_group1.date_febh_dependent_cert_exp :=  l_per_extra_info_rec.pei_information15;
   p_per_group1.family_member_emp_pref       :=  l_per_extra_info_rec.pei_information16;
   p_per_group1.family_member_status         :=  l_per_extra_info_rec.pei_information17;
   --Bug#4486823 RRR Changes
   p_per_group1.retention_inc_review_date    :=  l_per_extra_info_rec.pei_information21;

   l_per_extra_info_rec   :=  null;
--

-- Retrieve  Per_scd `

  ghr_history_fetch.fetch_peopleei
  (p_person_id              =>  p_pa_request_rec.person_id,
  p_information_type           => 'GHR_US_PER_SCD_INFORMATION',
  p_date_effective             =>  p_pa_request_rec.effective_date,
  p_per_ei_data                =>  l_per_extra_info_rec
  );

    hr_utility.set_location('After fetch SCD     ' || l_per_extra_info_rec.pei_information3,1);

   hr_utility.set_location('retrieved per scd ',8);

   p_per_scd_info.person_extra_info_id         :=  l_per_extra_info_rec.person_extra_info_id;
   p_per_scd_info.object_version_number        :=  l_per_extra_info_rec.object_version_number;
   p_per_scd_info.scd_leave                    :=  l_per_extra_info_rec.pei_information3;
   p_per_scd_info.scd_civilian                 :=  l_per_extra_info_rec.pei_information4;
   p_per_scd_info.scd_rif                      :=  l_per_extra_info_rec.pei_information5;
   p_per_scd_info.scd_tsp                      :=  l_per_extra_info_rec.pei_information6;
   -- Begin Bug# 4864508
   p_per_scd_info.scd_retirement			   :=  l_per_extra_info_rec.pei_information7;
   -- End Bug# 4864508
   --bug#4443968
   p_per_scd_info.scd_creditable_svc_annl_leave := l_per_extra_info_rec.pei_information12;
   l_per_extra_info_rec   :=  null;

-- Retrieve per_probations

   ghr_history_fetch.fetch_peopleei
  (p_person_id                 =>  p_pa_request_rec.person_id,
  p_information_type           => 'GHR_US_PER_PROBATIONS',
   p_date_effective            =>  p_pa_request_rec.effective_date,
  p_per_ei_data                =>  l_per_extra_info_rec
  );


  hr_utility.set_location('retrieved per probations  ',9);

   p_per_probations.person_extra_info_id         :=  l_per_extra_info_rec.person_extra_info_id;
   p_per_probations.object_version_number        :=  l_per_extra_info_rec.object_version_number;
   p_per_probations.date_prob_trial_period_begin :=  l_per_extra_info_rec.pei_information3;
   p_per_probations.date_prob_trial_period_ends  :=  l_per_extra_info_rec.pei_information4;
  -- p_per_probations.date_spvr_mgr_prob_Begins    :=  l_per_extra_info_rec.pei_information8; --Bug# 4588575
   p_per_probations.date_spvr_mgr_prob_ends      :=  l_per_extra_info_rec.pei_information5;
   p_per_probations.spvr_mgr_prob_completion     :=  l_per_extra_info_rec.pei_information6;
   p_per_probations.date_ses_prob_expires        :=  l_per_extra_info_rec.pei_information7;

   l_per_extra_info_rec   :=  null;

--  Retrieve per_retained_grade

-- Retained Grade has to retrieved with a special logic, as it can have multiple occurences
-- and on the same dates. The procedure below, returns the retained grade details that fetches the max. profit for
-- the person for the specific date.

-- Note : It is assumed that the retain_pay_table_id is not used by the CPDFs.
--        Actually the user_table_id is stored into the retain_pay_table_id , which is just the primary key id and not
--        the actual pay table name, like the quad 0s. Since the only pay table used by the CPDF is the Quad 0 and
--        has been hard coded for validations, it is OK to pass the id against the actual name of the pay table.
--


 begin

  If p_pa_request_rec.first_noa_code = '866' then
    l_retained_grade_rec :=  ghr_pc_basic_pay.get_retained_grade_details
                             (p_person_id       =>   p_pa_request_rec.person_id,
                              p_effective_date  =>   p_pa_request_rec.effective_date + 1,
                              p_pa_request_id   =>   p_pa_request_rec.pa_request_id
                             );
  Else
     l_retained_grade_rec :=  ghr_pc_basic_pay.get_retained_grade_details
                            (p_person_id       =>   p_pa_request_rec.person_id,
                             p_effective_date  =>   p_pa_request_rec.effective_date,
                             p_pa_request_id   =>   p_pa_request_rec.pa_request_id
                            );
   END IF;

     -- Bug#4423679 Added date_from, date_to
     p_per_retained_grade.date_from              :=  l_retained_grade_rec.date_from;
     p_per_retained_grade.date_to                :=  l_retained_grade_rec.date_to;
     -- Bug#4423679
     p_per_retained_grade.retain_grade            :=  l_retained_grade_rec.grade_or_level;
     p_per_retained_grade.retain_step_or_rate     :=  l_retained_grade_rec.step_or_rate;
     p_per_retained_grade.retain_pay_plan         :=  l_retained_grade_rec.pay_plan;
     p_per_retained_grade.retain_pay_table_id     :=  to_char(l_retained_grade_rec.user_table_id);
     p_per_retained_grade.retain_locality_percent :=  to_char(l_retained_grade_rec.locality_percent);
     p_per_retained_grade.retain_pay_basis        :=  l_retained_grade_rec.pay_basis;
     p_per_retained_grade.temp_step               :=  l_retained_grade_rec.temp_step;
   --End if;
    -- Bug 3021003 If Intervening actions are present in WGI, QSI corrections, get the corrected step.
	-- Bug 4658890 Removed 894 from first_noa_code
   IF   p_pa_request_rec.first_noa_code IN ('867','892','893') AND  l_session.noa_id_correct IS NOT NULL THEN
     hr_utility.set_location('Inside PRUP Sun if condn',10);
		ghr_pay_calc.is_retained_ia(p_pa_request_rec.person_id,
									   p_pa_request_rec.effective_date,
									   l_retained_grade_rec.pay_plan,
									   l_retained_grade_rec.grade_or_level,
									   l_retained_grade_rec.step_or_rate,
									   l_retained_grade_rec.temp_step,
									   l_ret_flag);
		 IF l_ret_flag = TRUE THEN
			IF l_retained_grade_rec.temp_step IS NOT NULL THEN
				hr_utility.set_location('Inside PRUP Sun if temp_step condn' || l_retained_grade_rec.temp_step,10);
				p_per_retained_grade.temp_step := ghr_pc_basic_pay.get_next_WGI_step (l_retained_grade_rec.pay_plan,l_retained_grade_rec.temp_step);
			ELSE
				hr_utility.set_location('Inside PRUP Sun ELSE temp_step condn' || l_retained_grade_rec.step_or_rate,10);
				p_per_retained_grade.retain_step_or_rate := ghr_pc_basic_pay.get_next_WGI_step (l_retained_grade_rec.pay_plan,l_retained_grade_rec.step_or_rate);
			END IF;
			p_per_sf52.per_sf52_flag := 'Y';
		 END IF;
   END IF;

  hr_utility.set_location('Retrieved Per_retained_grade',10);

-- Need to handle this Exception here because it is just a warning to indicate that the pay cannot be calculated
-- which is only apt for the Front End and does not matter in this context.

exception
  when ghr_pay_calc.pay_calc_message then
     null;
 end;

-- Retrieve per_separate_retire

   hr_utility.set_location('retrieved per unif ',13);
   hr_utility.set_location('p_per_separate_retire.agency_code_transfer_to = ' ||
                            p_per_separate_retire.agency_code_transfer_to ,13);
   hr_utility.set_location('l_per_extra_info_rec.pei_information8 = ' ||
                            l_per_extra_info_rec.pei_information8 ,13);
   ghr_history_fetch.fetch_peopleei
  (p_person_id                 =>  p_pa_request_rec.person_id,
   p_information_type          => 'GHR_US_PER_SEPARATE_RETIRE',
   p_date_effective            =>  p_pa_request_rec.effective_date,
   p_per_ei_data               =>  l_per_extra_info_rec
  );
  p_per_separate_retire.person_extra_info_id          := l_per_extra_info_rec.person_extra_info_id;
  p_per_separate_retire.object_version_number         := l_per_extra_info_rec.object_version_number;
  p_per_separate_retire.fers_coverage                 := l_per_extra_info_rec.pei_information3;
  p_per_separate_retire.prev_retirement_coverage      := l_per_extra_info_rec.pei_information4;
  p_per_separate_retire.frozen_service                := l_per_extra_info_rec.pei_information5;
  p_per_separate_retire.naf_retirement_indicator      := l_per_extra_info_rec.pei_information6;
  p_per_separate_retire.reason_for_separation         := l_per_extra_info_rec.pei_information7;
  p_per_separate_retire.agency_code_transfer_to       := l_per_extra_info_rec.pei_information8;
  p_per_separate_retire.date_projected_retirement     := l_per_extra_info_rec.pei_information9;
  p_per_separate_retire.mandatory_retirement_date     := l_per_extra_info_rec.pei_information10;
  --Start Bug 1359482
  If  nvl(p_pa_request_rec.first_noa_code,hr_api.g_varchar2) in ('300','301','302','303','304') then
    hr_utility.set_location('separate_pkg_status_indicator defaults to 1',14);
    p_per_separate_retire.separate_pkg_status_indicator := '1';
    p_per_separate_retire.per_sep_retire_flag := 'Y';
  else
    p_per_separate_retire.separate_pkg_status_indicator := l_per_extra_info_rec.pei_information11;
  end if;
  --End Bug 1359482

  p_per_separate_retire.separate_pkg_register_number  := l_per_extra_info_rec.pei_information12;
  p_per_separate_retire.separate_pkg_pay_office_id    := l_per_extra_info_rec.pei_information13;
  p_per_separate_retire.date_ret_appl_received        := l_per_extra_info_rec.pei_information14;
  p_per_separate_retire.date_ret_pkg_sent_to_payroll  := l_per_extra_info_rec.pei_information15;
  p_per_separate_retire.date_ret_pkg_recv_payroll     := l_per_extra_info_rec.pei_information16;
  p_per_separate_retire.date_ret_pkg_to_opm           := l_per_extra_info_rec.pei_information17;

  l_per_extra_info_rec   :=  null;

   hr_utility.set_location('p_per_separate_retire.agency_code_transfer_to = ' ||
                            p_per_separate_retire.agency_code_transfer_to ,14);
   hr_utility.set_location('l_per_extra_info_rec.pei_information8 = ' ||
                            l_per_extra_info_rec.pei_information8 ,14);
   hr_utility.set_location('retrieved per unif ',14);

-- Bug#4486823 RRR Changes
-- Retrieve per_service_obligation

  /*  ghr_history_fetch.fetch_peopleei
  (p_person_id                 =>  p_pa_request_rec.person_id,
   p_information_type          => 'GHR_US_PER_SERVICE_OBLIGATION',
   p_date_effective            =>  p_pa_request_rec.effective_date,
   p_per_ei_data               =>  l_per_extra_info_rec
  );
  p_per_service_oblig.person_extra_info_id          := l_per_extra_info_rec.person_extra_info_id;
  p_per_service_oblig.object_version_number         := l_per_extra_info_rec.object_version_number;
  p_per_service_oblig.service_oblig_type_code       := l_per_extra_info_rec.pei_information3;
  p_per_service_oblig.service_oblig_start_date      := l_per_extra_info_rec.pei_information4;
  p_per_service_oblig.service_oblig_end_date        := l_per_extra_info_rec.pei_information5;
  l_per_extra_info_rec   :=  null;

   hr_utility.set_location('p_per_service_oblig.service_oblig_type_code = ' ||
                            p_per_service_oblig.service_oblig_type_code ,15);
   hr_utility.set_location('p_per_service_oblig.service_oblig_start_date = ' ||
                            p_per_service_oblig.service_oblig_start_date ,15);
   hr_utility.set_location('retrieved per serv oblg ',15); */

 -- Retrieve per_uniformed_services

   ghr_history_fetch.fetch_peopleei
  (p_person_id                 =>  p_pa_request_rec.person_id,
   p_information_type          => 'GHR_US_PER_UNIFORMED_SERVICES',
   p_date_effective            =>  p_pa_request_rec.effective_date,
   p_per_ei_data               =>  l_per_extra_info_rec
  );

   p_per_uniformed_services.person_extra_info_id         :=  l_per_extra_info_rec.person_extra_info_id;
   p_per_uniformed_services.object_version_number        :=  l_per_extra_info_rec.object_version_number;
   p_per_uniformed_services.reserve_category             :=  l_per_extra_info_rec.pei_information3;
   p_per_uniformed_services.military_recall_status       :=  l_per_extra_info_rec.pei_information4;
   p_per_uniformed_services.creditable_military_service  :=  l_per_extra_info_rec.pei_information5;
   p_per_uniformed_services.date_retired_uniform_service :=  l_per_extra_info_rec.pei_information6;
   p_per_uniformed_services.uniform_service_component    :=  l_per_extra_info_rec.pei_information7;
   p_per_uniformed_services.uniform_service_designation  :=  l_per_extra_info_rec.pei_information8;
   p_per_uniformed_services.retirement_grade             :=  l_per_extra_info_rec.pei_information9;
   p_per_uniformed_services.military_retire_waiver_ind   :=  l_per_extra_info_rec.pei_information10;
   p_per_uniformed_services.exception_retire_pay_ind     :=  l_per_extra_info_rec.pei_information11;

   l_per_extra_info_rec   :=  null;


-- Retrieve per_conversions

   ghr_history_fetch.fetch_peopleei
  (p_person_id                 =>  p_pa_request_rec.person_id,
   p_information_type          => 'GHR_US_PER_CONVERSIONS',
   p_date_effective            =>  p_pa_request_rec.effective_date,
   p_per_ei_data               =>  l_per_extra_info_rec
  );

   p_per_conversions.person_extra_info_id         :=  l_per_extra_info_rec.person_extra_info_id;
   p_per_conversions.object_version_number        :=  l_per_extra_info_rec.object_version_number;
   p_per_conversions.date_conv_career_begins      :=  l_per_extra_info_rec.pei_information3;
   p_per_conversions.date_conv_career_due         :=  l_per_extra_info_rec.pei_information4;
   p_per_conversions.date_recmd_conv_begins       :=  l_per_extra_info_rec.pei_information5;
   p_per_conversions.date_recmd_conv_due          :=  l_per_extra_info_rec.pei_information7;
   p_per_conversions.date_vra_conv_due            :=  l_per_extra_info_rec.pei_information6;

   l_per_extra_info_rec   :=  null;

   -- 4352589 BEN_EIT Changes
   -- Retrieve per_benefit_info
   ghr_history_fetch.fetch_peopleei
  (p_person_id                 =>  p_pa_request_rec.person_id,
   p_information_type          => 'GHR_US_PER_BENEFIT_INFO',
   p_date_effective            =>  p_pa_request_rec.effective_date,
   p_per_ei_data               =>  l_per_extra_info_rec
  );

   p_per_benefit_info.person_extra_info_id           :=  l_per_extra_info_rec.person_extra_info_id;
   p_per_benefit_info.object_version_number          :=  l_per_extra_info_rec.object_version_number;
   p_per_benefit_info.FEGLI_Date_Eligibility_Expires :=  l_per_extra_info_rec.pei_information3;
   p_per_benefit_info.FEHB_Date_Eligibility_expires  :=  l_per_extra_info_rec.pei_information4;
   p_per_benefit_info.FEHB_Date_temp_eligibility     :=  l_per_extra_info_rec.pei_information5;
   p_per_benefit_info.FEHB_Date_dependent_cert_expir :=  l_per_extra_info_rec.pei_information6;
   p_per_benefit_info.FEHB_LWOP_contingency_st_date  :=  l_per_extra_info_rec.pei_information7;
   p_per_benefit_info.FEHB_LWOP_contingency_end_date :=  l_per_extra_info_rec.pei_information8;
   p_per_benefit_info.FEHB_Child_equiry_court_date   :=  l_per_extra_info_rec.pei_information10;
   p_per_benefit_info.FERS_Date_eligibility_expires  :=  l_per_extra_info_rec.pei_information11;
   p_per_benefit_info.FERS_Election_Date             :=  l_per_extra_info_rec.pei_information12;
   p_per_benefit_info.FERS_Election_Indicator        :=  l_per_extra_info_rec.pei_information13;
   p_per_benefit_info.TSP_Agncy_Contrib_Elig_date    :=  l_per_extra_info_rec.pei_information14;
   p_per_benefit_info.TSP_Emp_Contrib_Elig_date      :=  l_per_extra_info_rec.pei_information15;

   -- Changes related to 6312144 -- Addition of new segments introduced in benefit info record type
   p_per_benefit_info.FEGLI_Assignment_Ind:=  l_per_extra_info_rec.pei_information16;
   p_per_benefit_info.FEGLI_Post_Elec_Basic_Ins_Amt:=  l_per_extra_info_rec.pei_information17;
   p_per_benefit_info.FEGLI_Court_Order_Ind:=  l_per_extra_info_rec.pei_information18;
   p_per_benefit_info.Desg_FEGLI_Benf_Ind:=  l_per_extra_info_rec.pei_information19;
   p_per_benefit_info.FEHB_Event_Code:=  l_per_extra_info_rec.pei_information20;


    -- Bug 4724337 Race or National Origin changes
   	l_per_extra_info_rec   :=  null;
     ghr_history_fetch.fetch_peopleei
	  (p_person_id                 =>  p_pa_request_rec.person_id,
	   p_information_type          => 'GHR_US_PER_ETHNICITY_RACE',
	   p_date_effective            =>  p_pa_request_rec.effective_date,
	   p_per_ei_data               =>  l_per_extra_info_rec
	  );
   p_race_ethnic_info.person_extra_info_id           :=  l_per_extra_info_rec.person_extra_info_id;
   p_race_ethnic_info.object_version_number          :=  l_per_extra_info_rec.object_version_number;
   p_race_ethnic_info.p_hispanic 					 :=  l_per_extra_info_rec.pei_information3;
   p_race_ethnic_info.p_american_indian  			 :=  l_per_extra_info_rec.pei_information4;
   p_race_ethnic_info.p_asian     					 :=  l_per_extra_info_rec.pei_information5;
   p_race_ethnic_info.p_black_afr_american 			 :=  l_per_extra_info_rec.pei_information6;
   p_race_ethnic_info.p_hawaiian_pacific  			 :=  l_per_extra_info_rec.pei_information7;
   p_race_ethnic_info.p_white  						 :=  l_per_extra_info_rec.pei_information8;


-- Retrieve pos_valid_grade

   If p_pa_request_rec.to_position_id is null then
     l_position_id := p_pa_request_rec.from_position_id;
   Else
     l_position_id := p_pa_request_rec.to_position_id;
   End if;

  ghr_history_fetch.fetch_positionei
  (p_position_id                =>  l_position_id,
   p_information_type           => 'GHR_US_POS_VALID_GRADE',
   p_date_effective             =>  p_pa_request_rec.effective_date,
   p_pos_ei_data                =>  l_pos_extra_info_rec
   );

   hr_utility.set_location('retrieved pos valid grade ',15);

   p_valid_grade.position_extra_info_id            :=  l_pos_extra_info_rec.position_extra_info_id;
   p_valid_grade.object_version_number             :=  l_pos_extra_info_rec.object_version_number;
   p_valid_grade.valid_grade                       :=  l_pos_extra_info_rec.poei_information3;
   p_valid_grade.target_grade                      :=  l_pos_extra_info_rec.poei_information4;
   p_valid_grade.pay_table_id                      :=  l_pos_extra_info_rec.poei_information5;
   p_valid_grade.pay_basis                         :=  l_pos_extra_info_rec.poei_information6;
   p_valid_grade.employment_category_group         :=  l_pos_extra_info_rec.poei_information7;
   hr_utility.set_location('POS_VAL_GRADE - POS ID ' || to_char(l_position_id),1);
   hr_utility.set_location('POS_VAL_GRADE - OVN ' || to_char(l_pos_extra_info_rec.object_version_number),2);
   hr_utility.set_location('POS_VAL_GRADE - POEI ID' || to_char(l_pos_extra_info_rec.position_extra_info_id),3);

   l_pos_extra_info_rec   :=  null;

  -- Retrieve Position group1


  ghr_history_fetch.fetch_positionei
  (p_position_id                =>  l_position_id,
   p_information_type           => 'GHR_US_POS_GRP1',
   p_date_effective             =>  p_pa_request_rec.effective_date,
   p_pos_ei_data                =>  l_pos_extra_info_rec
  );


   hr_utility.set_location('retrieved pos grp 1 ',16);

   p_pos_grp1.position_extra_info_id            :=  l_pos_extra_info_rec.position_extra_info_id;
   p_pos_grp1.object_version_number             :=  l_pos_extra_info_rec.object_version_number;
   p_pos_grp1.personnel_office_id               :=  l_pos_extra_info_rec.poei_information3;
   p_pos_grp1.office_symbol                     :=  l_pos_extra_info_rec.poei_information4;
   p_pos_grp1.organization_structure_id         :=  l_pos_extra_info_rec.poei_information5;
   p_pos_grp1.occupation_category_code          :=  l_pos_extra_info_rec.poei_information6;
   p_pos_grp1.flsa_category                     :=  l_pos_extra_info_rec.poei_information7;
   p_pos_grp1.bargaining_unit_status            :=  l_pos_extra_info_rec.poei_information8;
   p_pos_grp1.competitive_level                 :=  l_pos_extra_info_rec.poei_information9;
   p_pos_grp1.work_schedule                     :=  l_pos_extra_info_rec.poei_information10;
   p_pos_grp1.functional_class                  :=  l_pos_extra_info_rec.poei_information11;
   p_pos_grp1.position_working_title            :=  l_pos_extra_info_rec.poei_information12;
   p_pos_grp1.position_sensitivity              :=  l_pos_extra_info_rec.poei_information13;
   p_pos_grp1.security_access                   :=  l_pos_extra_info_rec.poei_information14;
   p_pos_grp1.prp_sci                           :=  l_pos_extra_info_rec.poei_information15;
   p_pos_grp1.supervisory_status                :=  l_pos_extra_info_rec.poei_information16;
   p_pos_grp1.type_employee_supervised          :=  l_pos_extra_info_rec.poei_information17;
   p_pos_grp1.payroll_office_id                 :=  l_pos_extra_info_rec.poei_information18;
   p_pos_grp1.timekeeper                        :=  l_pos_extra_info_rec.poei_information19;
   p_pos_grp1.competitive_area                  :=  l_pos_extra_info_rec.poei_information20;
   p_pos_grp1.positions_organization            :=  l_pos_extra_info_rec.poei_information21;
   p_pos_grp1.oct_report_flag                   :=  l_pos_extra_info_rec.poei_information22;
   p_pos_grp1.part_time_hours                   :=  l_pos_extra_info_rec.poei_information23;



    hr_utility.set_location('POS_gRP1 - POS ID ' || to_char(l_position_id),1);
    hr_utility.set_location('POS_GRP1 - OVN ' || to_char(p_pos_grp1.object_version_number),2);
    hr_utility.set_location('POS_GRP1 - POEI ID' || to_char(p_pos_grp1.position_extra_info_id),3);

l_pos_extra_info_rec   :=  null;

 -- Retrieve Position Group2

 ghr_history_fetch.fetch_positionei
  (p_position_id                =>  l_position_id,
   p_information_type           => 'GHR_US_POS_GRP2',
   p_date_effective             =>  p_pa_request_rec.effective_date,
   p_pos_ei_data                =>  l_pos_extra_info_rec
  );


  hr_utility.set_location('retrieved pos grp 2 ',17);


   p_pos_grp2.position_extra_info_id            :=  l_pos_extra_info_rec.position_extra_info_id;
   p_pos_grp2.object_version_number             :=  l_pos_extra_info_rec.object_version_number;
   p_pos_grp2.position_occupied                 :=  l_pos_extra_info_rec.poei_information3;
   p_pos_grp2.organization_function_code        :=  l_pos_extra_info_rec.poei_information4;
   p_pos_grp2.date_position_classified          :=  l_pos_extra_info_rec.poei_information5;
   p_pos_grp2.date_last_position_audit          :=  l_pos_extra_info_rec.poei_information6;
   p_pos_grp2.classification_official           :=  l_pos_extra_info_rec.poei_information7;
   p_pos_grp2.language_required                 :=  l_pos_extra_info_rec.poei_information8;
   p_pos_grp2.drug_test                         :=  l_pos_extra_info_rec.poei_information9;
   p_pos_grp2.financial_statement               :=  l_pos_extra_info_rec.poei_information10;
   p_pos_grp2.training_program_id               :=  l_pos_extra_info_rec.poei_information11;
   p_pos_grp2.key_emergency_essential           :=  l_pos_extra_info_rec.poei_information12;
   p_pos_grp2.appropriation_code1               :=  l_pos_extra_info_rec.poei_information13;
   p_pos_grp2.appropriation_code2               :=  l_pos_extra_info_rec.poei_information14;
   p_pos_grp2.intelligence_position_ind         :=  l_pos_extra_info_rec.poei_information15;
   p_pos_grp2.leo_position_indicator            :=  l_pos_extra_info_rec.poei_information16;
    hr_utility.set_location('POS_2 - POS ID ' || to_char(l_position_id),1);
    hr_utility.set_location('POS_2 - OVN ' || to_char(l_pos_extra_info_rec.object_version_number),2);
    hr_utility.set_location('POS_2 - POEI ID' || to_char(l_pos_extra_info_rec.position_extra_info_id),3);

   l_pos_extra_info_rec   :=  null;

 -- Retrieve  Position Obligation

  ghr_history_fetch.fetch_positionei
  (p_position_id                =>  l_position_id,
   p_information_type           => 'GHR_US_POS_OBLIG',
   p_date_effective             =>  p_pa_request_rec.effective_date,
   p_pos_ei_data                =>  l_pos_extra_info_rec
  );
  p_pos_oblig.position_extra_info_id            := l_pos_extra_info_rec.position_extra_info_id;
  p_pos_oblig.object_version_number             := l_pos_extra_info_rec.object_version_number;
  p_pos_oblig.expiration_date 			:= l_pos_extra_info_rec.poei_information3;
  p_pos_oblig.obligation_type 			:= l_pos_extra_info_rec.poei_information4;
  p_pos_oblig.employee_ssn    		      := l_pos_extra_info_rec.poei_information5;
  l_pos_extra_info_rec           			:= null;

  hr_utility.set_location('retrieved pos oblig ',18);

/* Retrieve GHR_US_POS_CAR_PROG */

/* Retrieve GHR_US_PER_BENEFITS_CONT */
  -- Bug 6312144 IPA Benefits Continuation EIT changes

  hr_utility.set_location('Before retrieving IPA Benefits Continuation',19);
  l_per_extra_info_rec   :=  null;
  ghr_history_fetch.fetch_peopleei
  	  (p_person_id                 =>  p_pa_request_rec.person_id,
	   p_information_type          => 'GHR_US_PER_BENEFITS_CONT',
	   p_date_effective            =>  p_pa_request_rec.effective_date,
	   p_per_ei_data               =>  l_per_extra_info_rec
	  );
   p_ipa_benefits_cont.person_extra_info_id           :=  l_per_extra_info_rec.person_extra_info_id;
   p_ipa_benefits_cont.object_version_number          :=  l_per_extra_info_rec.object_version_number;
   p_ipa_benefits_cont.FEGLI_Indicator 		      :=  l_per_extra_info_rec.pei_information1;
   p_ipa_benefits_cont.FEGLI_Election_Date            :=  l_per_extra_info_rec.pei_information2;
   p_ipa_benefits_cont.FEGLI_Elec_Not_Date    	      :=  l_per_extra_info_rec.pei_information3;
   p_ipa_benefits_cont.FEHB_Indicator 	              :=  l_per_extra_info_rec.pei_information4;
   p_ipa_benefits_cont.FEHB_Election_Date  	      :=  l_per_extra_info_rec.pei_information5;
   p_ipa_benefits_cont.FEHB_Elec_Notf_Date	      :=  l_per_extra_info_rec.pei_information6;
   p_ipa_benefits_cont.retirement_Indicator           :=  l_per_extra_info_rec.pei_information7;
   p_ipa_benefits_cont.retirement_Elec_Date           :=  l_per_extra_info_rec.pei_information12;
   p_ipa_benefits_cont.retirement_Elec_Notf_Date      :=  l_per_extra_info_rec.pei_information8;
   p_ipa_benefits_cont.Cont_Term_Insuff_Pay_Elec_Date :=  l_per_extra_info_rec.pei_information9;
   p_ipa_benefits_cont.Cont_Term_Insuff_Pay_Notf_Date :=  l_per_extra_info_rec.pei_information10;
   p_ipa_benefits_cont.Cont_Term_Insuff_Pmt_Type_Code :=  l_per_extra_info_rec.pei_information11;

/* Retrieve GHR_US_PER_BENEFITS_CONT */
 hr_utility.set_location('Retrieving IPA Benefits Continuation',20);

/* Retrieve GHR_US_PER_RETIRMENT_SYS_INFO*/

 hr_utility.set_location('Before retrieving Retirement System Information',21);
 -- Bug 6312144 Retirement System Information EIT changes
 l_per_extra_info_rec   :=  null;
 ghr_history_fetch.fetch_peopleei
	   (p_person_id                 =>  p_pa_request_rec.person_id,
	    p_information_type          => 'GHR_US_PER_RETIRMENT_SYS_INFO',
	    p_date_effective            =>  p_pa_request_rec.effective_date,
	    p_per_ei_data               =>  l_per_extra_info_rec
	   );
   p_retirement_info.person_extra_info_id           :=  l_per_extra_info_rec.person_extra_info_id;
   p_retirement_info.object_version_number          :=  l_per_extra_info_rec.object_version_number;
   p_retirement_info.special_population_code        :=  l_per_extra_info_rec.pei_information1;
   p_retirement_info.App_Exc_CSRS_Ind               :=  l_per_extra_info_rec.pei_information2;
   p_retirement_info.App_Exc_FERS_Ind               :=  l_per_extra_info_rec.pei_information3;
   p_retirement_info.FICA_Coverage_Ind1             :=  l_per_extra_info_rec.pei_information4;
   p_retirement_info.FICA_Coverage_Ind2             :=  l_per_extra_info_rec.pei_information5;

   hr_utility.set_location('After Retirement System Information',22);
/* Retrieve GHR_US_PER_RETIRMENT_SYS_INFO*/

End retrieve_all_extra_info;



-- **********************  *********
-- procedure SF52_br_extra_info
-- *******************************
--
--
/*
	This procedure gets other Sf52 data that has not been retrieved by
      the process_sf52_extra_info and process_non_sf52_extra_info procedure
*/
--

procedure SF52_br_extra_info
(
  P_PA_REQUEST_REC  		IN       GHR_PA_REQUESTS%ROWTYPE
 ,p_agency_code			out nocopy      varchar2
 ) is
--
l_bus_gp 	            number;
l_agency_code 	      varchar2(50);
l_proc                  varchar2(70) := 'SF52_br_extra_info';
l_position_id           per_positions.position_id%type;

--
--Bug# 957677  -- Parameter Name Change
cursor   c_bus_gp(p_position_id number) is
  select pos.business_group_id
  from   hr_all_positions_f pos  -- Venkat - Position DT
  where  pos.position_id = p_position_id
     and p_pa_request_rec.effective_date between
         pos.effective_start_date and pos.effective_end_date;

Cursor c_pa_request_extra_info (l_information_type varchar2) is
  Select *
  from   ghr_pa_request_extra_info
  where  pa_request_id    =  p_pa_request_rec.pa_request_id
  and    information_type =  l_information_type;

--
Begin
  --
  g_effective_date              :=  nvl(p_pa_request_rec.effective_date,sysdate);
  hr_utility.set_location('Entering  ' || l_proc,10);
  --
  If p_pa_request_rec.to_position_id is null then
    l_position_id :=  p_pa_request_rec.from_position_id;
  Else
    l_position_id :=  p_pa_request_rec.to_position_id;
  End if;
  for bus_gp in c_bus_gp(l_position_id) loop
    l_bus_gp := bus_gp.business_group_id;
  End loop;
  --
  -- Agency Code
  -- if this is a change in data element and the pa_req ei agency code is not null,
  -- then take the agency code from the extra info for the action. If this is a realignment,
  -- and the pa_req_ei agency code is not null, then take the agency code from the extra info for the action.
  -- Otherwise, use the agency code associated with l_position_id.
  --
  if  p_pa_request_rec.noa_family_code = 'CHG_DATA_ELEMENT'  then
      for c_ei_rec in c_pa_request_extra_info('GHR_US_PAR_CHG_DATA_ELEMENT') loop
         l_agency_code   :=  c_ei_rec.rei_information4;
      end loop;
  elsif p_pa_request_rec.noa_family_code = 'REALIGNMENT' then
      for c_ei_rec in c_pa_request_extra_info('GHR_US_PAR_REALIGNMENT') loop
         l_agency_code   :=  c_ei_rec.rei_information10;
      end loop;
  end if;
  if  p_pa_request_rec.noa_family_code = 'CHG_DATA_ELEMENT'  and
	l_agency_code is not null  then
      p_agency_code := l_agency_code;
  elsif
	p_pa_request_rec.noa_family_code = 'REALIGNMENT' and
	l_agency_code is not null then
	p_agency_code := l_agency_code;
  else
  	p_agency_code  :=  ghr_api.get_position_agency_code_pos
                           (p_position_id       =>   l_position_id
                           ,p_business_group_id =>   l_bus_gp
                           ,p_effective_date    => p_pa_request_rec.effective_date
                           );
  end if;
  hr_utility.set_location('Leaving ' ||l_proc,40);
end SF52_br_extra_info;

--
-- *****************************
-- procedure Process_Sf52_Extra_Info
-- *****************************
--

-- This procedure Updates the various Record Groups with Data from the SF52 Form.

procedure Process_Sf52_Extra_Info
(p_pa_request_rec             in     ghr_pa_requests%rowtype,
 p_asg_sf52                   in out nocopy ghr_api.asg_sf52_type,
 p_per_sf52                   in out nocopy ghr_api.per_sf52_type,
 p_per_group1                 in out nocopy ghr_api.per_group1_type,
 p_per_scd_info               in out nocopy ghr_api.per_scd_info_type,
 p_pos_grp2                   in out nocopy ghr_api.pos_grp2_type,
 p_pos_grp1                   in out nocopy ghr_api.pos_grp1_type,
 p_loc_info                   in out nocopy ghr_api.loc_info_type,
 p_recruitment_bonus	      in out nocopy ghr_api.recruitment_bonus_type ,
 p_relocation_bonus           in out nocopy ghr_api.relocation_bonus_type,
 p_student_loan_repay         in out nocopy ghr_api.student_loan_repay_type,
 p_extra_info_rec	            in out nocopy ghr_api.extra_info_rec_type,
 p_valid_grade  in out  nocopy ghr_api.pos_valid_grade_type)
 is
--
l_noa_code		      ghr_nature_of_actions.code%type;
l_proc                  varchar2(70) := 'Process_Sf52_Extra_Info';
l_person_type           per_person_types.system_person_type%type;

--


 cursor    c_person_type is
   select  ppt.system_person_type
   from    per_person_types  ppt,
           per_all_people_f      ppf
   where   ppf.person_id       =  p_pa_request_rec.person_id
   and     ppt.person_type_id  =  ppf.person_type_id
   and     g_effective_date
   between ppf.effective_start_date
   and     ppf.effective_end_date;

/*Cursor c_pa_request_extra_info (l_information_type varchar2) is
  Select rei_information4,rei_information8
  from   ghr_pa_request_extra_info
  where  pa_request_id    =  p_pa_request_rec.pa_request_id
  and    information_type =  l_information_type; */
--
/*l_payroll_office_id       ghr_pa_request_extra_info.rei_information4%type;
l_pos_org                 ghr_pa_request_extra_info.rei_information8%type;*/
l_student_loan_repay       ghr_api.student_loan_repay_type;

--Bug  6881863
l_calc_table_id        pay_user_tables.user_table_id%type;
--

Begin

  g_effective_date           :=  nvl(p_pa_request_rec.effective_date,sysdate);

/*l_payroll_office_id          := p_pos_grp1.payroll_office_id;
l_pos_org                    := p_pos_grp1.positions_organization;*/
l_student_loan_repay := p_student_loan_repay;

  hr_utility.set_location('Entering ' ||l_proc,5);

--    **********************
--    Assignment SF52  Extra Info
--     **********************
--
  -- FWFA Changes.
  If P_pa_request_rec.To_Step_Or_Rate      is not null  or
     P_pa_request_rec.Tenure                is not null or
     P_pa_request_rec.Annuitant_Indicator   is not null or
     P_pa_request_rec.Pay_Rate_Determinant  is not null or
     p_pa_request_rec.to_pay_table_identifier is not null
   then
--
--
    hr_utility.set_location(l_proc,10);

--
    hr_utility.set_location('ASG FLAG ' || p_asg_sf52.asg_sf52_flag,1);
    If p_pa_request_rec.to_step_or_rate is not null then
      If P_pa_request_rec.to_step_or_rate <>
        nvl(p_asg_sf52.step_or_rate,hr_api.g_varchar2) then
        hr_utility.set_location(l_proc,20);
        p_Asg_sf52.Asg_sf52_flag       := 'Y';
        p_Asg_Sf52.Step_Or_Rate        :=  P_pa_request_rec.to_Step_Or_Rate;
      End if;
    End if;
--
    hr_utility.set_location('ASG FLAG ' || p_asg_sf52.asg_sf52_flag,2);
    hr_utility.set_location('old tenure  ' || p_asg_sf52.tenure,2);
    hr_utility.set_location('new tenure  ' || p_pa_request_rec.tenure,2);
    hr_utility.set_location('old ann ind  ' || p_asg_sf52.annuitant_indicator,2);


    If p_pa_request_rec.tenure is not null then
       If P_pa_request_rec.Tenure        <>
         nvl(p_asg_sf52.tenure,hr_api.g_varchar2) then
         hr_utility.set_location(l_proc,25);
         p_asg_sf52.asg_sf52_flag        := 'Y';
         P_Asg_Sf52.Tenure               :=  P_pa_request_rec.Tenure ;
       End if;
    End if;
--
    hr_utility.set_location('ASG FLAG ' || p_asg_sf52.asg_sf52_flag,3);

    If p_pa_request_rec.annuitant_indicator is not null then
      If P_pa_request_rec.Annuitant_Indicator <>
        nvl(p_asg_sf52.annuitant_indicator,hr_api.g_varchar2)then
        hr_utility.set_location(l_proc,30);
        p_asg_sf52.asg_sf52_flag        := 'Y';
        P_Asg_Sf52.Annuitant_Indicator  := P_pa_request_rec.Annuitant_Indicator;
      End if;
    End if;
--
    hr_utility.set_location('ASG FLAG ' || p_asg_sf52.asg_sf52_flag,4);

    If p_pa_request_rec.pay_rate_determinant is not null then
      If P_pa_request_rec.Pay_Rate_Determinant<>
        nvl(p_asg_sf52.pay_rate_determinant,hr_api.g_varchar2) then
        hr_utility.set_location(l_proc,35);
        p_asg_sf52.asg_sf52_flag         := 'Y';
        p_Asg_Sf52.Pay_Rate_Determinant  := P_pa_request_rec.Pay_Rate_Determinant;
      End if;
    End if;
   hr_utility.set_location('ASG FLAG ' || p_asg_sf52.asg_sf52_flag,5);
  End if;

  If nvl(P_pa_request_rec.work_schedule,hr_api.g_varchar2) <>
        nvl(p_asg_sf52.work_schedule,hr_api.g_varchar2) then
        hr_utility.set_location(l_proc,35);
        p_asg_sf52.asg_sf52_flag         := 'Y';
        p_Asg_Sf52.work_schedule  := P_pa_request_rec.work_schedule;
  End if;

    hr_utility.set_location('ASG FLAG ' || p_asg_sf52.asg_sf52_flag,6);

  If nvl(P_pa_request_rec.part_time_hours,hr_api.g_number) <>
        nvl(p_asg_sf52.part_time_hours,hr_api.g_number) then
        hr_utility.set_location(l_proc,35);
        p_asg_sf52.asg_sf52_flag         := 'Y';
        p_Asg_Sf52.part_time_hours   := P_pa_request_rec.part_time_hours;
  End if;
 -- 809503
  for person_type_rec in c_person_type loop
     IF person_type_rec.system_person_type  = 'EX_EMP' and
       p_pa_request_rec.noa_family_code in ('CONV_APP','APP','APPT_TRANS') THEN
       p_asg_sf52.asg_sf52_flag := 'Y';
     END IF;
  end loop;

   hr_utility.set_location('ASG FLAG ' || p_asg_sf52.asg_sf52_flag,6);
    If p_pa_request_rec.to_pay_table_identifier is not null then
      If P_pa_request_rec.to_pay_table_identifier <>
        nvl(p_asg_sf52.calc_pay_table,hr_api.g_number)then
        hr_utility.set_location(l_proc,30);
        p_asg_sf52.asg_sf52_flag        := 'Y';
        P_Asg_Sf52.calc_pay_table  := P_pa_request_rec.to_pay_table_identifier;
      End if;
    End if;

    -- Added for the bug # 6881863
    -- to fetch the pay table identifier from position if it getting as NULL if PRD is K or J
    IF p_pa_request_rec.to_pay_table_identifier is null and NVL(p_pa_request_rec.pay_rate_determinant,'X') in ('K','J') then
       l_calc_table_id := ghr_pay_calc.get_user_table_id(p_position_id => p_pa_request_rec.to_position_id,
	                                                p_effective_date => p_pa_request_rec.effective_date);
       p_asg_sf52.asg_sf52_flag        := 'Y';
       P_Asg_Sf52.calc_pay_table  := l_calc_table_id;
    END IF;
    -- 6881863
    hr_utility.set_location('ASG FLAG ' || p_asg_sf52.asg_sf52_flag,7);



--
--  ********************
-- Additional Location DDF
--  ********************
  p_Loc_Info.duty_station_id             := to_char(p_pa_request_rec.duty_station_id);


--
--    **********************
--    Person  SF52  Extra Info
--     **********************
--
  If P_pa_request_rec.Citizenship           is not null or
     P_pa_request_rec.Veterans_Preference   is not null or
     P_pa_request_rec.Veterans_Pref_for_rif is not null or
     P_pa_request_rec.Veterans_Status       is not null then
    hr_utility.set_location(l_proc,55);
--
--
    If p_pa_request_rec.citizenship is not null then
      If p_pa_request_rec.Citizenship  <> nvl(p_per_sf52.citizenship,hr_api.g_varchar2) then
        hr_utility.set_location(l_proc,65);
        P_Per_sf52.Per_Sf52_Flag      := 'Y';
        P_Per_sf52.Citizenship        := P_pa_request_rec.Citizenship;
      End if;
    End if;
--
  If p_pa_request_rec.veterans_preference is not null then
    If P_pa_request_rec.Veterans_Preference <>
      nvl(p_per_sf52.veterans_preference,hr_api.g_varchar2) then
      hr_utility.set_location(l_proc,70);
      P_Per_sf52.Per_Sf52_Flag       := 'Y';
      P_Per_sf52.Veterans_Preference := P_pa_request_rec.Veterans_Preference;
    End if;
  End if;

  If p_pa_request_rec.veterans_pref_for_rif is not null then
    If P_pa_request_rec.Veterans_Pref_for_rif <>
      nvl(p_per_sf52.veterans_preference_for_rif,hr_api.g_varchar2) then
      hr_utility.set_location(l_proc,75);
      P_Per_sf52.Per_Sf52_Flag               := 'Y';
      P_Per_sf52.Veterans_Preference_For_Rif := P_pa_request_rec.Veterans_Pref_for_rif;
    End if;
  End if;

  If p_pa_request_rec.veterans_status is not null then
    If P_pa_request_rec.Veterans_Status <>
      nvl(p_per_sf52.veterans_status,hr_api.g_varchar2)then
      hr_utility.set_location(l_proc,80);
      P_Per_sf52.Per_Sf52_Flag      := 'Y';
      P_Per_sf52.Veterans_Status    := P_pa_request_rec.Veterans_Status;
    End if;
  End if;
--
End if;

--
--    **********************
--    per_scd extra info
--     **********************

If p_pa_request_rec.service_comp_date is not null then
  hr_utility.set_location(l_proc,85);

  hr_utility.set_location(l_proc,90);
  If fnd_date.date_to_canonical(p_pa_request_rec.service_comp_date)
     <> nvl(p_per_scd_info.scd_leave,fnd_date.date_to_canonical(hr_api.g_date)) then
    hr_utility.set_location(l_proc,95);
    p_per_scd_info.scd_leave          := fnd_date.date_to_canonical(p_pa_request_rec.service_comp_date);
    p_per_scd_info.per_scd_info_flag  := 'Y';
  End if;
 End if;

--
--
--    **********************
--    Position Group1 Extra Info
--     **********************
--
-- JH Add part time Hours
  /*if p_pa_request_rec.noa_family_code = 'REALIGNMENT' then
  hr_utility.set_location('Inside PRUP realign check'||p_pa_request_rec.noa_family_code,12345);
      for c_ei_rec in c_pa_request_extra_info('GHR_US_PAR_REALIGNMENT') loop
         If c_ei_rec.rei_information4 is not null then
	 l_payroll_office_id   :=  c_ei_rec.rei_information4;
	 end if;
	 If c_ei_rec.rei_information8 is not null then
	 l_pos_org             :=  c_ei_rec.rei_information8;
	 end if;
      end loop;
    hr_utility.set_location('Inside PRUP payroll check'||l_payroll_office_id,12345);
    p_pos_grp1.payroll_office_id := l_payroll_office_id;

    hr_utility.set_location('Inside PRUP pos org check'||l_pos_org,12345);
    p_pos_grp1.positions_organization := l_pos_org;
  end if;*/

  If 	P_pa_request_rec.to_Occ_Code		      	is not null or
	P_pa_request_rec.Bargaining_Unit_Status	 	is not null or
	P_pa_request_rec.Work_Schedule		 	is not null or
	P_pa_request_rec.Functional_Class	 	      is not null or
	P_pa_request_rec.FLSA_Category		 	is not null or
	P_pa_request_rec.Supervisory_Status		      is not null or
      P_pa_request_rec.part_time_hours			is not null  then
    hr_utility.set_location(l_proc,95);
--
--
	-- Bug 3226555 Commented below code as they can never be equal. It was unnecessarily inserting a
	-- row into the history for the table PER_POSITIONS_EXTRA_INFO and thereby making the Position
	-- status as invalid when cancellation to any action was done.
 /*   If p_pa_request_rec.to_occ_code is not null then
      If P_pa_request_rec.to_Occ_Code <>
        nvl(p_pos_grp1.occupation_category_code,hr_api.g_varchar2) then
        hr_utility.set_location(l_proc,105);
        P_Pos_grp1.Pos_Grp1_Flag     := 'Y';
        P_Pos_grp1.Occupation_Category_Code := P_pa_request_rec.to_Occ_Code;
      End if;
    End if; */

    If p_pa_request_rec.bargaining_unit_status is not null then
      If P_pa_request_rec.Bargaining_Unit_Status <>
        nvl(p_pos_grp1.bargaining_unit_status,hr_api.g_varchar2) then
        hr_utility.set_location(l_proc,110);
        P_Pos_grp1.Pos_Grp1_Flag     := 'Y';
        P_Pos_grp1.Bargaining_Unit_Status := P_pa_request_rec.Bargaining_Unit_Status;
      End if;
    End if;

-- JH removing comments so position is updated for WS and adding PTH update
-- Bugs 773851, 773795
      If p_pa_request_rec.work_schedule is not null then
      If P_pa_request_rec.Work_Schedule <>
        nvl(p_pos_grp1.work_schedule,hr_api.g_varchar2) then
        hr_utility.set_location(l_proc,115);
        hr_utility.set_location('JH Rec WS = ' || P_pa_request_rec.work_schedule,115);
        hr_utility.set_location('JH Posn Grp1 WS = ' || p_pos_grp1.work_schedule,115);
        P_Pos_grp1.Pos_Grp1_Flag     := 'Y';
        P_Pos_grp1.Work_Schedule := P_pa_request_rec.Work_Schedule;
        hr_utility.set_location('JH Update WS = ' || p_pos_grp1.work_schedule,115);
      End if;
    End if;

-- JH Hard coded to pass null if WS is F, G, B, I, J.
     If p_pa_request_rec.part_time_hours is not null then
      If P_pa_request_rec.part_time_hours <>
        nvl(p_pos_grp1.part_time_hours,hr_api.g_number) then
        hr_utility.set_location(l_proc,117);
        hr_utility.set_location('JH Rec PTH = ' || P_pa_request_rec.part_time_hours,117);
        hr_utility.set_location('JH Posn Grp1 PTH = ' || p_pos_grp1.part_time_hours,117);
        P_Pos_grp1.Pos_Grp1_Flag     := 'Y';
        P_Pos_grp1.part_time_hours := P_pa_request_rec.part_time_hours;
        hr_utility.set_location('JH Update PTH = ' || p_pos_grp1.part_time_hours,117);
      End if;
    Elsif P_Pos_grp1.Work_Schedule in ('F', 'G', 'B', 'I', 'J') Then
        P_Pos_grp1.part_time_hours := null;
    End if;
-- JH End changes

    If p_pa_request_rec.functional_class is not null then
      If P_pa_request_rec.Functional_Class  <>
        nvl(p_pos_grp1.functional_class,hr_api.g_varchar2) then
        hr_utility.set_location(l_proc,120);
        P_Pos_grp1.Pos_Grp1_Flag     := 'Y';
        P_Pos_grp1.Functional_Class := P_pa_request_rec.Functional_Class;
      End if;
    End if;

    If p_pa_request_rec.flsa_category is not null then
      If P_pa_request_rec.FLSA_Category <>
        nvl(p_pos_grp1.flsa_category,hr_api.g_varchar2) then
        hr_utility.set_location(l_proc,125);
        P_Pos_grp1.Pos_Grp1_Flag     := 'Y';
        P_Pos_grp1.FLSA_Category := P_pa_request_rec.FLSA_Category;
      End if;
    End if;

    If p_pa_request_rec.supervisory_status is not null then
      If P_pa_request_rec.Supervisory_Status <>
        nvl(p_pos_grp1.supervisory_status,hr_api.g_varchar2) then
        hr_utility.set_location(l_proc,130);
        P_Pos_grp1.Pos_Grp1_Flag     := 'Y';
        P_Pos_grp1.Supervisory_Status := P_pa_request_rec.Supervisory_Status;
      End if;
    End if;

  End If;

--
--    **********************
--    Position Group2 Extra Info
--     **********************
--
  If  P_pa_request_rec.Appropriation_Code1	 	is not null or
	P_pa_request_rec.Appropriation_Code2	 	is not null or
      p_pa_request_rec.position_occupied              is not null then  --*
--
     hr_utility.set_location(l_proc,135);
--
    If p_pa_request_rec.position_occupied is not null then
      If p_pa_request_rec.position_occupied <> nvl(p_pos_grp2.position_occupied,hr_api.g_varchar2) then
        hr_utility.set_location(l_proc,145);
        P_Pos_grp2.Pos_grp2_flag          :=  'Y';
        p_pos_grp2.position_occupied      :=  p_pa_request_rec.position_occupied;
      End if;
    End if;

    If p_pa_request_rec.appropriation_code1 is not null then
      If P_pa_request_rec.Appropriation_Code1 <>  nvl(p_pos_grp2.appropriation_code1,hr_api.g_varchar2) then
        hr_utility.set_location(l_proc,150);
        P_Pos_grp2.Pos_grp2_flag    :=  'Y';
        P_Pos_grp2.Appropriation_Code1 := P_pa_request_rec.Appropriation_Code1;
      End if;
    End if;

--
    If p_pa_request_rec.appropriation_code2 is not null then
      If p_pa_request_rec.Appropriation_Code2 <> nvl(p_pos_grp2.appropriation_code2,hr_api.g_varchar2) then
        hr_utility.set_location(l_proc,155);
        P_Pos_grp2.Pos_grp2_flag    :=  'Y';
        P_Pos_grp2.Appropriation_Code2:= P_pa_request_rec.Appropriation_Code2;
      End if;
    End if;
--
  End if;

--    ************************
--    Position Valid Grade EIT
--    ************************
-- If Grade is changed, then need to update it to Position Bug 2414903
	IF p_pa_request_rec.to_grade_id IS NOT NULL THEN
		IF p_pa_request_rec.to_grade_id <> NVL(to_number(p_valid_grade.valid_grade),hr_api.g_number) THEN
			p_valid_grade.pos_valid_grade_flag := 'Y';
			p_valid_grade.valid_grade := p_pa_request_rec.to_grade_id;
		END IF;
	END IF;


--    *****************
--    Recruitment Bonus
--    *****************
--
	If  nvl(p_pa_request_rec.first_noa_code,hr_api.g_varchar2) = '815' then
         hr_utility.set_location(l_proc,165);
        p_recruitment_bonus.p_recruitment_bonus := p_pa_request_rec.award_amount;
		  p_recruitment_bonus.p_percentage        := p_pa_request_rec.award_percentage;
	END IF;
--
--
--
--    ***************
--    Relocation Bonus
--    ***************
--
	If nvl(p_pa_request_rec.first_noa_code,hr_api.g_varchar2) = '816' then
        hr_utility.set_location(l_proc,170);
        p_relocation_bonus.p_relocation_bonus := p_pa_request_rec.award_amount;
		  p_relocation_bonus.p_percentage        := p_pa_request_rec.award_percentage;
	End if;
--
--
--    ***************
--    Student Loan Repayment
--    ***************
--
	If nvl(p_pa_request_rec.first_noa_code,hr_api.g_varchar2) = '817' then
        hr_utility.set_location(l_proc,170);
        l_student_loan_repay.p_amount := p_pa_request_rec.award_amount;
	p_student_loan_repay          := l_student_loan_repay;
	End if;
--
--
--
EXCEPTION
WHEN OTHERS THEN
p_student_loan_repay := l_student_loan_repay;
raise;

End Process_Sf52_Extra_Info;

--
--  **********************************************************
--  Process_non_SF-52_Extra_Info
--  **********************************************************
--
PROCEDURE  Process_Non_Sf52_Extra_Info
--
(p_pa_request_rec			in out nocopy ghr_pa_requests%rowtype,
 p_generic_ei_rec             in     ghr_pa_request_extra_info%rowtype,
 p_per_group1		     	in out nocopy ghr_api.per_group1_type,
 p_per_scd_info               in out nocopy  ghr_api.per_scd_info_type,
 p_pos_grp2                   in out nocopy ghr_api.pos_grp2_type,
 p_pos_grp1                   in out nocopy ghr_api.pos_grp1_type,
 p_per_uniformed_services	in out nocopy ghr_api.per_uniformed_services_type,
 p_per_conversions            in out nocopy ghr_api.per_conversions_type,
 -- 4352589 BEN_EIT Changes
 p_per_benefit_info	      in out nocopy ghr_api.per_benefit_info_type,
 p_asg_non_sf52			in out nocopy ghr_api.asg_non_sf52_type,
 p_per_separate_Retire 		in out nocopy ghr_api.per_sep_retire_type,
 p_asg_nte_dates			in out nocopy ghr_api.asg_nte_dates_type,
 p_per_probations		      in out nocopy ghr_api.per_probations_type,
 p_per_retained_grade		in out nocopy ghr_api.per_retained_grade_type,
 --Bug#4486823 RRR Changes
 p_per_service_oblig        in out nocopy ghr_api.per_service_oblig_type,
 p_within_grade_increase	in out nocopy ghr_api.within_grade_increase_type,
 p_gov_awards                 in out nocopy ghr_api.government_awards_type,
 p_conduct_performance        in out nocopy ghr_api.conduct_performance_type,
 p_agency_sf52			in out nocopy ghr_api.agency_sf52_type,
 p_recruitment_bonus          in out nocopy ghr_apI.recruitment_bonus_type,
 p_relocation_bonus           in out nocopy ghr_apI.relocation_bonus_type,
 p_student_loan_repay         in out nocopy ghr_api.student_loan_repay_type,
 --Pradeep
 p_mddds_special_pay      in out nocopy ghr_api.mddds_special_pay_type,
  p_premium_pay_ind      in out nocopy ghr_api.premium_pay_ind_type,

 p_par_term_retained_grade    in out nocopy ghr_api.par_term_retained_grade_type,
 p_entitlement                in out nocopy ghr_api.entitlement_type,
 -- Bug#2759379 Added Fegli record
 p_fegli                      in out nocopy ghr_api.fegli_type,
 p_foreign_lang_prof_pay      in out nocopy ghr_api.foreign_lang_prof_pay_type,
-- Bug#3385386 Added FTA record
 p_imm_fta                    in out nocopy ghr_api.fta_type,
 p_edp_pay                    in out nocopy ghr_api.edp_pay_type,
 p_hazard_pay                 in out nocopy ghr_api.hazard_pay_type,
 p_health_benefits            in out nocopy ghr_api.health_benefits_type,
 p_danger_pay                 in out nocopy ghr_api.danger_pay_type,
 p_imminent_danger_pay        in out nocopy ghr_api.imminent_danger_pay_type,
 p_living_quarters_allow      in out nocopy ghr_api.living_quarters_allow_type,
 p_post_diff_amt              in out nocopy ghr_api.post_diff_amt_type,
 p_post_diff_percent          in out nocopy ghr_api.post_diff_percent_type,
 p_sep_maintenance_allow      in out nocopy ghr_api.sep_maintenance_allow_type,
 p_supplemental_post_allow    in out nocopy ghr_api.supplemental_post_allow_type,
 p_temp_lodge_allow           in out nocopy ghr_api.temp_lodge_allow_type,
 p_premium_pay                in out nocopy ghr_api.premium_pay_type,
 p_retirement_annuity         in out nocopy ghr_api.retirement_annuity_type,
 p_severance_pay              in out nocopy ghr_api.severance_pay_type,
 p_thrift_saving_plan         in out nocopy ghr_api.thrift_saving_plan,
 p_retention_allow_review     in out nocopy ghr_api.retention_allow_review_type,
 p_health_ben_pre_tax         in out nocopy ghr_api.health_ben_pre_tax_type,
 p_race_ethnic_info	      in out nocopy ghr_api.per_race_ethnic_type, -- Bug 4724337 Race or National Origin changes
 p_ipa_benefits_cont          in out nocopy ghr_api.per_ipa_ben_cont_info_type,
 p_retirement_info            in out nocopy ghr_api.per_retirement_info_type
)
--
IS
  --
  -- Declare local variables

  l_proc                      varchar2(70) := 'Process_non_sf52_extra_info';
  l_noa_code                  ghr_nature_of_actions.code%type;
  l_noa_id                    ghr_nature_of_actions.nature_of_action_id%type;
  l_information_type          ghr_pa_request_info_types.information_type%type;
  l_pa_request_ei_rec         ghr_pa_request_extra_info%rowtype;
  p_extra_info_agency_rec     ghr_api.extra_info_rec_type;
  l_session                   ghr_history_api.g_session_var_type;
  l_multiple_error_flag       boolean;
  -- Bug#5668878
  l_psi                       VARCHAR2(10);
  --
  -- Declare cursors
  --
  -- Bug#3941541 Added the effective date condition.
   Cursor c_info_types is
     Select  pit.information_type
     from    ghr_pa_request_info_types  pit,
             ghr_noa_families           nfa,
             ghr_families               fam
     where   nfa.nature_of_action_id  = p_pa_request_rec.first_noa_id
     and     nfa.noa_family_code      = fam.noa_family_code
     and     fam.pa_info_type_flag    = 'Y'
     and     pit.noa_family_code      = fam.noa_family_code
     and     pit.information_type     like 'GHR_US%'
     and     p_pa_request_rec.effective_date BETWEEN NVL(nfa.start_date_active,p_pa_request_rec.effective_date)
	                                             AND NVL(nfa.end_date_active,p_pa_request_rec.effective_date);
  --
    Cursor c_pa_request_extra_info is
       Select *
       from   ghr_pa_request_extra_info
       where  pa_request_id    =  p_pa_request_rec.pa_request_id
       and    information_type =  l_information_type;
-- Bug 3260890
  l_office_symbol per_position_extra_info.poei_information4%type := p_pos_grp1.office_symbol;
  l_organization_structure_id per_position_extra_info.poei_information5%type := p_pos_grp1.organization_structure_id;
  l_positions_organization 	per_position_extra_info.poei_information21%type := p_pos_grp1.positions_organization;
  l_organization_function_code per_position_extra_info.poei_information4%type := p_pos_grp2.organization_function_code;
  l_personnel_office_id per_position_extra_info.poei_information3%type := p_pos_grp1.personnel_office_id;
  l_payroll_office_id ghr_pa_request_extra_info.rei_information4%type := p_pos_grp1.payroll_office_id;
  -- End Bug 3260890

-- Bug# 4672772 Begin

	l_old_user_status			per_assignment_status_types.user_status%type;
	l_old_system_status			per_assignment_status_types.per_system_status%type;
	l_old_effective_start_date  date;
	l_asg_extra_info_rec		per_assignment_extra_info%rowtype;
	l_user_apnt_status			per_assignment_status_types.user_status%type;
	l_user_apnt_eff_date		date;

	Cursor c_user_status is
	select ast.user_status,
         ast.per_system_status,
         asg.effective_start_date
	from
		per_assignment_status_types ast,
		per_all_assignments_f asg
    where	asg.assignment_id = p_pa_request_rec.employee_assignment_id
    and		ast.assignment_status_type_id = asg.assignment_status_type_id
    and     p_pa_request_rec.effective_date
    between asg.effective_start_date
    and     asg.effective_end_date;

	CURSOR	c_user_apnt_status IS
	select 	ast.user_status,asg.effective_start_date
	from	per_assignment_status_types ast,
			per_all_assignments_f asg
	where	ast.assignment_status_type_id = asg.assignment_status_type_id
	and		asg.assignment_id = p_pa_request_rec.employee_assignment_id
	and 	asg.primary_flag = 'Y'
	order by asg.effective_start_date;

-- Bug# 4672772 End
--Begin Bug# 6083404
    l_user_actv_apnt_status			per_assignment_status_types.user_status%type;
    CURSOR c_user_actv_appt IS
    select 	ast.user_status
    from	per_assignment_status_types ast,
            per_all_assignments_f asg
    where	ast.assignment_status_type_id = asg.assignment_status_type_id
    and		asg.assignment_id = p_pa_request_rec.employee_assignment_id
    and 	asg.primary_flag = 'Y'
    and user_status='Active Appointment';
--end Bug# 6083404



--
  --
  -- Declare local procedures and local functions
  --
  -- Procedure  Set_extra_info
  --
  -- This overwrites the value of the core extra information segment with
  -- the value from the SF52 Extra Information entered by the User, along with the Current Request
  --
  Procedure set_extra_info
  (p_hr_extra_info         in out nocopy   varchar2,
   p_ghr_extra_info        in       varchar2,
   p_update_flag           in out nocopy   varchar2,
   p_auto_populate_flag    in       varchar2 default 'N'
  ) is
  Begin
    If nvl(p_hr_extra_info,hr_api.g_varchar2)
       <>  nvl(p_ghr_extra_info,hr_api.g_varchar2) then
       If p_auto_populate_flag = 'Y' and
          l_session.noa_id_correct is null then
          -- since it is autopopulated the user might have made it null
          -- and is not a correction
          p_hr_extra_info   := p_ghr_extra_info;
       else
          If p_ghr_extra_info is not null then
             p_hr_extra_info   := p_ghr_extra_info;
          elsif l_session.noa_id_correct is not null then
            -- VR -- Bug 2356243
            -- In the correction action -- All the extra info considred as auto
            -- populated. Update core with rpa extra info even if rpa extra
            -- info is null
             p_hr_extra_info   := p_ghr_extra_info;
          End if;
       end if;
       p_update_flag      := 'Y';
    End if;

  End set_extra_info;
  --
  --
  Procedure appt_info is
    l_proc     varchar2(70) := 'Process_non_sf52 - App1';
  --
  Begin
    hr_utility.set_location('Entering ' ||l_proc,5);
    hr_utility.set_location('before retr info in appt-info',1);

  -- If a CORRECTION action is being performed, then, we cannot force the User to
  -- enter the Mandatory Items on the SF52, as it might already exist in the Core
  -- Extra Information. In such cases , fetch the value from the CORE Extra information,
  -- if it is null on the SF52 Extra Information.

  -- In case of a correction ,org_app_auth_code1 and 2 will still be read from the
  -- LA Codes 1 and 2 and they have the potential to change it during a CORRECTION.

    If l_session.noa_id_correct is not null then
       set_extra_info(p_per_group1.appointment_type ,
                      l_pa_request_ei_rec.rei_information3,
                      p_per_group1.per_group1_flag);
       set_extra_info(p_per_group1.org_appointment_auth_code1,
                      p_pa_request_rec.first_action_la_code1,
                      p_per_group1.per_group1_flag);
       set_extra_info(p_per_group1.org_appointment_auth_code2,
                      p_pa_request_rec.first_action_la_code2,
                      p_per_group1.per_group1_flag);
       --Bug# 4941984(AFHR2)
       set_extra_info(p_per_group1.org_appointment_desc1,
                      p_pa_request_rec.first_action_la_desc1,
                      p_per_group1.per_group1_flag);
       set_extra_info(p_per_group1.org_appointment_desc2,
                      p_pa_request_rec.first_action_la_desc2,
                      p_per_group1.per_group1_flag);
       --Bug# 4941984(AFHR2)
    Else
      p_per_group1.appointment_type            :=  l_pa_request_ei_rec.rei_information3;
      p_per_group1.Org_appointment_auth_code1  :=  p_pa_request_rec.first_action_la_code1;
      p_per_group1.org_appointment_auth_code2  :=  p_pa_request_rec.first_action_la_code2;
      p_per_group1.org_appointment_desc1       :=  p_pa_request_rec.first_action_la_desc1;
      p_per_group1.org_appointment_desc2       :=  p_pa_request_rec.first_action_la_desc2;
      p_per_group1.per_group1_flag             :=  'Y';
    End if;

    set_extra_info(p_per_uniformed_services.creditable_military_service ,
                   l_pa_request_ei_rec.rei_information4,
                   p_per_uniformed_services.per_uniformed_services_flag, 'Y');
    set_extra_info(p_asg_non_sf52.Date_Arr_Personnel_office,
                   l_pa_request_ei_rec.rei_information5,
                   p_asg_non_sf52.asg_non_sf52_flag, 'Y');
    set_extra_info(p_within_grade_increase.p_date_wgi_due,
                   l_pa_request_ei_rec.rei_information6,
                   p_within_grade_increase.p_wgi_flag, 'N');
    set_extra_info(p_within_grade_increase.p_last_equi_incr,
                   l_pa_request_ei_rec.rei_information18,
                   p_within_grade_increase.p_wgi_flag, 'N');
    set_extra_info(p_per_separate_retire.frozen_service,
                   l_pa_request_ei_rec.rei_information7,
                   p_per_separate_Retire.per_sep_Retire_flag, 'Y' );
    set_extra_info(p_per_group1.handicap_code,
                   l_pa_request_ei_rec.rei_information8,
                   p_per_group1.per_group1_flag, 'Y');
    set_extra_info(p_asg_non_sf52.non_disc_agmt_status,
                   l_pa_request_ei_rec.rei_information9,
                   p_per_group1.per_group1_flag, 'Y');
    set_extra_info(p_asg_non_sf52.parttime_indicator,
                   l_pa_request_ei_rec.rei_information12,
                   p_asg_non_sf52.asg_non_sf52_flag, 'Y');
    set_extra_info(p_pos_grp1.position_working_title,
                   l_pa_request_ei_rec.rei_information13,
                   p_pos_grp1.pos_grp1_flag, 'Y');
    set_extra_info(p_per_separate_retire.prev_retirement_coverage,
                   l_pa_request_ei_rec.rei_information14,
                   p_per_separate_Retire.per_sep_Retire_flag, 'Y' );
    set_extra_info(p_asg_non_sf52.qualification_standard_waiver,
                   l_pa_request_ei_rec.rei_information15,
                   p_asg_non_sf52.asg_non_sf52_flag, 'Y');
    set_extra_info(p_per_group1.race_national_origin,
                   l_pa_request_ei_rec.rei_information16,
                   p_per_group1.per_group1_flag, 'Y');
    set_extra_info(p_per_group1.type_of_employment,
                   l_pa_request_ei_rec.rei_information17,
                   p_per_group1.per_group1_flag, 'Y');
    set_extra_info(p_per_separate_retire.fers_coverage,
                   l_pa_request_ei_rec.rei_information19,
                   p_per_separate_retire.per_sep_retire_flag, 'Y');

   --bug 4443968
    hr_utility.set_location('Creditable service' ||l_pa_request_ei_rec.rei_information23,0000);
    hr_utility.set_location('Populate flag' ||p_per_scd_info.per_scd_info_flag,3333);

  set_extra_info (p_per_scd_info.scd_creditable_svc_annl_leave,
                   l_pa_request_ei_rec.rei_information23,
                   p_per_scd_info.per_scd_info_flag, 'Y');
  hr_utility.set_location('Per Cred leave' ||p_per_scd_info.scd_creditable_svc_annl_leave,4444);
    --
    --
    hr_utility.set_location('Leaving  ' || l_proc,20);

  End appt_info;
  --
  --

  --Begin Bug# 8724192
Procedure appt_transfer_app is
l_proc  varchar2(70) := 'non_sf52_extra_info - appt_transfer_app';

Begin
	hr_utility.set_location('Entering  ' || l_proc,5);
	set_extra_info(p_per_group1.org_appointment_auth_code1,
		nvl(l_pa_request_ei_rec.rei_information1,p_pa_request_rec.first_action_la_code1),p_per_group1.per_group1_flag);
	set_extra_info(p_per_group1.org_appointment_desc1,
		nvl(l_pa_request_ei_rec.rei_information2,p_pa_request_rec.first_action_la_desc1),p_per_group1.per_group1_flag);
	set_extra_info(p_per_group1.org_appointment_auth_code2,
		nvl(l_pa_request_ei_rec.rei_information3,p_pa_request_rec.first_action_la_code2),p_per_group1.per_group1_flag);
	set_extra_info(p_per_group1.org_appointment_desc2,
		nvl(l_pa_request_ei_rec.rei_information4,p_pa_request_rec.first_action_la_desc2),p_per_group1.per_group1_flag);

	hr_utility.set_location('Leaving  ' ||l_proc,20);

End appt_transfer_app;

Procedure mass_transfer_nte is
l_proc  varchar2(70) := 'non_sf52_extra_info - mass_transfer_nte';

Begin
	hr_utility.set_location('Entering  ' || l_proc,5);
	p_asg_nte_dates.asg_nte_dates_flag 	:= 'Y';
	p_asg_nte_dates.asg_nte_start_date := l_pa_request_ei_rec.rei_information10;
	p_asg_nte_dates.assignment_nte := l_pa_request_ei_rec.rei_information11;
	hr_utility.set_location('Leaving  ' ||l_proc,20);

End mass_transfer_nte;
--End Bug# 8724192

  Procedure appt_transfer is
    l_proc  varchar2(70) := 'non_sf52_extra_info - app_3 ';

  Begin
    hr_utility.set_location('Entering  ' || l_proc,5);
    --
    --
    If l_session.noa_id_correct is not null then
       set_extra_info(p_per_group1.agency_code_transfer_from ,
                      l_pa_request_ei_rec.rei_information3, p_per_group1.per_group1_flag);
       set_extra_info(p_per_group1.appointment_type,
                      l_pa_request_ei_rec.rei_information4, p_per_group1.per_group1_flag);
       If p_pa_request_rec.first_noa_code <> '132' then
         set_extra_info(p_per_group1.org_appointment_auth_code1,
                      p_pa_request_rec.first_action_la_code1,p_per_group1.per_group1_flag);
         set_extra_info(p_per_group1.org_appointment_auth_code2,
                      p_pa_request_rec.first_action_la_code2,p_per_group1.per_group1_flag);
         --Bug# 4941984(AFHR2)
         set_extra_info(p_per_group1.org_appointment_desc1,
                      p_pa_request_rec.first_action_la_desc1,p_per_group1.per_group1_flag);
         set_extra_info(p_per_group1.org_appointment_desc2,
                      p_pa_request_rec.first_action_la_desc2,p_per_group1.per_group1_flag);
         --Bug# 4941984(AFHR2)
      End if;
    Else
       p_per_group1.agency_code_transfer_from     :=  l_pa_request_ei_rec.rei_information3;
       p_per_group1.appointment_type              :=  l_pa_request_ei_rec.rei_information4;
       If p_pa_request_rec.first_noa_code <> '132' then
          p_per_group1.org_appointment_auth_code1    :=  p_pa_request_rec.first_action_la_code1;
          p_per_group1.org_appointment_auth_code2    :=  p_pa_request_rec.first_action_la_code2;
          --Bug# 4941984(AFHR2)
          p_per_group1.org_appointment_desc1         :=  p_pa_request_rec.first_action_la_desc1;
          p_per_group1.org_appointment_desc2         :=  p_pa_request_rec.first_action_la_desc2;
          --Bug# 4941984(AFHR2)
       End if;
       p_per_group1.per_group1_flag               :=  'Y';
    End if;
    hr_utility.set_location('cOre CMS ' || p_per_uniformed_services.creditable_military_service,1);
    hr_utility.set_location('REI 7 '  || l_pa_request_ei_rec.rei_information7,2);
    hr_utility.set_location('REI CMS '  || l_pa_request_ei_rec.rei_information6,2);
    set_extra_info(p_per_uniformed_services.creditable_military_service,
                   l_pa_request_ei_rec.rei_information6,
                   p_per_uniformed_services.per_uniformed_services_flag);
   hr_utility.set_location('agency code trans from ' || p_per_group1.agency_code_transfer_from,1);
   hr_utility.set_location('CMS '  || p_per_uniformed_services.creditable_military_service,2);
    set_extra_info(p_asg_non_sf52.Date_Arr_Personnel_office,
                   l_pa_request_ei_rec.rei_information7, p_asg_non_sf52.asg_non_sf52_flag, 'Y');
    set_extra_info(p_within_grade_increase.p_date_wgi_due,
                   l_pa_request_ei_rec.rei_information8, p_within_grade_increase.p_wgi_flag, 'N');
    set_extra_info(p_within_grade_increase.p_last_equi_incr,
                   l_pa_request_ei_rec.rei_information20, p_within_grade_increase.p_wgi_flag, 'N');
    set_extra_info(p_per_separate_retire.frozen_service,
                   l_pa_request_ei_rec.rei_information9, p_per_separate_retire.per_sep_retire_flag, 'Y');
    set_extra_info(p_per_group1.handicap_code,
                   l_pa_request_ei_rec.rei_information10, p_per_group1.per_group1_flag, 'Y');
    set_extra_info(p_asg_non_sf52.non_disc_agmt_status,
                   l_pa_request_ei_rec.rei_information11,p_asg_non_sf52.asg_non_sf52_flag, 'Y');
    set_extra_info(p_asg_non_sf52.parttime_indicator,
                   l_pa_request_ei_rec.rei_information14,p_asg_non_sf52.asg_non_sf52_flag, 'Y');
    set_extra_info(p_pos_grp1.position_working_title,
                   l_pa_request_ei_rec.rei_information15,p_pos_grp1.pos_grp1_flag, 'Y');
    set_extra_info(p_per_separate_retire.prev_retirement_coverage,
                   l_pa_request_ei_rec.rei_information16,p_per_separate_retire.per_sep_retire_flag, 'Y');
    set_extra_info(p_asg_non_sf52.qualification_standard_waiver,
                   l_pa_request_ei_rec.rei_information17,p_asg_non_sf52.asg_non_sf52_flag, 'Y');
    set_extra_info(p_per_group1.race_national_origin,
                   l_pa_request_ei_rec.rei_information18,p_per_group1.per_group1_flag, 'Y');
    set_extra_info(p_per_group1.type_of_employment,
                   l_pa_request_ei_rec.rei_information19,p_per_group1.per_group1_flag, 'Y');
    set_extra_info(p_per_separate_retire.fers_coverage,
                   l_pa_request_ei_rec.rei_information21,
                   p_per_separate_retire.per_sep_retire_flag, 'Y');
    --bug 4443968
    set_extra_info(p_per_scd_info.scd_creditable_svc_annl_leave,
                   l_pa_request_ei_rec.rei_information25, p_per_scd_info.per_scd_info_flag, 'Y');



    hr_utility.set_location('Leaving  ' ||l_proc,20);

  End appt_transfer;
  --

  PROCEDURE appt_benefits IS
    l_proc  varchar2(70);
  BEGIN
    l_proc := 'non sf52 extra - appt_benefits';
	set_extra_info(p_per_benefit_info.FEHB_Date_Eligibility_Expires,
                   l_pa_request_ei_rec.rei_information3,p_per_benefit_info.per_benefit_info_flag, 'Y');
	set_extra_info(p_per_benefit_info.FEHB_Date_temp_eligibility,
                   l_pa_request_ei_rec.rei_information4,p_per_benefit_info.per_benefit_info_flag, 'Y');
	set_extra_info(p_per_benefit_info.FEHB_Date_dependent_cert_expir,
                   l_pa_request_ei_rec.rei_information7,p_per_benefit_info.per_benefit_info_flag, 'Y');
	set_extra_info(p_per_benefit_info.FEGLI_Date_Eligibility_Expires,
                  l_pa_request_ei_rec.rei_information10,p_per_benefit_info.per_benefit_info_flag, 'Y');
	set_extra_info(p_per_scd_info.scd_tsp,
                   l_pa_request_ei_rec.rei_information12,p_per_scd_info.per_scd_info_flag, 'Y');
	set_extra_info(p_per_benefit_info.TSP_Agncy_Contrib_Elig_date,
                   l_pa_request_ei_rec.rei_information17,p_per_benefit_info.per_benefit_info_flag, 'Y');
	set_extra_info(p_per_benefit_info.TSP_Emp_Contrib_Elig_date,
                   l_pa_request_ei_rec.rei_information18,p_per_benefit_info.per_benefit_info_flag, 'Y');


	-- Populating health benefits record group and flag
    p_health_benefits.enrollment       := l_pa_request_ei_rec.rei_information6;
    p_health_benefits.health_plan      := l_pa_request_ei_rec.rei_information5;
    p_health_benefits.temps_total_cost := l_pa_request_ei_rec.rei_information8;
    p_health_benefits.pre_tax_waiver   := l_pa_request_ei_rec.rei_information9;

    if p_health_benefits.enrollment       is not null or
       p_health_benefits.health_plan      is not null or
       p_health_benefits.temps_total_cost is not null or
       p_health_benefits.pre_tax_waiver is not null then
       p_health_benefits.health_benefits_flag := 'Y';
    end if;

	-- Populating TSP record group
	p_thrift_saving_plan.amount           := l_pa_request_ei_rec.rei_information13;
    p_thrift_saving_plan.rate             := l_pa_request_ei_rec.rei_information14;
    p_thrift_saving_plan.status           := l_pa_request_ei_rec.rei_information15;
    p_thrift_saving_plan.status_date      := l_pa_request_ei_rec.rei_information16;
    p_thrift_saving_plan.agncy_contrib_elig_date := l_pa_request_ei_rec.rei_information17;
    p_thrift_saving_plan.emp_contrib_elig_date := l_pa_request_ei_rec.rei_information18;

    if p_thrift_saving_plan.amount           is not null or
       p_thrift_saving_plan.rate             is not null or
       p_thrift_saving_plan.status           is not null or
       p_thrift_saving_plan.status_date      is not null then
       p_thrift_saving_plan.tsp_flag  := 'Y';
    end if;

  END appt_benefits;
  --
  PROCEDURE chg_data_elm is
    l_proc  varchar2(70) := 'non_sf52_extra - chg_data_elm';
  --
  Begin
    hr_utility.set_location('Entering  ' || l_proc,5);

	-- Bug#4126188 begin
	IF NVL(l_pa_request_ei_rec.rei_information3,hr_api.g_varchar2) <>
		NVL(p_pos_grp1.personnel_office_id,hr_api.g_varchar2) THEN
		set_extra_info(p_asg_non_sf52.date_arr_personnel_office,
                   l_pa_request_ei_rec.rei_information5, p_asg_non_sf52.asg_non_sf52_flag, 'Y');
	END IF;
	-- Bug#4126188 End
    set_extra_info(p_pos_grp1.personnel_office_id,
                   l_pa_request_ei_rec.rei_information3, p_pos_grp1.pos_grp1_flag, 'Y');
    hr_utility.set_location('Leaving '||l_proc,20);

  End chg_data_elm;
  --
  --
  Procedure chg_sched_hours is
    l_proc  varchar2(70) := 'non_sf52_extra - chg_hours';

  Begin
    hr_utility.set_location('Entering ' ||l_proc,5);
    set_extra_info(p_per_probations.date_prob_trial_period_begin ,
                   l_pa_request_ei_rec.rei_information3,p_per_probations.per_probation_flag);
    set_extra_info(p_per_probations.date_prob_trial_period_ends  ,
                   l_pa_request_ei_rec.rei_information4,p_per_probations.per_probation_flag);
    set_extra_info(p_within_grade_increase.p_date_wgi_due,
                   l_pa_request_ei_rec.rei_information5,p_within_grade_increase.p_wgi_flag);
    set_extra_info(p_within_grade_increase.p_date_wgi_postpone_effective,
                   l_pa_request_ei_rec.rei_information6,p_within_grade_increase.p_wgi_flag);
    set_extra_info(p_asg_non_sf52.parttime_indicator,l_pa_request_ei_rec.rei_information7,
                   p_asg_non_sf52.asg_non_sf52_flag, 'Y');
  --Added by deenath to fix bug 4542401.
    IF (p_pa_request_rec.first_noa_code  IN ('781','782') OR
        p_pa_request_rec.second_noa_code IN ('781','782')) THEN
       ghr_history_fetch.fetch_element_entry_value
                        (p_element_name          =>  'Within Grade Increase',
                         p_input_value_name      =>  'Last Equivalent Increase',
                         p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
                         p_date_effective        =>  p_pa_request_rec.effective_date,
                         p_screen_entry_value    =>  p_within_grade_increase.p_last_equi_incr);
    END IF;
  --End added by deenath to fix bug 4542401
    hr_utility.set_location('Leaving ' || l_proc,20);

  End chg_sched_hours;
  --
  --
  Procedure chg_ret_plan is
   l_proc        varchar2(70) := 'non_sf52_extra_info - chg_ret_plan';

  Begin
    hr_utility.set_location('Entering ' ||l_proc,5);
    set_extra_info(p_per_uniformed_services.creditable_military_service,
                   l_pa_request_ei_rec.rei_information3,
                   p_per_uniformed_services.per_uniformed_services_flag, 'Y');
    -- Start Bug # 1518650
       p_per_separate_retire.fers_coverage       := l_pa_request_ei_rec.rei_information4;
       p_per_separate_retire.per_sep_retire_flag := 'Y';
    -- End Bug # 1518650
    set_extra_info(p_per_separate_retire.frozen_service,
                   l_pa_request_ei_rec.rei_information5,
                   p_per_separate_Retire.per_sep_Retire_flag, 'Y');
    set_extra_info(p_per_separate_retire.prev_retirement_coverage,
                   l_pa_request_ei_rec.rei_information6,
                   p_per_separate_Retire.per_sep_Retire_flag, 'Y');
    hr_utility.set_location('Leaving  ' || l_proc,20);

  END chg_ret_plan;
  --
  --

  PROCEDURE chg_scd is
     l_proc   varchar2(70)  := 'non_sf52_extra - chg_scd';
   Begin
     hr_utility.set_location('Entering ' ||l_proc,5);
     set_extra_info(p_per_scd_info.scd_rif,l_pa_request_ei_rec.rei_information3,
                    p_per_scd_info.per_scd_info_flag, 'Y');
     set_extra_info(p_per_scd_info.scd_civilian,l_pa_request_ei_rec.rei_information4,
                    p_per_scd_info.per_scd_info_flag, 'Y');
     -- Bug 3675673
     set_extra_info(p_per_scd_info.scd_retirement,l_pa_request_ei_rec.rei_information8,
                    p_per_scd_info.per_scd_info_flag, 'Y');
     -- Bug 3675673
     set_extra_info(p_per_uniformed_services.creditable_military_service ,
                    l_pa_request_ei_rec.rei_information5,
                    p_per_uniformed_services.per_uniformed_services_flag, 'Y');
     set_extra_info(p_per_separate_retire.frozen_service, l_pa_request_ei_rec.rei_information6,
                    p_per_separate_retire.per_sep_retire_flag, 'Y');
     set_extra_info(p_per_separate_retire.prev_retirement_coverage,
                    l_pa_request_ei_rec.rei_information7,
                    p_per_separate_retire.per_sep_retire_flag, 'Y');
     --Pradeep start of the Bug 2146899
	  set_extra_info(p_per_scd_info.scd_tsp,l_pa_request_ei_rec.rei_information9,
                    p_per_scd_info.per_scd_info_flag, 'Y');
     --End of Bug 2146899

	  -- eHRI New Attribution Changes
 	  set_extra_info(p_per_scd_info.scd_ses,l_pa_request_ei_rec.rei_information10,
                    p_per_scd_info.per_scd_info_flag, 'Y');
 	  set_extra_info(p_per_scd_info.scd_spl_retirement,l_pa_request_ei_rec.rei_information11,
                    p_per_scd_info.per_scd_info_flag, 'Y');
	-- End eHRI New Attribution Changes
  --bug 4443968
       set_extra_info (p_per_scd_info.scd_creditable_svc_annl_leave,l_pa_request_ei_rec.rei_information12,
                       p_per_scd_info.per_scd_info_flag, 'Y');


     hr_utility.set_location('Leaving  ' ||l_proc,10);
   End chg_scd;
  --
  --
  Procedure conv_appt is
    l_proc  varchar2(70) := 'non_sf52_extra - conv_1';
  Begin
    hr_utility.set_location('Entering ' ||l_proc,5);
    If l_session.noa_id_correct is not null then
      set_extra_info(p_per_group1.appointment_type,
                     l_pa_request_ei_rec.rei_information3,p_per_group1.per_group1_flag);
      set_extra_info(p_per_group1.org_appointment_auth_code1,
                   p_pa_request_rec.first_action_la_code1,p_per_group1.per_group1_flag);
      set_extra_info(p_per_group1.org_appointment_auth_code2,
                   p_pa_request_rec.first_action_la_code2,p_per_group1.per_group1_flag);
      --Bug# 4941984(AFHR2)
      set_extra_info(p_per_group1.org_appointment_desc1,
              p_pa_request_rec.first_action_la_desc1,p_per_group1.per_group1_flag);
      set_extra_info(p_per_group1.org_appointment_desc2,
              p_pa_request_rec.first_action_la_desc2,p_per_group1.per_group1_flag);
      --Bug# 4941984(AFHR2)

    Else
      p_per_group1.appointment_type           :=   l_pa_request_ei_rec.rei_information3;
      p_per_group1.org_appointment_auth_code1 := p_pa_request_rec.first_action_la_code1;
      p_per_group1.org_appointment_auth_code2 := p_pa_request_rec.first_action_la_code2;
      --Bug# 4941984(AFHR2)
      p_per_group1.org_appointment_desc1      := p_pa_request_rec.first_action_la_desc1;
      p_per_group1.org_appointment_desc2      := p_pa_request_rec.first_action_la_desc2;
      --Bug# 4941984(AFHR2)
      p_per_group1.per_group1_flag            :=  'Y';

    End if;

    set_extra_info(p_per_uniformed_services.creditable_military_service,
                   l_pa_request_ei_rec.rei_information4,
                   p_per_uniformed_services.per_uniformed_services_flag, 'Y');

	-- Begin Bug#4126188
			set_extra_info(p_asg_non_sf52.date_arr_personnel_office,
			l_pa_request_ei_rec.rei_information5,p_asg_non_sf52.asg_non_sf52_flag,'Y');
    -- Bug#4126188 End
   -- set_extra_info(p_asg_non_sf52.Date_Arr_Personnel_office  ,
     --              l_pa_request_ei_rec.rei_information5,p_asg_non_sf52.asg_non_sf52_flag, 'Y');
    set_extra_info(p_per_separate_retire.frozen_service      ,
                   l_pa_request_ei_rec.rei_information6,p_per_separate_Retire.per_sep_Retire_flag, 'Y');
    set_extra_info(p_per_group1.handicap_code                ,
                   l_pa_request_ei_rec.rei_information7,p_per_group1.per_group1_flag, 'Y');
    set_extra_info(p_asg_non_sf52.parttime_indicator         ,
                   l_pa_request_ei_rec.rei_information8,p_asg_non_sf52.asg_non_sf52_flag, 'Y');
    set_extra_info(p_pos_grp1.position_working_title         ,
                   l_pa_request_ei_rec.rei_information9,p_pos_grp1.pos_grp1_flag, 'Y');
    set_extra_info(p_per_separate_retire.prev_retirement_coverage ,
                   l_pa_request_ei_rec.rei_information10,p_per_separate_Retire.per_sep_Retire_flag, 'Y');
    set_extra_info(p_asg_non_sf52.qualification_standard_waiver,
                   l_pa_request_ei_rec.rei_information11,p_asg_non_sf52.asg_non_sf52_flag, 'Y');
    set_extra_info(p_per_group1.race_national_origin,
                   l_pa_request_ei_rec.rei_information12,p_per_group1.per_group1_flag, 'Y');
    set_extra_info(p_per_group1.type_of_employment,
                   l_pa_request_ei_rec.rei_information13,p_per_group1.per_group1_flag, 'Y');
 -- Start Bug 1318341
    set_extra_info(p_within_grade_increase.p_date_wgi_due    ,
                   l_pa_request_ei_rec.rei_information19,p_within_grade_increase.p_wgi_flag);
 -- End Bug 1318341
    set_extra_info(p_within_grade_increase.p_last_equi_incr    ,
                   l_pa_request_ei_rec.rei_information20,p_within_grade_increase.p_wgi_flag);
 -- Start Bug 2165782
    set_extra_info(p_per_separate_retire.fers_coverage,
                   l_pa_request_ei_rec.rei_information21,
                   p_per_separate_retire.per_sep_retire_flag, 'Y');
 -- Start Bug 2165782
    --
    -- the following fields has to be set to the user entered values (null if not entered)
    -- except for corrections for the requirement 'conversion rpa ddf update' - 13-oct-98
    -- Also changed it to not autopopulate
    --
    If l_session.noa_id_correct is not null then
       set_extra_info(p_per_conversions.date_conv_career_begins ,
                      l_pa_request_ei_rec.rei_information14,p_per_conversions.per_conversions_flag,'N');
       set_extra_info(p_per_conversions.date_conv_career_due    ,
                      l_pa_request_ei_rec.rei_information15,p_per_conversions.per_conversions_flag,'N');
       set_extra_info(p_per_conversions.date_recmd_conv_begins  ,
                      l_pa_request_ei_rec.rei_information16,p_per_conversions.per_conversions_flag,'N');
       set_extra_info(p_per_conversions.date_recmd_conv_due     ,
                      l_pa_request_ei_rec.rei_information17,p_per_conversions.per_conversions_flag,'N');
       set_extra_info(p_per_conversions.date_vra_conv_due       ,
                      l_pa_request_ei_rec.rei_information18,p_per_conversions.per_conversions_flag,'N');
    else
       p_per_conversions.date_conv_career_begins := l_pa_request_ei_rec.rei_information14;
       p_per_conversions.date_conv_career_due    := l_pa_request_ei_rec.rei_information15;
       p_per_conversions.date_recmd_conv_begins  := l_pa_request_ei_rec.rei_information16;
       p_per_conversions.date_recmd_conv_due     := l_pa_request_ei_rec.rei_information17;
       p_per_conversions.date_vra_conv_due       := l_pa_request_ei_rec.rei_information18;
       p_per_conversions.per_conversions_flag := 'Y';
    end if;

  --
  /*

  -- The foll.  has been  removed as it is to be calculated in case of a CONV_APP
  --  set_extra_info(p_within_grade_increase.p_date_wgi_due    ,
  --                 l_pa_request_ei_rec.rei_information6,p_within_grade_increase.p_wgi_flag);

  */
    hr_utility.set_location('Leaving ' ||l_proc,10);

  END conv_appt;
  --
  --
  /* Denial WGI */
  --
  Procedure denial_wgi is
    l_proc  varchar2(70) := 'non_sf52_extra - denial_wgi';
  Begin
  --
  --
  -- Updating the record groups with NON SF52
  --
    hr_utility.set_location('Entering ' ||l_proc,5);
    If l_session.noa_id_correct is not null then
      set_extra_info(p_within_grade_increase.p_date_wgi_due,
                     l_pa_request_ei_rec.rei_information3,p_within_grade_increase.p_wgi_flag);
      set_extra_info(p_within_grade_increase.p_date_wgi_postpone_effective,
                     l_pa_request_ei_rec.rei_information4,p_within_grade_increase.p_wgi_flag);
    Else
      p_within_grade_increase.p_date_wgi_due                := l_pa_request_ei_rec.rei_information3;
      p_within_grade_increase.p_date_wgi_postpone_effective := l_pa_request_ei_rec.rei_information4;
      p_within_grade_increase.p_wgi_flag                    :=  'Y';
    End if;

    hr_utility.set_location('Leaving ' ||l_proc,10);

  End denial_wgi;
  --
  --
  Procedure ext_asgn_nte  is
    l_proc   varchar2(70) := 'ext_asgn_nte';
  --
  Begin

  --
  -- Updating the record groups with NON SF52
  --
     hr_utility.set_location('Entering ' ||l_proc,5);
     set_extra_info(p_asg_nte_dates.assignment_nte,
                    l_pa_request_ei_rec.rei_information3,p_asg_nte_dates.asg_nte_dates_flag);
     set_extra_info(p_within_grade_increase.p_date_wgi_due ,
                    l_pa_request_ei_rec.rei_information4,p_within_grade_increase.p_wgi_flag);
     set_extra_info(p_asg_nte_dates.lwp_nte,
                    l_pa_request_ei_rec.rei_information5,p_asg_nte_dates.asg_nte_dates_flag);
     set_extra_info(p_asg_nte_dates.sabatical_nte,
                    l_pa_request_ei_rec.rei_information6,p_asg_nte_dates.asg_nte_dates_flag);
     set_extra_info(p_asg_nte_dates.suspension_nte ,
                    l_pa_request_ei_rec.rei_information7,p_asg_nte_dates.asg_nte_dates_flag);
  --
     hr_utility.set_location('Leaving ' ||l_proc,10);

  End ext_asgn_nte  ;
  --
  --
  Procedure posn_chg is
    l_proc      varchar2(72)  :=  'non_sf52_extra - posn_chg';

  Begin
    hr_utility.set_location('Entering ' ||l_proc,5);
    set_extra_info(p_per_retained_grade.date_from ,
                   l_pa_request_ei_rec.rei_information1,p_per_retained_grade.per_retained_grade_flag);
    set_extra_info(p_per_retained_grade.date_to ,
                   l_pa_request_ei_rec.rei_information2,p_per_retained_grade.per_retained_grade_flag);
    set_extra_info(p_per_retained_grade.retain_grade,
                   l_pa_request_ei_rec.rei_information3,p_per_retained_grade.per_retained_grade_flag);
    set_extra_info(p_per_retained_grade.retain_step_or_rate	,
                   l_pa_request_ei_rec.rei_information4,p_per_retained_grade.per_retained_grade_flag);
    set_extra_info(p_per_retained_grade.retain_pay_plan,
                   l_pa_request_ei_rec.rei_information5,p_per_retained_grade.per_retained_grade_flag);
    set_extra_info(p_per_retained_grade.retain_pay_table_id	,
                   l_pa_request_ei_rec.rei_information6,p_per_retained_grade.per_retained_grade_flag);
    set_extra_info(p_per_retained_grade.retain_locality_percent,
                   l_pa_request_ei_rec.rei_information7,p_per_retained_grade.per_retained_grade_flag);
    set_extra_info(p_per_retained_grade.retain_pay_basis	,
                   l_pa_request_ei_rec.rei_information8,p_per_retained_grade.per_retained_grade_flag);
	-- Begin bug# 4126188
	set_extra_info(p_asg_non_sf52.date_arr_personnel_office,
                   l_pa_request_ei_rec.rei_information15, p_asg_non_sf52.asg_non_sf52_flag, 'Y');
    -- End bug# 4126188
    hr_utility.set_location('Leaving ' ||l_proc,10);

  End posn_chg;
  --
  -- Begin bug# 4126188
  Procedure rg_posn_chg is
    l_proc      varchar2(72)  :=  'non_sf52_extra - rg_posn_chg';
	Begin
		hr_utility.set_location('Entering ' ||l_proc,5);
		set_extra_info(p_asg_non_sf52.date_arr_personnel_office,
		l_pa_request_ei_rec.rei_information15, p_asg_non_sf52.asg_non_sf52_flag, 'Y');
		hr_utility.set_location('Leaving ' ||l_proc,10);
	End rg_posn_chg;
	-- End bug# 4126188

  Procedure salary_change is
    l_proc      varchar2(72)  :=  'non_sf52_extra - salary change';

  Begin
    hr_utility.set_location('Entering ' ||l_proc,5);
    If l_session.noa_id_correct is not null then
      set_extra_info(p_within_grade_increase.p_date_wgi_postpone_effective,
                     l_pa_request_ei_rec.rei_information3,p_within_grade_increase.p_wgi_flag);

--Added for bug 3263140

      set_extra_info(p_within_grade_increase.p_last_equi_incr,
                     l_pa_request_ei_rec.rei_information5,p_within_grade_increase.p_wgi_flag);
-- Bug # 1165309
-- Date Wgi Due should be calculated for GHR_US_PAR_SALARY_CHG
      set_extra_info(p_within_grade_increase.p_date_wgi_due,
                     l_pa_request_ei_rec.rei_information4,p_within_grade_increase.p_wgi_flag);
    Else
      p_within_grade_increase.p_date_wgi_postpone_effective   :=  l_pa_request_ei_rec.rei_information3;
      set_extra_info(p_within_grade_increase.p_date_wgi_due,
                     l_pa_request_ei_rec.rei_information4,p_within_grade_increase.p_wgi_flag);
      set_extra_info(p_within_grade_increase.p_last_equi_incr,
                     l_pa_request_ei_rec.rei_information5,p_within_grade_increase.p_wgi_flag);
      p_within_grade_increase.p_wgi_flag                      := 'Y';
    End if;
	-- Begin Bug#4126188
	IF p_pa_request_rec.first_noa_code in ('702','703','713') OR
		(p_pa_request_rec.first_noa_code = '002' AND p_pa_request_rec.second_noa_code IN ('702','703','713'))THEN
		set_extra_info(p_asg_non_sf52.date_arr_personnel_office,
		l_pa_request_ei_rec.rei_information6,p_asg_non_sf52.asg_non_sf52_flag,'Y');
    END IF;
    -- Bug#4126188 End

  End salary_change;
  --

  PROCEDURE realign is
    l_proc  varchar2(70) := 'non_sf52_extra - realign';

  Begin
    hr_utility.set_location('Entering ' ||l_proc,5);
    set_extra_info(p_asg_non_sf52.Date_Arr_Personnel_office ,
                   l_pa_request_ei_rec.rei_information3,p_asg_non_sf52.asg_non_sf52_flag);

    set_extra_info(p_pos_grp1.payroll_office_id	 	   ,
                   l_pa_request_ei_rec.rei_information4,p_pos_grp1.pos_grp1_flag);
    set_extra_info(p_pos_grp1.personnel_office_id 	   ,
                   l_pa_request_ei_rec.rei_information5,p_pos_grp1.pos_grp1_flag);
    -- Bug#3593584 Added code for Organization_structure_id(This is also known as
    --                                                    OPM Organizational Component)
    set_extra_info(p_pos_grp1.organization_structure_id	   ,
                   l_pa_request_ei_rec.rei_information11,p_pos_grp1.pos_grp1_flag);
    set_extra_info(p_pos_grp1.office_symbol              ,
                   l_pa_request_ei_rec.rei_information6,p_pos_grp1.pos_grp1_flag);
    set_extra_info(p_pos_grp2.organization_function_code ,
                   l_pa_request_ei_rec.rei_information7,p_pos_grp2.pos_grp2_flag);
    set_extra_info(p_pos_grp1.positions_organization 	   ,
                   l_pa_request_ei_rec.rei_information8,p_pos_grp1.pos_grp1_flag);
 --- Bug#2406905
    set_extra_info(p_pos_grp1.organization_structure_id  ,
                   l_pa_request_ei_rec.rei_information11,p_pos_grp1.pos_grp1_flag);

    if l_pa_request_ei_rec.rei_information9 is not null then
       p_pa_request_rec.to_organization_id := l_pa_request_ei_rec.rei_information9;
  -- Rohini added the else part
    else
      p_pa_request_rec.to_organization_id := Null;
    end if;
    -- Bug#3593584 Added the following If condition.
      if l_pa_request_ei_rec.rei_information10 is not null then
         p_pa_request_rec.agency_code := l_pa_request_ei_rec.rei_information10;
      end If;

    hr_utility.set_location('Leaving ' ||l_proc,10);

  End   realign ;
  --
  --
  Procedure reassign is
    l_proc varchar2(70) := 'non_sf52_extra_info - reassign';
  Begin
    hr_utility.set_location('Entering ' ||l_proc,5);
/* -- Commented - Venkat - Bug # 957209 -- 08/06/1999
    set_extra_info(p_asg_non_sf52.key_emer_essential_empl	,
                   l_pa_request_ei_rec.rei_information3,p_asg_non_sf52.asg_non_sf52_flag);
*/
    set_extra_info(p_asg_non_sf52.parttime_indicator		,
                   l_pa_request_ei_rec.rei_information4,p_asg_non_sf52.asg_non_sf52_flag, 'Y');
    set_extra_info(p_pos_grp1.position_working_title 		,
                   l_pa_request_ei_rec.rei_information5,p_pos_grp1.pos_grp1_flag, 'Y');
    set_extra_info(p_asg_non_sf52.qualification_standard_waiver	,
                   l_pa_request_ei_rec.rei_information6,p_asg_non_sf52.asg_non_sf52_flag, 'Y');
   -- Begin Bug#4126188
 	  set_extra_info(p_asg_non_sf52.date_arr_personnel_office,
	   l_pa_request_ei_rec.rei_information7, p_asg_non_sf52.asg_non_sf52_flag, 'Y');
     -- End Bug#4126188
    hr_utility.set_location('Leaving ' ||l_proc,10);

  End   reassign;
  --

  Procedure return_to_duty is
     l_proc      varchar2(70) := 'non_sf52_extra - return_to_duty';

  Begin

     hr_utility.set_location('Entering ' ||l_proc,5);
     set_extra_info(p_per_uniformed_services.creditable_military_service ,
                    l_pa_request_ei_rec.rei_information3,
                    p_per_uniformed_services.per_uniformed_services_flag, 'Y');
     set_extra_info(p_within_grade_increase.p_date_wgi_due ,
                    l_pa_request_ei_rec.rei_information4,p_within_grade_increase.p_wgi_flag, 'N');
     set_extra_info(p_per_separate_retire.frozen_service,
                    l_pa_request_ei_rec.rei_information5,p_per_separate_retire.per_sep_Retire_flag, 'Y');
     set_extra_info(p_asg_non_sf52.non_disc_agmt_status,
                    l_pa_request_ei_rec.rei_information6,p_asg_non_sf52.asg_non_sf52_flag, 'Y');
     set_extra_info(p_asg_non_sf52.parttime_indicator,
                    l_pa_request_ei_rec.rei_information7,p_asg_non_sf52.asg_non_sf52_flag, 'Y');
     set_extra_info(p_per_group1.type_of_employment,
                    l_pa_request_ei_rec.rei_information8,p_per_group1.per_group1_flag, 'Y');	-- Bug 3966783
     hr_utility.set_location('Leaving ' ||l_proc,10);

  End return_to_duty;
  --
  --
  Procedure separate352 is
     l_proc varchar2(70) := 'non_sf52_extra - separate3';

  Begin

    hr_utility.set_location('Entering ' ||l_proc,5);
   hr_utility.set_location('p_per_separate_retire.agency_code_transfer_to = ' ||
                            p_per_separate_retire.agency_code_transfer_to ,10);
	set_extra_info(p_per_separate_retire.agency_code_transfer_to,
                     l_pa_request_ei_rec.rei_information3,p_per_separate_Retire.per_sep_Retire_flag);
   hr_utility.set_location('p_per_separate_retire.agency_code_transfer_to = ' ||
                            p_per_separate_retire.agency_code_transfer_to ,10);
      hr_utility.set_location('Leaving ' ||l_proc,10);

  End separate352 ;
  --
  --
  Procedure recruitment_bonus is
     l_proc  varchar2(70) := 'non_sf52_extra - recruitment_bonus';

  Begin
     hr_utility.set_location('Entering ' ||l_proc,5);
     If l_session.noa_id_correct is not null then
       set_extra_info(p_recruitment_bonus.p_date_recruit_exp,
                      l_pa_request_ei_rec.rei_information3,p_recruitment_bonus.p_recruitment_bonus_flag);
     Else
       p_recruitment_bonus.p_date_recruit_exp        := l_pa_request_ei_rec.rei_information3 ;
       p_recruitment_bonus.p_recruitment_bonus_flag  := 'Y';
       hr_utility.set_location('Leaving ' ||l_proc,10);
     End if;

  End recruitment_bonus;
  --
  --
  Procedure relocation_bonus is
     l_proc  varchar2(70) := 'non_sf52_extra - relocation_bonus';

  Begin
     hr_utility.set_location('Entering ' ||l_proc,5);
     If l_session.noa_id_correct is not null then
       set_extra_info(p_relocation_bonus.p_date_reloc_exp,
                      l_pa_request_ei_rec.rei_information3,p_relocation_bonus.p_relocation_bonus_flag );
     Else
       p_relocation_bonus.p_date_reloc_exp         :=  l_pa_request_ei_rec.rei_information3;
       p_relocation_bonus.p_relocation_bonus_flag  :=  'Y';
     End if;
     hr_utility.set_location('Leaving ' ||l_proc,10);

  End  relocation_bonus;
  --

  Procedure government_awards is
     l_proc varchar2(72) := 'non_sf52_extra - awards_bonus';

  Begin
     --
     -- commented award percentage, as a new column has been added in the
     -- ghr_pa_requests table - 10/08/98
     --
     p_gov_awards.award_agency             :=  l_pa_request_ei_rec.rei_information3;
     p_gov_awards.award_type               :=  l_pa_request_ei_rec.rei_information4;
     p_gov_awards.group_award              :=  l_pa_request_ei_rec.rei_information6;
     p_gov_awards.tangible_benefit_dollars :=  l_pa_request_ei_rec.rei_information7;
     p_gov_awards.date_award_earned        :=  l_pa_request_ei_rec.rei_information9;
-- Bug # 1060184 -- Venkat 03/01/00
     p_gov_awards.award_appropriation_code :=  l_pa_request_ei_rec.rei_information10;
     p_gov_awards.date_exemp_award         :=  l_pa_request_ei_rec.rei_information11;

     hr_utility.set_location('date award -pre ' || p_gov_awards.date_award_earned,2);
     If p_gov_awards.award_agency             is not null or
        p_gov_awards.award_type               is not null or
        p_gov_awards.group_award              is not null or
        p_gov_awards.tangible_benefit_dollars is not null or
        p_gov_awards.date_award_earned        is not null or
        p_pa_request_rec.award_amount         is not null or
        p_gov_awards.award_appropriation_code is not null or
        p_gov_awards.date_exemp_award         is not null then
        p_gov_awards.award_flag := 'Y';

        If l_session.noa_id_correct is not null then -- for correction fetch the existing values
           if p_gov_awards.award_agency is null then
              ghr_history_fetch.fetch_element_entry_value
             (p_element_name          =>  'Federal Awards',
              p_input_value_name      =>  'Award Agency',
              p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
              p_date_effective        =>  p_pa_request_rec.effective_date,
              p_screen_entry_value    =>  p_gov_awards.award_agency
              );
           end if;
           if p_gov_awards.award_type is null then
              ghr_history_fetch.fetch_element_entry_value
             (p_element_name          =>  'Federal Awards',
              p_input_value_name      =>  'Award Type',
              p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
              p_date_effective        =>  p_pa_request_rec.effective_date,
              p_screen_entry_value    =>  p_gov_awards.award_type
              );
           end if;
           if p_gov_awards.group_award is null then
              ghr_history_fetch.fetch_element_entry_value
              (p_element_name          =>  'Federal Awards',
               p_input_value_name      =>  'Group Award',
               p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
               p_date_effective        =>  p_pa_request_rec.effective_date,
               p_screen_entry_value    =>  p_gov_awards.group_award
               );
           end if;
           if p_gov_awards.tangible_benefit_dollars is null then
              ghr_history_fetch.fetch_element_entry_value
              (p_element_name          =>  'Federal Awards',
               p_input_value_name      =>  'Tangible Benefit Dollars',
               p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
               p_date_effective        =>  p_pa_request_rec.effective_date,
               p_screen_entry_value    =>  p_gov_awards.tangible_benefit_dollars
               );
           end if;
           if p_gov_awards.date_award_earned is null then
              ghr_history_fetch.fetch_element_entry_value
             (p_element_name          =>  'Federal Awards',
              p_input_value_name      =>  'Date Award Earned',
              p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
              p_date_effective        =>  p_pa_request_rec.effective_date,
              p_screen_entry_value    =>  p_gov_awards.date_award_earned
              );
           end if;
           if p_gov_awards.award_appropriation_code is null then
              ghr_history_fetch.fetch_element_entry_value
             (p_element_name          =>  'Federal Awards',
              p_input_value_name      =>  'Appropriation Code',
              p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
              p_date_effective        =>  p_pa_request_rec.effective_date,
              p_screen_entry_value    =>  p_gov_awards.award_appropriation_code
              );
           end if;
/*
           -- Bug 2835929 Allow date_exemp_award to be updated to null.
           if p_gov_awards.date_exemp_award is null then
              ghr_history_fetch.fetch_element_entry_value
             (p_element_name          =>  'Federal Awards',
              p_input_value_name      =>  'Date Ex Emp Award Paid',
              p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
              p_date_effective        =>  p_pa_request_rec.effective_date,
              p_screen_entry_value    =>  p_gov_awards.date_exemp_award
              );
           end if;
*/
        end if;
     End if;
  End government_awards;
  --
  -- Bug#4486823 RRR Changes Added procedures service_obligation,incentive_retention.
  Procedure service_obligation is
     l_proc  varchar2(70) := 'non_sf52_extra - service_obligation';

  Begin
     hr_utility.set_location('Entering ' ||l_proc,5);
     If l_session.noa_id_correct is null then
       --6510320 Added the if condition of not creating the service obligation entry
       --in person EI if all the segments are null
       If  l_pa_request_ei_rec.rei_information3 is not null or
           l_pa_request_ei_rec.rei_information4 is not null or
	   l_pa_request_ei_rec.rei_information5 is not null then
         p_per_service_oblig.service_oblig_type_code  := l_pa_request_ei_rec.rei_information3;
         p_per_service_oblig.service_oblig_start_date := l_pa_request_ei_rec.rei_information4;
         p_per_service_oblig.service_oblig_end_date   := l_pa_request_ei_rec.rei_information5;
         p_per_service_oblig.per_service_oblig_flag   := 'Y';
       End If;
       hr_utility.set_location('Leaving ' ||l_proc,10);
     End if;

  End service_obligation;
  --
  --
  Procedure incentive_retention is
     l_proc  varchar2(70) := 'non_sf52_extra - incentive_retention';

  Begin
     hr_utility.set_location('Entering ' ||l_proc,5);
      If l_session.noa_id_correct is not null then
       set_extra_info(p_per_group1.retention_inc_review_date ,
                      l_pa_request_ei_rec.rei_information3,
                      p_per_group1.per_group1_flag);
    Else
      p_per_group1.retention_inc_review_date   :=  l_pa_request_ei_rec.rei_information3;
    End if;
    p_per_group1.per_group1_flag             :=  'Y';
  End incentive_retention;
  --  -- Bug#4486823 RRR Changes
  --
  Procedure non_pay_duty_status is
    l_proc                varchar2(72) := 'non_pay_duty_status';
    l_special_info_type   ghr_api.special_information_type;

  Begin
    set_extra_info(p_per_group1.type_of_employment,
                   l_pa_request_ei_rec.rei_information3,p_per_group1.per_group1_flag, 'Y');
    p_conduct_performance.adverse_action_noac        :=   l_pa_request_ei_rec.rei_information4;
    p_conduct_performance.cause_of_disc_action       :=   l_pa_request_ei_rec.rei_information5;
    p_conduct_performance.date_of_adverse_action     :=   l_pa_request_ei_rec.rei_information6;
    p_conduct_performance.days_suspended             :=   l_pa_request_ei_rec.rei_information7;
    p_conduct_performance.date_suspension_over_30    :=   l_pa_request_ei_rec.rei_information8;
    p_conduct_performance.date_suspension_under_30   :=   l_pa_request_ei_rec.rei_information9;
    p_conduct_performance.pip_action_taken           :=   l_pa_request_ei_rec.rei_information10;
    p_conduct_performance.pip_begin_date             :=   l_pa_request_ei_rec.rei_information11;
    p_conduct_performance.pip_end_date               :=   l_pa_request_ei_rec.rei_information12;
    p_conduct_performance.pip_extensions             :=   l_pa_request_ei_rec.rei_information13;
    p_conduct_performance.pip_length                 :=   l_pa_request_ei_rec.rei_information14;
    p_conduct_performance.date_reprimand_expires     :=   l_pa_request_ei_rec.rei_information15;

    hr_utility.set_location('non_pay_duty_status ', 20);
    -- If atleast one of the  above is not null , then set the flag to 'Y'

    If p_conduct_performance.adverse_action_noac      is not null or
       p_conduct_performance.cause_of_disc_action     is not null or
       p_conduct_performance.date_of_adverse_action   is not null or
       p_conduct_performance.days_suspended           is not null or
       p_conduct_performance.date_suspension_over_30  is not null or
       p_conduct_performance.date_suspension_under_30 is not null or
       p_conduct_performance.pip_action_taken         is not null or
       p_conduct_performance.pip_begin_date    		is not null or
       p_conduct_performance.pip_end_date       	is not null or
       p_conduct_performance.pip_extensions     	is not null or
       p_conduct_performance.pip_length        		is not null or
       p_conduct_performance.date_reprimand_expires	is not null then
       p_conduct_performance.cond_perf_flag         :=   'Y';
       hr_utility.set_location('non_pay_duty_status ', 25);
    End if;

    if l_session.noa_id_correct is not null then
       hr_utility.set_location('non_pay_duty_status ', 30);

       ghr_history_fetch.return_special_information
         (p_person_id         =>  p_pa_request_rec.person_id,
          p_structure_name    =>  'US Fed Conduct Perf',
          p_effective_date    =>  p_pa_request_rec.effective_date,
          p_special_info      =>  l_special_info_type
          );

       hr_utility.set_location('non_pay_duty_status :person analysis id '||l_special_info_type.person_analysis_id, 31);
       hr_utility.set_location('non_pay_duty_status :ovn '||l_special_info_type.object_version_number, 32);
       hr_utility.set_location('non_pay_duty_status :segment1 '||l_special_info_type.segment1, 33);
       hr_utility.set_location('non_pay_duty_status :segment2 '||l_special_info_type.segment2, 34);
       hr_utility.set_location('non_pay_duty_status :segment3 '||l_special_info_type.segment3, 35);
       hr_utility.set_location('non_pay_duty_status :segment4 '||l_special_info_type.segment4, 36);
       hr_utility.set_location('non_pay_duty_status :segment5 '||l_special_info_type.segment5, 37);
       hr_utility.set_location('non_pay_duty_status :segment6 '||l_special_info_type.segment6, 38);
       hr_utility.set_location('non_pay_duty_status :segment7 '||l_special_info_type.segment7, 39);

       p_conduct_performance.person_analysis_id         :=   l_special_info_type.person_analysis_id;
       p_conduct_performance.object_version_number      :=   l_special_info_type.object_version_number;
       if p_conduct_performance.cause_of_disc_action is null then
          p_conduct_performance.cause_of_disc_action    :=   l_special_info_type.segment1;
       end if;
       if p_conduct_performance.date_of_adverse_action is null then
          p_conduct_performance.date_of_adverse_action  :=   l_special_info_type.segment2;
       end if;
       if p_conduct_performance.days_suspended is null then
          p_conduct_performance.days_suspended          :=   l_special_info_type.segment3;
       end if;
       if p_conduct_performance.date_suspension_over_30 is null then
          p_conduct_performance.date_suspension_over_30 :=   l_special_info_type.segment4;
       end if;
       if p_conduct_performance.date_suspension_under_30 is null then
          p_conduct_performance.date_suspension_under_30 :=   l_special_info_type.segment5;
       end if;
       if p_conduct_performance.pip_action_taken is null then
          p_conduct_performance.pip_action_taken         :=   l_special_info_type.segment6;
       end if;
       if p_conduct_performance.pip_begin_date is null then
          p_conduct_performance.pip_begin_date          :=   l_special_info_type.segment7;
       end if;
       if p_conduct_performance.pip_end_date is null then
          p_conduct_performance.pip_end_date            :=   l_special_info_type.segment8;
       end if;
       if p_conduct_performance.pip_extensions is null then
          p_conduct_performance.pip_extensions          :=   l_special_info_type.segment9;
       end if;
       if p_conduct_performance.pip_length is null then
          p_conduct_performance.pip_length              :=   l_special_info_type.segment10;
       end if;
       if p_conduct_performance.date_reprimand_expires is null then
          p_conduct_performance.date_reprimand_expires  :=   l_special_info_type.segment11;
       end if;
       if p_conduct_performance.adverse_action_noac is null then
          p_conduct_performance.adverse_action_noac     :=   l_special_info_type.segment12;
       end if;

    end if;
    hr_utility.set_location('non_pay_duty_status ', 40);

  End non_pay_duty_status;
  --
  --
  Procedure lwop_info is
    l_proc                varchar2(72) := 'lwop_info';

  Begin
     --
     set_extra_info(p_per_group1.type_of_employment,
                    l_pa_request_ei_rec.rei_information3,
                    p_per_group1.per_group1_flag,
                    'Y'  );
     --
  End;
  --
  --
  Function fetch_extra_info_id (p_request_id number)
  return number is
     CURSOR c2 (c_request_id number) is
            SELECT  par.pa_request_id, par.altered_pa_request_id, pei.rei_information3
            FROM    ghr_pa_requests par, ghr_pa_request_extra_info pei
            WHERE   par.pa_request_id     = pei.pa_request_id(+)
              AND   pei.pa_request_id     = c_request_id
              AND   pei.information_type  = 'GHR_US_PAR_TERM_RET_GRADE';

     l_request_id         ghr_pa_requests.pa_request_id%type;
     l_extra_info_id      per_people_extra_info.person_extra_info_id%type;

  begin
     l_request_id := p_request_id;
     loop
        for c2_rec in c2(l_request_id) loop
            hr_utility.set_location('inside fetch extra info id loop',1);
            if c2_rec.rei_information3 is not null then
               l_extra_info_id := c2_rec.rei_information3;
            else
               l_request_id := c2_rec.pa_request_id;
            end if;
         end loop;
         if l_extra_info_id is not null then
            exit;
         end if;
      end loop;
      hr_utility.set_location('Leaving fetch extra_info_id',1);
      return(l_extra_info_id);
  end fetch_extra_info_id;
  --
  --
  Procedure term_retained_grade is
     CURSOR c1 (p_pei_id number) is
            SELECT  person_extra_info_id, object_version_number
            FROM    per_people_extra_info
            WHERE   person_extra_info_id = p_pei_id;

     l_proc                      varchar2(72)  :=  'non_sf52_extra - sss';
     l_per_extra_info_rec        per_people_extra_info%rowtype;
     l_person_extra_info_id      per_people_extra_info.person_extra_info_id%type;
     l_result_code               varchar2(100);

  Begin
     -- If it is a termination of retention grade , let us nullify all the entries in the per_retained_grade

        if l_pa_request_ei_rec.rei_information3 is null then
           -- errors out during the required check
           null;
        elsif l_pa_request_ei_rec.rei_information3 is not null  then
            -- fetch the ovn, set flag to Y
           for c1_rec in c1(l_pa_request_ei_rec.rei_information3) loop
               p_per_retained_grade.person_extra_info_id    :=  c1_rec.person_extra_info_id;
               hr_utility.set_location('RG 866 - set pei id',1);
             If l_session.noa_id_correct is null then
               p_per_retained_grade.object_version_number   :=  c1_rec.object_version_number;
               hr_utility.set_location('non correction -- RG 866',1);
               p_per_retained_grade.per_retained_grade_flag :=  'Y';
             end if;
           end loop;
        end if;


     hr_utility.set_location('leaving par term ret gr',1);

  End term_retained_grade;
  --
  --
  Procedure quality_step_increase is
     l_proc varchar2(72) := 'non_sf52_extra - quality_step_increase';

  Begin

     p_gov_awards.award_agency             :=  l_pa_request_ei_rec.rei_information3;
     p_gov_awards.award_type               :=  '07';
-- Venkat -- Bug #982677 -- Previously referring trunc
     p_gov_awards.date_award_earned        :=  fnd_date.date_to_canonical(p_pa_request_rec.effective_date);

     If l_session.noa_id_correct is null then
        p_gov_awards.award_flag := 'Y';
     elsIf l_session.noa_id_correct is not null and  -- for correction fetch the existing values
        p_gov_awards.award_agency is not null then
        p_gov_awards.award_flag := 'Y';
     end if;
  end quality_step_increase;
  --
  --
  --
  Procedure  entitlement is
    l_proc        varchar2(70) := 'non_sf52_extra_info - entitlement';

  Begin
    --
    hr_utility.set_location('Entering ' ||l_proc,5);
    --
    p_entitlement.entitlement_code        := l_pa_request_ei_rec.rei_information3;
    p_entitlement.entitlement_amt_percent := l_pa_request_ei_rec.rei_information4;
    --Venkat 05/00 -- Bug# 1140536
    hr_utility.set_location('entitlement code is '||p_entitlement.entitlement_code ||l_proc,6);
    if nvl(p_entitlement.entitlement_code,hr_api.g_varchar2) = '9'
      and substr(nvl(p_pa_request_rec.duty_station_code,hr_api.g_varchar2),1,2)
      not in ('02','15','AQ','CQ','DQ',
              'FQ','GQ','HQ','JQ','KQ',
              'LQ','MQ','RQ','VQ','WQ') then
       hr_utility.set_message(8301,'GHR_38030_INV_DS_4_NON_F_COLA');
       hr_utility.raise_error;
    end if;
    if nvl(p_entitlement.entitlement_code,hr_api.g_varchar2) = 'C'
      and substr(nvl(p_pa_request_rec.duty_station_code,hr_api.g_varchar2),1,2)
       in ('02','15','AQ','CQ','DQ',
              'FQ','GQ','HQ','JQ','KQ',
              'LQ','MQ','RQ','VQ','WQ') then
       hr_utility.set_message(8301,'GHR_38032_INV_DS_4_COLA');
       hr_utility.raise_error;
    end if;
    if p_entitlement.entitlement_code        is not null or
       p_entitlement.entitlement_amt_percent is not null then
       p_entitlement.entitlement_flag := 'Y';
    end if;
    If l_session.noa_id_correct is not null then -- for correction fetch the existing values
       if p_entitlement.entitlement_code is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Entitlement',
           p_input_value_name      =>  'Code',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_entitlement.entitlement_code
          );
       end if;
       if p_entitlement.entitlement_amt_percent is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Entitlement',
           p_input_value_name      =>  'Amount or Percent',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_entitlement.entitlement_amt_percent
          );
       end if;
    end if;
    --
    hr_utility.set_location('Leaving ' ||l_proc,5);
    --
  END entitlement;
  --
  --
  Procedure for_lang_pay is
    l_proc        varchar2(70) := 'non_sf52_extra_info - for_lang_pay';
  Begin
    --
    hr_utility.set_location('Entering ' ||l_proc,5);
    --
    p_foreign_lang_prof_pay.certification_date := l_pa_request_ei_rec.rei_information3;
    p_foreign_lang_prof_pay.pay_level_or_rate  := l_pa_request_ei_rec.rei_information4;
    if p_foreign_lang_prof_pay.certification_date is not null or
       p_foreign_lang_prof_pay.pay_level_or_rate  is not null then
       p_foreign_lang_prof_pay.for_lang_flag := 'Y';
    end if;
    If l_session.noa_id_correct is not null then -- for correction fetch the existing values
       if p_foreign_lang_prof_pay.certification_date is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Foreign Lang Proficiency Pay',
           p_input_value_name      =>  'Certification Date',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_foreign_lang_prof_pay.certification_date
          );
       end if;
       if p_foreign_lang_prof_pay.pay_level_or_rate is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Foreign Lang Proficiency Pay',
           p_input_value_name      =>  'Pay Level or Rate',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_foreign_lang_prof_pay.pay_level_or_rate
          );
       end if;
    end if;
    --
    hr_utility.set_location('Leaving ' ||l_proc,5);
    --
  END for_lang_pay;
  --
  Procedure fta is
    l_proc        varchar2(70) := 'non_sf52_extra_info - fta';
  Begin
    --
    hr_utility.set_location('Entering ' ||l_proc,5);
    --
    p_imm_fta.last_action_code := l_pa_request_ei_rec.rei_information3;
    p_imm_fta.number_family_members := l_pa_request_ei_rec.rei_information4;
    p_imm_fta.Miscellaneous_Expense:= l_pa_request_ei_rec.rei_information5;
    p_imm_fta.Wardrobe_Expense := l_pa_request_ei_rec.rei_information6;
    p_imm_fta.Pre_Departure_Subs_Expense := l_pa_request_ei_rec.rei_information7;
    p_imm_fta.Lease_Penalty_Expense := l_pa_request_ei_rec.rei_information8;
    p_imm_fta.amount := l_pa_request_ei_rec.rei_information9;
    if p_imm_fta.last_action_code is not null or
       p_imm_fta.number_family_members  is not null or
       p_imm_fta.Miscellaneous_Expense is not null or
       p_imm_fta.Wardrobe_Expense is not null or
       p_imm_fta.Pre_Departure_Subs_Expense is not null or
       p_imm_fta.Lease_Penalty_Expense is not null or
       p_imm_fta.amount is not null then
       p_imm_fta.fta_flag := 'Y';
    end if;

  End fta;
  --
  --
  Procedure edp_pay is
    l_proc        varchar2(70) := 'non_sf52_extra_info - edp_pay';
  Begin
    --
    hr_utility.set_location('Entering ' ||l_proc,5);
    --
    p_edp_pay.premium_pay_indicator := l_pa_request_ei_rec.rei_information3;
    p_edp_pay.edp_type              := l_pa_request_ei_rec.rei_information4;
    if p_edp_pay.premium_pay_indicator is not null or
       p_edp_pay.edp_type              is not null then
       p_edp_pay.edp_flag := 'Y';
    end if;
    If l_session.noa_id_correct is not null then -- for correction fetch the existing values
       if p_edp_pay.premium_pay_indicator is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'EDP Pay',
           p_input_value_name      =>  'Premium Pay Ind',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_edp_pay.premium_pay_indicator
          );
       end if;
       if p_edp_pay.edp_type is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'EDP Pay',
           p_input_value_name      =>  'EDP Type',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_edp_pay.edp_type
          );
       end if;
    end if;
    --
    hr_utility.set_location('Leaving ' ||l_proc,5);
    --
  END edp_pay;
  --
  --
  Procedure hazard_pay is
    l_proc        varchar2(70) := 'non_sf52_extra_info - hazard_pay';
  Begin
    --
    hr_utility.set_location('Entering ' ||l_proc,5);
    --
    p_hazard_pay.premium_pay_indicator := l_pa_request_ei_rec.rei_information3;
    p_hazard_pay.hazard_type           := l_pa_request_ei_rec.rei_information4;
    if p_hazard_pay.premium_pay_indicator is not null or
       p_hazard_pay.hazard_type           is not null then
       p_hazard_pay.hazard_flag := 'Y';
    end if;
    If l_session.noa_id_correct is not null then -- for correction fetch the existing values
       if p_hazard_pay.premium_pay_indicator is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Hazard Pay',
           p_input_value_name      =>  'Premium Pay Ind',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_hazard_pay.premium_pay_indicator
          );
       end if;
       if p_hazard_pay.hazard_type is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Hazard Pay',
           p_input_value_name      =>  'Hazard Type',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_hazard_pay.hazard_type
          );
       end if;
    end if;
    --
    hr_utility.set_location('Leaving ' ||l_proc,10);
    --
  END hazard_pay;
  --
  --
  Procedure health_benefits is
    l_proc        varchar2(70) := 'non_sf52_extra_info - health_benefits';
  Begin
    --
    hr_utility.set_location('Entering ' ||l_proc,5);
    --
    p_health_benefits.enrollment       := l_pa_request_ei_rec.rei_information3;
    p_health_benefits.health_plan      := l_pa_request_ei_rec.rei_information4;
    p_health_benefits.temps_total_cost := l_pa_request_ei_rec.rei_information5;
    p_health_benefits.pre_tax_waiver := l_pa_request_ei_rec.rei_information6;
    if p_health_benefits.enrollment       is not null or
       p_health_benefits.health_plan      is not null or
       p_health_benefits.temps_total_cost is not null or
       p_health_benefits.pre_tax_waiver is not null then
       p_health_benefits.health_benefits_flag := 'Y';
    end if;
    If l_session.noa_id_correct is not null then -- for correction fetch the existing values
       if p_health_benefits.enrollment is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Health Benefits',
           p_input_value_name      =>  'Enrollment',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_health_benefits.enrollment
          );
       end if;
       if p_health_benefits.health_plan is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Health Benefits',
           p_input_value_name      =>  'Health Plan',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_health_benefits.health_plan
          );
       end if;
       if p_health_benefits.temps_total_cost is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Health Benefits',
           p_input_value_name      =>  'Temps Total Cost',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_health_benefits.temps_total_cost
          );
       end if;
       if p_health_benefits.pre_tax_waiver is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Health Benefits',
           p_input_value_name      =>  'Pre tax Waiver',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_health_benefits.pre_tax_waiver
          );
       end if;
    end if;
    --
    hr_utility.set_location('Leaving ' ||l_proc,5);
    --
  END health_benefits;
  --
  --
  Procedure health_ben_pre_tax is
    l_proc        varchar2(70) := 'non_sf52_extra_info - health_ben_pre_tax';
  Begin
    --
    hr_utility.set_location('Entering ' ||l_proc,5);
    --
    p_health_ben_pre_tax.enrollment       := l_pa_request_ei_rec.rei_information3;
    p_health_ben_pre_tax.health_plan      := l_pa_request_ei_rec.rei_information4;
    p_health_ben_pre_tax.temps_total_cost := l_pa_request_ei_rec.rei_information5;
    if p_health_ben_pre_tax.enrollment       is not null or
       p_health_ben_pre_tax.health_plan      is not null or
       p_health_ben_pre_tax.temps_total_cost is not null then
       p_health_ben_pre_tax.health_ben_pre_tax_flag := 'Y';
    end if;
    If l_session.noa_id_correct is not null then -- for correction fetch the existing values
       if p_health_ben_pre_tax.enrollment is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Health Benefits Pre tax',
           p_input_value_name      =>  'Enrollment',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_health_ben_pre_tax.enrollment
          );
       end if;
       if p_health_ben_pre_tax.health_plan is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Health Benefits Pre tax',
           p_input_value_name      =>  'Health Plan',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_health_ben_pre_tax.health_plan
          );
       end if;
       if p_health_ben_pre_tax.temps_total_cost is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Health Benefits Pre Tax',
           p_input_value_name      =>  'Temps Total Cost',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_health_ben_pre_tax.temps_total_cost
          );
       end if;
    end if;
    --
    hr_utility.set_location('Leaving ' ||l_proc,5);
    --
  END health_ben_pre_tax;
  --
  Procedure danger_pay is
    l_proc        varchar2(70) := 'non_sf52_extra_info - danger_pay';
  Begin
    --
    hr_utility.set_location('Entering ' ||l_proc,5);
    --
    p_danger_pay.last_action_code   := l_pa_request_ei_rec.rei_information3;
    p_danger_pay.location           := l_pa_request_ei_rec.rei_information4;
    if p_danger_pay.last_action_code    is not null or
       p_danger_pay.location            is not null then
       p_danger_pay.danger_flag := 'Y';
    end if;
    If l_session.noa_id_correct is not null then -- for correction fetch the existing values
       if p_danger_pay.last_action_code is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Danger Pay',
           p_input_value_name      =>  'Last Action Code',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_danger_pay.last_action_code
          );
       end if;
       if p_danger_pay.location is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Danger Pay',
           p_input_value_name      =>  'Location',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_danger_pay.location
          );
       end if;
    end if;
    --
    hr_utility.set_location('Leaving ' ||l_proc,5);
    --
  END danger_pay;
  --
  --
  Procedure imminent_danger_pay is
    l_proc        varchar2(70) := 'non_sf52_extra_info - imminent_danger_pay';
  Begin
    --
    hr_utility.set_location('Entering ' ||l_proc,5);
    --
    p_imminent_danger_pay.amount             := l_pa_request_ei_rec.rei_information3;
    p_imminent_danger_pay.location           := l_pa_request_ei_rec.rei_information4;
    p_imminent_danger_pay.last_action_code   := l_pa_request_ei_rec.rei_information5;
    if p_imminent_danger_pay.amount             is not null or
       p_imminent_danger_pay.last_action_code   is not null or
       p_imminent_danger_pay.location           is not null  then
       p_imminent_danger_pay.imminent_danger_flag := 'Y';
    end if;
    If l_session.noa_id_correct is not null then -- for correction fetch the existing values
       if p_imminent_danger_pay.amount is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Imminent Danger Pay',
           p_input_value_name      =>  'Amount',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_imminent_danger_pay.amount
          );
       end if;
       if p_imminent_danger_pay.last_action_code is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Imminent Danger Pay',
           p_input_value_name      =>  'Last Action Code',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_imminent_danger_pay.last_action_code
          );
       end if;
       if p_imminent_danger_pay.location is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Imminent Danger Pay',
           p_input_value_name      =>  'Location',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_imminent_danger_pay.location
          );
       end if;
    end if;
    --
    hr_utility.set_location('Leaving ' ||l_proc,5);
    --
  END imminent_danger_pay;
  --
  --
  Procedure living_quarters_allow is
    l_proc        varchar2(70) := 'non_sf52_extra_info - living_quarters_allow';
  Begin
    --
    hr_utility.set_location('Entering ' ||l_proc,5);
    --
    p_living_quarters_allow.purchase_amount      := l_pa_request_ei_rec.rei_information3;
    p_living_quarters_allow.purchase_date        := l_pa_request_ei_rec.rei_information4;
    p_living_quarters_allow.rent_amount          := l_pa_request_ei_rec.rei_information5;
    p_living_quarters_allow.utility_amount       := l_pa_request_ei_rec.rei_information6;
    p_living_quarters_allow.last_action_code     := l_pa_request_ei_rec.rei_information7;
    p_living_quarters_allow.location             := l_pa_request_ei_rec.rei_information8;
    p_living_quarters_allow.quarters_type        := l_pa_request_ei_rec.rei_information9;
    p_living_quarters_allow.shared_percent       := l_pa_request_ei_rec.rei_information10;
    p_living_quarters_allow.no_of_family_members := l_pa_request_ei_rec.rei_information11;
    p_living_quarters_allow.summer_record_ind    := l_pa_request_ei_rec.rei_information12;
    p_living_quarters_allow.quarters_group       := l_pa_request_ei_rec.rei_information13;
    p_living_quarters_allow.currency             := l_pa_request_ei_rec.rei_information14;

    if p_living_quarters_allow.purchase_amount      is not null or
       p_living_quarters_allow.purchase_date        is not null or
       p_living_quarters_allow.rent_amount          is not null or
       p_living_quarters_allow.utility_amount       is not null or
       p_living_quarters_allow.last_action_code     is not null or
       p_living_quarters_allow.location             is not null or
       p_living_quarters_allow.quarters_type        is not null or
       p_living_quarters_allow.shared_percent       is not null or
       p_living_quarters_allow.no_of_family_members is not null or
       p_living_quarters_allow.summer_record_ind    is not null or
       p_living_quarters_allow.quarters_group       is not null or
       p_living_quarters_allow.currency             is not null then
       p_living_quarters_allow.living_quarters_allow_flag := 'Y';
    end if;

    If l_session.noa_id_correct is not null then -- for correction fetch the existing values
       if p_living_quarters_allow.purchase_amount is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Living Quarters Allowance',
           p_input_value_name      =>  'Purchase Amount',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_living_quarters_allow.purchase_amount
          );
       end if;
       if p_living_quarters_allow.purchase_date is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Living Quarters Allowance',
           p_input_value_name      =>  'Purchase Date',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_living_quarters_allow.purchase_date
          );
       end if;
       if p_living_quarters_allow.rent_amount is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Living Quarters Allowance',
           p_input_value_name      =>  'Rent Amount',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_living_quarters_allow.rent_amount
          );
       end if;
       if p_living_quarters_allow.utility_amount is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Living Quarters Allowance',
           p_input_value_name      =>  'Utility Amount',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_living_quarters_allow.utility_amount
          );
       end if;
       if p_living_quarters_allow.last_action_code is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Living Quarters Allowance',
           p_input_value_name      =>  'Last Action Code',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_living_quarters_allow.last_action_code
          );
       end if;
       if p_living_quarters_allow.location is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Living Quarters Allowance',
           p_input_value_name      =>  'Location',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_living_quarters_allow.location
          );
       end if;
       if p_living_quarters_allow.quarters_type is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Living Quarters Allowance',
           p_input_value_name      =>  'Quarters Type',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_living_quarters_allow.quarters_type
          );
       end if;
       if p_living_quarters_allow.shared_percent is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Living Quarters Allowance',
           p_input_value_name      =>  'Shared Percent',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_living_quarters_allow.shared_percent
          );
       end if;
       if p_living_quarters_allow.no_of_family_members is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Living Quarters Allowance',
           p_input_value_name      =>  'No. Family Members',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_living_quarters_allow.no_of_family_members
          );
       end if;
       if p_living_quarters_allow.summer_record_ind is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Living Quarters Allowance',
           p_input_value_name      =>  'Summer Record Ind',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_living_quarters_allow.summer_record_ind
          );
       end if;
       if p_living_quarters_allow.quarters_group is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Living Quarters Allowance',
           p_input_value_name      =>  'Quarters Group',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_living_quarters_allow.quarters_group
          );
       end if;
       if p_living_quarters_allow.currency is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Living Quarters Allowance',
           p_input_value_name      =>  'Currency',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_living_quarters_allow.currency
          );
       end if;
    end if;
    --
    hr_utility.set_location('Leaving ' ||l_proc,5);
    --
  END living_quarters_allow;
  --
  --
  Procedure post_diff_amt is
    l_proc        varchar2(70) := 'non_sf52_extra_info - post_diff_amt';
  Begin
    --
    hr_utility.set_location('Entering ' ||l_proc,5);
    --
    p_post_diff_amt.amount               := l_pa_request_ei_rec.rei_information3;
    p_post_diff_amt.last_action_code     := l_pa_request_ei_rec.rei_information4;
    p_post_diff_amt.location             := l_pa_request_ei_rec.rei_information5;
    p_post_diff_amt.no_of_family_members := l_pa_request_ei_rec.rei_information6;


    if p_post_diff_amt.amount               is not null or
       p_post_diff_amt.last_action_code     is not null or
       p_post_diff_amt.location             is not null or
       p_post_diff_amt.no_of_family_members is not null then
       p_post_diff_amt.post_diff_amt_flag  := 'Y';
    end if;
    If l_session.noa_id_correct is not null then -- for correction fetch the existing values
       if p_post_diff_amt.amount is null then
          ghr_history_fetch.fetch_element_entry_value
--          (p_element_name          =>  'Post Differential Amount', -- Bug 2645878 Renamed element
			(p_element_name          =>  'Post Allowance',
           p_input_value_name      =>  'Amount',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_post_diff_amt.amount
          );
       end if;
       if p_post_diff_amt.last_action_code is null then
          ghr_history_fetch.fetch_element_entry_value
--          (p_element_name          =>  'Post Differential Amount', -- Bug 2645878 Renamed element
			(p_element_name          =>  'Post Allowance',
           p_input_value_name      =>  'Last Action Code',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_post_diff_amt.last_action_code
          );
       end if;
       if p_post_diff_amt.location is null then
          ghr_history_fetch.fetch_element_entry_value
--          (p_element_name          =>  'Post Differential Amount', -- Bug 2645878 Renamed element
			(p_element_name          =>  'Post Allowance',
		   p_input_value_name      =>  'Location',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_post_diff_amt.location
          );
       end if;
       if p_post_diff_amt.no_of_family_members is null then
          ghr_history_fetch.fetch_element_entry_value
--          (p_element_name          =>  'Post Differential Amount', -- Bug 2645878 Renamed element
			(p_element_name          =>  'Post Allowance',
           p_input_value_name      =>  'No. Family Members',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_post_diff_amt.no_of_family_members
          );
       end if;
    end if;
    --
    hr_utility.set_location('Leaving ' ||l_proc,5);
    --
  END post_diff_amt;
  --
  --
  Procedure post_diff_percent is
    l_proc        varchar2(70) := 'non_sf52_extra_info - post_diff_percent';
  Begin
    --
    hr_utility.set_location('Entering ' ||l_proc,5);
    --
    p_post_diff_percent.percent              := l_pa_request_ei_rec.rei_information3;
    p_post_diff_percent.last_action_code     := l_pa_request_ei_rec.rei_information4;
    p_post_diff_percent.location             := l_pa_request_ei_rec.rei_information5;
    if p_post_diff_percent.percent              is not null or
       p_post_diff_percent.last_action_code     is not null or
       p_post_diff_percent.location             is not null then
       p_post_diff_percent.post_diff_percent_flag  := 'Y';
    end if;
    If l_session.noa_id_correct is not null then -- for correction fetch the existing values
       if p_post_diff_percent.percent is null then
          ghr_history_fetch.fetch_element_entry_value
--          (p_element_name          =>  'Post Differential Percent', -- Bug 2645878 Renamed element
			(p_element_name          =>  'Post Differential',
           p_input_value_name      =>  'Percentage',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_post_diff_percent.percent
          );
       end if;
       if p_post_diff_percent.last_action_code is null then
          ghr_history_fetch.fetch_element_entry_value
--          (p_element_name          =>  'Post Differential Percent', -- Bug 2645878 Renamed element
			(p_element_name          =>  'Post Differential',
           p_input_value_name      =>  'Last Action Code',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_post_diff_percent.last_action_code
          );
       end if;
       if p_post_diff_percent.location is null then
          ghr_history_fetch.fetch_element_entry_value
--          (p_element_name          =>  'Post Differential Percent', -- Bug 2645878 Renamed element
			(p_element_name          =>  'Post Differential',
           p_input_value_name      =>  'Location',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_post_diff_percent.location
          );
       end if;
    end if;
    --
    hr_utility.set_location('Leaving ' ||l_proc,5);
    --
  END post_diff_percent;
  --
  --
  Procedure sep_maintenance_allow is
    l_proc        varchar2(70) := 'non_sf52_extra_info - sep_maintenance_allow';
  Begin
    --
    hr_utility.set_location('Entering ' ||l_proc,5);
    --
    p_sep_maintenance_allow.amount               := l_pa_request_ei_rec.rei_information3;
    p_sep_maintenance_allow.last_action_code     := l_pa_request_ei_rec.rei_information4;
    p_sep_maintenance_allow.category             := l_pa_request_ei_rec.rei_information5;

    if p_sep_maintenance_allow.amount               is not null or
       p_sep_maintenance_allow.last_action_code     is not null or
       p_sep_maintenance_allow.category             is not null then
       p_sep_maintenance_allow.sep_maint_allow_flag  := 'Y';
    end if;
    If l_session.noa_id_correct is not null then -- for correction fetch the existing values
       if p_sep_maintenance_allow.amount is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Separate Maintenance Allowance',
           p_input_value_name      =>  'Amount',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_sep_maintenance_allow.amount
          );
       end if;
       if p_sep_maintenance_allow.last_action_code is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Separate Maintenance Allowance',
           p_input_value_name      =>  'Last Action Code',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_sep_maintenance_allow.last_action_code
          );
       end if;
       if p_sep_maintenance_allow.category is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Separate Maintenance Allowance',
           p_input_value_name      =>  'Category',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_sep_maintenance_allow.category
          );
       end if;
    end if;
    --
    hr_utility.set_location('Leaving ' ||l_proc,5);
    --
  END sep_maintenance_allow;
  --
  --
  Procedure supplemental_post_allow is
    l_proc        varchar2(70) := 'non_sf52_extra_info - supplemental_post_allow';
  Begin
    --
    hr_utility.set_location('Entering ' ||l_proc,5);
    --
    p_supplemental_post_allow.amount   := l_pa_request_ei_rec.rei_information3;

    if p_supplemental_post_allow.amount   is not null then
       p_supplemental_post_allow.sup_post_allow_flag  := 'Y';
    end if;
    If l_session.noa_id_correct is not null then -- for correction fetch the existing values
       if p_supplemental_post_allow.amount is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Supplemental Post Allowance',
           p_input_value_name      =>  'Amount',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_supplemental_post_allow.amount
          );
       end if;
    End if;
    hr_utility.set_location('Leaving ' ||l_proc,5);
    --
  END supplemental_post_allow;
  --
  --
  Procedure temp_lodge_allow is
    l_proc        varchar2(70) := 'non_sf52_extra_info - temp_lodge_allow';
  Begin
    --
    hr_utility.set_location('Entering ' ||l_proc,5);
    --
    p_temp_lodge_allow.allowance_type  := l_pa_request_ei_rec.rei_information3;
    p_temp_lodge_allow.daily_rate      := l_pa_request_ei_rec.rei_information4;

    if p_temp_lodge_allow.allowance_type   is not null and
       p_temp_lodge_allow.daily_rate is not null then
       p_temp_lodge_allow.temp_lodge_allow_flag  := 'Y';
    end if;
    If l_session.noa_id_correct is not null then -- for correction fetch the existing values
       if p_temp_lodge_allow.allowance_type is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Temporary Lodging Allowance',
           p_input_value_name      =>  'Allowance Type',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_temp_lodge_allow.allowance_type
          );
       end if;
       if p_temp_lodge_allow.daily_rate is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Temporary Lodging Allowance',
           p_input_value_name      =>  'Daily Rate',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_temp_lodge_allow.daily_rate
          );
       end if;
    End if;
    hr_utility.set_location('Leaving ' ||l_proc,5);
    --
  END temp_lodge_allow;
  --
  --
  Procedure premium_pay is
    l_proc        varchar2(70) := 'non_sf52_extra_info - premium_pay';
  Begin
    --
    hr_utility.set_location('Entering ' ||l_proc,5);
    --
    p_premium_pay.premium_pay_ind := l_pa_request_ei_rec.rei_information3;
    p_premium_pay.amount          := l_pa_request_ei_rec.rei_information4;

    if p_premium_pay.premium_pay_ind is not null or
       p_premium_pay.amount   is not null then
       p_premium_pay.premium_pay_flag  := 'Y';
    end if;
    If l_session.noa_id_correct is not null then -- for correction fetch the existing values
       if p_premium_pay.premium_pay_ind is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Premium Pay',
           p_input_value_name      =>  'Premium Pay Ind',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_premium_pay.premium_pay_ind
          );
       end if;
       if p_premium_pay.amount is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Premium Pay',
           p_input_value_name      =>  'Amount',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_premium_pay.amount
          );
       end if;
    End if;
    hr_utility.set_location('Leaving ' ||l_proc,5);
    --
  END premium_pay;
  --
  --
  Procedure retirement_annuity is
    l_proc        varchar2(70) := 'non_sf52_extra_info - retirement_annuity';
  Begin
    --
    hr_utility.set_location('Entering ' ||l_proc,5);
    --
    p_retirement_annuity.annuity_sum         := l_pa_request_ei_rec.rei_information3;
    p_retirement_annuity.eligibility_expires := l_pa_request_ei_rec.rei_information4;

    if p_retirement_annuity.annuity_sum         is not null or
       p_retirement_annuity.eligibility_expires is not null then
       p_retirement_annuity.retirement_annuity_flag  := 'Y';
    end if;
    If l_session.noa_id_correct is not null then -- for correction fetch the existing values
       if p_retirement_annuity.annuity_sum is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Retirement Annuity',
           p_input_value_name      =>  'Sum',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_retirement_annuity.annuity_sum
          );
       end if;
       if p_retirement_annuity.eligibility_expires is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Retirement Annuity',
           p_input_value_name      =>  'Eligibility Expires',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_retirement_annuity.eligibility_expires
          );
       end if;
    End if;
    hr_utility.set_location('Leaving ' ||l_proc,5);
    --
  END retirement_annuity;
  --
  --
  Procedure severance_pay is
    l_proc        varchar2(70) := 'non_sf52_extra_info - severance_pay';
  Begin
    --
    hr_utility.set_location('Entering ' ||l_proc,5);
    --
    p_severance_pay.amount                  := l_pa_request_ei_rec.rei_information3;
    p_severance_pay.total_entitlement_weeks := l_pa_request_ei_rec.rei_information4;
    p_severance_pay.number_weeks_paid       := l_pa_request_ei_rec.rei_information5;
    p_severance_pay.weekly_amount           := l_pa_request_ei_rec.rei_information6;

    if p_severance_pay.amount                  is not null or
       p_severance_pay.total_entitlement_weeks is not null or
       p_severance_pay.number_weeks_paid       is not null or
       p_severance_pay.weekly_amount           is not null then
       p_severance_pay.severance_pay_flag  := 'Y';
    end if;
    If l_session.noa_id_correct is not null then -- for correction fetch the existing values
       if p_severance_pay.amount is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Severance Pay',
           p_input_value_name      =>  'Amount',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_severance_pay.amount
          );
       end if;
       if p_severance_pay.total_entitlement_weeks is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Severance Pay',
           p_input_value_name      =>  'Total Entitlement Weeks',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_severance_pay.total_entitlement_weeks
          );
       end if;
       if p_severance_pay.number_weeks_paid is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Severance Pay',
           p_input_value_name      =>  'Number Weeks Paid',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_severance_pay.number_weeks_paid
          );
       end if;
       if p_severance_pay.weekly_amount is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'Severance Pay',
           p_input_value_name      =>  'Weekly Amount',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_severance_pay.weekly_amount
          );
       end if;
    End if;
    hr_utility.set_location('Leaving ' ||l_proc,5);
    --
  END severance_pay;
  --
  --
/*
  Procedure thrift_saving_plan is
    l_proc   varchar2(70) := 'non_sf52_extra_info - thrift_saving_plan';
  Begin
    --
    hr_utility.set_location('Entering ' ||l_proc,5);
    --
    p_thrift_saving_plan.amount           := l_pa_request_ei_rec.rei_information3;
    p_thrift_saving_plan.rate             := l_pa_request_ei_rec.rei_information4;
    p_thrift_saving_plan.g_fund           := l_pa_request_ei_rec.rei_information5;
    p_thrift_saving_plan.f_fund           := l_pa_request_ei_rec.rei_information6;
    p_thrift_saving_plan.c_fund           := l_pa_request_ei_rec.rei_information7;
    p_thrift_saving_plan.status           := l_pa_request_ei_rec.rei_information8;
    p_thrift_saving_plan.status_date      := l_pa_request_ei_rec.rei_information9;
    p_thrift_saving_plan.agncy_contrib_elig_date := l_pa_request_ei_rec.rei_information10;
    p_thrift_saving_plan.emp_contrib_elig_date := l_pa_request_ei_rec.rei_information11;

    if p_thrift_saving_plan.amount           is not null or
       p_thrift_saving_plan.rate             is not null or
       p_thrift_saving_plan.g_fund           is not null or
       p_thrift_saving_plan.f_fund           is not null or
       p_thrift_saving_plan.c_fund           is not null or
       p_thrift_saving_plan.status           is not null or
       p_thrift_saving_plan.status_date      is not null or
       p_thrift_saving_plan.agncy_contrib_elig_date is not null then
       p_thrift_saving_plan.tsp_flag  := 'Y';
    end if;

-- Bug#2146912  Added set_extra_info call
     set_extra_info(p_per_scd_info.scd_tsp,l_pa_request_ei_rec.rei_information12,
                    p_per_scd_info.per_scd_info_flag, 'Y');

    If l_session.noa_id_correct is not null then -- for correction fetch the existing values
       if p_thrift_saving_plan.amount is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'TSP',
           p_input_value_name      =>  'Amount',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_thrift_saving_plan.amount
          );
       end if;
       if p_thrift_saving_plan.rate is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'TSP',
           p_input_value_name      =>  'Rate',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_thrift_saving_plan.rate
          );
       end if;
       if p_thrift_saving_plan.g_fund is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'TSP',
           p_input_value_name      =>  'G Fund',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_thrift_saving_plan.g_fund
          );
       end if;
       if p_thrift_saving_plan.f_fund is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'TSP',
           p_input_value_name      =>  'F Fund',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_thrift_saving_plan.f_fund
          );
       end if;
       if p_thrift_saving_plan.c_fund is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'TSP',
           p_input_value_name      =>  'C Fund',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_thrift_saving_plan.c_fund
          );
       end if;
       if p_thrift_saving_plan.status is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'TSP',
           p_input_value_name      =>  'Status',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_thrift_saving_plan.status
          );
       end if;
       if p_thrift_saving_plan.status_date is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'TSP',
           p_input_value_name      =>  'Status Date',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_thrift_saving_plan.status_date
          );
       end if;
       if p_thrift_saving_plan.agncy_contrib_elig_date is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'TSP',
           p_input_value_name      =>  'Agncy Contrib Elig Date',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_thrift_saving_plan.agncy_contrib_elig_date
          );
       end if;
       if p_thrift_saving_plan.emp_contrib_elig_date is null then
          ghr_history_fetch.fetch_element_entry_value
          (p_element_name          =>  'TSP',
           p_input_value_name      =>  'Emp Contrib Elig Date',
           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
           p_date_effective        =>  p_pa_request_rec.effective_date,
           p_screen_entry_value    =>  p_thrift_saving_plan.emp_contrib_elig_date
          );
       end if;
    end if;
    hr_utility.set_location('Leaving ' ||l_proc,5);
    --
  END thrift_saving_plan;*/
  --
  --
  Procedure retention_allow_review is
    l_proc   varchar2(70) := 'non_sf52_extra_info - retention_allow_review';
  Begin
    --
    hr_utility.set_location('Entering ' ||l_proc,5);
       If  p_pa_request_rec.employee_assignment_id is not null then
      ghr_api.retrieve_element_entry_value
              (p_element_name          => 'Retention Allowance',
               p_input_value_name      => 'Date',
               p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
               p_effective_date        => nvl(p_pa_request_rec.effective_date,trunc(sysdate)) ,
               p_value                 => p_retention_allow_review.review_date,
               p_multiple_error_flag   => l_multiple_error_flag
               );
    set_extra_info(p_retention_allow_review.review_date,
                   l_pa_request_ei_rec.rei_information3,
                   p_retention_allow_review.retention_allow_review_flag, 'N');
    --
   end if;
  End retention_allow_review;
  --
  Procedure chg_in_tenure is
    l_proc  varchar2(70) := 'non_sf52_extra - chg_in_tenure';
  Begin
    hr_utility.set_location('Entering ' ||l_proc,5);
    IF l_session.noa_id_correct is not null THEN
      set_extra_info(p_per_group1.appointment_type,l_pa_request_ei_rec.rei_information3,p_per_group1.per_group1_flag);
    ELSE
      p_per_group1.appointment_type           :=   l_pa_request_ei_rec.rei_information3;
      p_per_group1.per_group1_flag            :=  'Y';
    END IF;
    hr_utility.set_location('Leaving ' ||p_per_group1.appointment_type ||l_proc,10);
  End chg_in_tenure;
  --
  -- 4352589 BEN_EIT Changes Assinging Eligibility Expires to Benefits EIT.
  Procedure chg_in_fegli  is
    l_proc  varchar2(70) := 'non_sf52_extra - chg_in_fegli';
  Begin
      hr_utility.set_location('Entering ' ||l_proc,5);
      --
      p_per_benefit_info.FEGLI_Date_Eligibility_Expires := l_pa_request_ei_rec.rei_information1;
      If p_per_benefit_info.FEGLI_Date_Eligibility_Expires is not null then
         p_per_benefit_info.per_benefit_info_flag := 'Y';
      End If;
    hr_utility.set_location('Leaving ' ||l_proc,10);
  End chg_in_fegli;
  --
--Pradeep
Procedure mddds_pay is
  l_proc                varchar2(72) := 'mddds_pay';

Begin

  hr_utility.set_location('Entering ' ||l_proc,6);

  set_extra_info(p_mddds_special_pay.Full_Time_Status,
	     l_pa_request_ei_rec.rei_information9,
	     p_mddds_special_pay.mddds_special_pay_flag,
	     'Y'  );
  set_extra_info(p_mddds_special_pay.Length_of_Service,
	     l_pa_request_ei_rec.rei_information10,
	     p_mddds_special_pay.mddds_special_pay_flag,
	     'Y'  );
  set_extra_info(p_mddds_special_pay.Scarce_Specialty,
	     l_pa_request_ei_rec.rei_information3,
	     p_mddds_special_pay.mddds_special_pay_flag,
	     'Y'  );
  set_extra_info(p_mddds_special_pay.Specialty_or_Board_Cert,
	     l_pa_request_ei_rec.rei_information4,
	     p_mddds_special_pay.mddds_special_pay_flag,
	     'Y'  );
  set_extra_info(p_mddds_special_pay.Geographic_Location,
	     l_pa_request_ei_rec.rei_information5,
	     p_mddds_special_pay.mddds_special_pay_flag,
	     'Y'  );
  set_extra_info(p_mddds_special_pay.Exceptional_Qualifications,
	     l_pa_request_ei_rec.rei_information6,
	     p_mddds_special_pay.mddds_special_pay_flag,
	     'Y'  );
  set_extra_info(p_mddds_special_pay.Executive_Position,
	     l_pa_request_ei_rec.rei_information7,
	     p_mddds_special_pay.mddds_special_pay_flag,
	     'Y'  );
  set_extra_info(p_mddds_special_pay.Dentist_Post_Graduate_Training,
	     l_pa_request_ei_rec.rei_information8,
	     p_mddds_special_pay.mddds_special_pay_flag,
	     'Y'  );
  set_extra_info(p_mddds_special_pay.amount,
	     l_pa_request_ei_rec.rei_information11,
	     p_mddds_special_pay.mddds_special_pay_flag,
	     'Y'  );

  set_extra_info(p_mddds_special_pay.mddds_special_pay_date,
	     fnd_date.canonical_to_date(l_pa_request_ei_rec.rei_information12),
	     p_mddds_special_pay.mddds_special_pay_flag,
	     'Y'  );
  set_extra_info(p_mddds_special_pay.premium_pay_ind,
	     l_pa_request_ei_rec.rei_information13,
	     p_mddds_special_pay.mddds_special_pay_flag,
	     'Y'  );

End;
  ----Pradeep
Procedure premium_pay_ind is
  l_proc                varchar2(72) := 'premium_pay_ind';

Begin

  hr_utility.set_location('Entering ' ||l_proc,7);


  set_extra_info(p_premium_pay_ind.premium_pay_ind,
	     l_pa_request_ei_rec.rei_information3,
	     p_premium_pay_ind.premium_pay_ind_flag,
	     'Y'  );

End;

-- Bug 4724337 Race or National Origin changes
Procedure race_ethnic_info is
  l_proc   varchar2(72) := 'race_ethnic_info';

Begin

  hr_utility.set_location('Entering ' ||l_proc,7);

  set_extra_info(p_race_ethnic_info.p_hispanic,l_pa_request_ei_rec.rei_information3,
   				 p_race_ethnic_info.p_race_ethnic_info_flag, 'Y'  );
  set_extra_info(p_race_ethnic_info.p_american_indian,l_pa_request_ei_rec.rei_information4,
   				 p_race_ethnic_info.p_race_ethnic_info_flag, 'Y'  );
  set_extra_info(p_race_ethnic_info.p_asian,l_pa_request_ei_rec.rei_information5,
   				 p_race_ethnic_info.p_race_ethnic_info_flag, 'Y'  );
  set_extra_info(p_race_ethnic_info.p_black_afr_american,l_pa_request_ei_rec.rei_information6,
   				 p_race_ethnic_info.p_race_ethnic_info_flag, 'Y'  );
  set_extra_info(p_race_ethnic_info.p_hawaiian_pacific,l_pa_request_ei_rec.rei_information7,
   				 p_race_ethnic_info.p_race_ethnic_info_flag, 'Y'  );
  set_extra_info(p_race_ethnic_info.p_white,l_pa_request_ei_rec.rei_information8,
   				 p_race_ethnic_info.p_race_ethnic_info_flag, 'Y'  );
End;

Procedure student_loan_repay is
  l_proc varchar2(80):= 'non_sf52_extra - student_loan_repay';

begin
    hr_utility.set_location('Entering ' ||l_proc,5);
      --
      set_extra_info(p_student_loan_repay.p_amount,
	     p_pa_request_rec.award_amount,
	     p_student_loan_repay.p_student_loan_flag,
	     'Y'  );

      set_extra_info(p_student_loan_repay.p_repay_schedule,
	     l_pa_request_ei_rec.rei_information8,
	     p_student_loan_repay.p_student_loan_flag,
	     'Y'  );

      set_extra_info(p_student_loan_repay.p_review_date,
	     l_pa_request_ei_rec.rei_information9,
	     p_student_loan_repay.p_student_loan_flag,
	     'Y'  );

      If p_student_loan_repay.p_review_date is not null then
         p_student_loan_repay.p_student_loan_flag := 'Y';
      End If;

--   p_student_loan_repay.p_amount :=p_pa_request_rec.award_amount;
--     p_student_loan_repay.p_repay_schedule  := l_pa_request_ei_rec.rei_information8;
--      p_student_loan_repay.p_review_date     := l_pa_request_ei_rec.rei_information9;

    hr_utility.set_location('Leaving ' ||l_proc,10);
end;

  -- Bug 4280026
  Procedure key_emergency_essntl is
     l_proc      varchar2(70) := 'non_sf52_extra - key_emergency_essntl';
  Begin
     hr_utility.set_location('Entering ' ||l_proc,5);
     set_extra_info(p_asg_non_sf52.key_emer_essential_empl,
                    l_pa_request_ei_rec.rei_information3,p_asg_non_sf52.asg_non_sf52_flag, 'Y');
     hr_utility.set_location('Leaving ' ||l_proc,10);
  End key_emergency_essntl;

  -- Bug 5482191
  Procedure ghr_conv_dates is
     l_proc      varchar2(70) := 'non_sf52_extra - ghr_conv_dates';
  Begin
     hr_utility.set_location('Entering ' ||l_proc,5);
     set_extra_info(p_per_conversions.date_conv_career_begins,
                      l_pa_request_ei_rec.rei_information3,p_per_conversions.per_conversions_flag,'Y');
     set_extra_info(p_per_conversions.date_conv_career_due,
                      l_pa_request_ei_rec.rei_information4,p_per_conversions.per_conversions_flag,'Y');
     set_extra_info(p_per_conversions.date_recmd_conv_begins,
                      l_pa_request_ei_rec.rei_information5,p_per_conversions.per_conversions_flag,'Y');
     set_extra_info(p_per_conversions.date_recmd_conv_due,
                      l_pa_request_ei_rec.rei_information7,p_per_conversions.per_conversions_flag,'Y');
     set_extra_info(p_per_conversions.date_vra_conv_due,
                      l_pa_request_ei_rec.rei_information6,p_per_conversions.per_conversions_flag,'Y');
     hr_utility.set_location('Leaving ' ||l_proc,10);
  End ghr_conv_dates;


-- Start of Bug 6312144 -- New IPA Benefits Continuation EIT
  Procedure ipa_benefits_cont is
     l_proc      varchar2(70) := 'non_sf52_extra - ipa_benefits_cont';
  Begin
     hr_utility.set_location('Entering ' ||l_proc,5);
     set_extra_info(p_ipa_benefits_cont.FEGLI_Indicator,
                      l_pa_request_ei_rec.rei_information1,p_ipa_benefits_cont.per_ben_cont_info_flag,'Y');
     set_extra_info(p_ipa_benefits_cont.FEGLI_Election_Date,
                      l_pa_request_ei_rec.rei_information2,p_ipa_benefits_cont.per_ben_cont_info_flag,'Y');
     set_extra_info(p_ipa_benefits_cont.FEGLI_Elec_Not_Date,
                      l_pa_request_ei_rec.rei_information3,p_ipa_benefits_cont.per_ben_cont_info_flag,'Y');
     set_extra_info(p_ipa_benefits_cont.FEHB_Indicator,
                      l_pa_request_ei_rec.rei_information4,p_ipa_benefits_cont.per_ben_cont_info_flag,'Y');
     set_extra_info(p_ipa_benefits_cont.FEHB_Election_Date,
                      l_pa_request_ei_rec.rei_information5,p_ipa_benefits_cont.per_ben_cont_info_flag,'Y');
     set_extra_info(p_ipa_benefits_cont.FEHB_Elec_Notf_Date,
                      l_pa_request_ei_rec.rei_information6,p_ipa_benefits_cont.per_ben_cont_info_flag,'Y');
     set_extra_info(p_ipa_benefits_cont.retirement_Indicator,
                      l_pa_request_ei_rec.rei_information7,p_ipa_benefits_cont.per_ben_cont_info_flag,'Y');
     set_extra_info(p_ipa_benefits_cont.retirement_Elec_Date,
                      l_pa_request_ei_rec.rei_information12,p_ipa_benefits_cont.per_ben_cont_info_flag,'Y');
     set_extra_info(p_ipa_benefits_cont.retirement_Elec_Notf_Date,
                      l_pa_request_ei_rec.rei_information8,p_ipa_benefits_cont.per_ben_cont_info_flag,'Y');
     set_extra_info(p_ipa_benefits_cont.Cont_Term_Insuff_Pay_Elec_Date,
                      l_pa_request_ei_rec.rei_information9,p_ipa_benefits_cont.per_ben_cont_info_flag,'Y');
     set_extra_info(p_ipa_benefits_cont.Cont_Term_Insuff_Pay_Notf_Date,
                      l_pa_request_ei_rec.rei_information10,p_ipa_benefits_cont.per_ben_cont_info_flag,'Y');
     set_extra_info(p_ipa_benefits_cont.Cont_Term_Insuff_Pmt_Type_Code,
                      l_pa_request_ei_rec.rei_information11,p_ipa_benefits_cont.per_ben_cont_info_flag,'Y');
     hr_utility.set_location('Leaving ' ||l_proc,10);
  End ipa_benefits_cont;


 -- Bug 6312144 -- New Federal Benefits Info EIT
  Procedure ben_info_cont is
     l_proc      varchar2(70) := 'non_sf52_extra - Federal Benefit Info';
  Begin
     hr_utility.set_location('Entering ' ||l_proc,5);
     set_extra_info(p_per_benefit_info.FEGLI_Assignment_Ind,
                      l_pa_request_ei_rec.rei_information1,p_per_benefit_info.per_benefit_info_flag,'Y');
     set_extra_info(p_per_benefit_info.FEGLI_Post_Elec_Basic_Ins_Amt,
                      l_pa_request_ei_rec.rei_information2,p_per_benefit_info.per_benefit_info_flag,'Y');
     set_extra_info(p_per_benefit_info.FEGLI_Court_Order_Ind,
                      l_pa_request_ei_rec.rei_information3,p_per_benefit_info.per_benefit_info_flag,'Y');
     set_extra_info(p_per_benefit_info.Desg_FEGLI_Benf_Ind,
                      l_pa_request_ei_rec.rei_information4,p_per_benefit_info.per_benefit_info_flag,'Y');
     set_extra_info(p_per_benefit_info.FEHB_Event_Code,
                      l_pa_request_ei_rec.rei_information5,p_per_benefit_info.per_benefit_info_flag,'Y');
     hr_utility.set_location('Leaving ' ||l_proc,10);
  End ben_info_cont;

  -- Bug 6312144 -- Retirement system information
  Procedure retirement_info is
     l_proc      varchar2(70) := 'non_sf52_extra - Retirement System Info';
  Begin
     hr_utility.set_location('Entering ' ||l_proc,5);
     set_extra_info(p_retirement_info.special_population_code,
                      l_pa_request_ei_rec.rei_information1,p_retirement_info.per_retirement_info_flag,'Y');
     set_extra_info(p_retirement_info.App_Exc_CSRS_Ind,
                      l_pa_request_ei_rec.rei_information2,p_retirement_info.per_retirement_info_flag,'Y');
     set_extra_info(p_retirement_info.App_Exc_FERS_Ind,
                      l_pa_request_ei_rec.rei_information3,p_retirement_info.per_retirement_info_flag,'Y');
     set_extra_info(p_retirement_info.FICA_Coverage_Ind1,
                      l_pa_request_ei_rec.rei_information4,p_retirement_info.per_retirement_info_flag,'Y');
     set_extra_info(p_retirement_info.FICA_Coverage_Ind2,
                      l_pa_request_ei_rec.rei_information5,p_retirement_info.per_retirement_info_flag,'Y');
     hr_utility.set_location('Leaving ' ||l_proc,10);
  End retirement_info;
   /* --Begin Bug# 4588575
    Procedure ghr_prob_info is
    l_proc      varchar2(70) := 'non_sf52_extra - ghr_prob_info';
    Begin
        hr_utility.set_location('Entering ' ||l_proc,55);
        set_extra_info(p_per_probations.date_prob_trial_period_begin ,
                       l_pa_request_ei_rec.rei_information10,p_per_probations.per_probation_flag);
        set_extra_info(p_per_probations.date_prob_trial_period_ends  ,
                       l_pa_request_ei_rec.rei_information11,p_per_probations.per_probation_flag);
        set_extra_info(p_per_probations.date_spvr_mgr_prob_begins  ,
                       l_pa_request_ei_rec.rei_information12,p_per_probations.per_probation_flag);
        set_extra_info(p_per_probations.date_spvr_mgr_prob_ends  ,
                       l_pa_request_ei_rec.rei_information13,p_per_probations.per_probation_flag);
        set_extra_info(p_per_probations.spvr_mgr_prob_completion  ,
                       l_pa_request_ei_rec.rei_information14,p_per_probations.per_probation_flag);
        set_extra_info(p_per_probations.date_ses_prob_expires ,
                       l_pa_request_ei_rec.rei_information15,p_per_probations.per_probation_flag);
         hr_utility.set_location('Leaving ' ||l_proc,56);
    End ghr_prob_info;

    PROCEDURE chg_scd_info is
        l_proc   varchar2(70)  := 'non_sf52_extra - chg_scd_info';
    Begin
        hr_utility.set_location('Entering ' ||l_proc,6);
        set_extra_info(p_per_scd_info.scd_civilian,l_pa_request_ei_rec.rei_information10,
                p_per_scd_info.per_scd_info_flag, 'Y');
        set_extra_info(p_per_scd_info.scd_rif,l_pa_request_ei_rec.rei_information11,
                p_per_scd_info.per_scd_info_flag, 'Y');
        set_extra_info(p_per_scd_info.scd_retirement,l_pa_request_ei_rec.rei_information12,
                p_per_scd_info.per_scd_info_flag, 'Y');
        set_extra_info(p_per_scd_info.scd_ses,l_pa_request_ei_rec.rei_information13,
                p_per_scd_info.per_scd_info_flag, 'Y');
        set_extra_info(p_per_scd_info.scd_spl_retirement,l_pa_request_ei_rec.rei_information14,
                p_per_scd_info.per_scd_info_flag, 'Y');
        hr_utility.set_location('Leaving  ' ||l_proc,60);
    End chg_scd_info;
    --end Bug# 4588575
    */ --Backout the changes done for Bug# 4588575
Begin

  -- Get session variables  to identify if a CORRECTION action is being performed
  ghr_history_api.get_g_session_var(l_session);
  --

  --  l_pos_org                    := p_pos_grp1.positions_organization;
  -- Get Element Entry Values in case of 'CORRECTION' -- only those elements that come off an extra_info

  If l_session.noa_id_correct is not null then
    ghr_history_fetch.fetch_element_entry_value
    (p_element_name          =>  'Within Grade Increase',
     p_input_value_name      =>  'Date Due',
     p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
     p_date_effective        =>  p_pa_request_rec.effective_date,
     p_screen_entry_value    =>  p_within_grade_increase.p_date_wgi_due
     );
    ghr_history_fetch.fetch_element_entry_value
    (p_element_name          =>  'Within Grade Increase',
     p_input_value_name      =>  'Pay Date',
     p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
     p_date_effective        =>  p_pa_request_rec.effective_date,
     p_screen_entry_value    =>  p_within_grade_increase.p_wgi_pay_date
     );
    ghr_history_fetch.fetch_element_entry_value
    (p_element_name          =>  'Within Grade Increase',
     p_input_value_name      =>  'Postponmt Effective',
     p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
     p_date_effective        =>  p_pa_request_rec.effective_date,
     p_screen_entry_value    =>  p_within_grade_increase.p_date_wgi_postpone_effective
     );
    ghr_history_fetch.fetch_element_entry_value
    (p_element_name          =>  'Within Grade Increase',
     p_input_value_name      =>  'Last Equivalent Increase',
     p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
     p_date_effective        =>  p_pa_request_rec.effective_date,
     p_screen_entry_value    =>  p_within_grade_increase.p_last_equi_incr
     );
    -- The foll. if conditions ensure that we fetch the elements only
    -- on correction to a noa relevant to the specific  elements
    If p_pa_request_rec.first_noa_code = '816' then
      ghr_history_fetch.fetch_element_entry_value
      (p_element_name         =>  'Relocation Bonus',
      p_input_value_name      =>  'Expiration Date',
      p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
      p_date_effective        =>  p_pa_request_rec.effective_date,
      p_screen_entry_value    =>  p_relocation_bonus.p_date_reloc_exp
      );
    End if;
    If p_pa_request_rec.first_noa_code  = '815' then
      ghr_history_fetch.fetch_element_entry_value
      (p_element_name         =>  'Recruitment Bonus',
      p_input_value_name      =>  'Expiration Date',
      p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
      p_date_effective        =>  p_pa_request_rec.effective_date,
      p_screen_entry_value    =>  p_recruitment_bonus.p_date_recruit_exp
      );
    End if;
  End if;

 -- Bug 3260890

  For info_type in c_info_types loop
     l_information_type := info_type.information_type;
     hr_utility.set_location('l_information_type :' || l_information_type,1);
     l_pa_request_ei_rec := null;
     FOR pa_request_extra_info IN c_pa_request_extra_info LOOP
        l_pa_request_ei_rec := pa_request_extra_info;
     END LOOP;

     hr_utility.set_location('rei 3 ' || l_pa_request_ei_rec.rei_information3,1);
     hr_utility.set_location('rei 4 ' || l_pa_request_ei_rec.rei_information4,1);
     hr_utility.set_location('rei 5 ' || l_pa_request_ei_rec.rei_information5,1);
     hr_utility.set_location('rei 6 ' || l_pa_request_ei_rec.rei_information6,1);
     hr_utility.set_location('rei 7 ' || l_pa_request_ei_rec.rei_information7,1);
     hr_utility.set_location('rei 8 ' || l_pa_request_ei_rec.rei_information8,1);
     hr_utility.set_location('rei 9 ' || l_pa_request_ei_rec.rei_information9,1);
     hr_utility.set_location('rei 11 ' || l_pa_request_ei_rec.rei_information11,1);

     --
     if l_information_type = 'GHR_US_PAR_APPT_INFO' then
        hr_utility.set_location(l_proc,5);
        hr_utility.set_location('info type ' || l_information_type,1);
        appt_info;
     elsif l_information_type =  'GHR_US_PAR_APPT_TRANSFER' then
        hr_utility.set_location(l_proc,10);
        hr_utility.set_location('info type ' || l_information_type,2);
        appt_transfer;
     --Begin Bug# 8724192
     elsif l_information_type =  'GHR_US_TRANS_CURN_APP_AUTH' then
        hr_utility.set_location(l_proc,10);
        hr_utility.set_location('info type ' || l_information_type,2);
        appt_transfer_app;
     elsif l_information_type =  'GHR_US_MASS_TRNSFR_NTE_DATES' then
        hr_utility.set_location(l_proc,10);
        hr_utility.set_location('info type ' || l_information_type,2);
        mass_transfer_nte;
      --End Bug# 8724192
     elsif l_information_type =  'GHR_US_PAR_CONV_APP' then
        hr_utility.set_location(l_proc,15);
        hr_utility.set_location('info type ' || l_information_type,3);
        conv_appt;
     elsif l_information_type = 'GHR_US_PAR_RETURN_TO_DUTY' then
        hr_utility.set_location(l_proc,20);
        hr_utility.set_location('info type ' || l_information_type,4);
        return_to_duty;
     elsif l_information_type = 'GHR_US_PAR_REASSIGNMENT' then
        hr_utility.set_location(l_proc,25);
        hr_utility.set_location('info type ' || l_information_type,5);
        reassign;
     elsif l_information_type = 'GHR_US_PAR_POSN_CHG' then
        hr_utility.set_location(l_proc,30);
        hr_utility.set_location('info type ' || l_information_type,6);
        posn_chg;
     elsif l_information_type = 'GHR_US_PAR_CHG_HOURS' then
        hr_utility.set_location(l_proc,35);
        hr_utility.set_location('info type ' || l_information_type,7);
        chg_sched_hours;
     elsif l_information_type = 'GHR_US_PAR_REALIGNMENT' then
        hr_utility.set_location(l_proc,40);
        hr_utility.set_location('info type ' || l_information_type,8);
        realign;
     elsif l_information_type =  'GHR_US_PAR_CHG_DATA_ELEMENT' then
        hr_utility.set_location(l_proc,45);
        hr_utility.set_location('info type ' || l_information_type,9);
        chg_data_elm;
     elsif  l_information_type =  'GHR_US_PAR_CHG_RETIRE_PLAN' then
        hr_utility.set_location(l_proc,50);
        hr_utility.set_location('info type ' || l_information_type,10);
        chg_ret_plan;
     elsif  l_information_type =  'GHR_US_PAR_CHG_SCD' then
        hr_utility.set_location(l_proc,55);
        hr_utility.set_location('info type ' || l_information_type,11);
        chg_scd;
/* Bug # 1165309
     elsif  l_information_type =  'GHR_US_PAR_DENIAL_WGI' then
        hr_utility.set_location(l_proc,60);
        hr_utility.set_location('info type ' || l_information_type,12);
        denial_wgi;
*/
     elsif  l_information_type =  'GHR_US_PAR_SALARY_CHG' then
        hr_utility.set_location(l_proc,65);
        hr_utility.set_location('info type ' || l_information_type,13);
        salary_change;
     elsif  l_information_type =  'GHR_US_PAR_RECRUIT_BONUS' then
        hr_utility.set_location(l_proc,70);
        hr_utility.set_location('info type ' || l_information_type,14);
        recruitment_bonus;
     elsif  l_information_type =  'GHR_US_PAR_RELOC_BONUS' then
        hr_utility.set_location(l_proc,75);
        hr_utility.set_location('info type ' || l_information_type,15);
        relocation_bonus;
     elsif  l_information_type =  'GHR_US_PAR_AWARDS_BONUS' then
        hr_utility.set_location(l_proc,80);
        hr_utility.set_location('info type ' || l_information_type,16);
        government_awards;
     elsif  l_information_type =  'GHR_US_PAR_NON_PAY_DUTY_STATUS' then
        hr_utility.set_location(l_proc,85);
        hr_utility.set_location('info type ' || l_information_type,17);
        non_pay_duty_status;
     elsif  l_information_type =  'GHR_US_PAR_TERM_RET_GRADE' then
        hr_utility.set_location(l_proc,90);
        hr_utility.set_location('info type ' || l_information_type,18);
        term_retained_grade;
     elsif  l_information_type =  'GHR_US_PAR_QSI_AWARD' then
        hr_utility.set_location(l_proc,95);
        hr_utility.set_location('info type ' || l_information_type,19);
        quality_step_increase;
     elsif  l_information_type =  'GHR_US_PAR_LWOP_INFO' then
        hr_utility.set_location(l_proc,100);
        hr_utility.set_location('info type ' || l_information_type,20);
        lwop_info;
     elsif  l_information_type =  'GHR_US_PAR_ENTITLEMENT' then
        hr_utility.set_location(l_proc,105);
        hr_utility.set_location('info type ' || l_information_type,21);
        entitlement;
     elsif  l_information_type =  'GHR_US_PAR_FOR_LANG_PROF_PAY' then
        hr_utility.set_location(l_proc,110);
        hr_utility.set_location('info type ' || l_information_type,22);
        for_lang_pay;
     elsif  l_information_type =  'GHR_US_PAR_EDP_PAY' then
        hr_utility.set_location(l_proc,115);
        hr_utility.set_location('info type ' || l_information_type,23);
        edp_pay;
     elsif  l_information_type =  'GHR_US_PAR_HAZARD_PAY' then
        hr_utility.set_location(l_proc,116);
        hr_utility.set_location('info type ' || l_information_type,24);
        hazard_pay;
/* Commented Out as as all future benefits enrollments are either
 through the Benefits PUI or FEHB module
     elsif  l_information_type =  'GHR_US_PAR_HEALTH_BENEFITS' then
        hr_utility.set_location(l_proc,120);
        hr_utility.set_location('info type ' || l_information_type,25);
        health_benefits;
     elsif  l_information_type =  'GHR_US_PAR_HEALTH_BEN_PRE_TAX' then
        hr_utility.set_location(l_proc,121);
        hr_utility.set_location('info type ' || l_information_type,25);
        health_ben_pre_tax;
*/
     elsif  l_information_type =  'GHR_US_PAR_DANGER_PAY' then
        hr_utility.set_location(l_proc,125);
        hr_utility.set_location('info type ' || l_information_type,26);
        danger_pay;
     elsif  l_information_type =  'GHR_US_PAR_IMMNT_DANGER_PAY' then
        hr_utility.set_location(l_proc,130);
        hr_utility.set_location('info type ' || l_information_type,27);
        imminent_danger_pay;
     elsif  l_information_type =  'GHR_US_PAR_LIVING_QUART_ALLOW' then
        hr_utility.set_location(l_proc,135);
        hr_utility.set_location('info type ' || l_information_type,28);
        living_quarters_allow;
     elsif  l_information_type =  'GHR_US_PAR_POST_DIFF_PERCENT' then
        hr_utility.set_location(l_proc,140);
        hr_utility.set_location('info type ' || l_information_type,29);
        post_diff_percent;
     elsif  l_information_type =  'GHR_US_PAR_POST_DIFF_AMOUNT' then
        hr_utility.set_location(l_proc,145);
        hr_utility.set_location('info type ' || l_information_type,30);
        post_diff_amt;
     elsif  l_information_type =  'GHR_US_PAR_SEP_MAINT_ALLOWANCE' then
        hr_utility.set_location(l_proc,150);
        hr_utility.set_location('info type ' || l_information_type,31);
        sep_maintenance_allow;
     elsif  l_information_type =  'GHR_US_PAR_SUP_POST_ALLOWANCE' then
        hr_utility.set_location(l_proc,155);
        hr_utility.set_location('info type ' || l_information_type,32);
        supplemental_post_allow;
     elsif  l_information_type =  'GHR_US_PAR_TMP_LODGE_ALLOWANCE' then
        hr_utility.set_location(l_proc,160);
        hr_utility.set_location('info type ' || l_information_type,33);
        temp_lodge_allow;
     elsif  l_information_type =  'GHR_US_PAR_PREMIUM_PAY' then
        hr_utility.set_location(l_proc,165);
        hr_utility.set_location('info type ' || l_information_type,34);
        premium_pay;
     elsif  l_information_type =  'GHR_US_PAR_RETIREMENT_ANNUITY' then
        hr_utility.set_location(l_proc,170);
        hr_utility.set_location('info type ' || l_information_type,35);
        retirement_annuity;
     elsif  l_information_type =  'GHR_US_PAR_SEVERANCE_PAY' then
        hr_utility.set_location(l_proc,175);
        hr_utility.set_location('info type ' || l_information_type,36);
        severance_pay;
     /*elsif  l_information_type =  'GHR_US_PAR_TSP' then
        hr_utility.set_location(l_proc,180);
        hr_utility.set_location('info type ' || l_information_type,37);
        thrift_saving_plan;*/
     elsif  l_information_type =  'GHR_US_PAR_RET_ALLOWANCE' then
        hr_utility.set_location(l_proc,180);
        hr_utility.set_location('info type ' || l_information_type,37);
        retention_allow_review;
      elsif  l_information_type = 'GHR_US_PAR_CHG_TEN' then
        hr_utility.set_location(l_proc,110);
        chg_in_tenure;
      --Bug#2759379  Added FEGLI related Code
      elsif  l_information_type = 'GHR_US_PAR_FEGLI' then
        hr_utility.set_location(l_proc,110);
        chg_in_fegli;
      elsif l_information_type = 'GHR_US_PAR_MD_DDS_PAY' then
         hr_utility.set_location(l_proc,200);
         mddds_pay;
      elsif l_information_type = 'GHR_US_PAR_PREMIUM_PAY_IND' then
         hr_utility.set_location(l_proc,200);
         premium_pay_ind;
      elsif l_information_type = 'GHR_US_PAR_STUDENT_LOAN' then
        hr_utility.set_location(l_proc,190);
        student_loan_repay;
      -- Bug#3385386 Added FTA condition.
      elsif  l_information_type =  'GHR_US_PAR_FOR_TRANSER_ALLOW' then
        hr_utility.set_location(l_proc,210);
        hr_utility.set_location('info type ' || l_information_type,22);
        fta;
	  elsif l_information_type = 'GHR_US_PAR_BENEFITS'   then
	    hr_utility.set_location(l_proc,210);
		hr_utility.set_location('info type ' || l_information_type,22);
		appt_benefits;
	  elsif l_information_type = 'GHR_US_PAR_MASS_TERM' then
	    hr_utility.set_location(l_proc,210);
		hr_utility.set_location('info type ' || l_information_type,22);
		separate352;
	  -- Bug 4724337 Race or National Origin changes
	  elsif l_information_type = 'GHR_US_PAR_ETHNICITY_RACE' then
	  	hr_utility.set_location(l_proc,210);
		hr_utility.set_location('info type ' || l_information_type,22);
		race_ethnic_info;
      -- Bug 4486823 RRR Changes
	  elsif l_information_type = 'GHR_US_PAR_SERVICE_OBLIGATION' then
	  	hr_utility.set_location(l_proc,220);
		hr_utility.set_location('info type ' || l_information_type,22);
		service_obligation;
        -- Bug 4724337 Race or National Origin changes
	  elsif l_information_type = 'GHR_US_PAR_RETENTION_INCENTIVE' then
	  	hr_utility.set_location(l_proc,230);
		hr_utility.set_location('info type ' || l_information_type,22);
		incentive_retention;
        -- Bug 4486823 RRR Changes
      elsif l_information_type = 'GHR_US_PAR_EMERG_ESSNTL_ASG' then
        hr_utility.set_location(l_proc,240);
        hr_utility.set_location('info type ' || l_information_type,22);
        key_emergency_essntl;
      -- Bug 4280026 Key Emergency Essential Changes .
	  -- Begin Bug# 4126188
	  elsif l_information_type = 'GHR_US_PAR_TERM_RG_POSN_CHG' then
        hr_utility.set_location(l_proc,250);
        hr_utility.set_location('info type ' || l_information_type,22);
        rg_posn_chg;
	  -- end Bug# 4126188
      elsif l_information_type = 'GHR_US_PAR_CONVERSION_DATES' then
        hr_utility.set_location(l_proc,260);
        hr_utility.set_location('info type ' || l_information_type,22);
        ghr_conv_dates;
        -- Bug 5482191
       --start of Bug# 6312144
      elsif l_information_type = 'GHR_US_PAR_BENEFITS_CONT' then
         hr_utility.set_location(l_proc,270);
         hr_utility.set_location('info type ' || l_information_type,22);
         ipa_benefits_cont;
      elsif l_information_type = 'GHR_US_PAR_BENEFIT_INFO' then
         hr_utility.set_location(l_proc,280);
         hr_utility.set_location('info type ' || l_information_type,22);
         ben_info_cont;
      elsif l_information_type = 'GHR_US_PAR_RETIRMENT_SYS_INFO' then
         hr_utility.set_location(l_proc,290);
         hr_utility.set_location('info type ' || l_information_type,22);
         retirement_info;
         --end of Bug# 6312144
      /*   --Begin Bug# 4588575
      elsif l_information_type = 'GHR_US_PAR_PROBATION_INFO' then
         hr_utility.set_location(l_proc,270);
         hr_utility.set_location('info type ' || l_information_type,270);
         ghr_prob_info;
      elsif l_information_type = 'GHR_US_PAR_SCD_INFO' then
         hr_utility.set_location(l_proc,280);
         hr_utility.set_location('info type ' || l_information_type,280);
         chg_scd_info;
         --end Bug# 4588575
      */ --Backout the changes done for Bug# 4588575
      end if;
  End loop;     -- info types


    -- Bug#5668878 Begin
    IF p_pa_request_rec.first_noa_code = '892' THEN

        l_psi := ghr_pa_requests_pkg.get_personnel_system_indicator
                 (p_pa_request_rec.to_position_id,
                  p_pa_request_rec.effective_date);

         IF l_psi <> '00' THEN
            p_within_grade_increase.p_last_equi_incr := p_pa_request_rec.effective_date;
            p_within_grade_increase.p_date_wgi_due := NULL;
            p_within_grade_increase.p_wgi_pay_date := NULL;
            p_within_grade_increase.p_wgi_flag       := 'Y';
        END IF;

    END IF;
    -- Bug#5668878 End
  -- Rohini
  l_noa_code := p_pa_request_rec.first_noa_code;
 /* if l_noa_code = '352' then
   hr_utility.set_location('p_per_separate_retire.agency_code_transfer_to = ' ||
                            p_per_separate_retire.agency_code_transfer_to ,38);
     set_extra_info(p_per_separate_retire.agency_code_transfer_to,
                    l_pa_request_ei_rec.rei_information3,
------ AVR          p_pa_request_rec.first_noa_information1,
                    p_per_separate_Retire.per_sep_Retire_flag);
   hr_utility.set_location('p_per_separate_retire.agency_code_transfer_to = ' ||
                            p_per_separate_retire.agency_code_transfer_to ,38);
  End if; */
  --
  --  Process Generic Agency information
  --
  -- Updating the record groups with Agency Info

  p_agency_sf52.agency_use_block_25  := p_generic_ei_rec.rei_information3;
  p_agency_sf52.agency_data_block_40 := p_generic_ei_rec.rei_information4;
  p_agency_sf52.agency_data_block_41 := p_generic_ei_rec.rei_information5;
  p_agency_sf52.agency_data_block_42 := p_generic_ei_rec.rei_information6;
  p_agency_sf52.agency_data_block_43 := p_generic_ei_rec.rei_information7;
  p_agency_sf52.agency_data_block_44 := p_generic_ei_rec.rei_information8;
  -- Set Flag to 'Y'
  p_agency_sf52.agency_flag := 'Y';
  --
  -- Bug# 4672772 Begin
	for asg_stat_rec in c_user_status loop
	  l_old_user_status				:= asg_stat_rec.user_status;
	  l_old_system_status			:= asg_stat_rec.per_system_status;
	  l_old_effective_start_date	:= asg_stat_rec.effective_start_date -1;
	  hr_utility.set_location('Old User status is '||l_old_user_status,96);
	  exit;
    end loop;
	-- Bug# 4672772 End

  hr_utility.set_location('Leaving  - process_non_sf52_extra_info',170);

  -- NTE start dates processing
  -- Added 515 -- Venkat 04/26
  If l_noa_code in ('108','115','117','122','148','149','153',
                    '154','171','190','508','515','517','522','548',
                    '549','553','554','571','590','741') then
    --Bug# 4602352 703 is removed from the list
    p_asg_nte_dates.asg_nte_start_date      := fnd_date.date_to_canonical(p_pa_request_rec.effective_date);
    hr_utility.set_location('inside asg nte dates ',1);
    hr_utility.set_location('nte date ' || (p_asg_nte_dates.asg_nte_start_date),2);
    p_asg_nte_dates.asg_nte_dates_flag := 'Y';
  --Begin Bug# 4602352
  Elsif  l_noa_code ='703' and (l_old_user_status <> 'Term Limited Appt') THEN
    p_asg_nte_dates.asg_nte_start_date      := fnd_date.date_to_canonical(p_pa_request_rec.effective_date);
    hr_utility.set_location('inside asg nte dates for 703 ',111);
    hr_utility.set_location('nte date ' || (p_asg_nte_dates.asg_nte_start_date),2);
    p_asg_nte_dates.asg_nte_dates_flag := 'Y';
  --End Bug# 4602352
  Elsif l_noa_code = '472' then
    p_asg_nte_dates.furlough_nte_start_date := fnd_date.date_to_canonical(p_pa_request_rec.effective_date);
    p_asg_nte_dates.asg_nte_dates_flag := 'Y';
  Elsif l_noa_code = '462' then
    p_asg_nte_dates.asg_nte_dates_flag := 'Y';
    p_asg_nte_dates.lwp_nte_start_date :=  fnd_date.date_to_canonical(p_pa_request_rec.effective_date);
  Elsif l_noa_code = '460' then
   p_asg_nte_dates.lwop_nte_start_date :=  fnd_date.date_to_canonical(p_pa_request_rec.effective_date);
    p_asg_nte_dates.asg_nte_dates_flag := 'Y';
  Elsif l_noa_code = '480' then
    p_asg_nte_dates.sabatical_nte_start_date :=  fnd_date.date_to_canonical(p_pa_request_rec.effective_date);
    p_asg_nte_dates.asg_nte_dates_flag := 'Y';
  Elsif l_noa_code = '450' then
    p_asg_nte_dates.asg_nte_dates_flag := 'Y';
    p_asg_nte_dates.suspension_nte_start_date :=  fnd_date.date_to_canonical(p_pa_request_rec.effective_date);
  End if;


  -- NTE dates processing

  If  l_noa_code in ('108','115','117','122','148','149','153',
                     '154','171','190','508','515','517','522',
                     '548','549','553','554','571','590',--'703', Removed for Bug# 4602352
                     '741','750','760','761','762','765','769','770') then
    p_asg_nte_dates.assignment_nte       :=   p_pa_request_rec.first_noa_information1;
    hr_utility.set_location('dates ' || p_asg_nte_dates.assignment_nte,1);
    p_asg_nte_dates.asg_nte_dates_flag := 'Y';
  --Begin Bug# 4602352
  Elsif  l_noa_code ='703' and (l_old_user_status <> 'Term Limited Appt') THEN
    p_asg_nte_dates.assignment_nte       :=   p_pa_request_rec.first_noa_information1;
    hr_utility.set_location('dates ' || p_asg_nte_dates.assignment_nte,100);
    p_asg_nte_dates.asg_nte_dates_flag := 'Y';
  --End Bug# 4602352
  Elsif l_noa_code in ('472','772') then
    hr_utility.set_location(' furlough nte dates for 472 and 772',1);
    p_asg_nte_dates.furlough_nte         :=   p_pa_request_rec.first_noa_information1;
    p_asg_nte_dates.asg_nte_dates_flag := 'Y';
  Elsif l_noa_code  = '462' then
    p_asg_nte_dates.lwp_nte              :=   p_pa_request_rec.first_noa_information1;
    p_asg_nte_dates.asg_nte_dates_flag := 'Y';
  Elsif l_noa_code  in ('460','773') then
    p_asg_nte_dates.lwop_nte             :=   p_pa_request_rec.first_noa_information1;
    p_asg_nte_dates.asg_nte_dates_flag := 'Y';
  Elsif l_noa_code  = '480' then
    p_asg_nte_dates.sabatical_nte        :=   p_pa_request_rec.first_noa_information1;
    p_asg_nte_dates.asg_nte_dates_flag := 'Y';
  Elsif l_noa_code  = '450' then
    p_asg_nte_dates.suspension_nte       :=   p_pa_request_rec.first_noa_information1;
    p_asg_nte_dates.asg_nte_dates_flag := 'Y';
  End if;

  --
  -- Processing for clearing of NTE dates\
  -- Bug 2941621 Included 280 and also furlough dates in the condition



  if (l_noa_code IN ('293','280')) then
	p_asg_nte_dates.asg_nte_dates_flag 			:= 'Y';
	p_asg_nte_dates.lwp_nte 					:= null;
	p_asg_nte_dates.lwp_nte_start_date 			:= null;
	p_asg_nte_dates.suspension_nte 				:= null;
	p_asg_nte_dates.suspension_nte_start_date 	:= null;
	p_asg_nte_dates.furlough_nte	 			:= null;
	p_asg_nte_dates.furlough_nte_start_date	 	:= null;
  elsif (l_noa_code = '292') then
	p_asg_nte_dates.asg_nte_dates_flag 			:= 'Y';
	p_asg_nte_dates.lwop_nte 					:= null;
	p_asg_nte_dates.lwop_nte_start_date			:= null;
	p_asg_nte_dates.suspension_nte 				:= null;
	p_asg_nte_dates.suspension_nte_start_date 	:= null;
	p_asg_nte_dates.furlough_nte	 			:= null;
	p_asg_nte_dates.furlough_nte_start_date	 	:= null;
  elsif (l_noa_code = '452') then
	p_asg_nte_dates.asg_nte_dates_flag 			:= 'Y';
	p_asg_nte_dates.suspension_nte 			:= null;
	p_asg_nte_dates.suspension_nte_start_date 	:= null;
  elsif (l_noa_code in ('500','501','507','512','520','524','540',
                        '541','542','543','546','549','550','551',
                        '555','570')) then
     -- Removed 721 from the list for bug# 3215526
     -- Removed '702','713','740' from the list 3698464
     --
	p_asg_nte_dates.asg_nte_dates_flag 			:= 'Y';
	p_asg_nte_dates.asg_nte_start_date 			:= null;
	p_asg_nte_dates.assignment_nte		 	:= null;

  -- Bug# 4672772 Begin
  elsif l_noa_code in ('702','713') AND (l_old_user_status = 'Temp. Promotion NTE') THEN
        FOR user_apnt_status_rec IN c_user_apnt_status
        LOOP
            l_user_apnt_status := user_apnt_status_rec.user_status;
            l_user_apnt_eff_date := user_apnt_status_rec.effective_start_date;
            EXIT;
        END LOOP;
        --Begin Bug#6083404
        FOR user_actv_appt_rec IN c_user_actv_appt
        LOOP
            l_user_actv_apnt_status := user_actv_appt_rec.user_status;
            EXIT;
        END LOOP;
        --End Bug# 6083404
        IF l_user_apnt_status = 'Temp. Appointment NTE'
            and nvl(l_user_actv_apnt_status,'XXX') <>'Active Appointment' THEN
        --Bug# 6083404 added l_user_actv_apnt_status condition
            ghr_history_fetch.fetch_asgei
                      (p_assignment_id              =>  p_pa_request_rec.employee_assignment_id,
                       p_information_type           => 'GHR_US_ASG_NTE_DATES',
                       p_date_effective             =>  l_user_apnt_eff_date,
                       p_asg_ei_data                =>  l_asg_extra_info_rec
                      );
            p_asg_nte_dates.asg_nte_dates_flag 		:= 'Y';
            p_asg_nte_dates.asg_nte_start_date 		:= l_asg_extra_info_rec.aei_information3;
            p_asg_nte_dates.assignment_nte		 	:= l_asg_extra_info_rec.aei_information4;
        ELSE
            p_asg_nte_dates.asg_nte_dates_flag 		:= 'Y';
            p_asg_nte_dates.asg_nte_start_date 		:= null;
            p_asg_nte_dates.assignment_nte		 	:= null;
        END IF;
	-- Bug# 4672772 End
  --Begin Bug# 4602352
  elsif l_noa_code in ('702','713','740') AND (l_old_user_status = 'Temp. Appointment NTE') THEN
    p_asg_nte_dates.asg_nte_dates_flag 			:= 'Y';
	p_asg_nte_dates.asg_nte_start_date 			:= null;
	p_asg_nte_dates.assignment_nte		 	    := null;
  --End Bug# 4602352
  elsif (l_noa_code in ('300','301','302','303','304','312','317',
                        '330','350','351','353','355','356','357','385')) then
	p_asg_nte_dates.asg_nte_dates_flag 			:= 'Y';
	p_asg_nte_dates.asg_nte_start_date 			:= null;
	p_asg_nte_dates.assignment_nte		 	:= null;
	p_asg_nte_dates.lwop_nte 				:= null;
	p_asg_nte_dates.lwop_nte_start_date			:= null;
	p_asg_nte_dates.suspension_nte 			:= null;
	p_asg_nte_dates.suspension_nte_start_date 	:= null;
	p_asg_nte_dates.furlough_nte	 			:= null;
	p_asg_nte_dates.furlough_nte_start_date	 	:= null;
	p_asg_nte_dates.sabatical_nte	 			:= null;
	p_asg_nte_dates.sabatical_nte_start_date	 	:= null;
  end if;

END Process_Non_Sf52_Extra_Info;
--
End  GHR_SF52_PRE_UPDATE;
--

/
