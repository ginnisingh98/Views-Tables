--------------------------------------------------------
--  DDL for Package Body GHR_CORR_CANC_SF52
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_CORR_CANC_SF52" as
/* $Header: ghcorcan.pkb 120.17.12010000.21 2009/11/16 10:19:34 vmididho ship $ */
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <Ghr_Corr_Canc_SF52> >--------------------------|
-- ----------------------------------------------------------------------------
--

--
	TYPE pa_req_info is record (
		pa_request_id			ghr_pa_requests.pa_request_id%type,
		object_version_number		ghr_pa_requests.object_version_number%type,
		status				ghr_pa_requests.status%type,
		row_id				varchar2(20),
                cancel_legal_authority          ghr_pa_requests.first_action_la_code1%type
	);

	cursor c_get_sf52 (c_pa_request_id in number) is
	select
		*
	from ghr_pa_requests
	where pa_request_id = c_pa_request_id;

--

-- Declaring local procedures and functions
Procedure	delete_element_entry(
				p_hist_rec 		in 	ghr_pa_history%rowtype,
				p_del_mode		in	varchar2 default hr_api.g_delete_next_change,
   			p_cannot_cancel	 out nocopy Boolean) ;

Procedure	delete_eleentval( p_hist_rec in ghr_pa_history%rowtype) ;
Procedure	delete_peop_row(
				p_person_id		in	varchar2,
  				p_dt_mode		in	varchar2,
  				p_date_effective	in	date) ;
Procedure	delete_asgn_row(
				p_assignment_id	in	varchar2,
  				p_dt_mode		in	varchar2,
  				p_date_effective	in	date) ;
Procedure	delete_peopei_row( p_person_extra_info_id	in	varchar2) ;
Procedure	delete_asgnei_row( p_assignment_extra_info_id	in	varchar2) ;
Procedure	delete_posnei_row( p_position_extra_info_id	in	varchar2) ;
Procedure	delete_address_row(p_address_id	in	varchar2) ;
Procedure	delete_person_analyses_row ( p_person_analysis_id	in	number);

Procedure	delete_appl_row(
				p_table_name	in	varchar2,
  				p_table_pk_id	in	varchar2,
  				p_dt_mode		in	varchar2,
  				p_date_effective	in	date) ;
Procedure	delete_hist_row (
				p_row_id 			in	rowid);
Procedure	delete_hist_row (
				p_pa_history_id 	in	ghr_pa_history.pa_history_id%type);
Procedure	apply_correction(
				p_sf52rec_correct  	in 		ghr_pa_requests%rowtype,
				p_corr_pa_request_id	in		ghr_pa_requests.pa_request_id%type,
			 	p_sf52rec   		in out nocopy 	ghr_pa_requests%rowtype ) ;
Procedure apply_noa_corrections(
				p_sf52_data		in	ghr_pa_requests%rowtype,
				p_sf52_data_result in out nocopy ghr_pa_requests%rowtype );
Procedure Undo_Mark_Cancel(
				p_sf52_data  in  ghr_pa_requests%rowtype);

Procedure what_to_do(	p_datetrack_table		in		boolean,
				p_pre_record_exists 	in 		boolean,
				p_interv_on_table		in		boolean,
				p_interv_on_eff_date	in		boolean,
				p_rec_created_flag	in		boolean,
				p_can_delete	 out nocopy 	boolean,
				p_last_row		 out nocopy 	boolean,
				p_cannot_cancel	 out nocopy 	boolean) ;

Procedure convert_shadow_to_sf52 (
				p_shadow	 in   ghr_pa_request_shadow%rowtype,
				p_sf52 out nocopy ghr_pa_requests%rowtype);

Procedure IF_ZAP_ELE_ENT(
				p_element_entry_id	in	number,
				p_effective_start_date	in	date,
				p_pa_history_id		in	number,
				p_result	 out nocopy Boolean);

-- VSM [Procedures for delete subsequent correction functionality]
Procedure Process_Cancel (
	p_sf52_data in out nocopy ghr_pa_requests%rowtype);

Procedure Cancel_subs_correction (
	p_corr_sf52_detail in out nocopy pa_req_info,
		p_which_noa        in number);

-- Bug#2521744
-- This procedure will delete the first datetrack row for the
-- other pay elements/other elements whereever necessary.
Procedure delete_other_pay_entries(p_hist_rec in ghr_pa_history%rowtype,
                                    p_element_name in varchar2);

-- This procedure will get the other pay component values
-- at the time of intervening correction.
PROCEDURE get_sf52_to_othpays_for_ia
            (p_sf52_ia_rec in out nocopy ghr_pa_requests%rowtype);
-- End of Bug#2521744

Function get_sf52_ovn ( p_pa_request_id in number) return number;
--

-- 6850492 Added this procedure for dual action corrections
Procedure  apply_dual_noa_corrections(p_sf52_data		in	ghr_pa_requests%rowtype,
				      p_sf52_data_result in out nocopy ghr_pa_requests%rowtype );



----- End of Local procedure declaration -------

-- ---------------------------------------------------------------------------
-- |--------------------------< cancel_term_sf52>---------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure cancels a termination sf52.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_sf52_data		->		ghr_pa_requests record of the cancellation sf52.
--
-- Post Success:
-- 	The termination sf52 will have been cancelled.
--
-- Post Failure:
--   No failure conditions.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

Procedure cancel_term_SF52 ( p_sf52_data	in out nocopy ghr_pa_requests%rowtype) is

	-- this cursor gets the rowids from ghr_pa_history for the given pa_request_id.
	cursor c_hist ( c_pa_request_id	number,
			    c_noa_id		number) is
	select
		rowid row_id, table_name,pa_history_id,information5
                ,information9, information10
	from ghr_pa_history
	where pa_request_id = c_pa_request_id
	and  nature_of_action_id = c_noa_id
	for update of person_id
        order by pa_history_id desc; -- Bug# 1316321


	cursor c_follow_rec( 	c_table_name	ghr_pa_history.table_name%type,
					c_pk_id		ghr_pa_history.information1%type,
					c_pa_history_id	ghr_pa_history.pa_history_id%type) is
	select 	pa_history_id
	from		ghr_pa_history
	where		table_name		= c_table_name
		and	information1	= c_pk_id
		and 	pa_history_id	> c_pa_history_id;


        cursor c_hist_sevpay ( c_pa_request_id  number,
                            c_table_name       ghr_pa_history.table_name%type) IS
        select  *
        from ghr_pa_history
        where pa_request_id = c_pa_request_id
          and table_name    = c_table_name;


	l_buf				number;
	l_follow_rec		boolean;
	l_hist_pre			ghr_pa_history%rowtype;
	l_hist_rec			ghr_pa_history%rowtype;
        l_hist_sevpay                   ghr_pa_history%rowtype;
        l_cannot_cancel_sevpay          boolean;
	l_interv_on_table		boolean;
	l_interv_on_eff_date	boolean;
	l_hist_data_as_of_date	ghr_pa_history%rowtype;
	l_session_var	ghr_history_api.g_session_var_type;
	l_agency_ei_data	ghr_pa_request_extra_info%rowtype;
	l_imm_asg_sf52          	ghr_api.asg_sf52_type;
	l_imm_asg_non_sf52		ghr_api.asg_non_sf52_type;
	l_imm_asg_nte_dates     	ghr_api.asg_nte_dates_type;
	l_imm_per_sf52          	ghr_api.per_sf52_type;
	l_imm_per_group1        	ghr_api.per_group1_type;
	l_imm_per_group2        	ghr_api.per_group2_type;
	l_imm_per_scd_info      	ghr_api.per_scd_info_type;
	l_imm_per_retained_grade    ghr_api.per_retained_grade_type;
	l_imm_per_probations        ghr_api.per_probations_type;
	l_imm_per_sep_retire        ghr_api.per_sep_retire_type;
	l_imm_per_security		    ghr_api.per_security_type;
	-- Bug#4486823 RRR changes
	l_imm_per_service_oblig     ghr_api.per_service_oblig_type;
	l_imm_per_conversions		ghr_api.per_conversions_type;
	-- 4352589 BEN_EIT Changes
	l_imm_per_benefit_info        ghr_api.per_benefit_info_type;
	l_imm_per_uniformed_services  ghr_api.per_uniformed_services_type;
	l_imm_pos_oblig               ghr_api.pos_oblig_type;
	l_imm_pos_grp2                ghr_api.pos_grp2_type;
	l_imm_pos_grp1                ghr_api.pos_grp1_type;
	l_imm_pos_valid_grade         ghr_api.pos_valid_grade_type;
	l_imm_pos_car_prog            ghr_api.pos_car_prog_type;
	l_imm_loc_info                ghr_api.loc_info_type;
	l_imm_wgi     	            ghr_api.within_grade_increase_type;
	l_imm_gov_awards              ghr_api.government_awards_type;
	l_imm_recruitment_bonus	      ghr_api.recruitment_bonus_type;
	l_imm_relocation_bonus		ghr_api.relocation_bonus_type;
	l_imm_student_loan_repay  	ghr_api.student_loan_repay_type;
	--Pradeep
	l_imm_mddds_special_pay         ghr_api.mddds_special_pay_type;
	l_imm_premium_pay_ind           ghr_api.premium_pay_ind_type;

	l_imm_extra_info_rec	 	ghr_api.extra_info_rec_type ;
	l_imm_sf52_from_data          ghr_api.prior_sf52_data_type;
	l_imm_personal_info		ghr_api.personal_info_type;
	l_imm_generic_extra_info_rec	ghr_api.generic_extra_info_rec_type ;
	l_imm_agency_sf52		      ghr_api.agency_sf52_type;
	l_agency_code			varchar2(50);
	l_imm_perf_appraisal          ghr_api.performance_appraisal_type;
	l_imm_conduct_performance     ghr_api.conduct_performance_type;
	l_imm_payroll_type            ghr_api.government_payroll_type;
	l_imm_par_term_retained_grade ghr_api.par_term_retained_grade_type;
	l_imm_entitlement             ghr_api.entitlement_type;
        -- Bug#2759379 Added FEGLI Record
        l_imm_fegli                   ghr_api.fegli_type;
	l_imm_foreign_lang_prof_pay   ghr_api.foreign_lang_prof_pay_type;
	-- Bug#3385386 Added FTA Record
	l_imm_fta                     ghr_api.fta_type;
	l_imm_edp_pay                 ghr_api.edp_pay_type;
	l_imm_hazard_pay              ghr_api.hazard_pay_type;
	l_imm_health_benefits         ghr_api.health_benefits_type;
	l_imm_danger_pay              ghr_api.danger_pay_type;
	l_imm_imminent_danger_pay     ghr_api.imminent_danger_pay_type;
	l_imm_living_quarters_allow   ghr_api.living_quarters_allow_type;
	l_imm_post_diff_amt           ghr_api.post_diff_amt_type;
	l_imm_post_diff_percent       ghr_api.post_diff_percent_type;
	l_imm_sep_maintenance_allow   ghr_api.sep_maintenance_allow_type;
	l_imm_supplemental_post_allow ghr_api.supplemental_post_allow_type;
	l_imm_temp_lodge_allow        ghr_api.temp_lodge_allow_type;
 	l_imm_premium_pay             ghr_api.premium_pay_type;
 	l_imm_retirement_annuity      ghr_api.retirement_annuity_type;
	l_imm_severance_pay           ghr_api.severance_pay_type;
 	l_imm_thrift_saving_plan      ghr_api.thrift_saving_plan;
 	l_imm_retention_allow_review  ghr_api.retention_allow_review_type;
	l_imm_health_ben_pre_tax      ghr_api.health_ben_pre_tax_type;
	l_imm_per_race_ethnic_info 	  ghr_api.per_race_ethnic_type; -- Bug 4724337 Race or National Origin changes
        --Bug# 6312144
        l_imm_ipa_benefits_cont       ghr_api.per_ipa_ben_cont_info_type;
        l_imm_retirement_info         ghr_api.per_retirement_info_type;

	l_sf52_data	              ghr_pa_requests%rowtype;
	l_sf52_data_rec           ghr_pa_requests%rowtype;
	l_health_plan	              varchar2(30);
	l_error_flag		      boolean;
	l_return_status	varchar2(30);

        l_position_definition_id      number;
        l_pos_name                    varchar2(2000);
        l_valid_grades_changed_warning boolean;
        l_object_version_number       number;
        l_effective_start_date        date;
        l_effective_end_date          date;

	l_result		varchar2(30);
	l_proc	varchar2(30):='cancel_term_SF52';
--

Begin

	hr_utility.set_location( 'entering : ' || l_proc, 10);
   l_sf52_data_rec := p_sf52_data;
--
--
	-- reinitialise session variables
	ghr_history_api.reinit_g_session_var;
	-- set values of session variables

	l_session_var.pa_request_id 	:= p_sf52_data.pa_request_id;
	l_session_var.noa_id		:= p_sf52_data.second_noa_id;
	-- No triggers should be fired as cancellation can not be corrected or cancelled
	-- so none of the changes will be saved.
	l_session_var.fire_trigger	:= 'N';
	l_session_var.date_Effective	:= p_sf52_data.effective_date;
	l_session_var.person_id		:= p_sf52_data.person_id;
	l_session_var.program_name	:= 'sf50';
	l_session_var.assignment_id	:= p_sf52_data.employee_assignment_id;
	l_session_var.altered_pa_request_id	:= p_sf52_data.altered_pa_request_id;
	l_session_var.noa_id_correct	:= p_sf52_data.second_noa_id;
	ghr_history_api.set_g_session_var(l_session_var);

	ghr_process_Sf52.Fetch_extra_info(
			p_pa_request_id 	=> p_sf52_data.pa_request_id,
			p_noa_id   		=> p_sf52_data.second_noa_id,
			p_agency_ei		=> TRUE,
			p_sf52_ei_data 	=> l_agency_ei_data,
			p_result		=> l_result);

	l_sf52_data 	:= p_sf52_data;
	-- all corrections will have the original sf52 information in the 2nd noa columns, so
	-- copy that information to 1st noa columns.
	ghr_process_sf52.copy_2ndNoa_to_1stNoa(l_sf52_data);
	-- null the second noa columns since we don't want anything to be done with these now.
	ghr_process_sf52.null_2ndNoa_cols(l_sf52_data);
	ghr_sf52_pre_update.populate_record_groups (
		 	p_pa_request_rec                => l_sf52_data,
			p_generic_ei_rec                => l_agency_ei_data,
			p_imm_asg_sf52                  => l_imm_asg_sf52,
			p_imm_asg_non_sf52              => l_imm_asg_non_sf52,
			p_imm_asg_nte_dates             => l_imm_asg_nte_dates,
			p_imm_per_sf52                  => l_imm_per_sf52,
			p_imm_per_group1                => l_imm_per_group1,
			p_imm_per_group2                => l_imm_per_group2,
			p_imm_per_scd_info              => l_imm_per_scd_info,
			p_imm_per_retained_grade        => l_imm_per_retained_grade,
			p_imm_per_probations            => l_imm_per_probations,
			p_imm_per_sep_retire            => l_imm_per_sep_retire,
			p_imm_per_security              => l_imm_per_security,
			--Bug#4486823 RRR Changes
            p_imm_per_service_oblig         => l_imm_per_service_oblig,
			p_imm_per_conversions           => l_imm_per_conversions,
			-- 4352589 BEN_EIT Changes
			p_imm_per_benefit_info          => l_imm_per_benefit_info,
			p_imm_per_uniformed_services    => l_imm_per_uniformed_services,
			p_imm_pos_oblig                 => l_imm_pos_oblig,
			p_imm_pos_grp2                  => l_imm_pos_grp2,
			p_imm_pos_grp1                  => l_imm_pos_grp1,
			p_imm_pos_valid_grade           => l_imm_pos_valid_grade,
			p_imm_pos_car_prog              => l_imm_pos_car_prog,
			p_imm_loc_info                  => l_imm_loc_info,
			p_imm_wgi                       => l_imm_wgi,
			p_imm_gov_awards                => l_imm_gov_awards,
			p_imm_recruitment_bonus         => l_imm_recruitment_bonus,
			p_imm_relocation_bonus          => l_imm_relocation_bonus,
			p_imm_student_loan_repay        => l_imm_student_loan_repay,
			p_imm_per_race_ethnic_info 		=> l_imm_per_race_ethnic_info, -- Bug 4724337 Race or National Origin changes
			--Pradeep
			p_imm_mddds_special_pay         => l_imm_mddds_special_pay,
			p_imm_premium_pay_ind           => l_imm_premium_pay_ind,

			p_imm_perf_appraisal            => l_imm_perf_appraisal,
			p_imm_conduct_performance       => l_imm_conduct_performance,
			p_imm_payroll_type              => l_imm_payroll_type,
			p_imm_extra_info_rec	        => l_imm_extra_info_rec,
			p_imm_sf52_from_data            => l_imm_sf52_from_data,
			p_imm_personal_info	        	=> l_imm_personal_info,
			p_imm_generic_extra_info_rec    => l_imm_generic_extra_info_rec,
			p_imm_agency_sf52               => l_imm_agency_sf52,
			p_agency_code                   => l_agency_code,
			p_imm_par_term_retained_grade   => l_imm_par_term_retained_grade,
			p_imm_entitlement               => l_imm_entitlement,
                        -- Bug#2759379 Added FEGLI Record
            p_imm_fegli                     => l_imm_fegli,
			p_imm_foreign_lang_prof_pay     => l_imm_foreign_lang_prof_pay,
			-- Bug#3385386 Added FTA Record
			p_imm_fta                       => l_imm_fta,
			p_imm_edp_pay                   => l_imm_edp_pay,
			p_imm_hazard_pay                => l_imm_hazard_pay,
			p_imm_health_benefits           => l_imm_health_benefits,
			p_imm_danger_pay                => l_imm_danger_pay,
			p_imm_imminent_danger_pay       => l_imm_imminent_danger_pay,
			p_imm_living_quarters_allow     => l_imm_living_quarters_allow,
			p_imm_post_diff_amt             => l_imm_post_diff_amt,
			p_imm_post_diff_percent         => l_imm_post_diff_percent,
			p_imm_sep_maintenance_allow     => l_imm_sep_maintenance_allow,
			p_imm_supplemental_post_allow   => l_imm_supplemental_post_allow,
			p_imm_temp_lodge_allow          => l_imm_temp_lodge_allow,
			p_imm_premium_pay               => l_imm_premium_pay,
			p_imm_retirement_annuity        => l_imm_retirement_annuity,
			p_imm_severance_pay             => l_imm_severance_pay,
			p_imm_thrift_saving_plan        => l_imm_thrift_saving_plan,
			p_imm_retention_allow_review    => l_imm_retention_allow_review,
			p_imm_health_ben_pre_tax        => l_imm_health_ben_pre_tax,
			--Bug# 6312144 RPA EIT Benefits
			p_imm_ipa_benefits_cont         => l_imm_ipa_benefits_cont,
                        p_imm_retirement_info           => l_imm_retirement_info
                         );
--
   		ghr_api.retrieve_element_entry_value
		( p_element_name	=> 'Health Benefits'
		 ,p_input_value_name    =>  'Health Plan'
		 ,p_assignment_id       =>   l_sf52_data.employee_assignment_id
		 ,p_effective_date      =>   trunc(l_sf52_data.effective_date)
		 ,p_value               =>   l_health_plan
		 ,p_multiple_error_flag =>   l_error_flag
		 );
--
	GHR_AGENCY_CHECK.AGENCY_CHECK(
			p_pa_request_rec			=> l_sf52_data,
			p_asg_sf52					=> l_imm_asg_sf52,
			p_asg_non_sf52				=> l_imm_asg_non_sf52,
			p_asg_nte_dates				=> l_imm_asg_nte_dates,
			p_per_sf52              	=> l_imm_per_sf52,
			p_per_group1            	=> l_imm_per_group1,
			p_per_group2            	=> l_imm_per_group2,
			p_per_scd_info          	=> l_imm_per_scd_info,
			p_per_retained_grade    	=> l_imm_per_retained_grade,
			p_per_probations			=> l_imm_per_probations,
			p_per_sep_Retire 	      	=> l_imm_per_sep_retire,
			p_per_security          	=> l_imm_per_security,
			p_per_conversions	      	=> l_imm_per_conversions,
			p_per_uniformed_services	=> l_imm_per_uniformed_services,
			p_pos_oblig                   => l_imm_pos_oblig,
			p_pos_grp2                    => l_imm_pos_grp2,
			p_pos_grp1                    => l_imm_pos_grp1,
			p_pos_valid_grade             => l_imm_pos_valid_grade,
			p_pos_car_prog                => l_imm_pos_car_prog,
			p_loc_info                    => l_imm_loc_info,
			p_wgi                         => l_imm_wgi,
			p_recruitment_bonus	      => l_imm_recruitment_bonus,
			p_relocation_bonus	      => l_imm_relocation_bonus ,
			p_sf52_from_data              => l_imm_sf52_from_data,
			p_personal_info	            => l_imm_personal_info,
			p_gov_awards_type             => l_imm_gov_awards,
			p_perf_appraisal_type         => l_imm_perf_appraisal,
			p_payroll_type                => l_imm_payroll_type,
			p_conduct_perf_type           => l_imm_conduct_performance,
			p_agency_code		      => l_agency_code,
			p_agency_sf52			=> l_imm_agency_sf52,
			p_health_plan			=> l_health_plan,
			p_entitlement                 => l_imm_entitlement,
			p_foreign_lang_prof_pay       => l_imm_foreign_lang_prof_pay,
			p_edp_pay                     => l_imm_edp_pay,
			p_hazard_pay                  => l_imm_hazard_pay,
			p_health_benefits             => l_imm_health_benefits,
			p_danger_pay                  => l_imm_danger_pay,
			p_imminent_danger_pay         => l_imm_imminent_danger_pay,
			p_living_quarters_allow       => l_imm_living_quarters_allow,
			p_post_diff_amt               => l_imm_post_diff_amt,
			p_post_diff_percent           => l_imm_post_diff_percent,
			p_sep_maintenance_allow       => l_imm_sep_maintenance_allow,
			p_supplemental_post_allow     => l_imm_supplemental_post_allow,
			p_temp_lodge_allow            => l_imm_temp_lodge_allow,
			p_premium_pay                 => l_imm_premium_pay,
			p_retirement_annuity          => l_imm_retirement_annuity,
			p_severance_pay               => l_imm_severance_pay,
			p_thrift_saving_plan          => l_imm_thrift_saving_plan,
			p_retention_allow_review      => l_imm_retention_allow_review,
			p_health_ben_pre_tax          => l_imm_health_ben_pre_tax,
            p_per_benefit_info            => l_imm_per_benefit_info,
            p_imm_retirement_info         => l_imm_retirement_info );--Bug# 7131104

        -- call to cancel termination moved after history handling. Bug# 1316321

	-- if this was a 352 termination, then the following special handling is required.
	if p_sf52_data.second_noa_code = '352' then
		-- null out end_date for position

                -- Added by Edward Nunez (Position Date Track Changes Phase 2).
/*
            -- Deleting of Position Rows handled by code below ref bug 2983738.
		-- Need to delete end dated position record only if it's MTO -- Sundar 2835138
		IF (UPPER(SUBSTR(p_sf52_data.request_number,1,3)) = 'MTO') THEN
		-- End 2835138
                SELECT name, object_version_number
                  INTO l_pos_name, l_object_version_number
                FROM hr_all_positions_f
                WHERE position_id = p_sf52_data.from_position_id
                  AND (p_sf52_data.effective_date  - 1) BETWEEN effective_start_date
                                                     AND effective_end_date;
                 hr_position_api.delete_position
                 (p_position_id                   => p_sf52_data.from_position_id,
                  p_object_version_number         => l_object_version_number,
                  p_effective_date                => p_sf52_data.effective_date - 1,
                  p_effective_start_date          => l_effective_start_date,
                  p_effective_end_date            => l_effective_end_date,
                  p_datetrack_mode                => 'DELETE_NEXT_CHANGE'
                  );
		END IF; -- If MTO
*/
                --

/*  -- Commented out by Edward Nunez (Position Date Track changes Phase 2).
		UPDATE 	per_positions
		SET 		date_end = null
		WHERE	 	position_id = p_sf52_data.from_position_id;
*/

		-- Bug # 9081332 Added the Exception to handle if there are no rows exists

		BEGIN
		SELECT 	*
		INTO 	l_hist_rec
		FROM 	ghr_pa_history
		WHERE	pa_request_id 		= p_sf52_data.altered_pa_request_id
		AND	information5 		= 'GHR_US_PER_SEPARATE_RETIRE'
		AND	table_name			= ghr_history_api.g_peopei_table
		AND	nature_of_action_id 	= (select nature_of_action_id from ghr_nature_of_actions where
									code = '352');



 		ghr_history_api.fetch_history_info(
 			p_table_name 		=> ghr_history_api.g_peopei_table,
  			p_hist_data			=> l_hist_pre,
  			p_pa_history_id		=> l_hist_rec.pa_history_id,
  			p_table_pk_id 		=> l_hist_rec.information1,
  			p_person_id			=> p_sf52_data.person_id,
  			p_date_effective		=> p_sf52_data.effective_date,
  			p_result_code		=> l_return_status);
  		if (l_return_status is not null) then
			-- there were no prevalues for this record
		      hr_utility.set_location('no pre-values'|| l_proc,15);
			-- only delete application table if there are no following records.
			open c_follow_rec(	c_table_name	=>	l_hist_rec.table_name,
							c_pk_id		=>	l_hist_rec.information1,
							c_pa_history_id	=>	l_hist_rec.pa_history_id);
			fetch c_follow_rec into l_buf;
			if c_follow_rec%NOTFOUND then
		      hr_utility.set_location('no following records. Deleting appl table. '|| l_proc,915);
			delete_appl_row(
				p_table_name	=> ghr_history_api.g_peopei_table,
				p_table_pk_id	=> l_hist_rec.information1,
				p_dt_mode		=> null,
				p_date_effective	=> l_hist_rec.effective_date);
			end if;
			close c_follow_rec;

		else
			-- there is a pre record, so apply it to the history table and to the application table.
 			ghr_history_cascade.cascade_history_data (
  				p_table_name		=> 	l_hist_rec.table_name,
  				p_person_id			=>	l_hist_rec.person_id,
  				p_pre_record		=>	l_hist_pre,
  				p_post_record		=>	l_hist_rec,
  				p_cascade_type		=>	'cancel',
  				p_interv_on_table 	=>	l_interv_on_table,
  				p_interv_on_eff_date	=>	l_interv_on_eff_date,
  				p_hist_data_as_of_date	=>	l_hist_data_as_of_date);
 			ghr_history_cascade.cascade_appl_table_data (
  				p_table_name		=> 	l_hist_rec.table_name,
  				p_person_id			=>	l_hist_rec.person_id,
  				p_pre_record		=>	l_hist_pre,
  				p_post_record		=>	l_hist_rec,
  				p_cascade_type		=>	'cancel',
  				p_interv_on_table 	=>	l_interv_on_table,
  				p_interv_on_eff_date	=>	l_interv_on_eff_date,
  				p_hist_data_as_of_date	=>	l_hist_data_as_of_date);

 		end if;
		EXCEPTION
		WHEN NO_DATA_FOUND THEN
		     NULL;
		END;

	end if;

-- Bug#2082535
     Open c_hist_sevpay(p_sf52_data.altered_pa_request_id,ghr_history_api.g_eleent_table);
        fetch c_hist_sevpay into l_hist_sevpay;
        if c_hist_sevpay%notfound then
                -- raise error;
                close c_hist_sevpay;
        else

          delete_element_entry( p_hist_rec   => l_hist_sevpay,
                         p_del_mode          => hr_api.g_zap,
                         p_cannot_cancel     => l_cannot_cancel_sevpay);

          if l_cannot_cancel_sevpay then
            -- raise error
           hr_utility.set_location('ERROR: Cannot Cancel'|| l_proc,35);
           hr_utility.set_message(8301,'GHR_38212_CANNOT_CANCEL');
           hr_utility.raise_error;
          else
           hr_utility.set_location('Delete rows.'|| l_proc,40);
           delete_hist_row ( l_hist_sevpay.pa_history_id);
           delete_eleentval( l_hist_sevpay);
          end if;
          close c_hist_sevpay;
        end if;

-- Bug#2082535

	-- delete all history records for the termination that is being cancelled.
	-- if an address table record is encountered, then set application
	-- table to what it currently should be according to history.
	hr_utility.set_location( l_proc, 20);
	for l_hist in c_hist( p_sf52_data.altered_pa_request_id,
				    l_session_var.noa_id_correct)
	loop
                hr_utility.set_location(' LOOP history_id(' || l_hist.pa_history_id || ')', 25);
		exit when c_hist%notfound;
		-- Bug#3780671 Added the Assignment Extra Info condition as
		-- the EIT "GHR_US_ASG_NTE_DATES" requires the process similar to
		-- Address table.
		IF (l_hist.table_name = ghr_history_api.g_addres_table) OR
		   (l_hist.table_name = 'PER_ASSIGNMENT_EXTRA_INFO' and
                    l_hist.information5 = 'GHR_US_ASG_NTE_DATES') THEN

			SELECT 	*
			INTO 		l_hist_rec
			FROM 		ghr_pa_history
			WHERE		pa_history_id	= l_hist.pa_history_id;

                        hr_utility.set_location('Non 352 and  Address '||l_hist.table_name,26);
			-- Bug#3780671 Passed the parameter l_hist.table_name instead of Address table
			--             to handle PER_ASSIGNMENT_EXTRA_INFO table.
	 		ghr_history_api.fetch_history_info(
	 			p_table_name 		=> l_hist.table_name,
  				p_hist_data		=> l_hist_pre,
  				p_pa_history_id		=> l_hist_rec.pa_history_id,
  				p_table_pk_id 		=> l_hist_rec.information1,
  				p_person_id		=> p_sf52_data.person_id,
  				p_date_effective	=> p_sf52_data.effective_date,
  				p_result_code		=> l_return_status);
  			if (l_return_status is not null) then
				-- there were no prevalues for this record
			    	hr_utility.set_location('no pre-values'|| l_proc,15);
				-- only delete application table if there are no following records.
				open c_follow_rec(	c_table_name	=>	l_hist_rec.table_name,
								c_pk_id		=>	l_hist_rec.information1,
								c_pa_history_id	=>	l_hist_rec.pa_history_id);
				fetch c_follow_rec into l_buf;
				if c_follow_rec%NOTFOUND then
				        -- Bug#3780671 Passed the parameter l_hist.table_name instead of Address table
			                --             to handle PER_ASSIGNMENT_EXTRA_INFO table.
					delete_appl_row(
						p_table_name	=> l_hist.table_name,
						p_table_pk_id	=> l_hist_rec.information1,
						p_dt_mode		=> null,
						p_date_effective	=> l_hist_rec.effective_date);
				end if;
				close c_follow_rec;
			else
				-- there is a pre record, so apply it to the history table and to the application table.
 				ghr_history_cascade.cascade_history_data (
  					p_table_name		=> 	l_hist_rec.table_name,
  					p_person_id			=>	l_hist_rec.person_id,
  					p_pre_record		=>	l_hist_pre,
  					p_post_record		=>	l_hist_rec,
  					p_cascade_type		=>	'cancel',
  					p_interv_on_table 	=>	l_interv_on_table,
  					p_interv_on_eff_date	=>	l_interv_on_eff_date,
  					p_hist_data_as_of_date	=>	l_hist_data_as_of_date);
				delete_hist_row( l_hist.row_id);
				ghr_history_cascade.cascade_appl_table_data (
					p_table_name		=> 	l_hist_rec.table_name,
					p_person_id			=>	l_hist_rec.person_id,
					p_pre_record		=>	l_hist_pre,
					p_post_record		=>	l_hist_rec,
					p_cascade_type		=>	'cancel',
					p_interv_on_table 	=>	l_interv_on_table,
					p_interv_on_eff_date	=>	l_interv_on_eff_date,
					p_hist_data_as_of_date	=>	l_hist_data_as_of_date);
			end if;

--		else
                hr_utility.set_location('Non 352 and  delete_hist_row '||l_proc,27);
--			delete_hist_row( l_hist.row_id);
		end if;
	end loop;

	-- delete all history records for the termination that is being cancelled.
	-- if an address table record is encountered, then set application
	-- table to what it currently should be according to history.
	hr_utility.set_location( l_proc, 20);
	for l_hist in c_hist( p_sf52_data.altered_pa_request_id,
				    l_session_var.noa_id_correct)
	loop
          exit when c_hist%notfound;
          delete_hist_row( l_hist.row_id);
        end loop;

        -- Moved after history handling due to bug# 1316321
	-- call core HR api to cancel the termination.
	hrempter.cancel_termination(
		p_person_id				=> p_sf52_data.person_id,
		p_Actual_termination_date 	=> p_sf52_data.effective_date
         	);
-- added to resolve bug#2205014
-- Commented the following procedure call as this is included in hrempter.cancel_termination
-- through Core HR Bug#3889294
/*      hr_per_type_usage_internal.cancel_person_type_usage
        (p_effective_date       => p_sf52_data.effective_date + 1
        ,p_person_id            => p_sf52_data.person_id
        ,p_system_person_type   => 'EX_EMP');
*/


	ghr_agency_update.ghr_agency_upd(
			p_pa_request_rec			=> l_sf52_data,
			p_asg_sf52				=> l_imm_asg_sf52,
			p_asg_non_sf52			=> l_imm_asg_non_sf52,
			p_asg_nte_dates			=> l_imm_asg_nte_dates,
			p_per_sf52              	=> l_imm_per_sf52,
			p_per_group1            	=> l_imm_per_group1,
			p_per_group2            	=> l_imm_per_group2,
			p_per_scd_info          	=> l_imm_per_scd_info,
			p_per_retained_grade    	=> l_imm_per_retained_grade,
			p_per_probations			=> l_imm_per_probations,
			p_per_sep_Retire 	      	=> l_imm_per_sep_retire,
			p_per_security          	=> l_imm_per_security,
			p_per_conversions	      	=> l_imm_per_conversions,
			p_per_uniformed_services	=> l_imm_per_uniformed_services,
			p_pos_oblig                   => l_imm_pos_oblig,
			p_pos_grp2                    => l_imm_pos_grp2,
			p_pos_grp1                    => l_imm_pos_grp1,
			p_pos_valid_grade             => l_imm_pos_valid_grade,
			p_pos_car_prog                => l_imm_pos_car_prog,
			p_loc_info                    => l_imm_loc_info,
			p_wgi                         => l_imm_wgi,
			p_recruitment_bonus	      => l_imm_recruitment_bonus,
			p_relocation_bonus	      => l_imm_relocation_bonus ,
			p_sf52_from_data              => l_imm_sf52_from_data,
			p_personal_info	            => l_imm_personal_info,
			p_gov_awards_type             => l_imm_gov_awards,
			p_perf_appraisal_type         => l_imm_perf_appraisal,
			p_payroll_type                => l_imm_payroll_type,
			p_conduct_perf_type           => l_imm_conduct_performance,
			p_agency_code		      => l_agency_code,
			p_agency_sf52			=> l_imm_agency_sf52,
			p_entitlement                 => l_imm_entitlement,
			p_foreign_lang_prof_pay       => l_imm_foreign_lang_prof_pay,
			p_edp_pay                     => l_imm_edp_pay,
			p_hazard_pay                  => l_imm_hazard_pay,
			p_health_benefits             => l_imm_health_benefits,
			p_danger_pay                  => l_imm_danger_pay,
			p_imminent_danger_pay         => l_imm_imminent_danger_pay,
			p_living_quarters_allow       => l_imm_living_quarters_allow,
			p_post_diff_amt               => l_imm_post_diff_amt,
			p_post_diff_percent           => l_imm_post_diff_percent,
			p_sep_maintenance_allow       => l_imm_sep_maintenance_allow,
			p_supplemental_post_allow     => l_imm_supplemental_post_allow,
			p_temp_lodge_allow            => l_imm_temp_lodge_allow,
			p_premium_pay                 => l_imm_premium_pay,
			p_retirement_annuity          => l_imm_retirement_annuity,
			p_severance_pay               => l_imm_severance_pay,
			p_thrift_saving_plan          => l_imm_thrift_saving_plan,
			p_retention_allow_review      => l_imm_retention_allow_review,
			p_health_ben_pre_tax          => l_imm_health_ben_pre_tax,
            p_per_benefit_info            => l_imm_per_benefit_info,
            p_imm_retirement_info         => l_imm_retirement_info); --Bug# 7131104

	-- call post_sf52_cancel to handle notifications, marking pa_requests cancelled, etc.
	hr_utility.set_location( l_proc, 30);
	ghr_sf52_post_update.post_sf52_cancel(
		p_pa_request_id		=> p_sf52_data.pa_request_id,
		p_effective_date	=> l_session_var.date_effective,
		p_object_version_number	=> p_sf52_data.object_version_number,
		p_from_position_id	=> p_sf52_data.from_position_id,
		p_to_position_id	=> p_sf52_data.to_position_id,
		p_agency_code		=> p_sf52_data.agency_code);

	hr_utility.set_location( 'leaving : ' || l_proc, 40);
  exception when others then
                 --
                 -- Reset IN OUT parameters and set OUT parameters
                 --
                 p_sf52_data := l_sf52_data_rec;
                 raise;
end cancel_term_SF52;

-- ---------------------------------------------------------------------------
-- |--------------------------< cancel_appt_sf52>---------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure cancels an appointment sf52.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_sf52_data		->		ghr_pa_requests record of the cancellation sf52.
--
-- Post Success:
-- 	The appointment sf52 will have been cancelled.
--
-- Post Failure:
--   No failure conditions.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

Procedure Cancel_Appt_SF52( p_sf52_data		in out nocopy 	ghr_pa_requests%rowtype) is

	l_session_var	ghr_history_api.g_session_var_type;
	l_hist_post		ghr_pa_history%rowtype;
	l_business_group_id	number;
	l_u_prh_object_version_number number;
	l_i_pa_routing_history_id     number;
	l_i_prh_object_version_number number;
	l_agency_ei_data	ghr_pa_request_extra_info%rowtype;
	l_imm_asg_sf52          	ghr_api.asg_sf52_type;
	l_imm_asg_non_sf52		ghr_api.asg_non_sf52_type;
	l_imm_asg_nte_dates     	ghr_api.asg_nte_dates_type;
	l_imm_per_sf52          	ghr_api.per_sf52_type;
	l_imm_per_group1        	ghr_api.per_group1_type;
	l_imm_per_group2        	ghr_api.per_group2_type;
	l_imm_per_scd_info      	ghr_api.per_scd_info_type;
	l_imm_per_retained_grade      ghr_api.per_retained_grade_type;
	l_imm_per_probations          ghr_api.per_probations_type;
	l_imm_per_sep_retire          ghr_api.per_sep_retire_type;
	l_imm_per_security		ghr_api.per_security_type;
	-- Bug#4486823 RRR changes
	l_imm_per_service_oblig     ghr_api.per_service_oblig_type;
	l_imm_per_conversions		ghr_api.per_conversions_type;
	-- 4352589 BEN_EIT Changes
	l_imm_per_benefit_info        ghr_api.per_benefit_info_type;
	l_imm_per_uniformed_services  ghr_api.per_uniformed_services_type;
	l_imm_pos_oblig               ghr_api.pos_oblig_type;
	l_imm_pos_grp2                ghr_api.pos_grp2_type;
	l_imm_pos_grp1                ghr_api.pos_grp1_type;
	l_imm_pos_valid_grade         ghr_api.pos_valid_grade_type;
	l_imm_pos_car_prog            ghr_api.pos_car_prog_type;
	l_imm_loc_info                ghr_api.loc_info_type;
	l_imm_wgi     	            ghr_api.within_grade_increase_type;
	l_imm_gov_awards              ghr_api.government_awards_type;
	l_imm_recruitment_bonus	      ghr_api.recruitment_bonus_type;
	l_imm_relocation_bonus		ghr_api.relocation_bonus_type;
	l_imm_student_loan_repay  	ghr_api.student_loan_repay_type;
	--Pradeep
	l_imm_mddds_special_pay         ghr_api.mddds_special_pay_type;
	l_imm_premium_pay_ind           ghr_api.premium_pay_ind_type;

	l_imm_extra_info_rec	 	ghr_api.extra_info_rec_type ;
	l_imm_sf52_from_data          ghr_api.prior_sf52_data_type;
	l_imm_personal_info		ghr_api.personal_info_type;
	l_imm_generic_extra_info_rec	ghr_api.generic_extra_info_rec_type ;
	l_imm_agency_sf52		      ghr_api.agency_sf52_type;
	l_agency_code			varchar2(50);
	l_imm_perf_appraisal          ghr_api.performance_appraisal_type;
	l_imm_conduct_performance     ghr_api.conduct_performance_type;
	l_imm_payroll_type            ghr_api.government_payroll_type;
	l_imm_par_term_retained_grade ghr_api.par_term_retained_grade_type;
	l_imm_entitlement             ghr_api.entitlement_type;
        -- Bug#2759379 Added FEGLI Record
    l_imm_fegli                   ghr_api.fegli_type;
	l_imm_foreign_lang_prof_pay   ghr_api.foreign_lang_prof_pay_type;
	-- Bug#3385386 Added FTA Record
	l_imm_fta                     ghr_api.fta_type;
	l_imm_edp_pay                 ghr_api.edp_pay_type;
	l_imm_hazard_pay              ghr_api.hazard_pay_type;
	l_imm_health_benefits         ghr_api.health_benefits_type;
	l_imm_danger_pay              ghr_api.danger_pay_type;
	l_imm_imminent_danger_pay     ghr_api.imminent_danger_pay_type;
	l_imm_living_quarters_allow   ghr_api.living_quarters_allow_type;
	l_imm_post_diff_amt           ghr_api.post_diff_amt_type;
	l_imm_post_diff_percent       ghr_api.post_diff_percent_type;
	l_imm_sep_maintenance_allow   ghr_api.sep_maintenance_allow_type;
	l_imm_supplemental_post_allow ghr_api.supplemental_post_allow_type;
	l_imm_temp_lodge_allow        ghr_api.temp_lodge_allow_type;
	l_imm_premium_pay             ghr_api.premium_pay_type;
	l_imm_retirement_annuity      ghr_api.retirement_annuity_type;
	l_imm_severance_pay           ghr_api.severance_pay_type;
	l_imm_thrift_saving_plan      ghr_api.thrift_saving_plan;
	l_imm_retention_allow_review  ghr_api.retention_allow_review_type;
	l_imm_health_ben_pre_tax         ghr_api.health_ben_pre_tax_type;
	l_imm_per_race_ethnic_info 	  ghr_api.per_race_ethnic_type; -- Bug 4724337 Race or National Origin changes
	l_sf52_data				ghr_pa_requests%rowtype;
	l_sf52_data_rec      ghr_pa_requests%rowtype;
	l_health_plan			varchar2(30);
	l_error_flag			boolean;
	l_return_status	varchar2(30);
	l_result		varchar2(30);
      -- JH CAO
      l_cao_effective_date          date;
      l_cancel_effective_date       date;

       --Bug# 6312144
       l_imm_ipa_benefits_cont       ghr_api.per_ipa_ben_cont_info_type;
       l_imm_retirement_info         ghr_api.per_retirement_info_type;



	-- this cursor gets the business_group_id for the person_id/effective_date passed.
	cursor c_bg ( c_person_id  number,
			  c_as_on_date date) is
	select
		business_group_id
	from per_people_f
	where person_id = c_person_id and
		c_as_on_date between effective_start_date and effective_end_date;

	-- this cursor gets the ghr_pa_history rows (with the rowid included) for the person_id specified and locks
	-- the rows for update.
	-- note that it selects all the records that were effective on or after the effective_date passed.
	-- also note that it orders by dml_operation, in order to ensure that updated rows are handled
	-- before inserted rows. This is necessary for the way we are handling the setting of extra info tables
	-- back to what they were prior to the appointment. If updated rows were handled before inserted rows, then
	-- the cascade_appl_table_data call may fail since it will be trying to fetch a pre-record for the
	-- updated row, but the pre-record has been deleted since we handled inserted rows first.
	cursor c_hist (c_person_id number,
			   c_eff_date  date) is
	select
		pah.rowid row_id,
		pah.*
	from ghr_pa_history pah
	where person_id = c_person_id and
		(effective_date > c_eff_date or
		 (effective_date = c_eff_date and pa_request_id is not NULL))
        and upper(pah.table_name) not in (upper(ghr_history_api.g_addres_table))
	for update of person_id
	order by dml_operation desc;

	--8259229 for address order by information1 and then on dml operation
	cursor c_add_hist (c_person_id number,
			   c_eff_date  date) is
	select
		pah.rowid row_id,
		pah.*
	from ghr_pa_history pah
	where person_id = c_person_id and
		(effective_date > c_eff_date or
		 (effective_date = c_eff_date and pa_request_id is not NULL))
	and upper(pah.table_name) in (upper(ghr_history_api.g_addres_table))
	for update of person_id
	order by information1 desc,dml_operation desc;
	--8259229

	-- this cursor gets the ghr_pa_request rows (with the rowid included) for the person_id passed and locks
	-- the rows for update.
	-- It returns all pa request rows that were effective on or after the effective date passed, as long as the
	-- pa request has been approved.
	cursor c_par ( c_person_id number,
			   c_eff_date  date) is
	select
		par.rowid,
		par.*
	from ghr_pa_requests par
	where person_id = c_person_id        and
		effective_date >= c_eff_date   and
            pa_notification_id is not null and
            approval_date is not null
	for update of person_id;

        l_pos_name                    varchar2(2000);
        l_object_version_number       number;
        l_effective_start_date        date;
        l_effective_end_date          date;

--
	l_proc	varchar2(30):='cancel_appt_sf52';

Begin

	hr_utility.set_location(' Entering : ' || l_proc, 10);
   l_sf52_data_rec := p_sf52_data;


	-- reinitialise session variables
	ghr_history_api.reinit_g_session_var;

	-- set values of session variables
	l_session_var.pa_request_id 	:= p_sf52_data.pa_request_id;
	l_session_var.noa_id		:= p_sf52_data.second_noa_id;
	-- No triggers should be fired as cancellation can not be corrected or cancelled
	-- so none of the changes will be saved.
	l_session_var.fire_trigger	:= 'N';
	l_session_var.date_Effective	:= p_sf52_data.effective_date;
	l_session_var.person_id		:= p_sf52_data.person_id;
	l_session_var.program_name	:= 'sf50';
	l_session_var.altered_pa_request_id	:= p_sf52_data.altered_pa_request_id;
	l_session_var.noa_id_correct	:= p_sf52_data.second_noa_id;
	l_session_var.assignment_id	:= p_sf52_data.employee_assignment_id;

	ghr_history_api.set_g_session_var(l_session_var);

	ghr_process_Sf52.Fetch_extra_info(
			p_pa_request_id 	=> p_sf52_data.pa_request_id,
			p_noa_id   		=> p_sf52_data.second_noa_id,
			p_agency_ei		=> TRUE,
			p_sf52_ei_data 	=> l_agency_ei_data,
			p_result		=> l_result);

	l_sf52_data 	:= p_sf52_data;
	-- all corrections will have the original sf52 information in the 2nd noa columns, so
	-- copy that information to 1st noa columns.
	ghr_process_sf52.copy_2ndNoa_to_1stNoa(l_sf52_data);
	-- null the second noa columns since we don't want anything to be done with these now.
	ghr_process_sf52.null_2ndNoa_cols(l_sf52_data);

	ghr_sf52_pre_update.populate_record_groups (
		 	p_pa_request_rec                => l_sf52_data,
			p_generic_ei_rec                => l_agency_ei_data,
			p_imm_asg_sf52                  => l_imm_asg_sf52,
			p_imm_asg_non_sf52              => l_imm_asg_non_sf52,
			p_imm_asg_nte_dates             => l_imm_asg_nte_dates,
			p_imm_per_sf52                  => l_imm_per_sf52,
			p_imm_per_group1                => l_imm_per_group1,
			p_imm_per_group2                => l_imm_per_group2,
			p_imm_per_scd_info              => l_imm_per_scd_info,
			p_imm_per_retained_grade        => l_imm_per_retained_grade,
			p_imm_per_probations            => l_imm_per_probations,
			p_imm_per_sep_retire            => l_imm_per_sep_retire,
			p_imm_per_security              => l_imm_per_security,
            --Bug#4486823 RRR Changes
            p_imm_per_service_oblig         => l_imm_per_service_oblig,
			p_imm_per_conversions           => l_imm_per_conversions,
			-- 4352589 BEN_EIT Changes
			p_imm_per_benefit_info          => l_imm_per_benefit_info,
			p_imm_per_uniformed_services    => l_imm_per_uniformed_services,
			p_imm_pos_oblig                 => l_imm_pos_oblig,
			p_imm_pos_grp2                  => l_imm_pos_grp2,
			p_imm_pos_grp1                  => l_imm_pos_grp1,
			p_imm_pos_valid_grade           => l_imm_pos_valid_grade,
			p_imm_pos_car_prog              => l_imm_pos_car_prog,
			p_imm_loc_info                  => l_imm_loc_info,
			p_imm_wgi                       => l_imm_wgi,
			p_imm_gov_awards                => l_imm_gov_awards,
			p_imm_recruitment_bonus         => l_imm_recruitment_bonus,
			p_imm_relocation_bonus          => l_imm_relocation_bonus,
			p_imm_student_loan_repay        => l_imm_student_loan_repay,
			p_imm_per_race_ethnic_info 		=> l_imm_per_race_ethnic_info, -- Bug 4724337 Race or National Origin changes
			--Pradeep
			p_imm_mddds_special_pay         => l_imm_mddds_special_pay,
			p_imm_premium_pay_ind           => l_imm_premium_pay_ind,

			p_imm_perf_appraisal            => l_imm_perf_appraisal,
			p_imm_conduct_performance       => l_imm_conduct_performance,
			p_imm_payroll_type              => l_imm_payroll_type,
			p_imm_extra_info_rec	        => l_imm_extra_info_rec,
			p_imm_sf52_from_data            => l_imm_sf52_from_data,
			p_imm_personal_info	        => l_imm_personal_info,
			p_imm_generic_extra_info_rec    => l_imm_generic_extra_info_rec,
			p_imm_agency_sf52               => l_imm_agency_sf52,
			p_agency_code                   => l_agency_code,
			p_imm_par_term_retained_grade   => l_imm_par_term_retained_grade,
			p_imm_entitlement               => l_imm_entitlement,
                        -- Bug#2759379 Added FEGLI Record
                        p_imm_fegli                     => l_imm_fegli,
			p_imm_foreign_lang_prof_pay     => l_imm_foreign_lang_prof_pay,
			-- Bug#3385386 Added FTA Record
			p_imm_fta                       => l_imm_fta,
			p_imm_edp_pay                   => l_imm_edp_pay,
			p_imm_hazard_pay                => l_imm_hazard_pay,
			p_imm_health_benefits           => l_imm_health_benefits,
			p_imm_danger_pay                => l_imm_danger_pay,
			p_imm_imminent_danger_pay       => l_imm_imminent_danger_pay,
			p_imm_living_quarters_allow     => l_imm_living_quarters_allow,
			p_imm_post_diff_amt             => l_imm_post_diff_amt,
			p_imm_post_diff_percent         => l_imm_post_diff_percent,
			p_imm_sep_maintenance_allow     => l_imm_sep_maintenance_allow,
			p_imm_supplemental_post_allow   => l_imm_supplemental_post_allow,
			p_imm_temp_lodge_allow          => l_imm_temp_lodge_allow,
			p_imm_premium_pay               => l_imm_premium_pay,
			p_imm_retirement_annuity        => l_imm_retirement_annuity,
			p_imm_severance_pay             => l_imm_severance_pay,
			p_imm_thrift_saving_plan        => l_imm_thrift_saving_plan,
			p_imm_retention_allow_review        => l_imm_retention_allow_review,
			p_imm_health_ben_pre_tax           => l_imm_health_ben_pre_tax,
			--Bug #6312144 RPA EIT Benefits
			p_imm_ipa_benefits_cont         => l_imm_ipa_benefits_cont,
                        p_imm_retirement_info           => l_imm_retirement_info);

	ghr_api.retrieve_element_entry_value
		( p_element_name	=> 'Health Benefits'
		 ,p_input_value_name    =>  'Health Plan'
		 ,p_assignment_id       =>   l_sf52_data.employee_assignment_id
		 ,p_effective_date      =>   trunc(l_sf52_data.effective_date)
		 ,p_value               =>   l_health_plan
		 ,p_multiple_error_flag =>   l_error_flag
		 );


	GHR_AGENCY_CHECK.AGENCY_CHECK(
			p_pa_request_rec			=> l_sf52_data,
			p_asg_sf52				=> l_imm_asg_sf52,
			p_asg_non_sf52			=> l_imm_asg_non_sf52,
			p_asg_nte_dates			=> l_imm_asg_nte_dates,
			p_per_sf52              	=> l_imm_per_sf52,
			p_per_group1            	=> l_imm_per_group1,
			p_per_group2            	=> l_imm_per_group2,
			p_per_scd_info          	=> l_imm_per_scd_info,
			p_per_retained_grade    	=> l_imm_per_retained_grade,
			p_per_probations			=> l_imm_per_probations,
			p_per_sep_Retire 	      	=> l_imm_per_sep_retire,
			p_per_security          	=> l_imm_per_security,
			p_per_conversions	      	=> l_imm_per_conversions,
			p_per_uniformed_services	=> l_imm_per_uniformed_services,
			p_pos_oblig                   => l_imm_pos_oblig,
			p_pos_grp2                    => l_imm_pos_grp2,
			p_pos_grp1                    => l_imm_pos_grp1,
			p_pos_valid_grade             => l_imm_pos_valid_grade,
			p_pos_car_prog                => l_imm_pos_car_prog,
			p_loc_info                    => l_imm_loc_info,
			p_wgi                         => l_imm_wgi,
			p_recruitment_bonus	      => l_imm_recruitment_bonus,
			p_relocation_bonus	      => l_imm_relocation_bonus ,
			p_sf52_from_data              => l_imm_sf52_from_data,
			p_personal_info	            => l_imm_personal_info,
			p_gov_awards_type             => l_imm_gov_awards,
			p_perf_appraisal_type         => l_imm_perf_appraisal,
			p_payroll_type                => l_imm_payroll_type,
			p_conduct_perf_type           => l_imm_conduct_performance,
			p_agency_code		      => l_agency_code,
			p_agency_sf52			=> l_imm_agency_sf52,
			p_health_plan			=> l_health_plan,
			p_entitlement                 => l_imm_entitlement,
			p_foreign_lang_prof_pay       => l_imm_foreign_lang_prof_pay,
			p_edp_pay                     => l_imm_edp_pay,
			p_hazard_pay                  => l_imm_hazard_pay,
			p_health_benefits             => l_imm_health_benefits,
			p_danger_pay                  => l_imm_danger_pay,
			p_imminent_danger_pay         => l_imm_imminent_danger_pay,
			p_living_quarters_allow       => l_imm_living_quarters_allow,
			p_post_diff_amt               => l_imm_post_diff_amt,
			p_post_diff_percent           => l_imm_post_diff_percent,
			p_sep_maintenance_allow       => l_imm_sep_maintenance_allow,
			p_supplemental_post_allow     => l_imm_supplemental_post_allow,
			p_temp_lodge_allow            => l_imm_temp_lodge_allow,
			p_premium_pay                 => l_imm_premium_pay,
			p_retirement_annuity          => l_imm_retirement_annuity,
			p_severance_pay               => l_imm_severance_pay,
			p_thrift_saving_plan          => l_imm_thrift_saving_plan,
			p_retention_allow_review      => l_imm_retention_allow_review,
			p_health_ben_pre_tax          => l_imm_health_ben_pre_tax,
            p_per_benefit_info            => l_imm_per_benefit_info,
            p_imm_retirement_info         => l_imm_retirement_info); --Bug# 7131104

        -- Segment which calls do_cancel_hire moved after history handling. Bug# 1295751.

	hr_utility.set_location( l_proc, 40);
	for l_hist in c_hist( p_sf52_data.person_id,
				    p_sf52_data.effective_date)
	loop
		hr_utility.set_location( 'GOT HERE!!!!: ' || l_proc, 59);
		exit when c_hist%notfound;
		delete_hist_row( l_hist.row_id);
		hr_utility.set_location( 'checking if table needs deleting: ' || l_hist.table_name|| l_proc, 58);
		-- Delete all extraInfo table records which were created by the SF52.
		if  upper(l_hist.table_name) in (upper(ghr_history_api.g_peopei_table),
							  upper(ghr_history_api.g_posnei_table),
							  upper(ghr_history_api.g_asgnei_table),
							  upper(ghr_history_api.g_addres_table),
							  upper(ghr_history_api.g_perana_table)) then
			hr_utility.set_location( 'table_name qualifies: ' || l_hist.table_name|| l_proc, 57);
			if l_hist.DML_operation = ghr_history_api.g_ins_operation then
				hr_utility.set_location( 'delete appl row table_name: ' || l_hist.table_name|| l_proc, 51);
				hr_utility.set_location( 'delete appl row information1: ' || l_hist.information1|| l_proc, 52);
				hr_utility.set_location( 'delete appl row effective_date: ' || l_hist.effective_date|| l_proc, 53);
				delete_appl_row(
					p_table_name	=> l_hist.table_name,
					p_table_pk_id	=> l_hist.information1,
					p_dt_mode		=> null,
					p_date_effective	=> l_hist.effective_date);
			elsif l_hist.DML_operation = ghr_history_api.g_upd_operation then
				l_hist_post.information1 	:= l_hist.information1;
				l_hist_post.person_id		:= l_hist.person_id;
				hr_utility.set_location(l_proc || 'l_hist.information1: ' || l_hist.information1, 1200);
				hr_utility.set_location(l_proc || 'l_hist.table_name: ' || l_hist.table_name, 1210);
				hr_utility.set_location(l_proc || 'l_hist.person_id: ' || l_hist.person_id, 1220);
				ghr_history_cascade.cascade_appl_table_data(
					p_table_name		=>	l_hist.table_name,
					p_person_id			=>	l_hist.person_id,
					p_pre_record		=>	null,
					p_post_record		=>	l_hist_post,
					p_cascade_type		=>	null,
					p_interv_on_table		=>	null,
					p_interv_on_eff_date	=>	null,
					p_hist_data_as_of_date	=>	null);
			end if;
		end if;
	end loop;

	--8259229   added a seperate loop for address
	for l_add_hist in c_add_hist( p_sf52_data.person_id,
			      p_sf52_data.effective_date)
	loop
		hr_utility.set_location( 'GOT HERE!!!!: ' || l_proc, 59);
		hr_utility.set_location( 'GOT HERE' || l_add_hist.pa_history_id, 59);
		exit when c_add_hist%notfound;
		delete_hist_row( l_add_hist.row_id);
		hr_utility.set_location( 'checking if table needs deleting: ' || l_add_hist.table_name|| l_proc, 58);
		-- Delete all extraInfo table records which were created by the SF52.
			hr_utility.set_location( 'table_name qualifies: ' || l_add_hist.table_name|| l_proc, 57);
			if l_add_hist.DML_operation = ghr_history_api.g_ins_operation then
				hr_utility.set_location( 'delete appl row table_name: ' || l_add_hist.table_name|| l_proc, 51);
				hr_utility.set_location( 'delete appl row information1: ' || l_add_hist.information1|| l_proc, 52);
				hr_utility.set_location( 'delete appl row effective_date: ' || l_add_hist.effective_date|| l_proc, 53);
				delete_appl_row(
					p_table_name	=> l_add_hist.table_name,
					p_table_pk_id	=> l_add_hist.information1,
					p_dt_mode		=> null,
					p_date_effective	=> l_add_hist.effective_date);
			elsif l_add_hist.DML_operation = ghr_history_api.g_upd_operation then
				l_hist_post.information1 	:= l_add_hist.information1;
				l_hist_post.person_id		:= l_add_hist.person_id;
				hr_utility.set_location(l_proc || 'l_add_hist.information1: ' || l_add_hist.information1, 1200);
				hr_utility.set_location(l_proc || 'l_add_hist.table_name: ' || l_add_hist.table_name, 1210);
				hr_utility.set_location(l_proc || 'l_add_hist.person_id: ' || l_add_hist.person_id, 1220);
				ghr_history_cascade.cascade_appl_table_data(
					p_table_name		=>	l_add_hist.table_name,
					p_person_id			=>	l_add_hist.person_id,
					p_pre_record		=>	null,
					p_post_record		=>	l_hist_post,
					p_cascade_type		=>	null,
					p_interv_on_table		=>	null,
					p_interv_on_eff_date	=>	null,
					p_hist_data_as_of_date	=>	null);
			end if;
	end loop;
	--8259229

        -- Moved this segment to be executed after history deletion handling.
        -- Bug# 1295751.
	hr_utility.set_location( l_proc, 20);
	open c_bg (p_sf52_data.person_id, p_sf52_data.effective_date);
	fetch c_bg into l_business_group_id;
	if c_bg%notfound then
		close c_bg;
	      hr_utility.set_message(8301,'GHR_38210_BUSINESS_GROUP_NFND');
	      hr_utility.raise_error;
		--raise error
	end if;
	hr_utility.set_location( l_proc, 30);
	-- Check if need to call cancel_hire_or_apl.lock_per_row ???
	-- call core HR api to cancel the hire.
--*****************************************************************************
-- Added as per Rohini's suggestion to fix bug#3106101
     pay_us_tax_internal.maintain_us_employee_taxes (
         p_effective_date =>  p_sf52_data.effective_date
        ,p_datetrack_mode => 'ZAP'
        ,p_assignment_id  => l_sf52_data.employee_assignment_id
       ,p_delete_routine => 'ASSIGNMENT' );

-- to fix bug 3106101
--*****************************************************************************

-- JH CAO
-- Bug 2989431 New User Hook GHR_AGENCY_CHECK.CANCEL_HIRE_CAO
	GHR_AGENCY_CHECK.CANCEL_HIRE_CAO(
			p_pa_request_rec			=> l_sf52_data,
			p_asg_sf52				=> l_imm_asg_sf52,
			p_asg_non_sf52			=> l_imm_asg_non_sf52,
			p_asg_nte_dates			=> l_imm_asg_nte_dates,
			p_per_sf52              	=> l_imm_per_sf52,
			p_per_group1            	=> l_imm_per_group1,
			p_per_group2            	=> l_imm_per_group2,
			p_per_scd_info          	=> l_imm_per_scd_info,
			p_per_retained_grade    	=> l_imm_per_retained_grade,
			p_per_probations			=> l_imm_per_probations,
			p_per_sep_Retire 	      	=> l_imm_per_sep_retire,
			p_per_security          	=> l_imm_per_security,
			p_per_conversions	      	=> l_imm_per_conversions,
			p_per_uniformed_services	=> l_imm_per_uniformed_services,
			p_pos_oblig                   => l_imm_pos_oblig,
			p_pos_grp2                    => l_imm_pos_grp2,
			p_pos_grp1                    => l_imm_pos_grp1,
			p_pos_valid_grade             => l_imm_pos_valid_grade,
			p_pos_car_prog                => l_imm_pos_car_prog,
			p_loc_info                    => l_imm_loc_info,
			p_wgi                         => l_imm_wgi,
			p_recruitment_bonus	      => l_imm_recruitment_bonus,
			p_relocation_bonus	      => l_imm_relocation_bonus ,
			p_sf52_from_data              => l_imm_sf52_from_data,
			p_personal_info	            => l_imm_personal_info,
			p_gov_awards_type             => l_imm_gov_awards,
			p_perf_appraisal_type         => l_imm_perf_appraisal,
			p_payroll_type                => l_imm_payroll_type,
			p_conduct_perf_type           => l_imm_conduct_performance,
			p_agency_code		      => l_agency_code,
			p_agency_sf52			=> l_imm_agency_sf52,
			p_health_plan			=> l_health_plan,
			p_entitlement                 => l_imm_entitlement,
			p_foreign_lang_prof_pay       => l_imm_foreign_lang_prof_pay,
			p_edp_pay                     => l_imm_edp_pay,
			p_hazard_pay                  => l_imm_hazard_pay,
			p_health_benefits             => l_imm_health_benefits,
			p_danger_pay                  => l_imm_danger_pay,
			p_imminent_danger_pay         => l_imm_imminent_danger_pay,
			p_living_quarters_allow       => l_imm_living_quarters_allow,
			p_post_diff_amt               => l_imm_post_diff_amt,
			p_post_diff_percent           => l_imm_post_diff_percent,
			p_sep_maintenance_allow       => l_imm_sep_maintenance_allow,
			p_supplemental_post_allow     => l_imm_supplemental_post_allow,
			p_temp_lodge_allow            => l_imm_temp_lodge_allow,
			p_premium_pay                 => l_imm_premium_pay,
			p_retirement_annuity          => l_imm_retirement_annuity,
			p_severance_pay               => l_imm_severance_pay,
			p_thrift_saving_plan          => l_imm_thrift_saving_plan,
			p_retention_allow_review      => l_imm_retention_allow_review,
			p_health_ben_pre_tax          => l_imm_health_ben_pre_tax,
                  p_cao_effective_date          => l_cao_effective_date
);

      IF l_cao_effective_date IS NOT NULL THEN
         l_cancel_effective_date := l_cao_effective_date;
      ELSE
         l_cancel_effective_date := p_sf52_data.effective_date;
      END IF;

	per_cancel_hire_or_apl_pkg.do_cancel_hire(
		p_person_id			=> p_sf52_data.person_id,
		p_date_start		=> l_cancel_effective_date,
		p_end_of_time		=> hr_api.g_eot,
		p_business_group_id	=> l_business_group_id,
		p_period_of_service_id	=> null
		);
        -- End segment for bug# 1295751

	ghr_agency_update.ghr_agency_upd(
			p_pa_request_rec			=> l_sf52_data,
			p_asg_sf52				=> l_imm_asg_sf52,
			p_asg_non_sf52			=> l_imm_asg_non_sf52,
			p_asg_nte_dates			=> l_imm_asg_nte_dates,
			p_per_sf52              	=> l_imm_per_sf52,
			p_per_group1            	=> l_imm_per_group1,
			p_per_group2            	=> l_imm_per_group2,
			p_per_scd_info          	=> l_imm_per_scd_info,
			p_per_retained_grade    	=> l_imm_per_retained_grade,
			p_per_probations			=> l_imm_per_probations,
			p_per_sep_Retire 	      	=> l_imm_per_sep_retire,
			p_per_security          	=> l_imm_per_security,
			p_per_conversions	      	=> l_imm_per_conversions,
			p_per_uniformed_services	=> l_imm_per_uniformed_services,
			p_pos_oblig                   => l_imm_pos_oblig,
			p_pos_grp2                    => l_imm_pos_grp2,
			p_pos_grp1                    => l_imm_pos_grp1,
			p_pos_valid_grade             => l_imm_pos_valid_grade,
			p_pos_car_prog                => l_imm_pos_car_prog,
			p_loc_info                    => l_imm_loc_info,
			p_wgi                         => l_imm_wgi,
			p_recruitment_bonus	      => l_imm_recruitment_bonus,
			p_relocation_bonus	      => l_imm_relocation_bonus ,
			p_sf52_from_data              => l_imm_sf52_from_data,
			p_personal_info	            => l_imm_personal_info,
			p_gov_awards_type             => l_imm_gov_awards,
			p_perf_appraisal_type         => l_imm_perf_appraisal,
			p_payroll_type                => l_imm_payroll_type,
			p_conduct_perf_type           => l_imm_conduct_performance,
			p_agency_code		      => l_agency_code,
			p_agency_sf52			=> l_imm_agency_sf52,
			p_entitlement                 => l_imm_entitlement,
			p_foreign_lang_prof_pay       => l_imm_foreign_lang_prof_pay,
			p_edp_pay                     => l_imm_edp_pay,
			p_hazard_pay                  => l_imm_hazard_pay,
			p_health_benefits             => l_imm_health_benefits,
			p_danger_pay                  => l_imm_danger_pay,
			p_imminent_danger_pay         => l_imm_imminent_danger_pay,
			p_living_quarters_allow       => l_imm_living_quarters_allow,
			p_post_diff_amt               => l_imm_post_diff_amt,
			p_post_diff_percent           => l_imm_post_diff_percent,
			p_sep_maintenance_allow       => l_imm_sep_maintenance_allow,
			p_supplemental_post_allow     => l_imm_supplemental_post_allow,
			p_temp_lodge_allow            => l_imm_temp_lodge_allow,
			p_premium_pay                 => l_imm_premium_pay,
			p_retirement_annuity          => l_imm_retirement_annuity,
			p_severance_pay               => l_imm_severance_pay,
			p_thrift_saving_plan          => l_imm_thrift_saving_plan,
			p_retention_allow_review      => l_imm_retention_allow_review,
			p_health_ben_pre_tax          => l_imm_health_ben_pre_tax,
            p_per_benefit_info            => l_imm_per_benefit_info,
            p_imm_retirement_info         => l_imm_retirement_info); --Bug# 7131104

	hr_utility.set_location( l_proc, 50);
	ghr_sf52_post_update.post_sf52_cancel(
		p_pa_request_id		=> p_sf52_data.pa_request_id,
		p_effective_date		=> l_session_var.date_effective,
		p_object_version_number	=> p_sf52_data.object_version_number,
		p_from_position_id	=> p_sf52_data.from_position_id,
		p_to_position_id		=> p_sf52_data.to_position_id,
		p_agency_code		=> p_sf52_data.agency_code);

	--
	-- Mark all the SF52s cancelled which were created after Appt. SF52
	--
	hr_utility.set_location( l_proc, 110);
	for l_par in c_par( p_sf52_data.person_id,
                          p_sf52_data.effective_date)
	loop
		hr_utility.set_location( l_proc, 111);
		exit when c_par%notfound;
		-- mark delete
		if l_par.first_noa_code not in ('001' , '002') then
			-- no need to do anything with cancellation/correction actions as they
			-- already will not appear in cancellation/correction form.
                        -- EDWARD NUNEZ 03/03/2000
                        -- NOTE: To fix bug# 1222525 please change following line
                        --       "if l_par.first_noa_cancel_or_correct is null then" to
                        --       "if l_par.first_noa_cancel_or_correct is null OR
                        --           NVL(l_par.first_noa_cancel_or_correct, '***') = 'CORRECT' then"
			if l_par.first_noa_cancel_or_correct is null or
                           NVL(l_par.first_noa_cancel_or_correct, '***') = 'CORRECT'
                        then
				l_par.first_noa_cancel_or_correct := ghr_history_api.g_cancel;
			end if;
		end if;

		if l_par.second_noa_code is not NULL then
			-- handle dual actions
			if l_par.second_noa_cancel_or_correct is null  then
				l_par.second_noa_cancel_or_correct := ghr_history_api.g_cancel;
			end if;

		     --6850492 added the condition for dual action correction
		     -- added for the bug 8250185
		     if l_par.first_noa_code not in ('001' , '002') and
		         l_par.second_noa_code is not NULL  and
			 NVL(l_par.second_noa_cancel_or_correct, '***') = 'CORRECT' then
			 l_par.second_noa_cancel_or_correct := ghr_history_api.g_cancel;
	             end if;
		     --8250185
		end if;


-- Special handling is required for the termination action 352.
-- Added by VVL

               if (l_par.first_noa_code = '352') then
                  -- null out end_date for position

                  SELECT name, object_version_number
                    INTO l_pos_name, l_object_version_number
                    FROM hr_all_positions_f
                   WHERE position_id = l_par.from_position_id
                     AND (l_par.effective_date  - 1) BETWEEN effective_start_date
                                                               AND effective_end_date;
                   hr_position_api.delete_position
                   (p_position_id                   => l_par.from_position_id,
                    p_object_version_number         => l_object_version_number,
                    p_effective_date                => l_par.effective_date - 1,
                    p_effective_start_date          => l_effective_start_date,
                    p_effective_end_date            => l_effective_end_date,
                    p_datetrack_mode                => 'DELETE_NEXT_CHANGE'
                    );
               end if;
--Added by VVL
		ghr_sf52_api.update_Sf52(
			p_pa_request_id                => l_par.pa_request_id,
			p_par_object_version_number    => l_par.object_version_number,
			p_first_noa_cancel_or_correct  => l_par.first_noa_cancel_or_correct,
			p_second_noa_cancel_or_correct => l_par.second_noa_cancel_or_correct,
			p_u_prh_object_version_number  => l_u_prh_object_version_number,
			p_i_pa_routing_history_id      => l_i_pa_routing_history_id,
			p_i_prh_object_version_number  => l_i_prh_object_version_number,
			p_u_action_taken               => 'NONE'
			);
	End loop;

	hr_utility.set_location( l_proc, 80);

	hr_utility.set_location(' Leaving ' || l_proc, 100);
  Exception when others then
            --
            -- Reset IN OUT parameters and set OUT parameters
            --
            p_sf52_data := l_sf52_data_rec;
            raise;

End Cancel_Appt_SF52;

-- ---------------------------------------------------------------------------
-- |--------------------------< cancel_correction_sf52>-----------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure cancels a correction sf52.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_sf52_data		->		ghr_pa_requests record of the correction sf52.
--
-- Post Success:
-- 	The correction sf52 will have been cancelled.
--
-- Post Failure:
--   	No failure conditions.
--
-- Developer Implementation Notes:
--   	At this point, cancellation of a correction sf52 is handled just the same as a cancellation
--	of a normal sf52. So, this procedure just calls the cancel_other_family_sf52 procedure.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure Cancel_Correction_SF52 ( p_sf52_data		in out nocopy 	ghr_pa_requests%rowtype) is
	l_proc	varchar2(30):='Cancel_Correction_SF52';
   l_sf52_data ghr_pa_requests%rowtype;
Begin
	hr_utility.set_location('entering : ' || l_proc, 10);
   l_sf52_data := p_sf52_data;
	Cancel_Other_Family_Sf52 (p_sf52_data);
	hr_utility.set_location('leaving : ' || l_proc, 20);
 exception when others then
           --
           -- Reset IN OUT parameters and set OUT parameters
           --
           p_sf52_data := l_sf52_data;
           raise;
End Cancel_Correction_SF52;

-- ---------------------------------------------------------------------------
-- |--------------------------< cancel_other_family_sf52>---------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure handles a cancellation of a 'normal' sf52.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_sf52_data		->		ghr_pa_requests record of the correction sf52.
-- Post Success:
-- 	The cancellation will have been applied.
--
-- Post Failure:
--   	No failure conditions.
--
-- Developer Implementation Notes:
--	None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

PROCEDURE Cancel_Other_Family_Sf52 ( p_sf52_data in out nocopy ghr_pa_requests%rowtype) AS
        l_buf                           number;
   	l_eff_date			date;
   	l_proc				varchar2(72) := 'Cancel_Other_Family_Sf52' ;
   	l_date_eff_rec			pay_element_entry_values_f%rowtype;
   	l_hist_dummy			ghr_pa_history%rowtype;
   	l_hist_rec			ghr_pa_requests%rowtype;
        l_hist_address_rec      ghr_pa_history%rowtype;
   	l_hist_pre			ghr_pa_history%rowtype;
   	l_hist_data_as_of_date	ghr_pa_history%rowtype;
   	l_return_status		varchar2(100);
   	l_interv_on_table		boolean;
   	l_interv_on_eff_date		boolean;
   	l_pre_record			boolean;
   	l_can_delete			boolean;
   	l_last_row			boolean;
   	l_cannot_cancel		boolean;
   	l_datetrack_table		boolean;
   	l_datetrack_mode		varchar2(30);
   	l_session_var			ghr_history_api.g_session_var_type;
   	l_result_code			varchar2(30);
   	l_rec_created_flag   	boolean;
   	l_del_mode			varchar2(30);
	l_agency_ei_data	ghr_pa_request_extra_info%rowtype;
	l_imm_asg_sf52          	ghr_api.asg_sf52_type;
	l_imm_asg_non_sf52		ghr_api.asg_non_sf52_type;
	l_imm_asg_nte_dates     	ghr_api.asg_nte_dates_type;
	l_imm_per_sf52          	ghr_api.per_sf52_type;
	l_imm_per_group1        	ghr_api.per_group1_type;
	l_imm_per_group2        	ghr_api.per_group2_type;
	l_imm_per_scd_info      	ghr_api.per_scd_info_type;
	l_imm_per_retained_grade      ghr_api.per_retained_grade_type;
	l_imm_per_probations          ghr_api.per_probations_type;
	l_imm_per_sep_retire          ghr_api.per_sep_retire_type;
	l_imm_per_security		ghr_api.per_security_type;
	-- Bug#4486823 RRR changes
	l_imm_per_service_oblig     ghr_api.per_service_oblig_type;
	l_imm_per_conversions		ghr_api.per_conversions_type;
	-- 4352589 BEN_EIT Changes
	l_imm_per_benefit_info        ghr_api.per_benefit_info_type;
	l_imm_per_uniformed_services  ghr_api.per_uniformed_services_type;
	l_imm_pos_oblig               ghr_api.pos_oblig_type;
	l_imm_pos_grp2                ghr_api.pos_grp2_type;
	l_imm_pos_grp1                ghr_api.pos_grp1_type;
	l_imm_pos_valid_grade         ghr_api.pos_valid_grade_type;
	l_imm_pos_car_prog            ghr_api.pos_car_prog_type;
	l_imm_loc_info                ghr_api.loc_info_type;
	l_imm_wgi     	            ghr_api.within_grade_increase_type;
	l_imm_gov_awards              ghr_api.government_awards_type;
	l_imm_recruitment_bonus	      ghr_api.recruitment_bonus_type;
	l_imm_relocation_bonus		ghr_api.relocation_bonus_type;
	l_imm_student_loan_repay  	ghr_api.student_loan_repay_type;
	--Pradeep
	l_imm_mddds_special_pay         ghr_api.mddds_special_pay_type;
	l_imm_premium_pay_ind           ghr_api.premium_pay_ind_type;

	l_imm_extra_info_rec	 	ghr_api.extra_info_rec_type ;
	l_imm_sf52_from_data          ghr_api.prior_sf52_data_type;
	l_imm_personal_info		ghr_api.personal_info_type;
	l_imm_generic_extra_info_rec	ghr_api.generic_extra_info_rec_type ;
	l_imm_agency_sf52		      ghr_api.agency_sf52_type;
	l_agency_code			varchar2(50);
	l_imm_perf_appraisal          ghr_api.performance_appraisal_type;
	l_imm_conduct_performance     ghr_api.conduct_performance_type;
	l_imm_payroll_type            ghr_api.government_payroll_type;
	l_imm_par_term_retained_grade ghr_api.par_term_retained_grade_type;
	l_imm_entitlement             ghr_api.entitlement_type;
        -- Bug#2759379 Added FEGLI Record
        l_imm_fegli                   ghr_api.fegli_type;
	l_imm_foreign_lang_prof_pay   ghr_api.foreign_lang_prof_pay_type;
	-- Bug#3385386 Added FTA Record
	l_imm_fta                     ghr_api.fta_type;
	l_imm_edp_pay                 ghr_api.edp_pay_type;
	l_imm_hazard_pay              ghr_api.hazard_pay_type;
	l_imm_health_benefits         ghr_api.health_benefits_type;
	l_imm_danger_pay              ghr_api.danger_pay_type;
	l_imm_imminent_danger_pay     ghr_api.imminent_danger_pay_type;
	l_imm_living_quarters_allow   ghr_api.living_quarters_allow_type;
	l_imm_post_diff_amt           ghr_api.post_diff_amt_type;
	l_imm_post_diff_percent       ghr_api.post_diff_percent_type;
	l_imm_sep_maintenance_allow   ghr_api.sep_maintenance_allow_type;
	l_imm_supplemental_post_allow ghr_api.supplemental_post_allow_type;
	l_imm_temp_lodge_allow        ghr_api.temp_lodge_allow_type;
	l_imm_premium_pay             ghr_api.premium_pay_type;
	l_imm_retirement_annuity      ghr_api.retirement_annuity_type;
	l_imm_severance_pay           ghr_api.severance_pay_type;
	l_imm_thrift_saving_plan      ghr_api.thrift_saving_plan;
	l_imm_retention_allow_review  ghr_api.retention_allow_review_type;
	l_imm_health_ben_pre_tax         ghr_api.health_ben_pre_tax_type;
	l_imm_per_race_ethnic_info 	  ghr_api.per_race_ethnic_type; -- Bug 4724337 Race or National Origin changes
	l_sf52_data				ghr_pa_requests%rowtype;
	l_sf52_data_rec      ghr_pa_requests%rowtype;
	l_health_plan			varchar2(30);
	l_error_flag			boolean;
	l_pa_history_id			number;
   	l_result				boolean;
   	l_deleted				boolean;
        l_system_type                   per_person_types.system_person_type%type;
        l_prior_noa_code                ghr_nature_of_actions.code%type;
        l_noa_family_code               ghr_families.noa_family_code%type;
		l_prior_asg_id					per_assignments_f.assignment_id%type; --Bug# 5442674

         -- bug #6312144
         l_imm_ipa_benefits_cont       ghr_api.per_ipa_ben_cont_info_type;
        l_imm_retirement_info         ghr_api.per_retirement_info_type;


   -- this cursor retrieves the ghr_pa_history row for the pa_request_id and noa_id given.
   -- note that this cursor orders by table name, this is due to the fact that we need to
   -- handle PAY_ELEMENT_ENTRY_VALUES_F history records before PAY_ELEMENT_ENTRIES_F history
   -- records due to the parent-child relationship of these two tables. Fetch_history routine
   -- for elements relies on the parent record in history being intact.
   cursor c_history_info 	(cp_pa_request_id in 	ghr_pa_requests.pa_request_id%type,
   				cp_noa_id		in	ghr_pa_requests.first_noa_id%type) is
   SELECT	*
   FROM		GHR_PA_HISTORY
   WHERE		pa_request_id		= cp_pa_request_id
   	AND	nature_of_action_id	= cp_noa_id
	ORDER BY DECODE(table_name, 'PAY_ELEMENT_ENTRY_VALUES_F', -2,
                                    'PAY_ELEMENT_ENTRIES_F', -1,
                        pa_history_id) asc;

--start of bug #5900178
-- Added this below cursor for the bug#5900178 to validate whether per_person_analyses
--record is available for updation or not if it is available it will be continue otherwise
--- it wont continue for cascading
    cursor chk_perana_exists(p_person_analysis_id in per_person_analyses.person_analysis_id%type)
        is
        SELECT 1
        FROM   PER_PERSON_ANALYSES
        WHERE  person_analysis_id = p_person_analysis_id;

   m_perana varchar2(1);
   l_rec_exists boolean;
--end of bug #5900178

-- Bug#2780976 Modified the cursor c_prior_person_type
-- Bug# 5442674 Modified the select statement
   Cursor c_prior_person_type is
  Select paf.assignment_id
      from   per_assignments_f paf
      where  paf.person_id =   p_sf52_data.person_id
	  and	 paf.assignment_type='E'
      and    p_sf52_data.effective_date-1 between paf.effective_start_date and paf.effective_end_date;

   Cursor c_prior_noa_code is
     Select par.first_noa_code,
            par.first_noa_id
     from   ghr_pa_requests par
     where  par.pa_request_id = p_sf52_data.altered_pa_request_id;

  Cursor c_noa_family(p_noa_id in number) is
    Select fam.noa_family_code
    from   ghr_noa_families nof,
           ghr_families fam
    where  nof.nature_of_action_id =  p_noa_id
    and    fam.noa_family_code     = nof.noa_family_code
    and    nvl(fam.proc_method_flag,hr_api.g_varchar2) = 'Y'
    and    p_sf52_data.effective_date
    between nvl(fam.start_date_active,p_sf52_data.effective_date)
    and     nvl(fam.end_date_active,p_sf52_data.effective_date);

    cursor c_follow_rec(        c_table_name    ghr_pa_history.table_name%type,
                                        c_pk_id         ghr_pa_history.information1%type,
                                        c_pa_history_id ghr_pa_history.pa_history_id%type) is
        select  pa_history_id
        from            ghr_pa_history
        where           table_name              = c_table_name
                and     information1    = c_pk_id
                and     pa_history_id   > c_pa_history_id;


        cursor c_hist_address ( c_pa_request_id number,
                            c_noa_id            number) is
        select
                rowid row_id, table_name,pa_history_id,information5
                ,information9, information10
        from ghr_pa_history
        where pa_request_id = c_pa_request_id
        and   table_name = ghr_history_api.g_addres_table
        and  nature_of_action_id = c_noa_id
        for update of person_id
        order by pa_history_id desc;
--
       Cursor Cur_bg(p_person_id NUMBER,
                    p_eff_date DATE) is
       Select distinct business_group_id bg
       from per_assignments_f
       where person_id = p_person_id
       and   p_eff_date between effective_start_date
             and effective_end_date;
--
       ll_bg_id                    NUMBER;
       ll_pay_basis                VARCHAR2(80);
       ll_effective_date           DATE;
       l_new_element_name          VARCHAR2(80);
   --
    -- Bug#2521744 Declared 2 variables,2 cursors.
           l_element_name    VARCHAR2(80);
           l_element_name1   VARCHAR2(80);
	   l_bus_group_id    NUMBER;

        CURSOR c_element_name(p_element_link_id NUMBER) IS
        SELECT elt.element_name
        FROM PAY_ELEMENT_LINKS_F ell,PAY_ELEMENT_TYPES_F elt
        WHERE ell.ELEMENT_type_id = elt.element_type_id
          AND ell.element_link_id = p_element_link_id;
    --
    --  Created the following cursor to handle same day other pay actions.
    CURSOR c_element_name1(p_element_entry_id NUMBER) IS
            SELECT elt.element_name
        FROM PAY_ELEMENT_LINKS_F ell,
             PAY_ELEMENT_TYPES_F elt,
             pay_element_entries_f ele
        WHERE ell.ELEMENT_type_id = elt.element_type_id
          AND ele.element_type_id = elt.element_type_id
          AND ell.element_link_id = ele.element_link_id
          AND ele.element_entry_id = p_element_entry_id;
    -- end of 2521744;
--
BEGIN
       -- hr_utility.trace_on(null,'venkat');
        hr_utility.set_location('Entering  '|| l_proc,5);
        l_sf52_data_rec  := p_sf52_data;
-- Initialization
--
	l_sf52_data_rec  := p_sf52_data;
         For BG_rec in Cur_BG(l_sf52_data_rec.person_id,
	                      l_sf52_data_rec.effective_date)
          Loop
           ll_bg_id  :=BG_rec.bg;
          End Loop;
-- Effective_date
     ll_effective_date := l_sf52_data_rec.effective_date;
--   Pick pay basis from PAR

          for noa_family_rec in c_noa_family(p_sf52_data.second_noa_id) loop
            l_noa_family_code :=  noa_family_rec.noa_family_code;
        end loop;
        If nvl(l_noa_family_code,hr_api.g_varchar2) = 'CONV_APP' then
          hr_utility.set_location('CAncel of conversion',1);
          -- check to see if the person was an EX_EMP prior to the effective
          -- date of this action.
          for prior_person_type in c_prior_person_type loop
            l_prior_asg_id :=  prior_person_type.assignment_id;  --Bug# 5442674
            exit;
          end loop;
          for prior_noa_code in c_prior_noa_code loop
            l_prior_noa_code := prior_noa_code.first_noa_code;
          end loop;
        End if;
		hr_utility.set_location('Family Code' || l_noa_family_code,1000);
		hr_utility.set_location('Second NOA Code' || p_sf52_data.second_noa_code,1000);
		hr_utility.set_location('Prior Assignment Id' || l_prior_asg_id,1001);
		hr_utility.set_location('Assignment Id' || l_sf52_data_rec.employee_assignment_id,1002);
        If nvl(l_noa_family_code,hr_api.g_varchar2) = 'CONV_APP'  and
		nvl(l_prior_asg_id,hr_api.g_number) <> l_sf52_data_rec.employee_assignment_id and  --Bug# 5442674
           nvl(l_prior_noa_code,hr_api.g_varchar2) <> '002' then

            hr_utility.set_location('Cancel of Ex_EMP conversion',1);
             ghr_corr_canc_sf52.cancel_appt_sf52(p_sf52_data);
        Else
  	-- reinitialise session variables
  	ghr_history_api.reinit_g_session_var;
  	-- set values of session variables
  	l_session_var.pa_request_id 	:= p_sf52_data.pa_request_id;
  	l_session_var.noa_id		:= p_sf52_data.second_noa_id;
  	l_session_var.fire_trigger	:= 'Y';
  	l_session_var.date_Effective	:= p_sf52_data.effective_date;
  	l_session_var.person_id		:= p_sf52_data.person_id;
  	l_session_var.program_name	:= 'sf50';
  	l_session_var.altered_pa_request_id	:= p_sf52_data.altered_pa_request_id;
  	l_session_var.noa_id_correct	:= p_sf52_data.second_noa_id;
  	l_session_var.assignment_id	:= p_sf52_data.employee_assignment_id;

  	ghr_history_api.set_g_session_var(l_session_var);

	ghr_process_Sf52.Fetch_extra_info(
			p_pa_request_id 	=> p_sf52_data.pa_request_id,
			p_noa_id   		=> p_sf52_data.second_noa_id,
			p_agency_ei		=> TRUE,
			p_sf52_ei_data 	=> l_agency_ei_data,
			p_result		=> l_result_code);

	l_sf52_data 	:= p_sf52_data;
	-- all corrections will have the original sf52 information in the 2nd noa columns, so
	-- copy that information to 1st noa columns.
	ghr_process_sf52.copy_2ndNoa_to_1stNoa(l_sf52_data);
	-- null the second noa columns since we don't want anything to be done with these now.
	ghr_process_sf52.null_2ndNoa_cols(l_sf52_data);

	ghr_sf52_pre_update.populate_record_groups (
		 	p_pa_request_rec                => l_sf52_data,
			p_generic_ei_rec                => l_agency_ei_data,
			p_imm_asg_sf52                  => l_imm_asg_sf52,
			p_imm_asg_non_sf52              => l_imm_asg_non_sf52,
			p_imm_asg_nte_dates             => l_imm_asg_nte_dates,
			p_imm_per_sf52                  => l_imm_per_sf52,
			p_imm_per_group1                => l_imm_per_group1,
			p_imm_per_group2                => l_imm_per_group2,
			p_imm_per_scd_info              => l_imm_per_scd_info,
			p_imm_per_retained_grade        => l_imm_per_retained_grade,
			p_imm_per_probations            => l_imm_per_probations,
			p_imm_per_sep_retire            => l_imm_per_sep_retire,
			p_imm_per_security              => l_imm_per_security,
            --Bug#4486823 RRR Changes
            p_imm_per_service_oblig         => l_imm_per_service_oblig,
			p_imm_per_conversions           => l_imm_per_conversions,
			-- 4352589 BEN_EIT Changes
			p_imm_per_benefit_info          => l_imm_per_benefit_info,
			p_imm_per_uniformed_services    => l_imm_per_uniformed_services,
			p_imm_pos_oblig                 => l_imm_pos_oblig,
			p_imm_pos_grp2                  => l_imm_pos_grp2,
			p_imm_pos_grp1                  => l_imm_pos_grp1,
			p_imm_pos_valid_grade           => l_imm_pos_valid_grade,
			p_imm_pos_car_prog              => l_imm_pos_car_prog,
			p_imm_loc_info                  => l_imm_loc_info,
			p_imm_wgi                       => l_imm_wgi,
			p_imm_gov_awards                => l_imm_gov_awards,
			p_imm_recruitment_bonus         => l_imm_recruitment_bonus,
			p_imm_relocation_bonus          => l_imm_relocation_bonus,
			p_imm_student_loan_repay        => l_imm_student_loan_repay,
			p_imm_per_race_ethnic_info 		=> l_imm_per_race_ethnic_info, -- Bug 4724337 Race or National Origin changes
			--Pradeep
			p_imm_mddds_special_pay         => l_imm_mddds_special_pay,
			p_imm_premium_pay_ind           => l_imm_premium_pay_ind,

			p_imm_perf_appraisal            => l_imm_perf_appraisal,
			p_imm_conduct_performance       => l_imm_conduct_performance,
			p_imm_payroll_type              => l_imm_payroll_type,
			p_imm_extra_info_rec	        => l_imm_extra_info_rec,
			p_imm_sf52_from_data            => l_imm_sf52_from_data,
			p_imm_personal_info	        => l_imm_personal_info,
			p_imm_generic_extra_info_rec    => l_imm_generic_extra_info_rec,
			p_imm_agency_sf52               => l_imm_agency_sf52,
			p_agency_code                   => l_agency_code,
			p_imm_par_term_retained_grade   => l_imm_par_term_retained_grade,
			p_imm_entitlement               => l_imm_entitlement,
                        -- Bug#2759379 Added FEGLI Record
                        p_imm_fegli                     => l_imm_fegli,
			p_imm_foreign_lang_prof_pay     => l_imm_foreign_lang_prof_pay,
			-- Bug#3385386 Added FTA Record
			p_imm_fta                       => l_imm_fta,
			p_imm_edp_pay                   => l_imm_edp_pay,
			p_imm_hazard_pay                => l_imm_hazard_pay,
			p_imm_health_benefits           => l_imm_health_benefits,
			p_imm_danger_pay                => l_imm_danger_pay,
			p_imm_imminent_danger_pay       => l_imm_imminent_danger_pay,
			p_imm_living_quarters_allow     => l_imm_living_quarters_allow,
			p_imm_post_diff_amt             => l_imm_post_diff_amt,
			p_imm_post_diff_percent         => l_imm_post_diff_percent,
			p_imm_sep_maintenance_allow     => l_imm_sep_maintenance_allow,
			p_imm_supplemental_post_allow   => l_imm_supplemental_post_allow,
			p_imm_temp_lodge_allow          => l_imm_temp_lodge_allow,
			p_imm_premium_pay               => l_imm_premium_pay,
			p_imm_retirement_annuity        => l_imm_retirement_annuity,
			p_imm_severance_pay             => l_imm_severance_pay,
			p_imm_thrift_saving_plan        => l_imm_thrift_saving_plan,
			p_imm_retention_allow_review        => l_imm_retention_allow_review,
			p_imm_health_ben_pre_tax           => l_imm_health_ben_pre_tax,
			--Bug# 6312144 RPA EIT Benefits
			p_imm_ipa_benefits_cont         => l_imm_ipa_benefits_cont,
                        p_imm_retirement_info           => l_imm_retirement_info);

--
	ghr_api.retrieve_element_entry_value
		( p_element_name	=>  'Health Benefits'
		 ,p_input_value_name    =>  'Health Plan'
		 ,p_assignment_id       =>   l_sf52_data.employee_assignment_id
		 ,p_effective_date      =>   trunc(l_sf52_data.effective_date)
		 ,p_value               =>   l_health_plan
		 ,p_multiple_error_flag =>   l_error_flag
		 );

	GHR_AGENCY_CHECK.AGENCY_CHECK(
			p_pa_request_rec			=> l_sf52_data,
			p_asg_sf52				=> l_imm_asg_sf52,
			p_asg_non_sf52			=> l_imm_asg_non_sf52,
			p_asg_nte_dates			=> l_imm_asg_nte_dates,
			p_per_sf52              	=> l_imm_per_sf52,
			p_per_group1            	=> l_imm_per_group1,
			p_per_group2            	=> l_imm_per_group2,
			p_per_scd_info          	=> l_imm_per_scd_info,
			p_per_retained_grade    	=> l_imm_per_retained_grade,
			p_per_probations			=> l_imm_per_probations,
			p_per_sep_Retire 	      	=> l_imm_per_sep_retire,
			p_per_security          	=> l_imm_per_security,
			p_per_conversions	      	=> l_imm_per_conversions,
			p_per_uniformed_services	=> l_imm_per_uniformed_services,
			p_pos_oblig                   => l_imm_pos_oblig,
			p_pos_grp2                    => l_imm_pos_grp2,
			p_pos_grp1                    => l_imm_pos_grp1,
			p_pos_valid_grade             => l_imm_pos_valid_grade,
			p_pos_car_prog                => l_imm_pos_car_prog,
			p_loc_info                    => l_imm_loc_info,
			p_wgi                         => l_imm_wgi,
			p_recruitment_bonus	      => l_imm_recruitment_bonus,
			p_relocation_bonus	      => l_imm_relocation_bonus ,
			p_sf52_from_data              => l_imm_sf52_from_data,
			p_personal_info	            => l_imm_personal_info,
			p_gov_awards_type             => l_imm_gov_awards,
			p_perf_appraisal_type         => l_imm_perf_appraisal,
			p_payroll_type                => l_imm_payroll_type,
			p_conduct_perf_type           => l_imm_conduct_performance,
			p_agency_code		      => l_agency_code,
			p_agency_sf52			=> l_imm_agency_sf52,
			p_health_plan			=> l_health_plan,
			p_entitlement                 => l_imm_entitlement,
			p_foreign_lang_prof_pay       => l_imm_foreign_lang_prof_pay,
			p_edp_pay                     => l_imm_edp_pay,
			p_hazard_pay                  => l_imm_hazard_pay,
			p_health_benefits             => l_imm_health_benefits,
			p_danger_pay                  => l_imm_danger_pay,
			p_imminent_danger_pay         => l_imm_imminent_danger_pay,
			p_living_quarters_allow       => l_imm_living_quarters_allow,
			p_post_diff_amt               => l_imm_post_diff_amt,
			p_post_diff_percent           => l_imm_post_diff_percent,
			p_sep_maintenance_allow       => l_imm_sep_maintenance_allow,
			p_supplemental_post_allow     => l_imm_supplemental_post_allow,
			p_temp_lodge_allow            => l_imm_temp_lodge_allow,
			p_premium_pay                 => l_imm_premium_pay,
			p_retirement_annuity          => l_imm_retirement_annuity,
			p_severance_pay               => l_imm_severance_pay,
			p_thrift_saving_plan          => l_imm_thrift_saving_plan,
			p_retention_allow_review      => l_imm_retention_allow_review,
			p_health_ben_pre_tax          => l_imm_health_ben_pre_tax,
            p_per_benefit_info            => l_imm_per_benefit_info,
            p_imm_retirement_info         => l_imm_retirement_info); --Bug# 7131104
-- Bug#2347658
--Cancel address records in a different style for Correction to Separation action.
  IF (l_noa_family_code = 'SEPARATION') Then
    FOR l_hist IN c_hist_address(p_sf52_data.altered_pa_request_id, p_sf52_data.second_noa_id)
    LOOP
                       SELECT   *
                        INTO            l_hist_address_rec
                        FROM            ghr_pa_history
                        WHERE           pa_history_id   = l_hist.pa_history_id;

                        ghr_history_api.fetch_history_info(
                                p_table_name            => ghr_history_api.g_addres_table,
                                p_hist_data                     => l_hist_pre,
                                p_pa_history_id         => l_hist_address_rec.pa_history_id,
                                p_table_pk_id           => l_hist_address_rec.information1,
                                p_person_id                     => p_sf52_data.person_id,
                                p_date_effective                => p_sf52_data.effective_date,
                                p_result_code           => l_return_status);
                        if (l_return_status is not null) then
                                -- there were no prevalues for this record
                                -- only delete application table if there are no following records.
                                open c_follow_rec(  c_table_name    =>      l_hist_address_rec.table_name,
                                                    c_pk_id        =>      l_hist_address_rec.information1,
                                                    c_pa_history_id =>      l_hist_address_rec.pa_history_id);
                                fetch c_follow_rec into l_buf;
                                if c_follow_rec%NOTFOUND then
                                        delete_appl_row(
                                                p_table_name    => ghr_history_api.g_addres_table,
                                                p_table_pk_id   => l_hist_address_rec.information1,
                                                p_dt_mode               => null,
                                                p_date_effective        => l_hist_address_rec.effective_date);
                                end if;
                                close c_follow_rec;
                        else
                       -- there is a pre record, so apply it to the history table and to the application table.
                                ghr_history_cascade.cascade_history_data (
                                        p_table_name            =>      l_hist_address_rec.table_name,
                                        p_person_id                     =>      l_hist_address_rec.person_id,
                                        p_pre_record            =>      l_hist_pre,
                                        p_post_record           =>      l_hist_address_rec,
                                        p_cascade_type          =>      'cancel',
                                        p_interv_on_table       =>      l_interv_on_table,
                                        p_interv_on_eff_date    =>      l_interv_on_eff_date,
                                        p_hist_data_as_of_date  =>      l_hist_data_as_of_date);
                                delete_hist_row( l_hist.row_id);
                                ghr_history_cascade.cascade_appl_table_data (
                                        p_table_name            =>      l_hist_address_rec.table_name,
                                        p_person_id             =>      l_hist_address_rec.person_id,
                                        p_pre_record            =>      l_hist_pre,
                                       p_post_record           =>      l_hist_address_rec,
                                        p_cascade_type          =>      'cancel',
                                        p_interv_on_table       =>      l_interv_on_table,
                                        p_interv_on_eff_date    =>      l_interv_on_eff_date,
                                        p_hist_data_as_of_date  =>      l_hist_data_as_of_date);
                        end if;
     END LOOP;
  END IF;
-- Bug#2347658 (End of fix)

  	-- loop thru all history records for the NOA that is being cancelled.
  	FOR l_hist_rec in c_history_info(p_sf52_data.altered_pa_request_id, p_sf52_data.second_noa_id) LOOP
	      hr_utility.set_location('Entering  LOOP'|| l_proc,10);
  		l_pre_record 	:=	TRUE;
  		l_datetrack_table	:= 	TRUE;
		-- initialize pre-record to all nulls
		l_hist_pre	:=	l_hist_dummy;
  		-- get pre-record for the record fetched
  		ghr_history_api.fetch_history_info(
 			p_table_name 		=> l_hist_rec.table_name,
  			p_hist_data			=> l_hist_pre,
  			p_pa_history_id		=> l_hist_rec.pa_history_id,
  			p_table_pk_id 		=> l_hist_rec.information1,
  			p_person_id			=> l_hist_rec.person_id,
  			p_date_effective		=> l_hist_rec.effective_date,
  			p_result_code		=> l_return_status);
		hr_utility.set_location('after fetch history info',12345);
		hr_utility.set_location('status is'||l_return_status,12345);
		hr_utility.set_location('hist id'||l_hist_rec.pa_history_id,12345);
		hr_utility.set_location('person id'||l_hist_rec.person_id,12345);
		hr_utility.set_location('eff_date is '||l_hist_rec.effective_date,12345);

		if (l_return_status is not null) then
			-- there were no prevalues for this record
		      hr_utility.set_location('no pre-values'|| l_proc,15);
 			l_pre_record 	:= FALSE;
		else
			-- Debug statements
			hr_utility.set_location('Pre Value - pa_history_id ' || l_hist_pre.pa_history_id, 16);
			hr_utility.set_location('Pre Value - effective_date ' || l_hist_pre.effective_date, 17);
			hr_utility.set_location('Information1 : ' || l_hist_pre.information1, 18);
			hr_utility.set_location('Information2 : ' || l_hist_pre.information2, 19);

 		end if;
		-- all mappings are such that information2 always corresponds to effective_start_date. If this
		-- column is null, then the row concerns a non-datetrack table. If it is not null, then this row
		-- concerns a datetrack table.
  		if (l_hist_rec.information2 is null) then
		      hr_utility.set_location('datetrack table'|| l_proc,20);
  			l_datetrack_table	:= FALSE;
  		end if;
		-- PAY_ELEMENT_ENTRY needs to be handled differently
  		if lower(l_hist_rec.table_name) = lower(ghr_history_api.g_eleent_table) then
		      hr_utility.set_location('Processing element entry record'|| l_proc,25);
    			if l_hist_rec.DML_operation = ghr_history_api.g_ins_operation then
			--6850492
			   if to_date(l_hist_pre.information2, ghr_history_api.g_hist_date_format) = to_date(l_hist_rec.information2, ghr_history_api.g_hist_date_format) then
			       ghr_history_api.fetch_history_info(
 			                 p_table_name 		=> l_hist_rec.table_name,
  			                 p_hist_data			=> l_hist_pre,
  			                 p_pa_history_id		=> l_hist_rec.pa_history_id,
  			                 p_table_pk_id 		=> l_hist_rec.information1,
  			                 p_person_id			=> l_hist_rec.person_id,
  			                 p_date_effective		=> l_hist_rec.effective_date-1,
  			                 p_result_code		=> l_return_status);
				if (l_return_status is not null) then
			            -- there were no prevalues for this record
		                     hr_utility.set_location('no pre-values'|| l_proc,15);
 			             l_pre_record 	:= FALSE;
		                else
				     null;
				end if;
			    end if;
			    --6850492

			      hr_utility.set_location('Record was created'|| l_proc,30);
  				-- Call Delete_element_entry;
  				-- delete all entry values from history;
				-- VSM Changes made for BUG # 611161
				-- To be able to delete this entry we have to pass previous record and
				-- ask to delete next change.
				-- If there is no pre-record then Call IF_ZAP_ELE_ENT to find if we need to zap
				-- the entry.
				l_result := FALSE;
				l_del_mode := hr_api.g_delete_next_change;
				if l_return_status is not null then
					hr_utility.set_location(' Call IF_ZAP_ELE_ENT' || l_proc, 31);
                                   If l_session_var.noa_id_correct is not null and l_sf52_data.first_noa_code = '866' then
			        		IF_ZAP_ELE_ENT(
							p_element_entry_id	=> l_hist_rec.information1,
							p_effective_start_date	=> l_hist_rec.effective_date + 1,
							p_pa_history_id		=> l_hist_rec.pa_history_id,
							p_result			=> l_result);
						if l_result then
						-- ie can zap the element;

							hr_utility.set_location(' ZAP Mode set ' || l_proc, 32);
							l_del_mode := hr_api.g_zap;
							-- As there is no pre record. copy current row in pre record
							l_hist_pre	:= l_hist_rec;
                                        	end if;
                                     	Else
			        		IF_ZAP_ELE_ENT(
							p_element_entry_id	=> l_hist_rec.information1,
							p_effective_start_date	=> l_hist_rec.effective_date,
							p_pa_history_id		=> l_hist_rec.pa_history_id,
							p_result			=> l_result);
						if l_result then
						-- ie can zap the element;

							hr_utility.set_location(' ZAP Mode set ' || l_proc, 32);
							l_del_mode := hr_api.g_zap;
							-- As there is no pre record. copy current row in pre record
							l_hist_pre	:= l_hist_rec;
                                        	end if;
			              End if;
				end if;

				if l_return_status is null or l_result then
					-- ie previous row exists or this is the only row.
	  				delete_element_entry( p_hist_rec 		=> l_hist_pre,
								    p_del_mode          => l_del_mode,
  								    p_cannot_cancel 	=> l_cannot_cancel);
  					if l_cannot_cancel then
  						-- raise error
					      hr_utility.set_location('ERROR: Cannot Cancel'|| l_proc,35);
  		     				hr_utility.set_message(8301,'GHR_38212_CANNOT_CANCEL');
					      hr_utility.raise_error;
  					else
					      hr_utility.set_location('Delete rows.'|| l_proc,40);
  						delete_hist_row ( l_hist_rec.pa_history_id);
  						delete_eleentval( l_hist_rec);
	  				end if;
				else
                                        --Bug#2521744 Added the following code
					for  element_name_rec in c_element_name(l_hist_rec.information7)
					loop
						l_element_name := element_name_rec.element_name;
						exit;
					end loop;
					hr_utility.set_location('element_name '||l_element_name,10);
				        delete_other_pay_entries(p_hist_rec => l_hist_rec,
				                             p_element_name => l_element_name);
					--Bug#2521744 testing
				end if;
  			else
			      hr_utility.set_location('Record was not created.'|| l_proc,45);
  				null;
  			end if;
			-- Delete history record
  			delete_hist_row ( l_hist_rec.pa_history_id);


  		-- PAY_ELEMENT_ENTRY_VALUE needs to be handled differently
		elsif lower(l_hist_rec.table_name) = lower (ghr_history_api.g_eleevl_table) then
		      hr_utility.set_location('Processing element entry value record'|| l_proc,47);
			if l_hist_rec.DML_operation = ghr_history_api.g_upd_operation then
			      hr_utility.set_location('Record was updated' || l_proc,48);
			      if (l_pre_record = FALSE) then
                                    -- Bug#2521744 Added if condition
				     for  element_name_rec1 in c_element_name1(l_hist_rec.information5)
				     loop
					    l_element_name1 := element_name_rec1.element_name;
					    exit;
				     end loop;
				     fnd_profile.get('PER_BUSINESS_GROUP_ID',l_bus_group_id);
                                     l_element_name1 := pqp_fedhr_uspay_int_utils.return_old_element_name
                                                        (l_element_name1,l_bus_group_id,l_hist_rec.effective_date);

					 hr_utility.set_location('element_name '||l_element_name1,10);
 				     IF l_element_name1 IN ('Retention Allowance','Supervisory Differential',
                                                              'AUO','Availability Pay','Other Pay') then
					hr_utility.set_location('Inside Oth pay elt val condition',15);
				        NULL;
				     Else
					 -- raise error. Must have a pre in order to cancel.
					 hr_utility.set_location('ERROR: Cannot Cancel'|| l_proc,35);
					 hr_utility.set_message(8301,'GHR_38212_CANNOT_CANCEL');
					 hr_utility.raise_error;
				   End IF;
				     -- End of Bug#2521744
				else
					-- get date_effective row from table. See if it is different than the value of the
					-- action we are cancelling. If it is different, then there are intervening actions on
					-- the same date and the update should not be applied to pay_element_entry_values_f table.
					-- If it is the same, then there are no intervening actions on the same date and the
					-- update should be applied.
					ghr_history_fetch.get_date_eff_eleevl(p_element_entry_value_id	=> l_hist_pre.information1,
											  p_date_effective		=> l_hist_rec.effective_date,
											  p_element_entry_data		=> l_date_eff_rec,
											  p_result_code			=> l_result_code,
											  p_pa_history_id			=> l_pa_history_id);
					if l_result_code is not null then
						-- this should never be the case
						-- raise error.
						hr_utility.set_location( l_proc, 50);
			     			hr_utility.set_message(8301,'GHR_38361_ELEMENT_ROW_NFND');
					      hr_utility.raise_error;
					end if;
					hr_utility.set_location( 'l_hist_rec.pa_history_id: ' || l_hist_rec.pa_history_id || l_proc, 1150);
					hr_utility.set_location( 'l_pa_history_id: ' || l_pa_history_id || l_proc, 1250);
					if (l_hist_rec.pa_history_id = l_pa_history_id) then

						-- update element_entry_value here.
						-- update application table with pre-values
						update_eleentval	(p_hist_pre		=>	l_hist_pre);
					end if;
				end if;
			end if;
			-- Delete history record
  			delete_hist_row ( l_hist_rec.pa_history_id);
  		else
		      hr_utility.set_location('Processing non element entry table'|| l_proc,50);
  			-- cascade changes thru history table
  			ghr_history_cascade.cascade_history_data (
  				p_table_name		=> 	l_hist_rec.table_name,
  				p_person_id			=>	l_hist_rec.person_id,
  				p_pre_record		=>	l_hist_pre,
  				p_post_record		=>	l_hist_rec,
  				p_cascade_type		=>	'cancel',
  				p_interv_on_table 	=>	l_interv_on_table,
  				p_interv_on_eff_date	=>	l_interv_on_eff_date,
  				p_hist_data_as_of_date	=>	l_hist_data_as_of_date);

			-- Determine if this record was created or updated.
			if l_datetrack_table then
                                  hr_utility.set_location('In Cancel - Date track table' ,1);
				if l_hist_rec.DML_operation = ghr_history_api.g_ins_operation then
                                  hr_utility.set_location('in Cancel - DML - Ins' ,1);
					l_rec_created_flag := TRUE;

				-- if this sf50 updated the row, then the pre must have the same date.
				-- The triggers work such that we will only have update from sf50 operation
				-- when the effective_date is the same. If the pre has a different effective
				-- date, then the original row that was created must have been deleted due to
				-- a cancellation. In this case, the current row becomes the row that was created
				-- by the sf52. So, we must set the rec_created_flag to true for this row. Note
				-- this stands true with date tracked tables only as with non-date tracked tables there
				-- is only one row in a record, so this case will never occur.
				elsif l_hist_rec.DML_operation = ghr_history_api.g_upd_operation then
                                               hr_utility.set_location('in Cancel - DML - Upd' ,1);
					if l_hist_rec.effective_date <> l_hist_pre.effective_date then
						l_rec_created_flag := TRUE;
                                                     hr_utility.set_location('in Cancel - Created' ,1);
					else
						l_rec_created_flag := FALSE;
                                                     hr_utility.set_location('in Cancel - Not Created' ,1);
					end if;
				end if;
			else
                                               hr_utility.set_location('In Cancel - Not a Date track table' ,1);
				l_rec_created_flag := (l_hist_rec.DML_operation = ghr_history_api.g_ins_operation);
			end if;

   			what_to_do(
				p_datetrack_table		=>	l_datetrack_table,
  				p_pre_record_exists 	=>	l_pre_record,
  				p_interv_on_table		=>	l_interv_on_table,
  				p_interv_on_eff_date	=>	l_interv_on_eff_date,
  				p_rec_created_flag	=>	l_rec_created_flag,
  				p_can_delete		=>	l_can_delete,
  				p_last_row			=>	l_last_row,
  				p_cannot_cancel		=>	l_cannot_cancel);
		   If l_interv_on_table then
				hr_utility.set_location('what to do' || '  interv on table',1);
		   else
		 		hr_utility.set_location('what to do ' || 'no interv on table',1);
		   end if;
		   If l_interv_on_eff_date then
				hr_utility.set_location('what to do' || '  interv on eff',1);
		   else
				hr_utility.set_location('what to do ' || 'no interv on eff' ,1);
		   end if;

  			if (l_cannot_cancel = TRUE) then
			      hr_utility.set_location('ERROR: Cannot cancel'|| l_proc,55);
  				-- error, cannot cancel
  			      hr_utility.set_message(8301,'GHR_38212_CANNOT_CANCEL');
			      hr_utility.raise_error;
  			end if;

			-- use flags to determine datetrack_mode, if needed.
			-- delete row under conditions outlined below.
			l_deleted	:= FALSE;
  			l_datetrack_mode := null;
  			if (l_can_delete = TRUE) then
			      hr_utility.set_location('CAN delete'|| l_proc,60);
  				if (l_datetrack_table = TRUE) then
				      hr_utility.set_location('Datetrack table'|| l_proc,65);
  					if (l_pre_record = FALSE and l_last_row = TRUE) then
					      hr_utility.set_location('Only Row'|| l_proc,70);
  						l_datetrack_mode := hr_api.g_zap;
  					else
					      hr_utility.set_location('Not Only Row'|| l_proc,75);
  						l_datetrack_mode	:= hr_api.g_delete_next_change;

  					end if;
  				end if;
                                hr_utility.set_location('after what to do Del Mode ' || l_datetrack_mode,1);
  				-- only do the delete if this is a datetrack table or if it is the only row of a
  				-- non datetrack table. In all other cases, cascade will properly handle it.

  				if (l_datetrack_table = TRUE or (l_last_row = TRUE and l_pre_record = FALSE)) then
					hr_utility.set_location('Deleting Application row'|| l_proc,80);
					l_deleted := TRUE;
  					delete_appl_row(	p_table_name	=> 	l_hist_rec.table_name,
  								p_table_pk_id	=>	l_hist_rec.information1,
  								p_dt_mode		=>	l_datetrack_mode,
  								p_date_effective	=>	l_hist_rec.effective_date);
                                         hr_utility.set_location('Hist Rec Eff . Date ' || l_hist_rec.effective_date,1);

  				end if;
  			end if;
			-- Delete history record
  			delete_hist_row ( l_hist_rec.pa_history_id);
  			-- cascade changes thru application table, if the application table record was not already deleted above.
                        if (l_deleted = FALSE)
                                     or (l_datetrack_mode   = hr_api.g_delete_next_change) then
                          if (l_deleted = FALSE) then
                          hr_utility.set_location('deleted is false : Bef cascade appl_table',1);
                          else

                          hr_utility.set_location('delete next change : Bef cascade appl_table',1);
                          end if;
			-- Sundar Bug#2872298 Cascade should not occur if records are already deleted and
				-- delete mode in DELETE_NEXT_CHANGE
				IF (l_deleted = TRUE) AND (l_datetrack_mode   = hr_api.g_delete_next_change) --AND (p_sf52_data.second_noa_code = '790')
				THEN
						   NULL;
				ELSE
				  --5900178
				      l_rec_exists := TRUE;
   	                              IF l_hist_rec.table_name = 'PER_PERSON_ANALYSES' THEN
      	                                 hr_utility.set_location('In per_person_analyses record checking',997);
                                	 OPEN chk_perana_exists(p_person_analysis_id => l_hist_rec.information1);
                                 	 FETCH chk_perana_exists into m_perana;
                                         IF chk_perana_exists%NOTFOUND THEN
                                       	    hr_utility.set_location('In per_person_analyses record checking--notfound',996);
                                            l_rec_exists := FALSE;
                                         END IF;
                                         CLOSE chk_perana_exists;
                                      END IF;

                                       IF l_rec_exists THEN
	  				ghr_history_cascade.cascade_appl_table_data (
						p_table_name		=> 	l_hist_rec.table_name,
						p_person_id	        =>	l_hist_rec.person_id,
						p_pre_record		=>	l_hist_pre,
						p_post_record		=>	l_hist_rec,
						p_cascade_type		=>	'cancel',
						p_interv_on_table 	=>	l_interv_on_table,
						p_interv_on_eff_date	=>	l_interv_on_eff_date,
						p_hist_data_as_of_date	=>	l_hist_data_as_of_date);
				       END IF;
				END IF;

			end if;
  		end if;
  	END LOOP;
	hr_utility.set_location('Exited Loop'|| l_proc,85);

	ghr_agency_update.ghr_agency_upd(
			p_pa_request_rec			=> l_sf52_data,
			p_asg_sf52				=> l_imm_asg_sf52,
			p_asg_non_sf52			=> l_imm_asg_non_sf52,
			p_asg_nte_dates			=> l_imm_asg_nte_dates,
			p_per_sf52              	=> l_imm_per_sf52,
			p_per_group1            	=> l_imm_per_group1,
			p_per_group2            	=> l_imm_per_group2,
			p_per_scd_info          	=> l_imm_per_scd_info,
			p_per_retained_grade    	=> l_imm_per_retained_grade,
			p_per_probations			=> l_imm_per_probations,
			p_per_sep_Retire 	      	=> l_imm_per_sep_retire,
			p_per_security          	=> l_imm_per_security,
			p_per_conversions	      	=> l_imm_per_conversions,
			p_per_uniformed_services	=> l_imm_per_uniformed_services,
			p_pos_oblig                   => l_imm_pos_oblig,
			p_pos_grp2                    => l_imm_pos_grp2,
			p_pos_grp1                    => l_imm_pos_grp1,
			p_pos_valid_grade             => l_imm_pos_valid_grade,
			p_pos_car_prog                => l_imm_pos_car_prog,
			p_loc_info                    => l_imm_loc_info,
			p_wgi                         => l_imm_wgi,
			p_recruitment_bonus	      => l_imm_recruitment_bonus,
			p_relocation_bonus	      => l_imm_relocation_bonus ,
			p_sf52_from_data              => l_imm_sf52_from_data,
			p_personal_info	            => l_imm_personal_info,
			p_gov_awards_type             => l_imm_gov_awards,
			p_perf_appraisal_type         => l_imm_perf_appraisal,
			p_payroll_type                => l_imm_payroll_type,
			p_conduct_perf_type           => l_imm_conduct_performance,
			p_agency_code		      => l_agency_code,
			p_agency_sf52			=> l_imm_agency_sf52,
			p_entitlement                 => l_imm_entitlement,
			p_foreign_lang_prof_pay       => l_imm_foreign_lang_prof_pay,
			p_edp_pay                     => l_imm_edp_pay,
			p_hazard_pay                  => l_imm_hazard_pay,
			p_health_benefits             => l_imm_health_benefits,
			p_danger_pay                  => l_imm_danger_pay,
			p_imminent_danger_pay         => l_imm_imminent_danger_pay,
			p_living_quarters_allow       => l_imm_living_quarters_allow,
			p_post_diff_amt               => l_imm_post_diff_amt,
			p_post_diff_percent           => l_imm_post_diff_percent,
			p_sep_maintenance_allow       => l_imm_sep_maintenance_allow,
			p_supplemental_post_allow     => l_imm_supplemental_post_allow,
			p_temp_lodge_allow            => l_imm_temp_lodge_allow,
			p_premium_pay                 => l_imm_premium_pay,
			p_retirement_annuity          => l_imm_retirement_annuity,
			p_severance_pay               => l_imm_severance_pay,
			p_thrift_saving_plan          => l_imm_thrift_saving_plan,
			p_retention_allow_review      => l_imm_retention_allow_review,
			p_health_ben_pre_tax          => l_imm_health_ben_pre_tax,
            p_per_benefit_info            => l_imm_per_benefit_info,
            p_imm_retirement_info         => l_imm_retirement_info); --Bug# 7131104

	-- call post_sf52_cancel to handle notifications, marking pa_requests cancelled, etc.
	ghr_sf52_post_update.post_sf52_cancel(
		p_pa_request_id		=> p_sf52_data.pa_request_id,
		p_effective_date		=> l_session_var.date_effective,
		p_object_version_number	=> p_sf52_data.object_version_number,
		p_from_position_id	=> p_sf52_data.from_position_id,
		p_to_position_id		=> p_sf52_data.to_position_id,
		p_agency_code		=> p_sf52_data.agency_code);

	hr_utility.set_location( l_proc, 90);
	Undo_Mark_Cancel ( p_sf52_data  => p_sf52_data);
	hr_utility.set_location( 'Leaving ' || l_proc, 100);
      End if;
 Exception when others then
           --
           -- Reset IN OUT parameters and set OUT parameters
           --
           p_sf52_data := l_sf52_data_rec;
           raise;

END Cancel_Other_Family_Sf52 ;

-- ---------------------------------------------------------------------------
-- |--------------------------< correction_sf52>------------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure handles a correction sf52.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_sf52_data		->		ghr_pa_requests record of the correction sf52.
-- Post Success:
-- 	The correction will have been applied.
--
-- Post Failure:
--   	No failure conditions.
--
-- Developer Implementation Notes:
--	None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

-- This is a sf52 wrapper procedure. It gets the sf52 and the sf52 extra info
-- record and calls db_update procedures.
Procedure correction_sf52( p_sf52_data 	in	ghr_pa_requests%rowtype,
			   p_process_type in	varchar2	default 'CURRENT',
                           p_capped_other_pay in number default null  ) is

	l_sf52_data_result	ghr_pa_requests%rowtype;
	l_sf52                  ghr_pa_requests%rowtype;
	l_root_sf52             ghr_pa_requests%rowtype;

	l_pa_request_id		number;
	l_today			date	:=sysdate;
	l_session_var		ghr_history_api.g_session_var_type;
	l_sf52_ei_data		ghr_pa_request_extra_info%rowtype;
	l_agency_ei_data		ghr_pa_request_extra_info%rowtype;
	l_sf52_data			ghr_pa_requests%rowtype;
	l_sf52_data1		ghr_pa_requests%rowtype;
	l_shadow_data		ghr_pa_request_shadow%rowtype;
	l_result			varchar2(1000);

	-- this cursor gets the noa_family_code for noa_id (nature of action ID) passed.
	cursor c_fam (c_noa_id number) is
	select
		fams.noa_family_code
	from  ghr_noa_families noafam,
		ghr_families     fams
	where noafam.nature_of_action_id = c_noa_id               and
		noafam.enabled_flag        = 'Y'                    and
		fams.noa_family_code 	   = noafam.noa_family_code and
		fams.enabled_flag          = 'Y'                    and
		fams.update_hr_flag = 'Y';

	cursor c_get_root (c_pa_request_id in number) is
	select *
	from ghr_pa_requests
		connect by pa_request_id = prior altered_pa_request_id
		start with pa_request_id = c_pa_request_id
	order by level desc;

	cursor c_get_hist_id (c_pa_request_id in number) is
	select
		min(pa_history_id)
	from ghr_pa_history
	where pa_request_id = c_pa_request_id;

	cursor get_shadow (c_pa_request_id in number) is
	select *
	from ghr_pa_request_shadow
	where pa_request_id = c_pa_request_id;

	l_proc		varchar2(30):='correction_sf52';
	l_people_data	per_all_people_f%rowtype;

	--6850492
	cursor chk_dual_action(c_pa_request_id in number)
	    is
	    select 'Y'
	    from   ghr_pa_requests
	    where  pa_request_id = (select min(pa_request_id)
     	                            from   ghr_pa_requests
               	                    where  pa_notification_id is not null
	                            connect by pa_request_id = prior altered_pa_request_id
	                            start with pa_request_id = c_pa_request_id)
            and   second_noa_code is not null
	    and   first_noa_code not in ('001','002');


	l_dual_flag_yn varchar2(1);
	--6850492



Procedure Refresh_Cascade_Name( p_sf52_rec	in out nocopy 	ghr_pa_requests%rowtype,
					 p_shadow_rec	in out nocopy ghr_pa_request_shadow%rowtype) is

	l_result_code	varchar2(30);
	l_people_data	per_all_people_f%rowtype;
	l_hist_id		number;
	l_proc		varchar2(40):='Refresh_Cascade_Name';
        l_capped_other_pay number := hr_api.g_number;

	cursor get_hist is
	select pa_history_id
	from ghr_pa_history
	where pa_request_id = p_sf52_rec.altered_pa_request_id and
		nature_of_action_id = p_sf52_rec.second_noa_id;

   l_sf52_rec   ghr_pa_requests%rowtype;
   l_shadow_rec ghr_pa_request_shadow%rowtype;
Begin

	hr_utility.set_location( 'Entering ' || l_proc, 10);
   l_sf52_rec    := p_sf52_rec;
   l_shadow_rec  := p_shadow_rec;

	open get_hist;
	fetch get_hist into l_hist_id;
	close get_hist;
	hr_utility.set_location( 'Fetched Hist id' || l_proc, 15);

	ghr_history_fetch.fetch_people(
		p_person_id				=> p_sf52_data.person_id,
		p_date_effective			=> p_sf52_data.effective_date,
		p_pa_history_id			=> l_hist_id,
		p_altered_pa_request_id		=> p_sf52_data.altered_pa_request_id,
		p_noa_id_corrected		=> p_sf52_data.second_noa_id,
		p_people_data			=> l_people_data,
		p_result_code			=> l_result_code
	);

	if l_result_code is NULL then
		hr_utility.set_location( 'People Data Found' || l_proc, 20);

		if nvl(p_sf52_rec.employee_first_name, hr_api.g_varchar2)  = nvl(p_shadow_rec.employee_first_name , hr_api.g_varchar2) and
		   nvl(p_sf52_rec.employee_last_name , hr_api.g_varchar2)  = nvl(p_shadow_rec.employee_last_name  , hr_api.g_varchar2) and
		   nvl(p_sf52_rec.employee_middle_names,hr_api.g_varchar2) = nvl(p_shadow_rec.employee_middle_names, hr_api.g_varchar2)    then

			hr_utility.set_location( 'Refresh Name ' || l_proc, 30);
			p_sf52_rec.employee_first_name	:=	l_people_data.first_name;
			p_sf52_rec.employee_last_name		:=	l_people_data.last_name;
			p_sf52_rec.employee_middle_names	:=	l_people_data.middle_names;

			p_shadow_rec.employee_first_name	:=	l_people_data.first_name;
			p_shadow_rec.employee_last_name	:=	l_people_data.last_name;
			p_shadow_rec.employee_middle_names	:=	l_people_data.middle_names;
		end if;

		hr_utility.set_location( 'Check SSN ' || l_proc, 35);
		if nvl(p_sf52_rec.employee_national_identifier, hr_api.g_varchar2) = nvl(p_shadow_rec.employee_national_identifier, hr_api.g_varchar2) then
			hr_utility.set_location( 'Refresh SSN ' || l_proc, 40);
			p_sf52_rec.employee_national_identifier   := l_people_data.national_identifier;
			hr_utility.set_location( 'Refresh SSN ' || l_proc, 41);
			p_shadow_rec.employee_national_identifier := l_people_data.national_identifier;
		end if;

		hr_utility.set_location( 'check DOB ' || l_proc, 45);
		if nvl(p_sf52_rec.employee_date_of_birth, hr_api.g_date) = nvl(p_shadow_rec.employee_date_of_birth, hr_api.g_date) then
			hr_utility.set_location( 'Refresh DOB ' || l_proc, 50);
			p_sf52_rec.employee_date_of_birth   := l_people_data.date_of_birth;
			hr_utility.set_location( 'Refresh DOB ' || l_proc, 51);
			p_shadow_rec.employee_date_of_birth := l_people_data.date_of_birth;
		end if;

	end if;
	hr_utility.set_location( 'Leaving ' || l_proc, 100);
 Exception when others then
      --
      -- Reset IN OUT parameters and set OUT parameters
      --
      p_sf52_rec    := l_sf52_rec;
      p_shadow_rec  := l_shadow_rec;
      raise;

End;

begin

	hr_utility.set_location('Entering:'|| l_proc, 5);
	-- reinitialise session variables
	ghr_history_api.reinit_g_session_var;

	-- set values of session variables
	l_session_var.pa_request_id 	:= p_sf52_data.pa_request_id;
	l_session_var.noa_id		:= p_sf52_data.second_noa_id;
	l_session_var.fire_trigger	:= 'Y';
	l_session_var.date_Effective	:= p_sf52_data.effective_date;
	l_session_var.person_id		:= p_sf52_data.person_id;
	l_session_var.program_name	:= 'sf50';
	l_session_var.altered_pa_request_id	:= p_sf52_data.altered_pa_request_id;
	l_session_var.noa_id_correct	:= p_sf52_data.second_noa_id;
	l_session_var.assignment_id	:= p_sf52_data.employee_assignment_id;
	ghr_history_api.set_g_session_var(l_session_var);


-- .47

	-- Refresh Correction and shadow for Employee Name
	open get_shadow( p_sf52_data.pa_request_id);
	fetch get_shadow into l_shadow_data;
	close get_shadow;

	l_sf52_data := p_sf52_data;
      IF (l_sf52_data.second_noa_code <> '780') then
	Refresh_Cascade_Name( p_sf52_rec	=> l_sf52_data,
				    p_shadow_rec	=> l_shadow_data);

	ghr_process_sf52.update_rfrs_values(p_sf52_data		=>	l_sf52_data,
							p_shadow_data	=>	l_shadow_data);
      END IF;

	l_sf52_data1 := l_sf52_data;
-- .47

/* .47
	-- get root sf52 for this correction
	hr_utility.set_location(l_proc, 102);
	open c_get_root (p_sf52_data.altered_pa_request_id);
	fetch c_get_root into l_root_sf52;
	if c_get_root%notfound then
		hr_utility.set_location(l_proc, 103);
		close c_get_root ;
	      hr_utility.set_message(8301,'GHR_38493_ROOT_SF52_NFND');
	      hr_utility.raise_error;
	else
		close c_get_root ;
	end if;


	-- refresh root sf52 and its correction
	-- get pa_history_id for the root pa_request_id
	open c_get_hist_id( l_root_sf52.pa_request_id);
	fetch c_get_hist_id into l_session_var.pa_history_id;
	if c_get_hist_id%notfound then
		-- raise error;
		close c_get_hist_id;
	else
		close c_get_hist_id;
	end if;
	-- We are setting pa_history_id in session var to be able to fetch
	-- Pre-record values of the root SF52 for refresh purpose.
	-- It'll be reset after refresh has been done

	ghr_history_api.set_g_session_var(l_session_var);
	ghr_process_sf52.refresh_req_shadow(p_sf52_data		=>	l_root_sf52,
							p_shadow_data	=>	l_shadow_data);
	ghr_process_sf52.redo_pay_calc(	p_sf52_rec		=>	l_root_sf52);
	ghr_process_sf52.update_rfrs_values(p_sf52_data		=>	l_root_sf52,
							p_shadow_data	=>	l_shadow_data);

	-- reset pa_history_id in session variable.
	l_session_var.pa_history_id := null;
	ghr_history_api.set_g_session_var(l_session_var);

-- .47
*/


	-- fetch the noa_family_code for the original noa in the correction chain; second_noa_id contains the
	-- noa_id of the original noa in the chain).
	open c_fam(l_sf52_data.second_noa_id);
	fetch c_fam into l_sf52_data.noa_family_code;
	if c_fam%NOTFOUND then
		close c_fam;
	      hr_utility.set_message(8301,'GHR_38211_NOA_FAMILY_NOTFOUND');
	      hr_utility.raise_error;
	end if;
	close c_fam;


	-- build up the sf52_data record by calling apply_noa_corrections.
	-- when this completes, l_sf52_data_result will contain the data of the original
	-- sf52, with all corrections in the correction chain applied onto it.
	-- apply_noa_corrections ensures that name/dob/ssn are retained from the last correction ie the one being processed.
	hr_utility.set_location('from_step_or_rate right before apply_noa_corrections: '|| l_sf52_data.from_step_or_rate || l_proc, 915);
        ghr_process_sf52.print_sf52(' l_sf52_data before apply_noa ',l_sf52_data);
        ghr_process_sf52.print_sf52(' l_sf52_data_result before apply_noa ',l_sf52_data_result);
	-- Bug # 6850492 added the following if condition to call seperate correction
	-- procedure for dual actions.
	hr_utility.set_location('l_root_sf52.second_noa_code'||l_root_sf52.second_noa_code,100);
	hr_utility.set_location('l_root_sf52.first_noa_code'||l_root_sf52.first_noa_code,100);
        hr_utility.set_location('l_sf52_data.mass_action_id'||l_sf52_data.mass_action_id,100);
        hr_utility.set_location('l_sf52_data.rpa_type'||l_sf52_data.rpa_type,100);
	l_dual_flag_yn :='N';
	open chk_dual_action(l_sf52_data.pa_request_id);
	fetch  chk_dual_action into l_dual_flag_yn;
	close chk_dual_action;
	if NVL(l_dual_flag_yn,'N') = 'Y' and  l_sf52_data.mass_action_id is not null and
	  l_sf52_data.rpa_type = 'DUAL' then
	    hr_utility.set_location('Calling dual noa_corrections',1000);
	    apply_dual_noa_corrections(l_sf52_data, l_sf52_data_result);
	else
	    apply_noa_corrections( 	l_sf52_data, l_sf52_data_result );
	end if;
        ghr_process_sf52.print_sf52(' l_sf52_data after apply_noa ',l_sf52_data);
        ghr_process_sf52.print_sf52(' l_sf52_data_result after apply_noa ',l_sf52_data_result);

	ghr_process_Sf52.Fetch_extra_info(
			p_pa_request_id 	=> l_sf52_data.pa_request_id,
			p_noa_id   		=> l_sf52_data.second_noa_id,
			p_sf52_ei_data 	=> l_sf52_ei_data,
			p_result		=> l_result);

	ghr_process_Sf52.Fetch_extra_info(
			p_pa_request_id 	=> l_sf52_data.pa_request_id,
			p_noa_id   		=> l_sf52_data.second_noa_id,
			p_agency_ei		=> TRUE,
			p_sf52_ei_data 	=> l_agency_ei_data,
			p_result		=> l_result);

	-- check for future action
	hr_utility.set_location('national_identifier right before update sf52: '|| l_sf52_data_result.employee_national_identifier || l_proc, 915);
	hr_utility.set_location('from_step_or_rate right before update sf52: '|| l_sf52_data_result.from_step_or_rate || l_proc, 915);
	hr_utility.set_location('to_step_or_rate right before update sf52: '|| l_sf52_data_result.to_step_or_rate || l_proc, 915);

	ghr_history_api.display_g_session_var;
      -- Check if atleast the min. required items exist in the pa_request
      ghr_sf52_validn_pkg.prelim_req_chk_for_update_hr(p_pa_request_rec       =>  l_sf52_data_result);
	if (l_session_var.date_Effective > l_today) then
		-- issue savepoint
		savepoint single_Action_sf52;

		ghr_sf52_update.main( 	p_pa_request_rec    	=> 	l_sf52_data_result,
						p_pa_request_ei_rec 	=>	l_sf52_ei_data,
						p_generic_ei_rec		=> 	l_agency_ei_data,
                                                p_capped_other_pay => p_capped_other_pay);
		-- rollback to savepoint
		rollback  to single_action_sf52;
	else
               --RP
		ghr_sf52_update.main( 	p_pa_request_rec    	=> 	l_sf52_data_result,
						p_pa_request_ei_rec 	=>	l_sf52_ei_data,
						p_generic_ei_rec		=> 	l_agency_ei_data,
                                                p_capped_other_pay => p_capped_other_pay);
	hr_utility.set_location('to_position_id right before update sf52: '|| l_sf52_data_result.to_position_id || l_proc, 915);
     hr_utility.set_location('After main update :'|| l_proc, 20);
                ghr_sf52_post_update.Post_sf52_process(
                        p_pa_request_id         => p_sf52_data.pa_request_id,
                        p_effective_date                => l_session_var.date_effective,
                        p_object_version_number => l_sf52_data1.object_version_number,
                        p_from_position_id      => l_sf52_data_result.from_position_id,
                        p_to_position_id                => l_sf52_data_result.to_position_id,
                        p_agency_code           => l_sf52_data_result.agency_code,
                        p_sf52_data_result      => l_sf52_data_result,
                        p_called_from           => 'CORRECTION_SF52'
                );

       end if;
		hr_utility.set_location(' Leaving:'||l_proc, 10);
end correction_sf52;

-- ---------------------------------------------------------------------------
-- |--------------------------< delete_hist_row>------------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure deletes a row in ghr_pa_history for the rowid passed.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_row_id		->		rowid of the row to be deleted in
--						ghr_pa_history.
-- Post Success:
-- 	The row will have been deleted.
--
-- Post Failure:
--   	No failure conditions.
--
-- Developer Implementation Notes:
--	None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

Procedure delete_hist_row ( p_row_id 	in	rowid) is
	l_proc	varchar2(30):='delete_hist_row';
Begin
	hr_utility.set_location( 'Entering : ' || l_proc, 10);
	delete ghr_pa_history
		where rowid = p_row_id;
	hr_utility.set_location( 'Leaving : ' || l_proc, 20);
End delete_hist_row;

-- ---------------------------------------------------------------------------
-- |--------------------------< delete_hist_row>------------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure deletes a row in ghr_pa_history for the pa_history_id passed.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_pa_history_id		->		pa_history_id
--							of the row to be deleted in ghr_pa_history.
-- Post Success:
-- 	The row will have been deleted.
--
-- Post Failure:
--   	No failure conditions.
--
-- Developer Implementation Notes:
--	None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

Procedure delete_hist_row ( p_pa_history_id 	in	ghr_pa_history.pa_history_id%type) is
	l_proc	varchar2(30):='delete_hist_row';
Begin
	hr_utility.set_location( 'Entering : ' || l_proc, 30);
	delete ghr_pa_history
		where pa_history_id = p_pa_history_id;
	hr_utility.set_location( 'Leaving : ' || l_proc, 40);
End delete_hist_row;

-- ---------------------------------------------------------------------------
-- |--------------------------< apply_correction>-----------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure applies a correction by copying the fields from the
--	p_sf52rec_correct record to p_sf52rec record and puts the result in
--	sf52rec_result.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_sf52_rec_correct		->		the ghr_pa_requests record that we are
--								copying from.
--	p_corr_pa_request_id		->		the pa_request_id of the correction
--								that is currently being processed.
--	p_sf52rec				->		results of the applied correction are put
--								here.
-- Post Success:
-- 	The correction will have been applied and the result put in p_sf52rec.
--
-- Post Failure:
--   	No failure conditions.
--
-- Developer Implementation Notes:
--	Note that a lot of thought went into determining which fields should be copied and
--	which fields should not be copied. (Need to re-visit this comment to put in details of
--	why certain fields were included and others not included).
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

-- This procedure copies the fields from the p_sf52rec_correct record to
-- p_sf52rec record and puts te result in sf52rec_result.
PROCEDURE apply_correction (
   		p_sf52rec_correct  	in 		ghr_pa_requests%rowtype,
		p_corr_pa_request_id	in		ghr_pa_requests.pa_request_id%type,
 		p_sf52rec   		in out nocopy 	ghr_pa_requests%rowtype ) is

	l_proc	varchar2(30):='apply_correction';
    l_sf52rec ghr_pa_requests%rowtype;

    -- Begin Bug# 5014663
    l_asg_ei_data  		per_assignment_extra_info%rowtype;
    l_award_salary		number;
    l_temp_award_amount	number;
    -- End Bug# 5014663


BEGIN
	hr_utility.set_location('Entering:'|| l_proc, 5);
   l_sf52rec := p_sf52rec;
	hr_utility.set_location('pre par: rec_correct pa_request id=' || p_sf52rec_correct.pa_request_id,6);
	hr_utility.set_location('pre par: rec pa_request id=' || p_sf52rec.pa_request_id,7);
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.pa_request_id                   , p_sf52rec.pa_request_id                    );
	hr_utility.set_location('post par: rec_correct pa_request id=' || p_sf52rec_correct.pa_request_id,6);
	hr_utility.set_location('post par: rec pa_request id=' || p_sf52rec.pa_request_id,7);
-- the following two fields are not filled in because they are derived.
--	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.pa_notification_id              , p_sf52rec.pa_notification_id               );
--	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.noa_family_code                 , p_sf52rec.noa_family_code                  );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.academic_discipline             , p_sf52rec.academic_discipline              );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.agency_code                     , p_sf52rec.agency_code                      );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.altered_pa_request_id           , p_sf52rec.altered_pa_request_id            );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.annuitant_indicator             , p_sf52rec.annuitant_indicator              );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.annuitant_indicator_desc        , p_sf52rec.annuitant_indicator_desc         );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.appropriation_code1             , p_sf52rec.appropriation_code1              );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.appropriation_code2             , p_sf52rec.appropriation_code2              );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.approval_date                   , p_sf52rec.approval_date                    );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.approving_official_work_title   , p_sf52rec.approving_official_work_title    );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.award_uom                       , p_sf52rec.award_uom                        );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.bargaining_unit_status          , p_sf52rec.bargaining_unit_status           );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.citizenship                     , p_sf52rec.citizenship                      );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.duty_station_code               , p_sf52rec.duty_station_code                );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.duty_station_desc               , p_sf52rec.duty_station_desc                );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.duty_station_id                 , p_sf52rec.duty_station_id                  );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.duty_station_location_id        , p_sf52rec.duty_station_location_id         );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.education_level                 , p_sf52rec.education_level                  );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.effective_date                  , p_sf52rec.effective_date                   );
	hr_utility.set_location('pre: rec_correct assignment id=' || p_sf52rec_correct.employee_assignment_id,6);
	hr_utility.set_location('pre: rec assignment id=' || p_sf52rec.employee_assignment_id,7);
	hr_utility.set_location('pre: rec_correct pa_request id=' || p_sf52rec_correct.pa_request_id,6);
	hr_utility.set_location('pre: rec pa_request id=' || p_sf52rec.pa_request_id,7);
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.employee_assignment_id          , p_sf52rec.employee_assignment_id           );
	hr_utility.set_location('post: rec_correct assignment id=' || p_sf52rec_correct.employee_assignment_id,8);
	hr_utility.set_location('post: rec assignment id=' || p_sf52rec.employee_assignment_id,9);
	hr_utility.set_location('post: rec_correct pa_request id=' || p_sf52rec_correct.pa_request_id,6);
	hr_utility.set_location('post: rec pa_request id=' || p_sf52rec.pa_request_id,7);
	hr_utility.set_location('post: national_identifier=' || p_sf52rec.employee_national_identifier,7);
    	hr_utility.set_location('post: reccorrect national_identifier =' || p_sf52rec_correct.employee_national_identifier,7);
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.employee_date_of_birth          , p_sf52rec.employee_date_of_birth           );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.employee_dept_or_agency         , p_sf52rec.employee_dept_or_agency          );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.employee_first_name             , p_sf52rec.employee_first_name              );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.employee_last_name              , p_sf52rec.employee_last_name               );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.employee_middle_names           , p_sf52rec.employee_middle_names            );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.employee_national_identifier    , p_sf52rec.employee_national_identifier     );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.fegli                           , p_sf52rec.fegli                            );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.fegli_desc                      , p_sf52rec.fegli_desc                       );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.first_action_la_code1           , p_sf52rec.first_action_la_code1            );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.first_action_la_code2           , p_sf52rec.first_action_la_code2            );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.first_action_la_desc1           , p_sf52rec.first_action_la_desc1            );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.first_action_la_desc2           , p_sf52rec.first_action_la_desc2            );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.first_noa_cancel_or_correct     , p_sf52rec.first_noa_cancel_or_correct      );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.first_noa_code                  , p_sf52rec.first_noa_code                   );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.first_noa_desc                  , p_sf52rec.first_noa_desc                   );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.first_noa_id                    , p_sf52rec.first_noa_id                     );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.first_noa_pa_request_id         , p_sf52rec.first_noa_pa_request_id          );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.flsa_category                   , p_sf52rec.flsa_category                    );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.forwarding_address_line1        , p_sf52rec.forwarding_address_line1         );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.forwarding_address_line2        , p_sf52rec.forwarding_address_line2         );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.forwarding_address_line3        , p_sf52rec.forwarding_address_line3         );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.forwarding_country              , p_sf52rec.forwarding_country               );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.forwarding_postal_code          , p_sf52rec.forwarding_postal_code           );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.forwarding_region_2             , p_sf52rec.forwarding_region_2              );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.forwarding_town_or_city         , p_sf52rec.forwarding_town_or_city          );

	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.from_adj_basic_pay              , p_sf52rec.from_adj_basic_pay               );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.from_position_org_line1         , p_sf52rec.from_position_org_line1          );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.from_agency_code                , p_sf52rec.from_agency_code                 );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.from_agency_desc                , p_sf52rec.from_agency_desc                 );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.from_basic_pay                  , p_sf52rec.from_basic_pay                   );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.from_grade_or_level             , p_sf52rec.from_grade_or_level              );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.from_locality_adj               , p_sf52rec.from_locality_adj                );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.from_occ_code                   , p_sf52rec.from_occ_code                    );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.from_office_symbol              , p_sf52rec.from_office_symbol               );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.from_other_pay_amount           , p_sf52rec.from_other_pay_amount            );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.from_pay_basis                  , p_sf52rec.from_pay_basis                   );
      hr_utility.set_location('correct ' || p_sf52rec_correct.from_pay_plan,1);
      hr_utility.set_location('sf52rec ' || p_sf52rec.from_pay_plan,1);
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.from_pay_plan                   , p_sf52rec.from_pay_plan                    );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.from_position_id                , p_sf52rec.from_position_id                 );
-- this is informational only and is not needed
-- ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.from_position_name              , p_sf52rec.from_position_name               );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.from_position_number            , p_sf52rec.from_position_number             );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.from_position_seq_no            , p_sf52rec.from_position_seq_no             );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.from_position_title             , p_sf52rec.from_position_title              );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.from_step_or_rate               , p_sf52rec.from_step_or_rate                );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.from_total_salary               , p_sf52rec.from_total_salary                );


	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.functional_class                , p_sf52rec.functional_class                 );
    -- Bug#4694896
    ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.input_pay_rate_determinant      , p_sf52rec.input_pay_rate_determinant       );
    ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.pay_rate_determinant            , p_sf52rec.pay_rate_determinant             );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.personnel_office_id             , p_sf52rec.personnel_office_id              );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.person_id                       , p_sf52rec.person_id                        );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.position_occupied               , p_sf52rec.position_occupied                );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.resign_and_retire_reason_desc   , p_sf52rec.resign_and_retire_reason_desc    );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.retirement_plan                 , p_sf52rec.retirement_plan                  );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.retirement_plan_desc            , p_sf52rec.retirement_plan_desc             );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.service_comp_date               , p_sf52rec.service_comp_date                );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.supervisory_status              , p_sf52rec.supervisory_status               );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.tenure                          , p_sf52rec.tenure                           );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.to_grade_id                     , p_sf52rec.to_grade_id                      );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.to_office_symbol                , p_sf52rec.to_office_symbol                 );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.to_job_id   		          , p_sf52rec.to_job_id	                   );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.to_occ_code  	                , p_sf52rec.to_occ_code                 	 );

-- this is informational only and is not needed
	-- ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.to_position_name                , p_sf52rec.to_position_name                 );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.to_step_or_rate                 , p_sf52rec.to_step_or_rate                  );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.to_total_salary                 , p_sf52rec.to_total_salary                  );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.to_other_pay_amount             , p_sf52rec.to_other_pay_amount	 );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.to_availability_pay             , p_sf52rec.to_availability_pay	 );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.to_ap_premium_pay_indicator     , p_sf52rec.to_ap_premium_pay_indicator );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.to_auo_premium_pay_indicator    , p_sf52rec.to_auo_premium_pay_indicator );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.to_au_overtime	       	    , p_sf52rec.to_au_overtime		 );
--VSM .49
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.to_basic_pay                    , p_sf52rec.to_basic_pay       );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.to_locality_adj                 , p_sf52rec.to_locality_adj    );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.to_adj_basic_pay                , p_sf52rec.to_adj_basic_pay   );
-- VSM .49
	/*
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.to_position_org_line1   	    , p_sf52rec.to_position_org_line1          );
	-- Sundar 15Dec2003 Bug 3191676 Copy other orglines too.
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.to_position_org_line2   	    , p_sf52rec.to_position_org_line2          );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.to_position_org_line3   	    , p_sf52rec.to_position_org_line3          );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.to_position_org_line4   	    , p_sf52rec.to_position_org_line4          );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.to_position_org_line5   	    , p_sf52rec.to_position_org_line5          );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.to_position_org_line6   	    , p_sf52rec.to_position_org_line6          );
	-- End Bug 3191676 */
	-- Above lines commented by Sundar for Bug 2681726 They've been moved below.
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.veterans_preference             , p_sf52rec.veterans_preference              );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.veterans_pref_for_rif           , p_sf52rec.veterans_pref_for_rif            );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.veterans_status                 , p_sf52rec.veterans_status                  );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.work_schedule_desc              , p_sf52rec.work_schedule_desc               );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.year_degree_attained            , p_sf52rec.year_degree_attained             );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.first_noa_information1          , p_sf52rec.first_noa_information1           );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.first_noa_information2          , p_sf52rec.first_noa_information2           );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.first_noa_information3          , p_sf52rec.first_noa_information3           );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.first_noa_information4          , p_sf52rec.first_noa_information4           );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.first_noa_information5          , p_sf52rec.first_noa_information5           );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.first_lac1_information1         , p_sf52rec.first_lac1_information1          );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.first_lac1_information2         , p_sf52rec.first_lac1_information2          );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.first_lac1_information3         , p_sf52rec.first_lac1_information3          );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.first_lac1_information4         , p_sf52rec.first_lac1_information4          );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.first_lac1_information5         , p_sf52rec.first_lac1_information5          );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.first_lac2_information1         , p_sf52rec.first_lac2_information1          );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.first_lac2_information2         , p_sf52rec.first_lac2_information2          );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.first_lac2_information3         , p_sf52rec.first_lac2_information3          );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.first_lac2_information4         , p_sf52rec.first_lac2_information4          );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.first_lac2_information5         , p_sf52rec.first_lac2_information5          );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.attribute_category              , p_sf52rec.attribute_category               );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.attribute1                      , p_sf52rec.attribute1                       );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.attribute2                      , p_sf52rec.attribute2                       );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.attribute3                      , p_sf52rec.attribute3                       );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.attribute4                      , p_sf52rec.attribute4                       );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.attribute5                      , p_sf52rec.attribute5                       );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.attribute6                      , p_sf52rec.attribute6                       );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.attribute7                      , p_sf52rec.attribute7                       );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.attribute8                      , p_sf52rec.attribute8                       );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.attribute9                      , p_sf52rec.attribute9                       );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.attribute10                     , p_sf52rec.attribute10                      );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.attribute11                     , p_sf52rec.attribute11                      );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.attribute12                     , p_sf52rec.attribute12                      );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.attribute13                     , p_sf52rec.attribute13                      );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.attribute14                     , p_sf52rec.attribute14                      );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.attribute15                     , p_sf52rec.attribute15                      );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.attribute16                     , p_sf52rec.attribute16                      );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.attribute17                     , p_sf52rec.attribute17                      );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.attribute18                     , p_sf52rec.attribute18                      );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.attribute19                     , p_sf52rec.attribute19                      );
	ghr_history_conv_rg.copy_field_value( p_sf52rec_correct.attribute20                     , p_sf52rec.attribute20                      );


	-- the following fields should only be copied if the position_id changed, otherwise original values should be
	-- retained.
    if ( 	p_sf52rec_correct.to_position_id is not null ) then
		hr_utility.set_location(' Position id changed :'||l_proc, 20);
		p_sf52rec.to_position_id                  := p_sf52rec_correct.to_position_id     ;
		p_sf52rec.to_organization_id              := p_sf52rec_correct.to_organization_id ;
		p_sf52rec.to_pay_plan                     := p_sf52rec_correct.to_pay_plan        ;
		p_sf52rec.to_position_title               := p_sf52rec_correct.to_position_title  ;
		p_sf52rec.to_position_number              := p_sf52rec_correct.to_position_number ;
		p_sf52rec.to_position_seq_no              := p_sf52rec_correct.to_position_seq_no ;
		p_sf52rec.to_grade_or_level               := p_sf52rec_correct.to_grade_or_level  ;
/*
		p_sf52rec.to_basic_pay                    := p_sf52rec_correct.to_basic_pay       ;
		p_sf52rec.to_locality_adj                 := p_sf52rec_correct.to_locality_adj    ;
		p_sf52rec.to_adj_basic_pay                := p_sf52rec_correct.to_adj_basic_pay   ;
*/
		p_sf52rec.to_pay_basis                    := p_sf52rec_correct.to_pay_basis       ;

                -- Populating position org lines (Bug# 948208)
		-- Bug 3343579 Commented the following IF condition.

		-- IF (p_sf52rec.to_position_org_line1 IS NULL)   THEN
		  p_sf52rec.to_position_org_line1           := p_sf52rec_correct.to_position_org_line1;
                  p_sf52rec.to_position_org_line2           := p_sf52rec_correct.to_position_org_line2;
                  p_sf52rec.to_position_org_line3           := p_sf52rec_correct.to_position_org_line3;
                  p_sf52rec.to_position_org_line4           := p_sf52rec_correct.to_position_org_line4;
                  p_sf52rec.to_position_org_line5           := p_sf52rec_correct.to_position_org_line5;
                  p_sf52rec.to_position_org_line6           := p_sf52rec_correct.to_position_org_line6;
                -- END IF;

       end if;

       p_sf52rec.custom_pay_calc_flag            := p_sf52rec_correct.custom_pay_calc_flag;

	-- Below Added by Sundar for Bug 3191676 and 2681726
	IF ( p_sf52rec_correct.first_noa_code = '790') THEN
	p_sf52rec.to_position_org_line1           := p_sf52rec_correct.to_position_org_line1;
        p_sf52rec.to_position_org_line2           := p_sf52rec_correct.to_position_org_line2;
        p_sf52rec.to_position_org_line3           := p_sf52rec_correct.to_position_org_line3;
        p_sf52rec.to_position_org_line4           := p_sf52rec_correct.to_position_org_line4;
        p_sf52rec.to_position_org_line5           := p_sf52rec_correct.to_position_org_line5;
        p_sf52rec.to_position_org_line6           := p_sf52rec_correct.to_position_org_line6;
	ELSIF ( p_sf52rec_correct.first_noa_code = '352') THEN
 	  p_sf52rec.to_position_org_line1           := p_sf52rec_correct.to_position_org_line1;
	END IF;
	-- End Bug 3191676 and 2681726

	-- work_schedule and part_time_hours are interdependent, part_time_hours should also
	-- be copied when work_schedule changes.
	if ( p_sf52rec_correct.work_schedule <> p_sf52rec.work_schedule
    		AND p_sf52rec_correct.work_schedule is not null ) then
		hr_utility.set_location(' Work Schedule changed :'||l_proc, 30);
		p_sf52rec.work_schedule                   := p_sf52rec_correct.work_schedule     ;
		p_sf52rec.part_time_hours                 := p_sf52rec_correct.part_time_hours   ;
	elsif (p_sf52rec_correct.part_time_hours <> p_sf52rec.part_time_hours) then
		hr_utility.set_location(' Part Time hours changed :'||l_proc, 30);
		p_sf52rec.part_time_hours                 := p_sf52rec_correct.part_time_hours   ;
	end if;

	if (p_corr_pa_request_id = p_sf52rec_correct.pa_request_id) then
		-- these fields should retain value of correction currently being processed. Any values from previous
		-- corrections are ignored.
		hr_utility.set_location(' Last correction :'||l_proc, 35);
		p_sf52rec.routing_group_id 			:= p_sf52rec_correct.routing_group_id			;
		p_sf52rec.proposed_effective_asap_flag    := p_sf52rec_correct.proposed_effective_asap_flag	;
		p_sf52rec.additional_info_person_id       := p_sf52rec_correct.additional_info_person_id    	;
		p_sf52rec.additional_info_tel_number      := p_sf52rec_correct.additional_info_tel_number   	;
		p_sf52rec.authorized_by_person_id         := p_sf52rec_correct.authorized_by_person_id      	;
		p_sf52rec.authorized_by_title             := p_sf52rec_correct.authorized_by_title          	;
		p_sf52rec.concurrence_date                := p_sf52rec_correct.concurrence_date             	;
		p_sf52rec.notepad                         := p_sf52rec_correct.notepad                      	;
		p_sf52rec.proposed_effective_date         := p_sf52rec_correct.proposed_effective_date      	;
		p_sf52rec.requested_by_person_id          := p_sf52rec_correct.requested_by_person_id          	;
		p_sf52rec.requested_by_title              := p_sf52rec_correct.requested_by_title              	;
		p_sf52rec.requested_date                  := p_sf52rec_correct.requested_date                  	;
		p_sf52rec.requesting_office_remarks_desc  := p_sf52rec_correct.requesting_office_remarks_desc  	;
		p_sf52rec.requesting_office_remarks_flag  := p_sf52rec_correct.requesting_office_remarks_flag  	;
		p_sf52rec.request_number                  := p_sf52rec_correct.request_number                  	;

		p_sf52rec.employee_first_name			:= p_sf52rec_correct.employee_first_name			;
		p_sf52rec.employee_last_name			:= p_sf52rec_correct.employee_last_name			;
		p_sf52rec.employee_middle_names		:= p_sf52rec_correct.employee_middle_names		;
		p_sf52rec.employee_national_identifier	:= p_sf52rec_correct.employee_national_identifier	;
		p_sf52rec.employee_date_of_birth		:= p_sf52rec_correct.employee_date_of_birth		;

	end if;
      -- added by skutteti on 14-oct-98 to take care of the new requirements for
      -- percentages on awards and other pay
      if p_sf52rec_correct.award_amount is not null or
         p_sf52rec_correct.award_percentage is not null then
		 p_sf52rec.award_amount     := p_sf52rec_correct.award_amount;
         p_sf52rec.award_percentage := p_sf52rec_correct.award_percentage;
      else
         ghr_history_conv_rg.copy_field_value(p_sf52rec_correct.award_percentage,p_sf52rec.award_percentage);
		 IF p_sf52rec.award_percentage IS NOT NULL THEN
             -- Begin Bug# 5014663
             ghr_history_fetch.fetch_asgei(
                                p_assignment_id    => p_sf52rec.employee_assignment_id,
                                p_information_type => 'GHR_US_ASG_SF52',
                                p_date_effective   => p_sf52rec.effective_date,
                                p_asg_ei_data      => l_asg_ei_data);

             ghr_pay_calc.award_amount_calc (
                             p_position_id		=> p_sf52rec.from_position_id
                            ,p_pay_plan			=> p_sf52rec.from_pay_plan
                            ,p_award_percentage => p_sf52rec.award_percentage
                            ,p_user_table_id	=> p_sf52rec.from_pay_table_identifier
                            ,p_grade_or_level	=> p_sf52rec.from_grade_or_level
                            ,p_effective_date	=> p_sf52rec.effective_date
                            ,p_basic_pay		=> p_sf52rec.from_basic_pay
                            ,p_adj_basic_pay	=> p_sf52rec.from_adj_basic_pay
                            ,p_duty_station_id	=> p_sf52rec.duty_station_id
                            ,p_prd				=> l_asg_ei_data.aei_information6
                            ,p_pay_basis		=> p_sf52rec.from_pay_basis
                            ,p_person_id		=> p_sf52rec.person_id
                            ,p_award_amount		=> l_temp_award_amount
                            ,p_award_salary		=> l_award_salary
                            );
                ghr_history_conv_rg.copy_field_value(l_temp_award_amount,p_sf52rec.award_amount);
        ELSE
            ghr_history_conv_rg.copy_field_value(p_sf52rec_correct.award_amount,p_sf52rec.award_amount);
        END IF;
		-- End Bug# 5014663

      end if;
      if p_sf52rec_correct.to_supervisory_differential is not null or
         p_sf52rec_correct.to_supervisory_diff_percentage is not null then
         p_sf52rec.to_supervisory_differential    := p_sf52rec_correct.to_supervisory_differential;
         p_sf52rec.to_supervisory_diff_percentage := p_sf52rec_correct.to_supervisory_diff_percentage;
      else
         ghr_history_conv_rg.copy_field_value(p_sf52rec_correct.to_supervisory_differential,
                                              p_sf52rec.to_supervisory_differential);
         ghr_history_conv_rg.copy_field_value(p_sf52rec_correct.to_supervisory_diff_percentage,
                                              p_sf52rec.to_supervisory_diff_percentage);
      end if;
      if p_sf52rec_correct.to_retention_allowance is not null or
         p_sf52rec_correct.to_retention_allow_percentage is not null then
         p_sf52rec.to_retention_allowance        := p_sf52rec_correct.to_retention_allowance;
         p_sf52rec.to_retention_allow_percentage := p_sf52rec_correct.to_retention_allow_percentage;
      else
         ghr_history_conv_rg.copy_field_value(p_sf52rec_correct.to_retention_allowance,
                                              p_sf52rec.to_retention_allowance);
         ghr_history_conv_rg.copy_field_value(p_sf52rec_correct.to_retention_allow_percentage,
                                              p_sf52rec.to_retention_allow_percentage);
      end if;
      if p_sf52rec_correct.to_staffing_differential is not null or
         p_sf52rec_correct.to_staffing_diff_percentage is not null then
         p_sf52rec.to_staffing_differential    := p_sf52rec_correct.to_staffing_differential;
         p_sf52rec.to_staffing_diff_percentage := p_sf52rec_correct.to_staffing_diff_percentage;
      else
         ghr_history_conv_rg.copy_field_value(p_sf52rec_correct.to_staffing_differential,
                                              p_sf52rec.to_staffing_differential);
         ghr_history_conv_rg.copy_field_value(p_sf52rec_correct.to_staffing_diff_percentage,
                                              p_sf52rec.to_staffing_diff_percentage);
      end if;

	hr_utility.set_location(' Leaving:'||l_proc, 40);
  Exception when others then
            --
            -- Reset IN OUT parameters and set OUT parameters
            --
            p_sf52rec := l_sf52rec;
            raise;
End  apply_correction ;

-- --------------------------------------------------------------------------------
-- |--------------------------< apply_noa_corrections>-----------------------------|
-- --------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- 	This procedure finds the original sf52 record and the intermediate incremental
-- 	changes. The intermediate incremental changes are applied in sequence to
-- 	arrive at final corrected record.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_sf52_data			->	the ghr_pa_requests record for the
--						correction we are currently processing.
--	p_sf52_data_result	->	the ghr_pa_requests record that will hold the final
--						corrected data for all corrections in the correction
--						chain upon successful completion of this procedure.
-- Post Success:
-- 	All the corrections in the correction chain will have been applied and the
--	result put in p_sf52_data_result.
--
-- Post Failure:
--   	No failure conditions.
--
-- Developer Implementation Notes:
--	None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

Procedure apply_noa_corrections( 	p_sf52_data		in	ghr_pa_requests%rowtype,
						p_sf52_data_result in out nocopy ghr_pa_requests%rowtype ) is

l_sf52_data_orig		ghr_pa_requests%rowtype;
l_sf52_data_step		ghr_pa_requests%rowtype;
l_sf52_ia_rec                   ghr_pa_requests%rowtype;
l_sf52_dummy		ghr_pa_requests%rowtype;
l_sf52_cursor_step_indx	number;
l_session_var		ghr_history_api.g_session_var_type;
-- Bug#5435374 added l_session_var1.
l_session_var1   ghr_history_api.g_session_var_type;
l_capped_other_pay number := hr_api.g_number;
l_retro_eff_date        ghr_pa_requests.effective_date%type;
l_retro_pa_request_id   ghr_pa_requests.pa_request_id%type;
l_retro_first_noa       ghr_nature_of_actions.code%type;
l_retro_second_noa       ghr_nature_of_actions.code%type;
l_sf52_data_result      ghr_pa_requests%rowtype;
-- Bug#3543213 Created l_dummy variable
l_dummy                 VARCHAR2(30);
-- this cursor selects all rows in the correction chain from ghr_pa_requests
cursor  l_sf52_cursor is
	select 	*
	from 		ghr_pa_requests
	connect by 	prior altered_pa_request_id = pa_request_id
	start with	pa_request_id = p_sf52_data.pa_request_id
	order by 	level desc;

cursor c_orig_details_for_ia is
        select pa_request_id,pa_notification_id,person_id,
               effective_date,from_position_id,
               to_position_id
        from ghr_pa_requests
        where pa_request_id = p_sf52_data.altered_pa_request_id;

	cursor c_get_hist_id (c_pa_request_id in number) is
	select
		min(pa_history_id)
	from ghr_pa_history
	where pa_request_id = c_pa_request_id;

	-- Bug#5435374
	l_pos_ei_grade_data  per_position_extra_info%rowtype;

	cursor c_grade_kff (grd_id number) is
        select gdf.segment1
              ,gdf.segment2
          from per_grades grd,
               per_grade_definitions gdf
         where grd.grade_id = grd_id
           and grd.grade_definition_id = gdf.grade_definition_id;

--bug #6356058 start
l_core_chg_avbl number;
l_prev_request_id number;
l_curr_pa_history_id number;
l_pos_ei_grp1_data	per_position_extra_info%rowtype;
--   8737300 Modified the cursor for improving performance
cursor core_chg_check(p_to_position_id in number,
                      p_effective_date in date)
    is
       select  1
       from    ghr_pa_history hist_1
       where   pa_request_id is null
       and     hist_1.pa_history_id > (select min(pa_history_id)
                                       from ghr_pa_history
	  			       where pa_request_id = l_prev_request_id)
       and     hist_1.pa_history_id < nvl(l_curr_pa_history_id,999999999)
       and     information1 in   (select  to_char(position_extra_info_id)
                                  from    per_position_extra_info
                                  where   position_id          =  p_to_position_id
                                  and     information_type     in  ('GHR_US_POS_GRP1'))
       and     information5   =  'GHR_US_POS_GRP1'
       and     effective_date =  p_effective_date
       and     table_name     =  'PER_POSITION_EXTRA_INFO';
--bug #6356058 start



	l_shadow_data	ghr_pa_request_shadow%rowtype;
	l_proc	varchar2(30):='apply_noa_corrections';
begin
	hr_utility.set_location('Entering:'|| l_proc, 5);
   l_sf52_data_result := p_sf52_data_result;
	ghr_history_api.get_g_session_var(l_session_var);
	-- loop through all corrections in the correction chain, incrementally applying them by
	-- calling apply_corrections procedure.
	open l_sf52_cursor ;
	l_sf52_cursor_step_indx := 0;
	loop
		-- initialize l_sf52_data_step to nulls;
		l_sf52_data_step := l_sf52_dummy;
		-- l_sf52_data_step holds intermediate incremental values for final corrected record that is
		-- being built.
		fetch l_sf52_cursor into l_sf52_data_step;
		exit when l_sf52_cursor%notfound;
		l_sf52_cursor_step_indx := l_sf52_cursor_step_indx +1;
		if ( 	l_sf52_cursor_step_indx = 1) then
		--Bug # 6356058 start
		         l_prev_request_id := l_sf52_data_step.pa_request_id;
		--Bug # 6356058 end
			hr_utility.set_location('Fetch l_sf52_data_step original :'|| l_proc, 10);
			l_sf52_data_orig 	  := l_sf52_data_step;
			p_sf52_data_result  := l_sf52_data_step;
			hr_utility.set_location('assignment_id of original =' || l_sf52_data_step.employee_assignment_id, 14);
			hr_utility.set_location('from grd or leveloriginal =' || l_sf52_data_step.from_grade_or_level, 14);

			hr_utility.set_location(l_proc || 'pa_request_id of original= ' || l_sf52_data_step.pa_request_id,26);
-- .47
			-- refresh root sf52 and its correction
			-- get pa_history_id for the root pa_request_id
			open c_get_hist_id( l_sf52_data_step.pa_request_id);
			fetch c_get_hist_id into l_session_var.pa_history_id;
			if c_get_hist_id%notfound then
				-- raise error;
				close c_get_hist_id;
			else
				close c_get_hist_id;
			end if;
			-- We are setting pa_history_id in session var to be able to fetch
			-- Pre-record values of the root SF52 for refresh purpose.
			-- It'll be reset after refresh has been done

			ghr_history_api.set_g_session_var(l_session_var);
			ghr_process_sf52.refresh_req_shadow(p_sf52_data		=>	p_sf52_data_result,
									p_shadow_data	=>	l_shadow_data);
			ghr_process_sf52.redo_pay_calc(	p_sf52_rec		=>	p_sf52_data_result,
                                                        p_capped_other_pay      =>   l_capped_other_pay);

			-- reset pa_history_id in session variable.
			l_session_var.pa_history_id := null;
			ghr_history_api.set_g_session_var(l_session_var);
-- .47
 		        -- Bug#3543213 For PRD U,V and NOA 894(Pay Adjustment) get the PRD Value from assignment
			IF p_sf52_data_result.first_noa_code = '894' AND
			   p_sf52_data_result.pay_rate_determinant IN ('U','V') THEN
			   ghr_pa_requests_pkg.get_SF52_asg_ddf_details
	                     (p_assignment_id         => p_sf52_data_result.employee_assignment_id
	                     ,p_date_effective        => p_sf52_data_result.effective_date
	                     ,p_tenure                => l_dummy
	                     ,p_annuitant_indicator   => l_dummy
	                     ,p_pay_rate_determinant  => p_sf52_data_result.pay_rate_determinant
                           ,p_work_schedule         => l_dummy
                           ,p_part_time_hours       => l_dummy);
			END IF;
		        -- End of Bug#3543213

			-- check if original action in correction chain was a dual action. If so, determine which of
			--   the two actions this correction is for and call ghr_process_sf52.assign_new_rg to null out columns not having
			--   to do with the noa we are correcting.
			if (p_sf52_data_result.second_noa_id is not null) then
				hr_utility.set_location('original sf52 is dual action :'|| l_proc, 11);
				if (p_sf52_data.second_noa_id = p_sf52_data_result.second_noa_id) then
					hr_utility.set_location('Correcting second action in dual action:'|| l_proc, 12);
					ghr_process_sf52.assign_new_rg(p_action_num			=>	2,
										 p_pa_req				=>	p_sf52_data_result);
				else
					hr_utility.set_location('Correcting first action in dual action:'|| l_proc, 13);
					ghr_process_sf52.assign_new_rg(p_action_num			=>	1,
								 		 p_pa_req				=>	p_sf52_data_result);
		 			-- if first action is 893, then we need to derive to_columns as both actions of
					-- the dual action potentially could have changed the to fields (in particular,
					-- to_step_or_rate) so we need to determine what the to_fields should be or the first action.
					if (p_sf52_data_result.first_noa_code = '893') then--Bug# 8926400
						ghr_process_sf52.derive_to_columns(p_sf52_data	=>	p_sf52_data_result);
					end if;
				end if;
			end if;
			-- Nullfy columns which must not be passed
			p_sf52_data_result.pa_notification_id		:= NULL;
			p_sf52_data_result.agency_code			:= NULL;
			p_sf52_data_result.approval_date			:= NULL;
			p_sf52_data_result.approving_official_work_title:= NULL;
			p_sf52_data_result.employee_dept_or_agency 	:= NULL;
			p_sf52_data_result.from_agency_code			:= NULL;
			p_sf52_data_result.from_agency_desc			:= NULL;
			p_sf52_data_result.from_office_symbol		:= NULL;
			p_sf52_data_result.personnel_office_id		:= NULL;
			p_sf52_data_result.to_office_symbol			:= NULL;
		else
		        l_retro_pa_request_id := NULL;
			hr_utility.set_location('Fetch l_sf52_data_step loop :'|| l_proc, 15);
			-- all corrections will have the original sf52 information in the 2nd noa columns, so
			-- copy that information to 1st noa columns.
			hr_utility.set_location('from grd or levelbefcp2to1 =' || l_sf52_data_step.from_grade_or_level, 14);
			ghr_process_sf52.copy_2ndNoa_to_1stNoa(l_sf52_data_step);
			-- null the second noa columns since we don't want anything to be done with these now.
			hr_utility.set_location('from grd or levelaftcp2to1 =' || l_sf52_data_step.from_grade_or_level, 14);
			ghr_process_sf52.null_2ndNoa_cols(l_sf52_data_step);
			hr_utility.set_location('from grd or levelaftnull2noa =' || l_sf52_data_step.from_grade_or_level, 14);
			hr_utility.set_location(l_proc || 'pa_request_id before correction= ' || l_sf52_data_step.pa_request_id,16);
			hr_utility.set_location(l_proc || 'assignment id before correction= ' || l_sf52_data_step.employee_assignment_id,17);
			hr_utility.set_location('from grd or levelbef appcorr =' || l_sf52_data_step.from_grade_or_level, 14);
                        ghr_process_sf52.print_sf52('l_sf52_step bef apply_correction',
                                                     l_sf52_data_step );
                        ghr_process_sf52.print_sf52('result bef copy_ia_rec_on_result',
                                                     p_sf52_data_result );
                       -- Start Intervening Actions Processing
                       -- Processing added to assign the From side details to
                       -- To side if it is a Intervening action and
                       -- Original action from position_id = to position id
                       -- Fetch the original action details
                       FOR c_orig_det_rec in c_orig_details_for_ia
                       LOOP
                            hr_utility.set_location('Inside the orig_details for loop' ,15);
                            hr_utility.set_location('orig pa_request_id'||c_orig_det_rec.pa_request_id ,15);
                            hr_utility.set_location('orig pa_notification_id'||c_orig_det_rec.pa_notification_id ,15);
                            hr_utility.set_location('orig person_id'||c_orig_det_rec.person_id ,15);
                            hr_utility.set_location('orig from_position_id'||c_orig_det_rec.from_position_id ,15);
                            hr_utility.set_location('orig to_position_id'||c_orig_det_rec.to_position_id ,15);
                            hr_utility.set_location('orig effective_date'||c_orig_det_rec.effective_date ,15);
			    --BUG #7216635 added the parameter p_noa_id_correct
                           GHR_APPROVED_PA_REQUESTS.determine_ia(
                                 p_pa_request_id => c_orig_det_rec.pa_request_id,
                                 p_pa_notification_id => c_orig_det_rec.pa_notification_id,
                                 p_person_id      => c_orig_det_rec.person_id,
                                 p_effective_date => c_orig_det_rec.effective_date,
				 p_noa_id_correct => l_session_var.noa_id_correct,
                                 p_retro_pa_request_id => l_retro_pa_request_id,
                                 p_retro_eff_date => l_retro_eff_date,
                                 p_retro_first_noa => l_retro_first_noa,
                                 p_retro_second_noa => l_retro_second_noa);
                            hr_utility.set_location('retro effective_date is '||l_retro_eff_date ,16);
                            -- Bug#2521744 Splitting the single if condition into 2 separate if conditions.
                            IF l_retro_eff_date is NOT NULL  THEN
                               IF c_orig_det_rec.from_position_id
                                    = c_orig_det_rec.to_position_id THEN
                                       -- copy the from details
                                    hr_utility.set_location('Its a Intervening Action ' ,16);
                                    hr_utility.set_location('pa_request_id passed to get_sf52_to_det '||p_sf52_data.pa_request_id ,17);

                                    get_sf52_to_details_for_ia
                                       (p_pa_request_id => p_sf52_data.pa_request_id,
                                        p_retro_eff_date   => l_retro_eff_date,
                                        p_sf52_ia_rec  => p_sf52_data_result);
                                    ghr_process_sf52.print_sf52('result aft get_sf52_to_details_for_ia',
                                                     p_sf52_data_result );
                                    get_sf52_to_othpays_for_ia(p_sf52_ia_rec  => p_sf52_data_result);
                                    ghr_process_sf52.print_sf52('reslt aft get_sf52_to_other_pay_det_for_ia',
                                                     p_sf52_data_result );
                              ELSE
                                -- Verify whether the original action is one of the salary change actions
                                -- If yes, check whether the other pay related elements are present or not
                                -- as on the effective date. If they are not present, set that other pay comp
                                -- to_value as null.
                                get_sf52_to_othpays_for_ia(p_sf52_ia_rec  => p_sf52_data_result);
                                ghr_process_sf52.print_sf52('Aft get_sf52_to_other_pay_det_for_ia in else',
                                                 p_sf52_data_result );
                              END IF;


                 	       END IF;
--bug #6356058 start
                            IF p_sf52_data_result.from_position_id = p_sf52_data_result.to_position_id THEN
                              IF l_retro_pa_request_id IS NOT NULL THEN
			         l_prev_request_id := l_retro_pa_request_id;
			      end if;
                                open c_get_hist_id(l_sf52_data_step.pa_request_id);
			        fetch c_get_hist_id into l_curr_pa_history_id;
				close c_get_hist_id;
                                open core_chg_check( p_sf52_data_result.to_position_id,
				                     c_orig_det_rec.effective_date);
				fetch core_chg_check into l_core_chg_avbl;
				if core_chg_check%found then
				  ghr_history_api.get_g_session_var(l_session_var);
                                  ghr_history_api.reinit_g_session_var;
                                  l_session_var1.date_Effective            := l_session_var.date_Effective;
                                  l_session_var1.person_id                 := l_session_var.person_id;
                                  l_session_var1.assignment_id             := l_session_var.assignment_id;
                                  l_session_var1.fire_trigger    := 'N';
                                  l_session_var1.program_name := 'sf50';
                                  ghr_history_api.set_g_session_var(l_session_var1);
				  ghr_history_fetch.fetch_positionei(
                                       p_position_id      => p_sf52_data_result.to_position_id,
                                       p_information_type => 'GHR_US_POS_GRP1',
                                       p_date_effective   => p_sf52_data_result.effective_date,
                                       p_pos_ei_data      => l_pos_ei_grp1_data);
				    p_sf52_data_result.supervisory_status     := l_pos_ei_grp1_data.poei_information16;
                                    p_sf52_data_result.part_time_hours        := l_pos_ei_grp1_data.poei_information23;
                                  ghr_history_api.reinit_g_session_var;
                                  ghr_history_api.set_g_session_var(l_session_var);
				end if;
				close core_chg_check;
                              END IF;
--bug #6356058 end
                       END LOOP;
		       --bug #6356058
		       l_prev_request_id := l_sf52_data_step.pa_request_id;
           			   hr_utility.set_location('Out side the orig_details for loop' ,17);
                       -- End Intervening Actions Processing

                        apply_correction( p_sf52rec_correct		=>	l_sf52_data_step,
                                    p_corr_pa_request_id	=>	p_sf52_data.pa_request_id,
                                    p_sf52rec			=>	p_sf52_data_result );

                        -- Recalculating Retention Allowance
                        -- Recalculate Retention allowance if it is a OTHER_PAY action
                        -- and Correction of Intervening Action
                         if p_sf52_data_result.noa_family_code = 'OTHER_PAY' and
                           l_retro_eff_date is NOT NULL and
                           p_sf52_data_result.to_retention_allow_percentage is not null then
   --Modified for FWS
                           IF p_sf52_data_result.to_pay_basis ='PH' THEN
       			      p_sf52_data_result.to_retention_allowance :=
                                 TRUNC(p_sf52_data_result.to_basic_pay * p_sf52_data_result.to_retention_allow_percentage/100,2);
			   ELSE
			        p_sf52_data_result.to_retention_allowance :=
                                 TRUNC(p_sf52_data_result.to_basic_pay * p_sf52_data_result.to_retention_allow_percentage/100,0);
                           END IF;

                             p_sf52_data_result.to_other_pay_amount :=
                             nvl(p_sf52_data_result.to_au_overtime,0) +
                             nvl(p_sf52_data_result.to_availability_pay,0) +
                             nvl(p_sf52_data_result.to_retention_allowance,0) +
                             nvl(p_sf52_data_result.to_supervisory_differential,0) +
                             nvl(p_sf52_data_result.to_staffing_differential,0);
                             p_sf52_data_result.to_total_salary :=
                             p_sf52_data_result.to_adj_basic_pay + p_sf52_data_result.to_other_pay_amount;
                             if p_sf52_data_result.to_other_pay_amount = 0 then
                               p_sf52_data_result.to_other_pay_amount := null;
                             end if;
                           end if;
			hr_utility.set_location( l_proc || 'assignment_id after correction=' || p_sf52_data_result.employee_assignment_id ,18);
			hr_utility.set_location('Applied corrections :'|| l_proc, 20);
		end if;
	end loop;
	close l_sf52_cursor;

	 -- Bug#5435374 If the from and to position ids are same, verify the pay plan, grade details.
	 IF p_sf52_data_result.from_position_id = p_sf52_data_result.to_position_id THEN

        -- Reinitializing the session variables to get the valid grade as on the
        -- effective date.
        ghr_history_api.get_g_session_var(l_session_var);
        ghr_history_api.reinit_g_session_var;
        l_session_var1.date_Effective            := l_session_var.date_Effective;
        l_session_var1.person_id                 := l_session_var.person_id;
        l_session_var1.assignment_id             := l_session_var.assignment_id;
        l_session_var1.fire_trigger    := 'N';
        l_session_var1.program_name := 'sf50';
        ghr_history_api.set_g_session_var(l_session_var1);

		 -- Retrieve the Grade info from the POI history table
		ghr_history_fetch.fetch_positionei(
		p_position_id      => p_sf52_data_result.to_position_id,
		p_information_type => 'GHR_US_POS_VALID_GRADE',
		p_date_effective   => p_sf52_data_result.effective_date,
		p_pos_ei_data      => l_pos_ei_grade_data);

        -- Reset the session variables after getting the date effective valid grade
        -- to continue with the correction process.
        ghr_history_api.reinit_g_session_var;
        ghr_history_api.set_g_session_var(l_session_var);

		IF l_pos_ei_grade_data.position_extra_info_id IS NOT NULL THEN
			hr_utility.set_location('GL: to grd id:'||p_sf52_data_result.to_grade_id,30);
			hr_utility.set_location('GL: pos ei grd:'||l_pos_ei_grade_data.poei_information3,40);
			IF l_pos_ei_grade_data.poei_information3 <> p_sf52_data_result.to_grade_id THEN
				--Bug# 5638869
                --p_sf52_data_result.to_grade_id := l_pos_ei_grade_data.poei_information3;
                l_pos_ei_grade_data.poei_information3 := p_sf52_data_result.to_grade_id;
                --Bug# 5638869
				FOR c_grade_kff_rec IN c_grade_kff (p_sf52_data_result.to_grade_id)
				LOOP
					hr_utility.set_location('GL: Inside setting pay plan grade',60);
					p_sf52_data_result.to_pay_plan := c_grade_kff_rec.segment1  ;
					p_sf52_data_result.to_grade_or_level := c_grade_kff_rec.segment2;
					EXIT;
    			END LOOP;
			END IF;
    	END IF;
	END IF;
    -- Bug#5435374 End of the fix.

	hr_utility.set_location(' Leaving:'||l_proc, 25);
 Exception when others then
           --
           -- Reset IN OUT parameters and set OUT parameters
           --
           p_sf52_data_result := l_sf52_data_result;
           raise;
end apply_noa_corrections;

-- ---------------------------------------------------------------------------
-- |--------------------------< what_to_do>-----------------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--	This procedure sets p_can_delete, p_last_row, and p_cannot_cancel flags
--	according to the data it was passed.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_datetrack_table		->	boolean that indicates if this is a datetrack table or not.
--	p_pre_record_exists	->	boolean that indicates if a pre-value was found for this history record.
--	p_interv_on_table		->	boolean that indicates if there are intervening changes to this row.
--	p_interv_on_eff_date	->	boolean that indicates if there are intervening changes to this row on the
--						same date.
--	p_rec_created_flag	->	boolean that indicates if this record was created by this action.
--	p_can_delete		->	output flag that indicates if this row can be deleted.
--	p_last_row			->	output flag that indicates if this row is the last row in history (there are
--						no following records).
--	p_cannot_cancel		->	output flag that indicates if this row can be cancelled or not.
--
-- Post Success:
-- 	p_can_delete, p_last_row, and p_rec_created_flag will be set appropriately.
--
-- Post Failure:
--   	No failure conditions.
--
-- Developer Implementation Notes:
--	None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

PROCEDURE what_to_do(	p_datetrack_table		in		boolean,
				p_pre_record_exists 	in 		boolean,
				p_interv_on_table		in		boolean,
				p_interv_on_eff_date	in		boolean,
				p_rec_created_flag	in		boolean,
				p_can_delete	 out nocopy 	boolean,
				p_last_row		 out nocopy 	boolean,
				p_cannot_cancel	 out nocopy 	boolean) IS
   	l_proc		varchar2(72) := 'what_to_do?';
 BEGIN
     	hr_utility.set_location('Entering  '|| l_proc,5);
	-- initialize output parms.
  	p_can_delete 	:= FALSE;
  	p_last_row	 	:= FALSE;
  	p_cannot_cancel	:= FALSE;
  	if (p_datetrack_table = TRUE) then
     		hr_utility.set_location('Datetrack table  '|| l_proc,10);
  		-- this is a datetrack table
  		if (p_pre_record_exists = FALSE) then
        		hr_utility.set_location('no pre'|| l_proc,15);
   			if (p_interv_on_eff_date = FALSE) then
   	      		hr_utility.set_location('no following records on same date'|| l_proc,20);
   				if (p_interv_on_table = TRUE) then
					-- datetrack tables with no pre cannot be cancelled if they have following records in history.
		      		hr_utility.set_location(' Following records on later date'|| l_proc,45);
   					p_cannot_cancel 	:= TRUE;
				else
		      		hr_utility.set_location('NO Following records on later date'|| l_proc,70);
					-- there is no pre and no following records, so we CAN cancel and we CAN delete. And this is
					-- the last row in history.
   					p_can_delete 	:= TRUE;
    					p_last_row 		:= TRUE;
    				end if;
   			else
	      		hr_utility.set_location('Following records on same date'|| l_proc,75);
				-- datetrack tables with no pre cannot be cancelled if they have following records in history.
				p_cannot_cancel	:= TRUE;
			end if;
		else
			-- there is a pre_record
      		hr_utility.set_location('has pre'|| l_proc,25);
			if (p_interv_on_eff_date = FALSE) then
	      		hr_utility.set_location(' no following recs on same date'|| l_proc,30);
				if (p_rec_created_flag = TRUE) then
		      		hr_utility.set_location('record created = TRUE'|| l_proc,35);
					p_can_delete := TRUE;
				end if;
				if (p_interv_on_table = FALSE) then
		      		hr_utility.set_location(' no following recs at all'|| l_proc,40);
					p_last_row := TRUE;
				end if;
			end if;
		end if;
	else
		-- this is a non datetrack table
     		hr_utility.set_location(' non datetrack table'|| l_proc,50);
		-- assume there is always a pre-record for datetrack tables. It is just all nulls.
		if (p_interv_on_table = FALSE) then
	      	hr_utility.set_location('no following recs '|| l_proc,60);
			if (p_rec_created_flag = TRUE) then
		      	hr_utility.set_location('record created = Y '|| l_proc,65);
				p_can_delete := TRUE;
				p_last_row   := TRUE;
			end if;
		end if;
	end if;
 exception when others then
           --
           -- Reset IN OUT parameters and set OUT parameters
           --
           p_can_delete     := null;
           p_last_row       := null;
           p_cannot_cancel  := null;
           raise;
END what_to_do;

-- ---------------------------------------------------------------------------
-- |--------------------------< delete_element_entry>--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--	This procedure deletes an element entry.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_hist_rec			->	element entry to be deleted (ghr_pa_history%rowtype).
--	p_cannot_cancel		->	boolean indicates if there is some problem with deleting this element (the action
--						cannot be cancelled).
--
-- Post Success:
-- 	element entry will have been deleted. p_cannot_cancel will be false.
--
-- Post Failure:
--   	p_cannot_cancel will be true.
--
-- Developer Implementation Notes:
--	None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

   Procedure delete_element_entry( p_hist_rec 		in 	ghr_pa_history%rowtype,
					     p_del_mode		in	varchar2 default hr_api.g_delete_next_change,
   					     p_cannot_cancel out nocopy Boolean) is
   	l_del_warning	boolean;
	-- this cursor selects the element_entry_id and object_version_number from
	-- pay_element_entries_f for the element_entry_id and date_effective passed.
   	cursor c_elmt ( cp_element_entry_id number,
   			    cp_date_Effective	date) is
   	select element_entry_id,
   		 object_version_number
   	from pay_element_entries_f
  	where element_entry_id = cp_element_entry_id and
 		cp_date_effective between effective_start_date and effective_end_date;
  	l_c_elmt	c_elmt%rowtype;
  	l_eff_start_date	date;
  	l_eff_end_date	date;
  	l_proc	varchar2(30):='delete_element_entry';
  Begin
  	hr_utility.set_location( 'Entering : ' || l_proc, 10);
  	hr_utility.set_location( ' info 1 : ' || p_hist_rec.information1 || l_proc, 11);
  	hr_utility.set_location( ' info 2 : ' || p_hist_rec.information2 || l_proc, 12);

	p_cannot_cancel := FALSE;
  	open c_elmt (p_hist_rec.information1,
  			 to_date(p_hist_rec.information2, ghr_history_conv_rg.g_hist_date_format));
  	fetch c_elmt into l_c_elmt;
  	if c_elmt%notfound then
  		hr_utility.set_location( l_proc, 20);
  		close c_elmt;
  		p_cannot_cancel	:=	TRUE;
  	else
  		close c_elmt;
  		hr_utility.set_location( l_proc, 30);

		hr_utility.set_location( 'effective date ' || p_hist_rec.information2, 31);
		hr_utility.set_location( 'element entry id ' || l_c_elmt.element_entry_id, 32);
		hr_utility.set_location( 'ovn ' || l_c_elmt.object_version_number, 33);

  		PY_element_entry_api.delete_element_entry(
 			p_datetrack_delete_mode		=>	nvl(p_del_mode, hr_api.g_delete_next_change),
  			p_effective_date		=>	to_date(p_hist_rec.information2, ghr_history_conv_rg.g_hist_date_format),
  			p_element_entry_id		=>	l_c_elmt.element_entry_id,
  			p_object_version_number		=>	l_c_elmt.object_version_number,
  			p_effective_start_date		=>	l_eff_start_date,
  			p_effective_end_date		=>	l_eff_end_date,
  			p_delete_warning			=>	l_del_warning);
		if l_del_warning then
			hr_utility.set_location( 'Warning ' || l_proc, 39);
		end if;

  --added
  	end if;
 	hr_utility.set_location( 'Leaving : ' || l_proc, 40);
   exception when others then
             --
             -- Reset IN OUT parameters and set OUT parameters
             --
             p_cannot_cancel := null;
             raise;
 End delete_element_entry;

-- ---------------------------------------------------------------------------
-- |--------------------------< update_eleentval>--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--	This procedure updates an element entry value.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_hist_pre			->	value to update element entry value to  (ghr_pa_history%rowtype).
--
-- Post Success:
-- 	element entry value will have been updated.
--
-- Post Failure:
--   	User message will have been displayed explaining why the element_entry_value couldn't be
--	updated.
--
-- Developer Implementation Notes:
--	Note that this is used in other packages as well. Changes to this procedure will have effects on the other
--	packages using this procedure.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

PROCEDURE update_eleentval(	p_hist_pre	in	ghr_pa_history%rowtype) IS
	-- this cursor selects the input value name given the input_value_id and effective date.

        CURSOR 	c_input_value (cp_input_value_id     in number
          		       ,cp_eff_date          in date
				,p_bg_id             in NUMBER)
	IS
        		SELECT 	IPV.NAME
          		FROM		PAY_INPUT_VALUES_F IPV
         		WHERE  	TRUNC(cp_eff_date)
			        BETWEEN IPV.EFFECTIVE_START_DATE AND IPV.EFFECTIVE_END_DATE
          		AND 	IPV.INPUT_VALUE_ID = cp_input_value_id;
--			AND (IPV.BUSINESS_GROUP_ID IS NULL OR IPV.BUSINESS_GROUP_ID=P_BG_ID);

	-- this cursor selects the element name given the element_entry_id and effective date.
	CURSOR	c_element_name(	cp_element_entry_id 	in	number
				,cp_eff_date		in	date
				,p_bg_id                IN      number)
	IS
			SELECT 	ELT.ELEMENT_NAME
			FROM		PAY_ELEMENT_TYPES_F	ELT,
					PAY_ELEMENT_LINKS_F	ELL,
					PAY_ELEMENT_ENTRIES_F	ELE
			WHERE	TRUNC(cp_eff_date)	BETWEEN	ELT.EFFECTIVE_START_DATE
									AND	ELT.EFFECTIVE_END_DATE
			AND	TRUNC(cp_eff_date)	BETWEEN	ELL.EFFECTIVE_START_DATE
									AND	ELL.EFFECTIVE_END_DATE
			AND	TRUNC(cp_eff_date)	BETWEEN	ELE.EFFECTIVE_START_DATE
									AND	ELE.EFFECTIVE_END_DATE
			AND	ELE.ELEMENT_ENTRY_ID	= 	cp_element_entry_id
			AND	ELL.ELEMENT_LINK_ID	=	ELE.ELEMENT_LINK_ID
			AND	ELT.ELEMENT_TYPE_ID	= 	ELL.ELEMENT_TYPE_ID
                        AND    (ELT.BUSINESS_GROUP_ID is null OR ELT.BUSINESS_GROUP_ID = p_bg_id);

	-- this cursor gets the assignment id given the primary key, efective_start_date, effective_end_date and
	-- table name. (ghr_pa_history views are structured such that ghr_pa_history.information1 is always the primary
	-- key, information2 is always the effective_start_date, and information3 is always the effective_end_date).
	cursor	c_asgmt_id(	cp_information1	in	ghr_pa_history.information1%type,
					cp_information2	in	ghr_pa_history.information2%type,
					cp_information3	in	ghr_pa_history.information3%type,
					cp_table_name	in	ghr_pa_history.table_name%type) IS
			SELECT	ASSIGNMENT_ID
			FROM		GHR_PA_HISTORY
			WHERE		INFORMATION1	=	cp_information1
				AND	INFORMATION2	= 	cp_information2
				AND 	INFORMATION3	=	cp_information3
				AND	TABLE_NAME		= 	cp_table_name
                        ORDER BY PROCESS_DATE DESC;  -- Line Added by ENUNEZ (04/11/2000) bug# 1235958

	l_ipv_name		pay_input_values_f.name%type;
	l_element_name	pay_element_types_f.element_name%type;
	l_proc_warn		boolean;
	l_proc		varchar2(30):='update_eleentval';
	l_eff_date		date;
	l_asg_id		number;
        l_value1 pay_element_entry_values_f.screen_entry_value%type;

  cursor c_ipv (ele_name       in varchar2
               ,input_name     in varchar2
               ,eff_date       in date
		,p_bg_id         in number) is
             select ipv.uom
          from pay_element_types_f elt,
               pay_input_values_f ipv
         where trunc(eff_date) between elt.effective_start_date
                                   and elt.effective_end_date
           and trunc(eff_date) between ipv.effective_start_date
                                   and ipv.effective_end_date
           and elt.element_type_id = ipv.element_type_id
           and upper(elt.element_name) = upper(ele_name)
           and upper(ipv.name) = upper(input_name);
--           and (elt.business_group_id is NULL or elt.business_group_id =p_bg_id);
--
-- Payroll Integration Changes
--
CURSOR Cur_bg(p_person_id NUMBER,
              p_eff_date DATE)
IS
SELECT business_group_id bg
FROM   per_assignments_f
WHERE  person_id = p_person_id
AND    p_eff_Date between effective_start_Date
       AND effective_end_Date;

ll_bg_id           NUMBER;
l_new_element_name VARCHAR2(80);
--*****************************************************************************
--- to fix bug 3102049
CURSOR cur_is_old_ele_name(p_ele_name IN VARCHAR2)
IS
SELECT pcv_information1 ele_name
FROM   pqp_configuration_Values
WHERE  pcv_information_category='PQP_FEDHR_ELEMENT'
AND    business_group_id is NULL and legislation_code='US'
AND    upper(pcv_information1)=upper(p_ele_name);

l_ele_name        VARCHAR2(80);
--*****************************************************************************
--
BEGIN
--
  	hr_utility.set_location( 'Entering : ' || l_proc, 10);
  	hr_utility.set_location( 'information4 : ' || p_hist_pre.information4 || l_proc, 11);
  	hr_utility.set_location( 'Effective Date : ' || p_hist_pre.information2 || l_proc, 12);
 	hr_utility.set_location( 'Business Group id : ' || ll_bg_id, 100000002);
--
--Payroll Integration Changes
--
FOR bg_rec IN Cur_bg(p_hist_pre.person_id,
                     p_hist_pre.effective_date)
LOOP
ll_bg_id := bg_rec.bg;
END LOOP;

IF ll_bg_id is null THEN
ll_bg_id := fnd_profile.value('PER_BUSINESS_GROUP_ID');
END IF;


  	hr_utility.set_location( 'information4 : ' || p_hist_pre.information4 || l_proc, 11);
  	hr_utility.set_location( 'Effective Date : ' || p_hist_pre.information2 || l_proc, 12);
 	hr_utility.set_location( 'Business Group id : ' || ll_bg_id, 100000002);

	l_eff_date := to_date(p_hist_pre.information2, ghr_history_api.g_hist_date_format);
	hr_utility.set_location('Converted eff Date: ' || l_eff_date || l_proc,18);
	-- get input value name.
	open c_input_value(	cp_input_value_id	=>	p_hist_pre.information4,
				cp_eff_date		=> 	l_eff_date,
				p_bg_id  	        =>      ll_bg_id);
	hr_utility.set_location('After open cursor: ' || l_proc,19);
	fetch c_input_value into l_ipv_name;
	hr_utility.set_location('After fetch cursor: ' || l_proc,21);
	if c_input_value%NOTFOUND then
	 	hr_utility.set_location( 'input_value_name notfound : ' || l_proc, 20);
		close c_input_value;
	      hr_utility.set_message(8301,'GHR_38270_INPUT_VALUE_NAME_NF');
	      hr_utility.raise_error;
	end if;
	close c_input_value;
  	hr_utility.set_location( 'Open element name cursor: ' || l_proc, 30);
	-- get element name.
	open c_element_name(	cp_element_entry_id	=>  p_hist_pre.information5,
				cp_eff_date		=>  l_eff_date,
				p_bg_id                 =>  ll_bg_id);
	hr_utility.set_location('Fetch element name cursor: ' || l_proc, 31);
	fetch c_element_name into l_element_name;
	hr_utility.set_location('After Fetch element name cursor: ' || l_proc, 32);
	if c_element_name%NOTFOUND then
	 	hr_utility.set_location( 'element_name notfound : ' || l_proc, 40);
		close c_element_name;
	      hr_utility.set_message(8301,'GHR_38271_ELEMENT_NAME_NOTFND');
	      hr_utility.raise_error;
	end if;
	close c_element_name;
	-- get assignment id.
	open	c_asgmt_id	(cp_information1 =>	p_hist_pre.information1,
				cp_information2	 =>	p_hist_pre.information2,
				cp_information3	 =>	p_hist_pre.information3,
				cp_table_name	 =>	ghr_history_api.g_eleevl_table);
	fetch c_asgmt_id into l_asg_id;
	if c_asgmt_id%NOTFOUND then
	 	hr_utility.set_location( 'assignment_id notfound : ' || l_proc, 41);
		close c_asgmt_id;
	      hr_utility.set_message(8301,'GHR_38362_ASGMT_ID_NOTFND');
	      hr_utility.raise_error;
	end if;

	hr_utility.set_location('Element Assignment ID: ' || p_hist_pre.assignment_id || l_proc, 36);
	hr_utility.set_location('Element name: ' || l_element_name || l_proc, 37);
	hr_utility.set_location('IPV Name: ' || l_ipv_name || l_proc, 38);
       -- UOM error for date input values
        hr_utility.set_location('p_hist_pre.information6: '
                   || p_hist_pre.information6 || l_proc, 38);
        l_value1 :=  p_hist_pre.information6;
        hr_utility.set_location('l_value1: ' || l_value1 || l_proc, 38);
        FOR c_ipv_rec IN c_ipv(l_element_name,l_ipv_name,l_eff_date,ll_bg_id) LOOP
          IF c_ipv_rec.uom = 'D'  THEN
            l_value1 := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(l_value1));
            hr_utility.set_location('l_value1: ' || l_value1 || l_proc, 38);
          END IF;
        END LOOP;
---*****************************************************************************
--- Check if the element name is new element name or hard coded ele name
--- to fix bug 3102049
        FOR old_ele_name IN cur_is_old_ele_name(l_element_name)
        LOOP
           l_ele_name := old_ele_name.ele_name;
        END LOOP;

	IF l_ele_name is not null THEN
          l_new_element_name := l_element_name;
	ELSE
          l_new_element_name := pqp_fedhr_uspay_int_utils.return_old_element_name(
                      l_element_name,
		      ll_bg_id,
		      l_eff_date);
        END IF;
--- to fix bug 3102049
---*****************************************************************************
      ghr_element_api.process_sf52_element
	(p_assignment_id  	=>	l_asg_id
	,p_element_name	      =>	l_new_element_name
	,p_input_value_name1	=>	l_ipv_name
	,p_value1		      => l_value1
	,p_effective_date		=>   l_eff_date
	,p_process_warning	=>	l_proc_warn
      );
	/*To be included after Martin Reid's element api handles the create and update warning
	if l_proc_warn = FALSE then
     	hr_utility.set_message(8301,'GHR_99999_FL_TO_UPD_ELEMENT_FOR_CANC');
     	hr_utility.raise_error;
  	end if;
	*/
 	hr_utility.set_location( 'Leaving : ' || l_proc, 50);
END update_eleentval;

-- ---------------------------------------------------------------------------
-- |--------------------------< delete_eleentval>-----------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--	This procedure deletes an element entry value from history table.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_hist_rec			->	element entry value to delete (ghr_pa_history%rowtype).
--
-- Post Success:
-- 	element entry value will have been deleted rom history.
--
-- Post Failure:
--	no failure conditions.
--
-- Developer Implementation Notes:
--	None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

  Procedure delete_eleentval( p_hist_rec in ghr_pa_history%rowtype) is
	-- this cursor gets the rowid of the history_rec for the ghr_pa_history row passed
	-- to us.
  	cursor c_hist is
  	select rowid row_id
  	from ghr_pa_history
  	where table_name			= ghr_history_api.g_eleevl_table	and
  		pa_request_id		= p_hist_rec.pa_request_id		and
  		nature_of_action_id	= p_hist_rec.nature_of_action_id
  	for update of table_name;
	l_proc		varchar2(30):='delete_eleentval';
  Begin
  	hr_utility.set_location( 'Entering : ' || l_proc, 10);
  	for c_data in c_hist
  	loop
  		delete_hist_row( c_data.row_id);
  	end loop;
  	hr_utility.set_location( 'Leaving : ' || l_proc, 20);
  end delete_eleentval;

-- ---------------------------------------------------------------------------
-- |--------------------------< delete_peop_row>------------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--	This procedure deletes a row from per_people_f table.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_person_id			->	person_id to be deleted.
--	p_dt_mode			->	datetrack delete mode.
--	p_date_effective		->	effective date of delete.
--
-- Post Success:
-- 	per_people_f row will have been deleted.
--
-- Post Failure:
--	message will have been displayed to user explaining why the delete could not be completed.
--
-- Developer Implementation Notes:
--	None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

  PROCEDURE	delete_peop_row(	p_person_id		in	varchar2,
  					p_dt_mode		in	varchar2,
  					p_date_effective	in	date) IS
  	l_proc	varchar2(72) 	:= 	'delete_per_people_f_row';
  	l_ovn		number;
  	l_effective_start_date	date;
  	l_effective_end_date	date;
  	cursor	c_get_ovn	(cp_person_id	in	number,
  					cp_date_effective	in	date) 	is
  	SELECT object_version_number
  	FROM	PER_PEOPLE_F
  	WHERE person_id = cp_person_id
  		AND cp_date_effective between effective_start_date and effective_end_date;
  BEGIN
  	hr_utility.set_location( 'Entering : ' || l_proc, 10);
  	if (p_dt_mode = hr_api.g_delete_next_change) then
  		open c_get_ovn(p_person_id, p_date_effective -1);
  		fetch c_get_ovn into l_ovn;
  		if c_get_ovn%NOTFOUND then
			-- can't delete without object_version_number.
			close c_get_ovn;
		      hr_utility.set_message(8301,'GHR_38213_PEOPLE_OVN_NOTFOUND');
		      hr_utility.raise_error;
  			-- raise error;
  		end if;
  		per_per_del.del(
  			p_person_id			=>	p_person_id,
  			p_effective_start_date	=>	l_effective_start_date,
  			p_effective_end_date	=>	l_effective_end_date,
  			p_object_version_number	=>	l_ovn,
  			p_effective_date		=>	p_date_effective -1,
  			p_datetrack_mode		=>	p_dt_mode);
  	elsif (p_dt_mode = hr_api.g_zap) then
  		open c_get_ovn(p_person_id, p_date_effective );
  		fetch c_get_ovn into l_ovn;
  		if c_get_ovn%NOTFOUND then
  			-- raise error;
			-- can't delete without object_version_number.
			close c_get_ovn;
 		      hr_utility.set_message(8301,'GHR_38213_PEOPLE_OVN_NOTFOUND');
		      hr_utility.raise_error;
  		end if;
  		per_per_del.del(
  			p_person_id			=>	p_person_id,
  			p_effective_start_date	=>	l_effective_start_date,
  			p_effective_end_date	=>	l_effective_end_date,
  			p_object_version_number	=>	l_ovn,
  			p_effective_date		=>	p_date_effective,
  			p_datetrack_mode		=>	p_dt_mode );
  	else
  		-- raise error, unacceptable datetrack mode
	      hr_utility.set_message(8301,'GHR_38216_INVALID_DT_MODE_PPL');
	      hr_utility.raise_error;
  	end if;
  	hr_utility.set_location( 'Leaving : ' || l_proc, 20);
  END delete_peop_row;

--  Added Procedure delete_posn_row. ENUNEZ 11-MAY-2000, it didnt exist before as position used to
--  be a non datetracked table.  Bug# 1252481
  PROCEDURE	delete_posn_row(	p_position_id		in	varchar2,
  					p_dt_mode		in	varchar2,
  					p_date_effective	in	date) IS
  	l_proc	varchar2(72) 	:= 	'delete_hr_all_positions_f_row';
  	l_ovn		number;
  	l_effective_start_date	date;
  	l_effective_end_date	date;
  	cursor	c_get_ovn	(cp_position_id	in	number,
  					cp_date_effective	in	date) 	is
  	SELECT object_version_number
  	FROM	HR_ALL_POSITIONS_F
  	WHERE position_id = cp_position_id
  		AND cp_date_effective between effective_start_date and effective_end_date;

        -- Bug 3786467 Procedure to update position name in hr_all_positions_f_tl

          PROCEDURE ghr_regenerate_position_name(p_position_id IN hr_all_positions_f.position_id%type) IS
			CURSOR c_position(c_position_id  IN hr_all_positions_f.position_id%type) is
            SELECT psf.position_definition_id
            FROM hr_all_positions_f psf
            WHERE position_id = c_position_id
            AND effective_end_date = hr_api.g_eot
            FOR UPDATE;
            --
            l_position_definition_id       number;
            BEGIN
              IF (p_position_id IS NOT NULL) THEN
            --
                OPEN c_position(p_position_id);
                FETCH c_position INTO l_position_definition_id;
            --
                IF (c_position%FOUND) THEN
                  --
                   hr_pft_upd.upd_tl
                  ( p_language_code                => 'US'
                  , p_position_id                  => p_position_id
                  , p_position_definition_id       => l_position_definition_id
                  );
                  --
                END IF;
            --
                CLOSE c_position;
            --
          END IF;
        END ghr_regenerate_position_name;
  BEGIN
  	hr_utility.set_location( 'Entering : ' || l_proc, 10);
  	if (p_dt_mode = hr_api.g_delete_next_change) then
  		open c_get_ovn(p_position_id, p_date_effective -1);
  		fetch c_get_ovn into l_ovn;
  		if c_get_ovn%NOTFOUND then
			-- can't delete without object_version_number.
			close c_get_ovn;
		      hr_utility.set_message(8301,'GHR_38504_POS_OVN_NOTFOUND');
		      hr_utility.raise_error;
  			-- raise error;
  		end if;
  		hr_psf_del.del(
  			p_position_id			=>	p_position_id,
  			p_effective_start_date	=>	l_effective_start_date,
  			p_effective_end_date	=>	l_effective_end_date,
  			p_object_version_number	=>	l_ovn,
  			p_effective_date		=>	p_date_effective -1,
  			p_datetrack_mode		=>	p_dt_mode);
		-- Regenerate Position Bug 3786467.
        hr_utility.set_location('Entered ghr regenerate position',15);
		ghr_regenerate_position_name(p_position_id);
  	elsif (p_dt_mode = hr_api.g_zap) then
  		open c_get_ovn(p_position_id, p_date_effective );
  		fetch c_get_ovn into l_ovn;
  		if c_get_ovn%NOTFOUND then
  			-- raise error;
			-- can't delete without object_version_number.
			close c_get_ovn;
 		      hr_utility.set_message(8301,'GHR_38504_POS_OVN_NOTFOUND');
		      hr_utility.raise_error;
  		end if;
  		hr_psf_del.del(
  			p_position_id			=>	p_position_id,
  			p_effective_start_date	=>	l_effective_start_date,
  			p_effective_end_date	=>	l_effective_end_date,
  			p_object_version_number	=>	l_ovn,
  			p_effective_date		=>	p_date_effective,
  			p_datetrack_mode		=>	p_dt_mode );
		-- Regenerate Position Bug 3786467
        hr_utility.set_location('Entered ghr regenerate position',15);
		ghr_regenerate_position_name(p_position_id);
  	else
  		-- raise error, unacceptable datetrack mode
	      hr_utility.set_message(8301,'GHR_38216_INVALID_DT_MODE_PPL');
	      hr_utility.raise_error;
  	end if;
  	hr_utility.set_location( 'Leaving : ' || l_proc, 20);
  END delete_posn_row;

-- ---------------------------------------------------------------------------
-- |--------------------------< delete_asgn_row>------------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--	This procedure deletes a row from per_people_f table.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_assignment_id		->	assignment_id to be deleted.
--	p_dt_mode			->	datetrack delete mode.
--	p_date_effective		->	effective date of delete.
--
-- Post Success:
-- 	per_assignments_f row will have been deleted.
--
-- Post Failure:
--	message will have been displayed to user explaining why the delete could not be completed.
--
-- Developer Implementation Notes:
--	None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

  PROCEDURE	delete_asgn_row(	p_assignment_id	in	varchar2,
  					p_dt_mode		in	varchar2,
  					p_date_effective	in	date) IS
  	l_proc	varchar2(72) 	:= 	'delete_per_assignments_f_row';
  	l_ovn		number;
  	l_effective_start_date		date;
  	l_effective_end_date		date;
  	l_validation_start_date		date;
  	l_validation_end_date		date;
  	l_business_group_id		number;
  	l_org_now_no_manager_warning  boolean;
	-- this cursor gets the object_version_number given the assignment_id and effective_date.
  	cursor	c_get_ovn	(cp_assignment_id	in	number,
  					cp_date_effective	in	date) 	is
  	SELECT object_version_number
  	FROM	PER_ASSIGNMENTS_F
  	WHERE assignment_id = cp_assignment_id
 		AND cp_date_effective between effective_start_date and effective_end_date;

Cursor Cur_proposal_exists (p_assignment_id IN NUMBER,
                            p_eff_date IN DATE) is
Select ppp.pay_proposal_id       proposal_id
       ,ppp.object_version_number ovn
from   per_pay_proposals ppp
where  ppp.assignment_id = p_assignment_id
and    change_date  <= p_eff_date;

l_pay_proposal_id          NUMBER;
-- sal admin fields
l_sal_admin_ovn number;

l_payroll_warn boolean;
l_approve_warn  boolean;
l_sal_warn  boolean;
l_date_warn  boolean;
--
l_asg_del_ovn                  NUMBER;
--l_org_now_no_manager_warning   BOOLEAN;
l_payroll_value                NUMBER;
l_ele_entry_id                 NUMBER;
ll_payroll_value               NUMBER;
ll_value                       NUMBER;
l_pay_intg                     BOOLEAN:=FALSE;

  BEGIN
  	hr_utility.set_location( 'Entering : ' || l_proc, 10);
  	if (p_dt_mode = hr_api.g_delete_next_change) then
  		open c_get_ovn(p_assignment_id, p_date_effective -1);
  		fetch c_get_ovn into l_ovn;
  		if c_get_ovn%NOTFOUND then
			-- can't delete without object_version_number.
  			-- raise error;
			close c_get_ovn;
  		      hr_utility.set_message(8301,'GHR_38215_ASSG_OVN_NOTFOUND');
		      hr_utility.raise_error;
  		end if;
  		per_asg_del.del(
  			p_assignment_id			=>	p_assignment_id,
  			p_effective_start_date		=>	l_effective_start_date,
  			p_effective_end_date		=>	l_effective_end_date,
  			p_validation_start_date		=>	l_validation_start_date,
  			p_validation_end_date		=>	l_validation_end_date,
  			p_business_group_id		=>	l_business_group_id,
  			p_object_version_number		=>	l_ovn,
  			p_effective_date			=>	p_date_effective -1,
  			p_datetrack_mode			=>	p_dt_mode,
  			p_org_now_no_manager_warning	=>  	l_org_now_no_manager_warning  );
  	elsif (p_dt_mode = hr_api.g_zap) then
  		open c_get_ovn(p_assignment_id, p_date_effective );
  		fetch c_get_ovn into l_ovn;
  		if c_get_ovn%NOTFOUND then
			-- can't delete without object_version_number.
  			-- raise error;
			close c_get_ovn;
  		      hr_utility.set_message(8301,'GHR_38215_ASSG_OVN_NOTFOUND');
		      hr_utility.raise_error;
  		end if;
       -- Payroll Integration Changes
       ----**********************************************************************
       --           CHECK # :- Existence of PAYROLL Product
       ----**********************************************************************
       IF (hr_utility.chk_product_install('GHR','US')  = TRUE
         and hr_utility.chk_product_install('PAY', 'US') = TRUE
         and fnd_profile.value('HR_USER_TYPE')='INT')
       THEN
         l_pay_intg:=TRUE;
       ELSE
         l_pay_intg:=FALSE;
       END IF;
       ----**********************************************************************
        IF l_pay_intg  THEN

	  For Proposal_rec IN Cur_proposal_exists
             (p_assignment_id,p_date_effective-1)
          Loop
            l_pay_proposal_id   := proposal_rec.proposal_id;
            l_sal_admin_ovn     := proposal_rec.ovn;
          End Loop;

          hr_utility.set_location('l_hist basic value not null '||ll_value,100000);

          per_asg_del.del(
        	  p_assignment_id              => p_assignment_id,
	          p_effective_start_date      => l_effective_start_date,
	          p_effective_end_date        => l_effective_end_date,
	          p_validation_start_date      => l_validation_start_date,
	          p_validation_end_date        => l_validation_end_date,
	          p_business_group_id          => l_business_group_id,
	          p_object_version_number      => l_ovn,
	          p_effective_date            =>  (p_date_effective -1),
	          p_datetrack_mode            => 'DELETE_NEXT_CHANGE',
	          p_org_now_no_manager_warning => l_org_now_no_manager_warning  );

	 /* hr_maintain_proposal_api.delete_salary_proposal
                (
                p_pay_proposal_id      => l_pay_proposal_id ,
                p_business_group_id    => l_business_group_id         ,
                p_object_version_number => l_sal_admin_ovn            ,
                p_validate              => FALSE            ,
                p_salary_warning        => l_sal_warn
                ); */

            per_pay_proposals_populate.GET_ELEMENT_ID(
                           p_assignment_id      => p_assignment_id,
                           p_business_group_id  => l_business_group_id,
                           p_change_date        => p_date_effective -1,
                           p_payroll_value      => l_payroll_value,
                           p_element_entry_id   => l_ele_entry_id );

             hr_utility.set_location(' The Entry value '||ll_payroll_value,12345);
             hr_utility.set_location(' The Entry id '||l_ele_entry_id,12345);

             hr_entry_api.delete_element_entry
	                   ('DELETE_NEXT_CHANGE',
	                    p_date_effective - 1,
	                    l_ele_entry_id  );

          ELSE
  		per_asg_del.del(
  			p_assignment_id		=>	p_assignment_id,
  			p_effective_start_date	=>	l_effective_start_date,
  			p_effective_end_date	=>	l_effective_end_date,
  			p_validation_start_date	=>	l_validation_start_date,
  			p_validation_end_date	=>	l_validation_end_date,
  			p_business_group_id	=>	l_business_group_id,
  			p_object_version_number	=>	l_ovn,
  			p_effective_date		=>	p_date_effective,
   			p_datetrack_mode		=>	p_dt_mode,
 			p_org_now_no_manager_warning	=>  	l_org_now_no_manager_warning  );
          END IF;
  	else
  		-- raise error, unacceptable datetrack mode
  		hr_utility.set_message(8301,'GHR_38214_INVALID_DT_MODE_ASSG');
		hr_utility.raise_error;
  	end if;
  	hr_utility.set_location( 'Leaving : ' || l_proc, 20);
  END delete_asgn_row;

-- ---------------------------------------------------------------------------
-- |--------------------------< delete_peopei_row>----------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--	This procedure deletes a row from per_people_extra_info table.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_person_extra_info_id	->	person_extra_info_id to be deleted.
--
-- Post Success:
-- 	per_person_extra_info row will have been deleted.
--
-- Post Failure:
--	message will have been displayed to user explaining why the delete could not be completed.
--
-- Developer Implementation Notes:
--	None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

  PROCEDURE	delete_peopei_row(	p_person_extra_info_id	in	varchar2) IS
  	l_proc	varchar2(72) 	:= 	'delete_per_people_extra_info_row';
  	l_ovn		number;
  	cursor	c_get_ovn	(cp_person_extra_info_id	in	number) 	is
  	SELECT object_version_number
  	FROM	PER_PEOPLE_EXTRA_INFO
  	WHERE person_extra_info_id = cp_person_extra_info_id ;
 BEGIN
  	hr_utility.set_location( 'Entering : ' || l_proc, 10);
  	open c_get_ovn(p_person_extra_info_id);
  	fetch c_get_ovn into l_ovn;
  	if c_get_ovn%NOTFOUND then
		-- can't do delete without object_version_number.
		close c_get_ovn;
		return;
		-- if record is not there means it has already been deleted thru core form.
	      -- hr_utility.set_message(8301,'GHR_38217_PEI_OVN_NOTFOUND');
	      -- hr_utility.raise_error;
  	end if;
  	pe_pei_del.del(
  		p_person_extra_info_id	=>	p_person_extra_info_id,
  		p_object_version_number	=>	l_ovn);
  	hr_utility.set_location( 'Leaving : ' || l_proc, 20);
  END delete_peopei_row;

-- ---------------------------------------------------------------------------
-- |--------------------------< delete_asgnei_row>----------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--	This procedure deletes a row from per_assignment_extra_info table.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_assignment_extra_info_id	->	assignment_extra_info_id to be deleted.
--
-- Post Success:
-- 	per_assignment_extra_info row will have been deleted.
--
-- Post Failure:
--	message will have been displayed to user explaining why the delete could not be completed.
--
-- Developer Implementation Notes:
--	None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

  PROCEDURE	delete_asgnei_row(	p_assignment_extra_info_id	in	varchar2) IS
  	l_proc	varchar2(72) 	:= 	'delete_per_assignment_extra_info_row';
  	l_ovn		number;
	-- this cursor gets the object_version_number for the assignment_extra_info_id passed.
  	cursor	c_get_ovn	(cp_assignment_extra_info_id	in	number) 	is
  	SELECT object_version_number
  	FROM	PER_ASSIGNMENT_EXTRA_INFO
  	WHERE assignment_extra_info_id = cp_assignment_extra_info_id ;
  BEGIN
  	hr_utility.set_location( 'Entering : ' || l_proc, 10);
  	open c_get_ovn(p_assignment_extra_info_id);
  	fetch c_get_ovn into l_ovn;
  	if c_get_ovn%NOTFOUND then
		-- can't do delete without object_version_number.
		close c_get_ovn;
		return;
		-- if record is not there means it has already been deleted thru core form.
	      -- hr_utility.set_message(8301,'GHR_38218_ASGEI_OVN_NOTFOUND');
	      -- hr_utility.raise_error;
  	end if;
  	pe_aei_del.del(
  		p_assignment_extra_info_id	=>	p_assignment_extra_info_id,
  		p_object_version_number		=>	l_ovn);
  	hr_utility.set_location( 'Leaving : ' || l_proc, 20);
  END delete_asgnei_row;

-- ---------------------------------------------------------------------------
-- |--------------------------< delete_posnei_row>----------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--	This procedure deletes a row from per_position_extra_info table.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_position_extra_info_id	->	position_extra_info_id to be deleted.
--
-- Post Success:
-- 	per_position_extra_info row will have been deleted.
--
-- Post Failure:
--	message will have been displayed to user explaining why the delete could not be completed.
--
-- Developer Implementation Notes:
--	None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
  PROCEDURE	delete_posnei_row(	p_position_extra_info_id	in	varchar2) IS
  	l_proc	varchar2(72) 	:= 	'delete_per_position_extra_info_row';
  	l_ovn		number;
	-- this cursor gets the object_version_number for the position_extra_info_id passed.
  	cursor	c_get_ovn	(cp_position_extra_info_id	in	number) 	is
  	SELECT object_version_number
  	FROM	PER_POSITION_EXTRA_INFO
  	WHERE position_extra_info_id = cp_position_extra_info_id ;
  BEGIN
  	hr_utility.set_location( 'Entering : ' || l_proc, 10);
  	open c_get_ovn(p_position_extra_info_id);
  	fetch c_get_ovn into l_ovn;
  	if c_get_ovn%NOTFOUND then
		-- can't do delete without object_version_number.
		close c_get_ovn;
		return;
		-- if record is not there means it has already been deleted thru core form.
	      -- hr_utility.set_message(8301,'GHR_38218_ASGEI_OVN_NOTFOUND');
	      -- hr_utility.raise_error;
  	end if;
  	pe_poi_del.del(
  		p_position_extra_info_id	=>	p_position_extra_info_id,
  		p_object_version_number		=>	l_ovn);
  	hr_utility.set_location( 'Leaving : ' || l_proc, 20);
  END delete_posnei_row;

-- ---------------------------------------------------------------------------
-- |--------------------------< delete_address_row>----------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--	This procedure deletes a row from per_addresses table.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_address_id	->	address_id to be deleted.
--
-- Post Success:
-- 	per_addresses row will have been deleted.
--
-- Post Failure:
--	message will have been displayed to user explaining why the delete could not be completed.
--
-- Developer Implementation Notes:
--	None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

  PROCEDURE	delete_address_row(	p_address_id	in	varchar2) IS

  	l_proc	varchar2(72) 	:= 	'delete_per_addresses_row';
  	l_ovn		number;
  	cursor	c_get_ovn	(cp_address_id	in	number) 	is
  	SELECT object_version_number
  	FROM	PER_ADDRESSES
  	WHERE address_id = cp_address_id ;

  BEGIN
  	hr_utility.set_location( 'Entering : ' || l_proc, 10);
  	open c_get_ovn(p_address_id);
  	fetch c_get_ovn into l_ovn;
  	if c_get_ovn%NOTFOUND then
		-- can't do delete without object_version_number.
		close c_get_ovn;
		return;
		-- if record is not there means it has already been deleted thru core form.
	      -- hr_utility.set_message(8301,'GHR_38220_ADDRESS_OVN_NOTFOUND');
	      -- hr_utility.raise_error;
  	end if;
        hr_utility.set_location('*Deleting p_address_id:' || p_address_id, 12);
  	per_add_del.del(
  		p_address_id			=>	p_address_id,
  		p_object_version_number		=>	l_ovn);
  	hr_utility.set_location( 'Leaving : ' || l_proc, 20);
  END delete_address_row;

-- ---------------------------------------------------------------------------
-- |--------------------------< delete_person_analyses_row>-------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--	This procedure deletes a row from per_person_analyses table.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_person_analysis_id	->	person_analysis_id to be deleted.
--
-- Post Success:
-- 	per_person_analyses row will have been deleted.
--
-- Post Failure:
--	message will have been displayed to user explaining why the delete could not be completed.
--
-- Developer Implementation Notes:
--	None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

  PROCEDURE delete_person_analyses_row ( p_person_analysis_id	in	number) is

  	l_proc	varchar2(72) 	:= 	'delete_person_analyses_row';
  	l_ovn		number;
  	cursor	c_get_ovn	(cp_person_analysis_id	in	number) 	is
  	SELECT object_version_number
  	FROM	PER_PERSON_ANALYSES
  	WHERE person_analysis_id = cp_person_analysis_id ;

  Begin
  	hr_utility.set_location( 'Entering : ' || l_proc, 10);
  	open c_get_ovn(p_person_analysis_id);
  	fetch c_get_ovn into l_ovn;
  	if c_get_ovn%NOTFOUND then
		-- can't do delete without object_version_number.
  		-- raise error;
		close c_get_ovn;
		return;
		-- if record is not there means it has already been deleted thru core form.
	      -- hr_utility.set_message(8301,'GHR_38272_PERSON_ANALYSE_OV_NF');
	      -- hr_utility.raise_error;
  	end if;

	per_pea_del.del(
		p_person_analysis_id	=>	p_person_analysis_id,
		p_object_version_number	=>	l_ovn);

  End delete_person_analyses_row;

-- ---------------------------------------------------------------------------
-- |--------------------------< delete_appl_row>------------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--	This procedure deletes a row from the corresponding application table.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_table_name	->	name of table to be deleted from.
--	p_table_pk_id	->	pk_id of row to be deleted.
--	p_dt_mode		->	datetrack delete mode.
--	p_date_effective	->	effective date of delete.
--
-- Post Success:
-- 	specified application table row will have been deleted.
--
-- Post Failure:
--	message will have been displayed to user explaining why the delete could not be completed.
--
-- Developer Implementation Notes:
--	None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
  PROCEDURE	delete_appl_row(	p_table_name	in	varchar2,
  					p_table_pk_id	in	varchar2,
  					p_dt_mode		in	varchar2,
  					p_date_effective	in	date) IS
  	l_proc	varchar2(72) 	:= 	'delete_appl_row';
  BEGIN
  	hr_utility.set_location( 'Entering : ' || l_proc, 10);
        hr_utility.set_location('     P_TABLE_NAME:' || p_table_name, 15);
  	if (lower(p_table_name) = lower(ghr_history_api.g_peop_table)) then
  		delete_peop_row(		p_person_id	=>	p_table_pk_id,
  						p_dt_mode		=>	p_dt_mode,
  						p_date_effective	=>	p_date_effective);
        -- Added Handling of Position table. Bug# 1252481 11-MAY-2000
  	elsif (lower(p_table_name) = lower(ghr_history_api.g_posn_table)) then
  		delete_posn_row(		p_position_id	=>	p_table_pk_id,
  						p_dt_mode		=>	p_dt_mode,
  						p_date_effective	=>	p_date_effective);
  	elsif (lower(p_table_name) = lower(ghr_history_api.g_asgn_table)) then
  		delete_asgn_row(		p_assignment_id	=>	p_table_pk_id,
  						p_dt_mode		=>	p_dt_mode,
  						p_date_effective	=>	p_date_effective);
  	elsif (lower(p_table_name) = lower(ghr_history_api.g_peopei_table)) then
  		delete_peopei_row(	p_person_extra_info_id	=>	p_table_pk_id);
  	elsif (lower(p_table_name) = lower(ghr_history_api.g_asgnei_table)) then
  		delete_asgnei_row(	p_assignment_extra_info_id	=>	p_table_pk_id);
  	elsif (lower(p_table_name) = lower(ghr_history_api.g_posnei_table)) then
  		delete_posnei_row(	p_position_extra_info_id	=>	p_table_pk_id);
  	elsif (lower(p_table_name) = lower(ghr_history_api.g_addres_table)) then
  		delete_address_row(	p_address_id	=>	p_table_pk_id);
	elsif (lower(p_table_name) = lower(ghr_history_api.g_perana_table)) then
  		delete_person_analyses_row(	p_person_analysis_id	=>	p_table_pk_id);
  	end if;
  	hr_utility.set_location( 'Leaving : ' || l_proc, 20);
  END delete_appl_row;

-- ---------------------------------------------------------------------------
-- |--------------------------< undo_mark_cancel>------------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--	This procedure makes the parent sf52 available for cancellation/correction. This
--	is needed in the case where a correction is cancelled and the parent sf52 has
--	been marked as unavailable for correction/cancellation. This procedure will mark it
--	available again.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_sf52_data		->	ghr_pa_requests row of the cancellation being processed.
--
-- Post Success:
-- 	If this is a cancellation of correction, the parent sf52 will have been marked as
--	available for cancellation/correction again.
--
-- Post Failure:
--	Exception will have ben raised and message displayed.
--
-- Developer Implementation Notes:
--	None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

Procedure Undo_Mark_Cancel ( p_sf52_data  in  ghr_pa_requests%rowtype) is
	cursor get_req (cp_pa_request_id number) is
	select
		pa_request_id,
		altered_pa_request_id,
		first_noa_id,
		second_noa_id,
		object_version_number ovn
	from ghr_pa_requests
	where pa_request_id = cp_pa_request_id;
	l_proc		varchar2(30):='Undo_Mark_Cancel';
	l_sf52_data	get_req%rowtype;
Begin
	hr_utility.set_location( 'Entering ' || l_proc, 10);
	if p_sf52_data.altered_pa_request_id is not null then
		-- if it is a correction/cancellation it'll have altered_pa_request_id
		hr_utility.set_location( l_proc, 20);
		-- fetch cancelled/corrected pa_request record
		open get_req( p_sf52_data.altered_pa_request_id);
		fetch get_req into l_sf52_data;
		if get_req%notfound then
			-- this must never happen until data has been corrupted.
			hr_utility.set_location( 'Error ' || l_proc, 30);
			hr_utility.set_message(8301 , 'GHR_38278_PARENT_SF52_NOT_FND');
			hr_utility.raise_error;
		end if;
		close get_req;
		-- Only if a correction is canceled following logic must be executed to mark
		-- parent SF52 available for cancellation/correction.
		if l_sf52_data.altered_pa_request_id is not null then
			hr_utility.set_location( l_proc, 40);
			open get_req(l_sf52_data.altered_pa_request_id);
			fetch get_req into l_sf52_data;
			if get_req%notfound then
				hr_utility.set_location( 'Error ' || l_proc , 50);
				hr_utility.set_message(8301 , 'GHR_38278_PARENT_SF52_NOT_FND');
				hr_utility.raise_error;
			end if;
			close get_req;
			if l_sf52_data.first_noa_id = p_sf52_data.second_noa_id then
				hr_utility.set_location( l_proc, 60);
				ghr_par_upd.upd
				(p_pa_request_id                 =>  l_sf52_data.pa_request_id,
				 p_object_version_number         =>  l_sf52_data.ovn,
				 p_first_noa_cancel_or_correct   =>  NULL,
				 p_first_noa_pa_request_id       =>  NULL
				);
			elsif l_sf52_data.second_noa_id = p_sf52_data.second_noa_id then
				hr_utility.set_location( l_proc, 70);
				ghr_par_upd.upd
				(p_pa_request_id                 =>  l_sf52_data.pa_request_id,
				 p_object_version_number         =>  l_sf52_data.ovn,
				 p_second_noa_cancel_or_correct  =>  NULL,
				 p_second_noa_pa_request_id      =>  NULL
				);
			else
				-- This must never be the case where parent SF52 has different
				-- NOACs then the correction/cancellation.
				hr_utility.set_location( l_proc, 80);
				hr_utility.set_message(8301 , 'GHR_38279_PARENT_NOA_IS_DIFF');
				hr_utility.raise_error;
				null;
			end if;
		end if;
		hr_utility.set_location( l_proc, 90);
	end if;
	hr_utility.set_location( 'Leaving ' || l_proc, 100);

End Undo_Mark_Cancel;

Procedure convert_shadow_to_sf52 (
	p_shadow	 in   ghr_pa_request_shadow%rowtype,
	p_sf52 out nocopy ghr_pa_requests%rowtype) is
l_sf52  ghr_pa_requests%rowtype;
Begin

    l_sf52                                   := p_sf52;
    p_sf52.pa_request_id                     := p_shadow.pa_request_id                ;
    p_sf52.academic_discipline               := p_shadow.academic_discipline          ;
    p_sf52.annuitant_indicator               := p_shadow.annuitant_indicator          ;
    p_sf52.appropriation_code1               := p_shadow.appropriation_code1          ;
    p_sf52.appropriation_code2               := p_shadow.appropriation_code2          ;
    p_sf52.bargaining_unit_status            := p_shadow.bargaining_unit_status       ;
    p_sf52.citizenship                       := p_shadow.citizenship                  ;
--    p_sf52.duty_station_code                 := p_shadow.duty_station_code            ;
    p_sf52.duty_station_location_id          := p_shadow.duty_station_location_id     ;
    p_sf52.education_level                   := p_shadow.education_level              ;
--    p_sf52.employee_assignment_id            := p_shadow.employee_assignment_id       ;
    p_sf52.fegli                             := p_shadow.fegli                        ;
    p_sf52.flsa_category                     := p_shadow.flsa_category                ;
    p_sf52.forwarding_address_line1          := p_shadow.forwarding_address_line1 ;
    p_sf52.forwarding_address_line2          := p_shadow.forwarding_address_line2 ;
    p_sf52.forwarding_address_line3          := p_shadow.forwarding_address_line3  ;
    p_sf52.forwarding_country_short_name     := p_shadow.forwarding_country_short_name;
    p_sf52.forwarding_postal_code            := p_shadow.forwarding_postal_code       ;
    p_sf52.forwarding_region_2               := p_shadow.forwarding_region_2          ;
    p_sf52.forwarding_town_or_city           := p_shadow.forwarding_town_or_city      ;
    p_sf52.functional_class                  := p_shadow.functional_class             ;
    p_sf52.part_time_hours                   := p_shadow.part_time_hours              ;
    p_sf52.pay_rate_determinant              := p_shadow.pay_rate_determinant         ;
    p_sf52.position_occupied                 := p_shadow.position_occupied            ;
    p_sf52.retirement_plan                   := p_shadow.retirement_plan              ;
    p_sf52.service_comp_date                 := p_shadow.service_comp_date            ;
    p_sf52.supervisory_status                := p_shadow.supervisory_status           ;
    p_sf52.tenure                            := p_shadow.tenure                       ;
    p_sf52.to_ap_premium_pay_indicator       := p_shadow.to_ap_premium_pay_indicator  ;
    p_sf52.to_auo_premium_pay_indicator      := p_shadow.to_auo_premium_pay_indicator ;
--    p_sf52.to_au_overtime                    := p_shadow.to_au_overtime               ;
--    p_sf52.to_availability_pay               := p_shadow.to_availability_pay          ;
    p_sf52.to_occ_code                       := p_shadow.to_occ_code                  ;
--    p_sf52.to_other_pay_amount               := p_shadow.to_other_pay_amount          ;
    p_sf52.to_position_id                    := p_shadow.to_position_id               ;
    p_sf52.to_retention_allowance            := p_shadow.to_retention_allowance       ;
    p_sf52.to_retention_allow_percentage     := p_shadow.to_retention_allow_percentage;
    p_sf52.to_staffing_differential          := p_shadow.to_staffing_differential     ;
    p_sf52.to_staffing_diff_percentage       := p_shadow.to_staffing_diff_percentage  ;
    p_sf52.to_step_or_rate                   := p_shadow.to_step_or_rate              ;
    p_sf52.to_supervisory_differential       := p_shadow.to_supervisory_differential  ;
    p_sf52.to_supervisory_diff_percentage    := p_shadow.to_supervisory_diff_percentage ;
    p_sf52.veterans_preference               := p_shadow.veterans_preference          ;
    p_sf52.veterans_pref_for_rif             := p_shadow.veterans_pref_for_rif        ;
    p_sf52.veterans_status                   := p_shadow.veterans_status              ;
    p_sf52.work_schedule                     := p_shadow.work_schedule                ;
    p_sf52.year_degree_attained              := p_shadow.year_degree_attained         ;
  exception when others then
            --
            -- Reset IN OUT parameters and set OUT parameters
            --
            p_sf52 := null;
            raise;

End;

Procedure convert_sf52_to_shadow (
	p_sf52	 in	ghr_pa_requests%rowtype,
	p_shadow out nocopy   ghr_pa_request_shadow%rowtype
) is

Begin

    p_shadow.pa_request_id                     := p_sf52.pa_request_id                ;
    p_shadow.academic_discipline               := p_sf52.academic_discipline          ;
    p_shadow.annuitant_indicator               := p_sf52.annuitant_indicator          ;
    p_shadow.appropriation_code1               := p_sf52.appropriation_code1          ;
    p_shadow.appropriation_code2               := p_sf52.appropriation_code2          ;
    p_shadow.bargaining_unit_status            := p_sf52.bargaining_unit_status       ;
    p_shadow.citizenship                       := p_sf52.citizenship                  ;
--    p_shadow.duty_station_code                 := p_sf52.duty_station_code            ;
    p_shadow.duty_station_location_id          := p_sf52.duty_station_location_id     ;
    p_shadow.education_level                   := p_sf52.education_level              ;
--    p_shadow.employee_assignment_id            := p_sf52.employee_assignment_id       ;
    p_shadow.fegli                             := p_sf52.fegli                        ;
    p_shadow.flsa_category                     := p_sf52.flsa_category                ;
    p_shadow.forwarding_address_line1          := p_sf52.forwarding_address_line1 ;
    p_shadow.forwarding_address_line2          := p_sf52.forwarding_address_line2 ;
    p_shadow.forwarding_address_line3          := p_sf52.forwarding_address_line3  ;
    p_shadow.forwarding_country_short_name     := p_sf52.forwarding_country_short_name;
    p_shadow.forwarding_postal_code            := p_sf52.forwarding_postal_code       ;
    p_shadow.forwarding_region_2               := p_sf52.forwarding_region_2          ;
    p_shadow.forwarding_town_or_city           := p_sf52.forwarding_town_or_city      ;
    p_shadow.functional_class                  := p_sf52.functional_class             ;
    p_shadow.part_time_hours                   := p_sf52.part_time_hours              ;
    p_shadow.pay_rate_determinant              := p_sf52.pay_rate_determinant         ;
    p_shadow.position_occupied                 := p_sf52.position_occupied            ;
    p_shadow.retirement_plan                   := p_sf52.retirement_plan              ;
    p_shadow.service_comp_date                 := p_sf52.service_comp_date            ;
    p_shadow.supervisory_status                := p_sf52.supervisory_status           ;
    p_shadow.tenure                            := p_sf52.tenure                       ;
    p_shadow.to_ap_premium_pay_indicator       := p_sf52.to_ap_premium_pay_indicator  ;
    p_shadow.to_auo_premium_pay_indicator      := p_sf52.to_auo_premium_pay_indicator ;
--    p_shadow.to_au_overtime                    := p_sf52.to_au_overtime               ;
--    p_shadow.to_availability_pay               := p_sf52.to_availability_pay          ;
    p_shadow.to_occ_code                       := p_sf52.to_occ_code                  ;
--    p_shadow.to_other_pay_amount               := p_sf52.to_other_pay_amount          ;
    p_shadow.to_position_id                    := p_sf52.to_position_id               ;
    p_shadow.to_retention_allowance            := p_sf52.to_retention_allowance       ;
    p_shadow.to_retention_allow_percentage     := p_sf52.to_retention_allow_percentage;
    p_shadow.to_staffing_differential          := p_sf52.to_staffing_differential     ;
    p_shadow.to_staffing_diff_percentage       := p_sf52.to_staffing_diff_percentage     ;

    p_shadow.to_step_or_rate                   := p_sf52.to_step_or_rate              ;
    p_shadow.to_supervisory_differential       := p_sf52.to_supervisory_differential  ;
    p_shadow.to_supervisory_diff_percentage    := p_sf52.to_supervisory_diff_percentage  ;
    p_shadow.veterans_preference               := p_sf52.veterans_preference          ;
    p_shadow.veterans_pref_for_rif             := p_sf52.veterans_pref_for_rif        ;
    p_shadow.veterans_status                   := p_sf52.veterans_status              ;
    p_shadow.work_schedule                     := p_sf52.work_schedule                ;
    p_shadow.year_degree_attained              := p_sf52.year_degree_attained         ;
  exception when others then
            --
            -- Reset IN OUT parameters and set OUT parameters
            --
            p_shadow := null;
            raise;

End;

Procedure build_corrected_sf52(p_pa_request_id		in number,
		p_noa_code_correct	in varchar2,
		p_sf52_data_result in out nocopy ghr_pa_requests%rowtype,
                p_called_from in varchar2 default null ) is

	l_sf52_data_orig		ghr_pa_requests%rowtype;
	l_sf52_data_step		ghr_pa_requests%rowtype;
	l_sf52_data_result_rec		ghr_pa_requests%rowtype;
	l_sf52_dummy		ghr_pa_requests%rowtype;
	l_sf52_cursor_step_indx	number;
        l_capped_other_pay number := hr_api.g_number;

	-- this cursor selects all rows in the correction chain from ghr_pa_requests
	cursor  l_sf52_cursor is
	select 	*
	from 		ghr_pa_requests
	connect by 	prior altered_pa_request_id = pa_request_id
	start with	pa_request_id = p_pa_request_id
	order by 	level desc;
	l_shadow_data	ghr_pa_request_shadow%rowtype;
	l_proc	varchar2(30):='build_corrected_sf52';

--Bug 2141522
   l_session_var   ghr_history_api.g_session_var_type;
   -- Bug#5435374 added l_session_var1.
   l_session_var1   ghr_history_api.g_session_var_type;
   l_session_sf52_rec ghr_pa_requests%rowtype;
   cursor c_rpa is
   select *
   from ghr_pa_requests
   where pa_request_id = p_pa_request_id;
--Bug 2141522
cursor c_orig_details_for_ia is
        select pa_request_id,pa_notification_id,person_id,
               effective_date,from_position_id,
               to_position_id
        from ghr_pa_requests
        where pa_request_id in (
            select  altered_pa_request_id from
             ghr_pa_requests where pa_request_id = p_pa_request_id);

	     -- Bug#5435374
        l_pos_ei_grade_data  per_position_extra_info%rowtype;

        cursor c_grade_kff (grd_id number) is
            select gdf.segment1
                  ,gdf.segment2
              from per_grades grd,
                   per_grade_definitions gdf
             where grd.grade_id = grd_id
               and grd.grade_definition_id = gdf.grade_definition_id;

l_retro_eff_date date;
l_retro_pa_request_id   ghr_pa_requests.pa_request_id%type;
l_retro_first_noa       ghr_nature_of_actions.code%type;
l_retro_second_noa       ghr_nature_of_actions.code%type;
l_sf52_ia_rec		ghr_pa_requests%rowtype;


begin
	hr_utility.set_location('Entering:'|| l_proc, 5);
   l_sf52_data_result_rec := p_sf52_data_result;
--	ghr_history_api.get_g_session_var(l_session_var);
--Bug 2141522
        -- set values of session variables
        open  c_rpa;
        fetch c_rpa into l_session_sf52_rec;
        close c_rpa;

        l_session_var.pa_request_id             := p_pa_request_id;
        l_session_var.noa_id                    := l_session_sf52_rec.second_noa_id;
        l_session_var.fire_trigger              := 'N';
        l_session_var.date_Effective            := l_session_sf52_rec.effective_date;
        l_session_var.person_id                 := l_session_sf52_rec.person_id;
        l_session_var.program_name              := 'sf50';
        l_session_var.assignment_id             := l_session_sf52_rec.employee_assignment_id;
        l_session_var.altered_pa_request_id     := l_session_sf52_rec.altered_pa_request_id;
        l_session_var.noa_id_correct            := l_session_sf52_rec.second_noa_id;
        ghr_history_api.set_g_session_var(l_session_var);
--Bug 2141522

	-- loop through all corrections in the correction chain, incrementally applying them by
	-- calling apply_corrections procedure.
	open l_sf52_cursor ;
	l_sf52_cursor_step_indx := 0;
	loop
		-- initialize l_sf52_data_step to nulls;
		l_sf52_data_step := l_sf52_dummy;
		-- l_sf52_data_step holds intermediate incremental values for final corrected record that is
		-- being built.
		fetch l_sf52_cursor into l_sf52_data_step;
		exit when l_sf52_cursor%notfound;
		l_sf52_cursor_step_indx := l_sf52_cursor_step_indx +1;
		if ( 	l_sf52_cursor_step_indx = 1) then
			hr_utility.set_location('Fetch l_sf52_data_step original :'|| l_proc, 10);
			l_sf52_data_orig 	  := l_sf52_data_step;
			p_sf52_data_result  := l_sf52_data_step;
            -- Bug 3228557 Added the following IF condition. In case of NPA Printing
            -- Pass parameter 'NPA' to the procedure call to refresh_req_shadow.
            IF NVL(p_called_from,hr_api.g_varchar2) = 'NPA' THEN
			    hr_utility.set_location('Inside NPA printing',10);
			    ghr_process_sf52.refresh_req_shadow(p_sf52_data=>p_sf52_data_result,
                                                                p_shadow_data=>l_shadow_data,
                                                                p_process_type => 'NPA');
            ELSE
			    hr_utility.set_location('Calling Refresh_req_shadow ',10);
                            ghr_process_sf52.refresh_req_shadow(p_sf52_data=>p_sf52_data_result,
                                                                  p_shadow_data=>l_shadow_data);
            END IF;
            -- Bug 3228557 Skip Pay Calculation in case of NPA report printing.
			IF nvl(p_called_from,hr_api.g_varchar2) NOT IN ('FROM_PAYCAL','NPA') THEN
			ghr_process_sf52.redo_pay_calc(	p_sf52_rec		=>	p_sf52_data_result,
                                            p_capped_other_pay      =>   l_capped_other_pay);
            END IF;
			hr_utility.set_location('assignment_id of original =' || l_sf52_data_step.employee_assignment_id, 14);
			hr_utility.set_location(l_proc || 'pa_request_id of original= ' || l_sf52_data_step.pa_request_id,26);
			-- check if original action in correction chain was a dual action. If so, determine which of
			--   the two actions this correction is for and call ghr_process_sf52.assign_new_rg to null out columns not having
			--   to do with the noa we are correcting.
			if (p_sf52_data_result.second_noa_id is not null) then
				hr_utility.set_location('original sf52 is dual action :'|| l_proc, 11);
---- commented the below if condition because is is compared against NOAC Code
---- Dual action correction need to be tested.
----        if (p_noa_code_correct = p_sf52_data_result.second_noa_id) then
				if (p_noa_code_correct = p_sf52_data_result.second_noa_code) then
					hr_utility.set_location('Correcting second action in dual action:'|| l_proc, 12);
					-- Bug 8264475Modified to comment the code for handling dual actions
					-- as both the actions need to consider the same to side information
					/*ghr_process_sf52.assign_new_rg(p_action_num			=>	2,
										 p_pa_req				=>	p_sf52_data_result);*/
					ghr_process_sf52.copy_2ndNoa_to_1stNoa(p_sf52_data_result);
                              	        ghr_process_sf52.null_2ndNoa_cols(p_sf52_data_result);
				else
					hr_utility.set_location('Correcting first action in dual action:'|| l_proc, 13);
					-- Bug 8264475Modified to comment the code for handling dual actions
					-- as both the actions need to consider the same to side information

					/*ghr_process_sf52.assign_new_rg(p_action_num			=>	1,
								 		 p_pa_req				=>	p_sf52_data_result);*/
		 			-- if first action is 893, then we need to derive to_columns as both actions of
					-- the dual action potentially could have changed the to fields (in particular,
					-- to_step_or_rate) so we need to determine what the to_fields should be or the first action.
					if (p_sf52_data_result.first_noa_code = '893') then--Bug# 8926400
						ghr_process_sf52.derive_to_columns(p_sf52_data	=>	p_sf52_data_result);
					end if;
					ghr_process_sf52.null_2ndNoa_cols(p_sf52_data_result);
				end if;
			end if;
			-- Nullfy columns which must not be passed
			p_sf52_data_result.pa_notification_id		:= NULL;
			p_sf52_data_result.agency_code			:= NULL;
			p_sf52_data_result.approval_date			:= NULL;
			p_sf52_data_result.approving_official_work_title:= NULL;
			p_sf52_data_result.employee_dept_or_agency 	:= NULL;
			p_sf52_data_result.from_agency_code			:= NULL;
			p_sf52_data_result.from_agency_desc			:= NULL;
			p_sf52_data_result.from_office_symbol		:= NULL;
			p_sf52_data_result.personnel_office_id		:= NULL;
			p_sf52_data_result.to_office_symbol			:= NULL;
		else
			hr_utility.set_location('Fetch l_sf52_data_step loop :'|| l_proc, 15);
			-- all corrections will have the original sf52 information in the 2nd noa columns, so
			-- copy that information to 1st noa columns.
			ghr_process_sf52.copy_2ndNoa_to_1stNoa(l_sf52_data_step);
			-- null the second noa columns since we don't want anything to be done with these now.
			ghr_process_sf52.null_2ndNoa_cols(l_sf52_data_step);
			hr_utility.set_location(l_proc || 'pa_request_id before correction= ' || l_sf52_data_step.pa_request_id,16);
			hr_utility.set_location(l_proc || 'assignment id before correction= ' || l_sf52_data_step.employee_assignment_id,17);
                       -- Start Intervening Actions Processing
                       -- Processing added to assign the From side details to
                       -- To side if it is a Intervening action and
                       -- Original action from position_id = to position id
                       -- Fetch the original action details
                       FOR c_orig_det_rec in c_orig_details_for_ia
                       LOOP
			hr_utility.set_location('Inside the orig_details for loop' ,15);
			hr_utility.set_location('orig pa_request_id'||c_orig_det_rec.pa_request_id ,15);
			hr_utility.set_location('orig pa_notification_id'||c_orig_det_rec.pa_notification_id ,15);
			hr_utility.set_location('orig person_id'||c_orig_det_rec.person_id ,15);
			hr_utility.set_location('orig from_position_id'||c_orig_det_rec.from_position_id ,15);
			hr_utility.set_location('orig to_position_id'||c_orig_det_rec.to_position_id ,15);
			hr_utility.set_location('orig effective_date'||c_orig_det_rec.effective_date ,15);
		    --BUG #7216635 added the parameter p_noa_id_correct
                        GHR_APPROVED_PA_REQUESTS.determine_ia(
                             p_pa_request_id => c_orig_det_rec.pa_request_id,
                             p_pa_notification_id => c_orig_det_rec.pa_notification_id,
                             p_person_id      => c_orig_det_rec.person_id,
                             p_effective_date => c_orig_det_rec.effective_date,
			      p_noa_id_correct => l_session_var.noa_id_correct,
                             p_retro_pa_request_id => l_retro_pa_request_id,
                             p_retro_eff_date => l_retro_eff_date,
                             p_retro_first_noa => l_retro_first_noa,
                             p_retro_second_noa => l_retro_second_noa);
			hr_utility.set_location('retro effective_date is '||l_retro_eff_date ,16);
			-- Bug#2521744 Splitting the single if condition into 2 separate if conditions.
                        IF l_retro_eff_date is NOT NULL  THEN
                           IF c_orig_det_rec.from_position_id
                                = c_orig_det_rec.to_position_id THEN
                                -- copy the from details
                                -- copy the from details
				hr_utility.set_location('Its a Intervening Action ' ,16);
				hr_utility.set_location('pa_request_id passed to get_sf52_to_det '||p_pa_request_id ,17);

				get_sf52_to_details_for_ia
				   (p_pa_request_id => p_pa_request_id,
				    p_retro_eff_date   => l_retro_eff_date,
				    p_sf52_ia_rec  => p_sf52_data_result);
				get_sf52_to_othpays_for_ia(p_sf52_ia_rec  => p_sf52_data_result);
				ghr_process_sf52.print_sf52('result aft get_sf52_to_details_for_ia',
							     p_sf52_data_result );
                          ELSE
                                -- Verify whether the original action is one of the salary change actions
                                -- If yes, check whether the other pay related elements are present or not
                                -- as on the effective date. If they are not present, set that other pay comp
                                -- to_value as null.
                                get_sf52_to_othpays_for_ia(p_sf52_ia_rec  => p_sf52_data_result);
                                ghr_process_sf52.print_sf52('Aft get_sf52_to_other_pay_det_for_ia in else',
                                                 p_sf52_data_result );
                          END IF;
                        END IF;
                      END LOOP;
                        ghr_process_sf52.print_sf52('step aft get_sf52_to_details_for_ia',
                                                    l_sf52_data_step);
			apply_correction( p_sf52rec_correct		=>	l_sf52_data_step,
						p_corr_pa_request_id	=>	p_pa_request_id,
						p_sf52rec		=>	p_sf52_data_result );

                        if (l_sf52_data_step.first_noa_code = '352') then
                                p_sf52_data_result.to_position_org_line1 :=
                                ghr_pa_requests_pkg2.get_agency_code_to(
                                  p_pa_request_id => l_sf52_data_step.pa_request_id,
                                  p_noa_id        => l_sf52_data_step.first_noa_id);
               -- Bug#2681726 In case of Realignment print all the Position Org Lines.
                        elsif (l_sf52_data_step.first_noa_code = '790' ) then
                           ghr_pa_requests_pkg.get_rei_org_lines(
                                 p_pa_request_id       => p_sf52_data_result.pa_request_id,
                                 p_organization_id     => p_sf52_data_result.to_organization_id,
                                 p_position_org_line1  => p_sf52_data_result.to_position_org_line1,
                                 p_position_org_line2  => p_sf52_data_result.to_position_org_line2,
                                 p_position_org_line3  => p_sf52_data_result.to_position_org_line3,
                                 p_position_org_line4  => p_sf52_data_result.to_position_org_line4,
                                 p_position_org_line5  => p_sf52_data_result.to_position_org_line5,
                                 p_position_org_line6  => p_sf52_data_result.to_position_org_line6);
                        end if;

                        -- Recalculating Retention Allowance
                        -- Recalculate Retention allowance if it is a OTHER_PAY action
                        -- and Correction of Intervening Action
                         if p_sf52_data_result.noa_family_code = 'OTHER_PAY' and
                           l_retro_eff_date is NOT NULL and
			   p_sf52_data_result.to_retention_allow_percentage is not null then
   --Modified for FWS
                           IF p_sf52_data_result.to_pay_basis ='PH' THEN
       			      p_sf52_data_result.to_retention_allowance :=
                                 TRUNC(p_sf52_data_result.to_basic_pay * p_sf52_data_result.to_retention_allow_percentage/100,2);
			   ELSE
			        p_sf52_data_result.to_retention_allowance :=
                                 TRUNC(p_sf52_data_result.to_basic_pay * p_sf52_data_result.to_retention_allow_percentage/100,0);
                           END IF;
    --FWS END
                             p_sf52_data_result.to_other_pay_amount :=
                             nvl(p_sf52_data_result.to_au_overtime,0) +
                             nvl(p_sf52_data_result.to_availability_pay,0) +
                             nvl(p_sf52_data_result.to_retention_allowance,0) +
                             nvl(p_sf52_data_result.to_supervisory_differential,0) +
                             nvl(p_sf52_data_result.to_staffing_differential,0);
                             p_sf52_data_result.to_total_salary :=
                             p_sf52_data_result.to_adj_basic_pay + p_sf52_data_result.to_other_pay_amount;
                             if p_sf52_data_result.to_other_pay_amount = 0 then
                               p_sf52_data_result.to_other_pay_amount := null;
                             end if;
                           end if;
			hr_utility.set_location( l_proc || 'assignment_id after correction=' || p_sf52_data_result.employee_assignment_id ,18);
			hr_utility.set_location('Applied corrections :'|| l_proc, 20);
		end if;
	end loop;
	close l_sf52_cursor;

    -- Bug#5435374 If the from and to position ids are same, verify the grade details.
	 IF p_sf52_data_result.from_position_id = p_sf52_data_result.to_position_id THEN

        -- Reinitializing the session variables to get the valid grade as on the
        -- effective date.
        ghr_history_api.get_g_session_var(l_session_var);
        ghr_history_api.reinit_g_session_var;
        l_session_var1.date_Effective            := l_session_var.date_Effective;
        l_session_var1.person_id                 := l_session_var.person_id;
        l_session_var1.assignment_id             := l_session_var.assignment_id;
        l_session_var1.fire_trigger    := 'N';
        l_session_var1.program_name := 'sf50';
        ghr_history_api.set_g_session_var(l_session_var1);

        -- Retrieve the Grade info from the POI history table
		ghr_history_fetch.fetch_positionei(
		p_position_id      => p_sf52_data_result.to_position_id,
		p_information_type => 'GHR_US_POS_VALID_GRADE',
		p_date_effective   => p_sf52_data_result.effective_date,
		p_pos_ei_data      => l_pos_ei_grade_data);

        -- Reset the session variables after getting the date effective grade value.
        ghr_history_api.reinit_g_session_var;
        ghr_history_api.set_g_session_var(l_session_var);

        IF l_pos_ei_grade_data.position_extra_info_id IS NOT NULL THEN
			hr_utility.set_location('GL: to grd id:'||p_sf52_data_result.to_grade_id,30);
			hr_utility.set_location('GL: pos ei grd:'||l_pos_ei_grade_data.poei_information3,40);
			IF l_pos_ei_grade_data.poei_information3 <> p_sf52_data_result.to_grade_id THEN
				--Bug# 5638869
                --p_sf52_data_result.to_grade_id := l_pos_ei_grade_data.poei_information3;
                l_pos_ei_grade_data.poei_information3 := p_sf52_data_result.to_grade_id;
                --Bug# 5638869
				FOR c_grade_kff_rec IN c_grade_kff (p_sf52_data_result.to_grade_id)
				LOOP
					p_sf52_data_result.to_pay_plan := c_grade_kff_rec.segment1  ;
					p_sf52_data_result.to_grade_or_level := c_grade_kff_rec.segment2;
					EXIT;
				END LOOP;
			END IF;
		END IF;
	 END IF;
     -- Bug#5435374 End of bug fix.

     ghr_process_sf52.print_sf52('Result after apply_correction ' , p_sf52_data_result);

     hr_utility.set_location(' Leaving:'||l_proc, 25);
exception when others then
            --
            -- Reset IN OUT parameters and set OUT parameters
            --
            p_sf52_data_result := l_sf52_data_result_rec;
            raise;

end build_corrected_sf52;

-- Following 4 procedures and functions are created to handle correction RPAs
-- In reports.

Procedure populate_corrected_sf52(p_pa_request_id    in number,
                                  p_noa_code_correct in varchar2)
is
  l_session_var     ghr_history_api.g_session_var_type;
  l_sf52_data       ghr_pa_requests%ROWTYPE;


  FUNCTION get_record_category(p_sf52_record IN ghr_pa_requests%ROWTYPE)
  RETURN NUMBER IS
    CURSOR c_noa_fam_code(c_noa_id NUMBER) is
    select fam.noa_family_code family_code
    from ghr_noa_families fam
    where fam.nature_of_action_id = c_noa_id;

    l_found VARCHAR2(10) := 'FALSE';
    l_proc  VARCHAR2(30) := 'get_record_category';

  BEGIN
     hr_utility.set_location('Entering: '||l_proc,0);
     IF p_sf52_record.from_position_id      IS NOT NULL AND
        p_sf52_record.from_position_title   IS NOT NULL AND
        p_sf52_record.from_position_number  IS NOT NULL AND
      --  p_sf52_record.from_position_seq_no  IS NOT NULL AND
        p_sf52_record.from_pay_plan         IS NOT NULL AND
        p_sf52_record.from_grade_or_level   IS NOT NULL AND
        p_sf52_record.from_step_or_rate     IS NOT NULL AND
        p_sf52_record.from_pay_basis        IS NOT NULL AND
        p_sf52_record.from_basic_pay        IS NOT NULL AND
        p_sf52_record.from_adj_basic_pay    IS NOT NULL AND
        p_sf52_record.from_locality_adj     IS NOT NULL AND
        p_sf52_record.from_total_salary     IS NOT NULL AND
        p_sf52_record.to_position_id        IS NOT NULL AND
        p_sf52_record.to_position_title     IS NOT NULL AND
        p_sf52_record.to_position_number    IS NOT NULL AND
    --    p_sf52_record.to_position_seq_no    IS NOT NULL AND
        p_sf52_record.to_pay_plan           IS NOT NULL AND
        p_sf52_record.to_grade_or_level     IS NOT NULL AND
        p_sf52_record.to_step_or_rate       IS NOT NULL AND
        p_sf52_record.to_pay_basis          IS NOT NULL AND
        p_sf52_record.to_basic_pay          IS NOT NULL AND
        p_sf52_record.to_adj_basic_pay      IS NOT NULL AND
        p_sf52_record.to_locality_adj       IS NOT NULL AND
        p_sf52_record.to_total_salary       IS NOT NULL THEN
            hr_utility.set_location('Leaving: '||l_proc,10);
            -- Added the following code as there are some 2 category corr. to Other Pay
            -- actions where all the above fields are not null. but, still the record belongs
            -- to 2nd category if the correction is dummy correction. In this case,
            -- to_au_overtime/to_availability pay is null.
            FOR noa_fam_rec  IN c_noa_fam_code(p_sf52_record.second_noa_id)
            LOOP
                hr_utility.set_location(' OTHER PAY Family Code = '||noa_fam_rec.family_code,15);
                IF  noa_fam_rec.family_code IN ('OTHER_PAY') THEN
                    l_found := 'TRUE';
                    EXIT;
                END IF;
            END LOOP;
            IF l_found = 'TRUE' THEN
                IF (p_sf52_record.second_noa_code = '818' AND p_sf52_record.to_au_overtime IS NULL) OR
                   (p_sf52_record.second_noa_code = '819' AND p_sf52_record.to_availability_pay IS NULL) THEN
                   Return 2;
                ELSE
                   Return 3;
                END IF;
            ELSE
                Return 3;
            END IF;

        ELSIF
        p_sf52_record.from_position_id      IS NOT NULL AND
        p_sf52_record.from_position_title   IS NOT NULL AND
        p_sf52_record.from_position_number  IS NOT NULL AND
      --  p_sf52_record.from_position_seq_no  IS NOT NULL AND
        p_sf52_record.from_pay_plan         IS NOT NULL AND
        p_sf52_record.from_grade_or_level   IS NOT NULL AND
        p_sf52_record.from_step_or_rate     IS NOT NULL AND
        p_sf52_record.from_pay_basis        IS NOT NULL AND
        p_sf52_record.from_basic_pay        IS NOT NULL AND
        p_sf52_record.from_adj_basic_pay    IS NOT NULL AND
        p_sf52_record.from_locality_adj     IS NOT NULL AND
        p_sf52_record.from_total_salary     IS NOT NULL THEN
            -- For correction to Separation actions also, from side data is
            -- NOT NULL and TO SIDE DATA IS NULL. So, in such case, return
            -- value should be 3.
            IF  p_sf52_record.to_position_id        IS NULL AND
                p_sf52_record.to_position_title     IS NULL AND
                p_sf52_record.to_position_number    IS NULL AND
              --  p_sf52_record.to_position_seq_no    IS NULL AND
                p_sf52_record.to_pay_plan           IS NULL AND
                p_sf52_record.to_grade_or_level     IS NULL AND
                p_sf52_record.to_step_or_rate       IS NULL AND
                p_sf52_record.to_pay_basis          IS NULL AND
                p_sf52_record.to_basic_pay          IS NULL AND
                p_sf52_record.to_adj_basic_pay      IS NULL AND
                p_sf52_record.to_locality_adj       IS NULL AND
                p_sf52_record.to_total_salary       IS NULL THEN
                FOR noa_fam_rec  IN c_noa_fam_code(p_sf52_record.second_noa_id)
                LOOP
                    hr_utility.set_location(' SEP Family Code = '||noa_fam_rec.family_code,15);
                    IF  noa_fam_rec.family_code IN ('SEPARATION','NON_PAY_DUTY_STATUS',
		                                    'AWARD','GHR_INCENTIVE') THEN
                        l_found := 'TRUE';
                        EXIT;
                    END IF;
                END LOOP;
                IF l_found = 'TRUE' THEN
                    hr_utility.set_location('Leaving: '||l_proc,20);
                    Return 3;
                ELSE
                    hr_utility.set_location('Leaving: '||l_proc,30);
                    Return 2;
                END IF;
            ELSE
                hr_utility.set_location('Leaving: '||l_proc,40);
                Return 2;
            END IF;
        ELSE
            -- For correction to Appointment actions also, from side data is
            -- NULL and TO SIDE DATA IS NOT NULL. So, in such case, return
            -- value should be 3.
	        IF  p_sf52_record.from_position_id      IS NULL AND
                p_sf52_record.from_position_title   IS NULL AND
                p_sf52_record.from_position_number  IS NULL AND
             --   p_sf52_record.from_position_seq_no  IS NULL AND
                p_sf52_record.from_pay_plan         IS NULL AND
                p_sf52_record.from_grade_or_level   IS NULL AND
                p_sf52_record.from_step_or_rate     IS NULL AND
                p_sf52_record.from_pay_basis        IS NULL AND
                p_sf52_record.from_basic_pay        IS NULL AND
                p_sf52_record.from_adj_basic_pay    IS NULL AND
                p_sf52_record.from_locality_adj     IS NULL AND
                p_sf52_record.from_total_salary     IS NULL AND
                p_sf52_record.to_position_id        IS NOT NULL AND
                p_sf52_record.to_position_title     IS NOT NULL AND
                p_sf52_record.to_position_number    IS NOT NULL AND
              --  p_sf52_record.to_position_seq_no    IS NOT NULL AND
                p_sf52_record.to_pay_plan           IS NOT NULL AND
                p_sf52_record.to_grade_or_level     IS NOT NULL AND
                p_sf52_record.to_step_or_rate       IS NOT NULL AND
                p_sf52_record.to_pay_basis          IS NOT NULL AND
                p_sf52_record.to_basic_pay          IS NOT NULL AND
                p_sf52_record.to_adj_basic_pay      IS NOT NULL AND
                p_sf52_record.to_locality_adj       IS NOT NULL AND
                p_sf52_record.to_total_salary       IS NOT NULL THEN
                    hr_utility.set_location('Leaving: '||l_proc,40);
                    Return 3;
             ELSE
                hr_utility.set_location('Leaving: '||l_proc,50);
                Return 1;
            END IF;
        END IF;
    END get_record_category;

BEGIN
    -- Get the CORRECTION RPA record from ghr_pa_requests table.
    SELECT *
    INTO l_sf52_data
    FROM ghr_pa_requests
    WHERE pa_request_id = p_pa_request_id;
    -- Check the record's category..
    -- If record belongs to category 1 or 2 then call build_corrected_sf52 with NPA parameter.
    -- BUG#3958914 Added the OR Conidtions
    IF (get_record_category(l_sf52_data) IN (1,2) OR
         ( l_sf52_data.appropriation_code1 IS NULL OR l_sf52_data.appropriation_code2 IS NULL      OR
           l_sf52_data.annuitant_indicator is NULL OR l_sf52_data.fegli is NULL                    OR
           l_sf52_data.retirement_plan is NULL     OR l_sf52_data.service_comp_date IS NULL OR
           l_sf52_data.tenure IS NULL              OR l_sf52_data.veterans_preference IS NULL      OR
           l_sf52_data.veterans_pref_for_rif IS NULL
	 )
       )THEN
        l_session_var.pa_request_id   := l_sf52_data.pa_request_id;
        l_session_var.noa_id          := l_sf52_data.second_noa_id;
        -- No triggers should be fired as cancellation can not be corrected or cancelled
        -- so none of the changes will be saved.
        l_session_var.fire_trigger    := 'N';
        l_session_var.date_Effective  := l_sf52_data.effective_date;
        l_session_var.person_id               := l_sf52_data.person_id;
        l_session_var.program_name    := 'GHRSF50';
        l_session_var.assignment_id   := l_sf52_data.employee_assignment_id;
        l_session_var.altered_pa_request_id   := l_sf52_data.altered_pa_request_id;
        l_session_var.noa_id_correct  := l_sf52_data.second_noa_id;
        ghr_history_api.set_g_session_var(l_session_var);
      ---Bug 5220727
        IF (l_sf52_data.second_noa_code <> '825' AND
           NOT(l_sf52_data.rpa_type='DUAL' and l_sf52_data.second_noa_code like '3%')) then --Bug# 8299172
	build_corrected_sf52(p_pa_request_id, p_noa_code_correct, sf52_corr_rec,'NPA');
        ELSE
        sf52_corr_rec := l_sf52_data;
        END IF;
    ELSE
      hr_utility.set_location('assinging the original record',20);
      sf52_corr_rec := l_sf52_data;
    END IF;
end populate_corrected_sf52;

Function  get_date_column(p_value in varchar2) return date is
  p_rows   integer;
  l_cursor integer;
begin
  l_cursor := dbms_sql.open_cursor;
  dbms_sql.parse(l_cursor,
     'begin ' ||
     '  ghr_corr_canc_sf52.l_date_result := ghr_corr_canc_sf52.sf52_corr_rec.' || p_value || '; ' ||
     'end;', dbms_sql.v7);
  p_rows := dbms_sql.execute(l_cursor);
  dbms_sql.close_cursor(l_cursor);
  return l_date_result;
end get_date_column;

Function  get_number_column(p_value in varchar2) return number is
  p_rows   integer;
  l_cursor integer;
begin
  l_cursor := dbms_sql.open_cursor;
  dbms_sql.parse(l_cursor,
     'begin ' ||
     '  ghr_corr_canc_sf52.l_number_result := ghr_corr_canc_sf52.sf52_corr_rec.' || p_value || '; ' ||
     'end;', dbms_sql.v7);
  p_rows := dbms_sql.execute(l_cursor);
  dbms_sql.close_cursor(l_cursor);
  return l_number_result;
end get_number_column;

Function  get_varchar2_column(p_value in varchar2) return varchar2 is
  p_rows   integer;
  l_cursor integer;
begin
  l_cursor := dbms_sql.open_cursor;
  dbms_sql.parse(l_cursor,
     'begin ' ||
     '  ghr_corr_canc_sf52.l_varchar2_result := ghr_corr_canc_sf52.sf52_corr_rec.' || p_value || '; ' ||
     'end;', dbms_sql.v7);
  p_rows := dbms_sql.execute(l_cursor);
  dbms_sql.close_cursor(l_cursor);
  return l_varchar2_result;
end get_varchar2_column;


-- Procedure IF_ZAP_ELE_ENT
-- Description : This procedure will be called from Cancel_Other_Family
-- when we know that there does not exist a pre-record (by looking into history)
-- for element_entry table and it needs to figure out if it can zap the element entry or not
-- Logic : If element entry type is Non-recurring then it can be zapped
--         But re-curring elements can be zapped only if there are no following records in history table
--         for element entry values  ie only one transaction touched element entry and element entry values
--
Procedure IF_ZAP_ELE_ENT(
		p_element_entry_id	in	number,
		p_effective_start_date	in	date,
		p_pa_history_id		in	number,
		p_result	 out nocopy Boolean) is

	cursor c_get_ele_ent
		(cp_element_entry_id		in number,
		 cp_effective_start_date	in date) is
	select
		pet.effective_start_date,
		pet.effective_end_date,
		pet.processing_type
	from
		pay_element_types_f pet, pay_element_links_f pel, pay_element_entries_f pee
	where pee.element_entry_id 	= cp_element_entry_id and
		pee.element_link_id	= pel.element_link_id and
		pet.element_type_id	= pel.element_type_id and
		cp_effective_start_date between pee.effective_start_date and pee.effective_end_date and
		cp_effective_start_date between pet.effective_start_date and pet.effective_end_date and
		cp_effective_start_date between pel.effective_start_date and pel.effective_end_date ;

/*	cursor get_root_min_hist_id (cp_pa_history_id	in	number) is
	select min(pa_history_id)
	from ghr_pa_history
	where pa_request_id = (select min(pa_request_id)
					from ghr_pa_requests
					start with pa_request_id = (select pa_request_id -- Bug# 1253981
										from ghr_pa_history
										where pa_history_id = cp_pa_history_id)
					connect by  prior altered_pa_request_id  =  pa_request_id)
--					connect by pa_request_id = altered_pa_request_id)
		and nature_of_action_id = (select nature_of_action_id
							from ghr_pa_history
							where pa_history_id = cp_pa_history_id); */

	-- Bug 3694358
	-- In the cursor get_root_min_hist_id, start with - connect by is removed as it always returns the original
	-- action as the min. and no need to loop through all the correction actions and find the min pa_request_id
/*Bug 6868486 below cursor changed*/
	cursor get_root_min_hist_id (cp_pa_history_id	in	number) is
	select min(pa_history_id)
	from ghr_pa_history
	where pa_request_id = (select pa_request_id -- Bug# 1253981
				from ghr_pa_history
				where pa_history_id = cp_pa_history_id);

	-- Bug 3694358
	-- Changed connect by pa_request_id = altered_pa_request_id
	-- to connect by altered_pa_request_id = pa_request_id
	-- This cursor will fetch element entr value records, for a given element entry, that
	-- were created after the c_root_hist_id
      Cursor c_history(
			c_information1	varchar2,
			c_effective_date	date,
			c_root_hist_id	number) is
		Select   pa_history_id
		from     ghr_pa_history  pah
		where    table_name 	      = ghr_history_api.g_eleevl_table
		and      information5 	      = c_information1
		and      (effective_date      > c_effective_date   or
			   (effective_date      = c_effective_date  and
			    c_root_hist_id      <
						(select min(pa_history_id)
						from ghr_pa_history
						where pa_request_id =
						(select 	min(pa_request_id)
						from 		ghr_pa_requests
						connect by 	prior altered_pa_request_id 	=  pa_request_id
						start with 	pa_request_id 		= 	pah.pa_request_id))));

	l_ele			c_get_ele_ent%rowtype;
	l_root_hist_id	number;
	l_dummy		number;
	l_ret_val		Boolean:=FALSE;
	l_proc		varchar2(30):='IF_ZAP_ELE_ENT';
Begin

	hr_utility.set_location('Entering : ' || l_proc, 5);
	-- Find Element Type
	open c_get_ele_ent(
		p_element_entry_id,
		p_effective_start_date);
	fetch c_get_ele_ent into l_ele;
	if c_get_ele_ent%notfound then
		close c_get_ele_ent;
		-- This case must not happen.
		-- Not raising error. As it must be handled in calling routine
		hr_utility.set_location(' Could not find Element Type. Must not happen !!' || l_proc, 10);
		l_ret_val := FALSE;
	else
		if l_ele.processing_type = 'N' then
			-- Non-recurring elemnt can be zapped.
			close c_get_ele_ent;
			l_ret_val := TRUE;
			hr_utility.set_location('Non recurring CAN ZAP' || l_proc, 20);
		else
			-- For recurring
			close c_get_ele_ent;
			open get_root_min_hist_id (p_pa_history_id);
			fetch get_root_min_hist_id into l_root_hist_id;
			if get_root_min_hist_id%notfound then
				close get_root_min_hist_id;
				hr_utility.set_location(' Root Hist ID Not found!! Must not happen'  || l_proc, 30);
				l_ret_val := FALSE;
			else
				close get_root_min_hist_id;
				hr_utility.set_location(' Fetching successor,if any, from history'  || l_proc, 40);
				open c_history(
					c_information1	=> p_element_entry_id,
					c_effective_date	=> p_effective_start_date,
					c_root_hist_id	=> l_root_hist_id);
				fetch c_history into l_dummy;
				l_ret_val := c_history%notfound;
			end if;
		end if;
	end if;
	p_result := l_ret_val;
	hr_utility.set_location(' Leaving : '  || l_proc, 100);
   Exception when others then
             --
             -- Reset IN OUT parameters and set OUT parameters
             --
             p_result := null;
             raise;

End IF_ZAP_ELE_ENT;

-- VSM
Procedure Cancel_Routine (p_sf52_data in out nocopy ghr_pa_requests%rowtype) is

	l_proc			varchar2(30):='cancel_routine';
   l_sf52_data_rec ghr_pa_requests%rowtype;

	--

	-- This cursor would fetch active chain of subsequent corrections.
	cursor c_get_subs_corr (c_pa_request_id	in number,
					c_noa_id		in number) is
	select
		 pa_request_id
		,object_version_number
		,status
		,rowid row_id
	from ghr_pa_requests
	where (level = 1 or ( level > 1 								and
		nvl(second_noa_cancel_or_correct, '@#$') <> ghr_history_api.g_cancel))	and
		first_noa_code <> '001'									and
		nvl(status, '@!#') <> 'CANCELED'
	start with pa_request_id = c_pa_request_id
	connect by  prior pa_request_id	= altered_pa_request_id and
			prior c_noa_id 		= second_noa_id;


	TYPE array_pa_req is table of pa_req_info index by binary_integer;
	l_subsequent_pa_req	array_pa_req;
	l_count			number:=0;
	l_rev_count			number;
	l_noa_id			ghr_pa_requests.first_noa_id%type;
	l_sf52_canc			ghr_pa_requests%rowtype;
	l_sf52			ghr_pa_requests%rowtype;
	l_canc_pa_request_id	ghr_pa_requests.pa_request_id%type;
	l_username			varchar2(30):=fnd_global.user_name;
	l_null_sf52			ghr_pa_requests%rowtype;
	l_ovn				number;
	l_which_noa			number;
	--
Begin
	hr_utility.set_location( 'Entering : ' || l_proc, 10);
	hr_utility.set_location( 'PA_Request_id : ' || p_sf52_data.pa_request_id || '   ' || l_proc, 15);
   l_sf52_data_rec := p_sf52_data;

	-- Fetch Original SF50 being cancelled
	for v_get_sf52 in c_get_sf52 ( p_sf52_data.altered_pa_request_id)
	loop
		l_sf52 := v_get_sf52;
		exit;
	end loop;

	--
	--

	l_noa_id := p_sf52_data.second_noa_id;

	-- >> Build array of subsequent corrections;
	for v_pa_req in c_get_subs_corr ( p_sf52_data.altered_pa_request_id, p_sf52_data.second_noa_id)
	loop
		hr_utility.set_location( 'Sub Pa_request_id  : ' || v_pa_req.pa_request_id || '   ' || l_proc, 20);
		l_count := l_count + 1;
		l_subsequent_pa_req(l_count).pa_request_id		:= v_pa_req.pa_request_id;
		l_subsequent_pa_req(l_count).object_version_number	:= v_pa_req.object_version_number;
		l_subsequent_pa_req(l_count).status				:= v_pa_req.status;
		l_subsequent_pa_req(l_count).row_id				:= v_pa_req.row_id;
                l_subsequent_pa_req(l_count).cancel_legal_authority     := p_sf52_data.first_action_la_code1;
	end loop;

	l_rev_count := l_count;

	if l_count = 0 then
		hr_utility.set_location('Subsequent SF52 Tree is blank. Error !!!! ' || l_proc, 40);
	      hr_utility.set_message(8301 , 'GHR_99999_CANC_SF52_NOT_FOUND');
	      hr_utility.raise_error;
	end if;


	hr_utility.set_location(' Start Process Subsequent SF52 ' || l_proc , 60);
	while l_rev_count > 0
	loop
		l_sf52_canc := l_null_sf52;
		if l_rev_count = 1 then
			-- original SF52;
			hr_utility.set_location('Processing Original SF52 ' || l_proc , 70);
			l_sf52_canc := p_sf52_data;
			-- Cancel SF52
			Process_Cancel( p_sf52_Data => l_sf52_canc);
		elsif nvl(l_subsequent_pa_req(l_rev_count).status, 'CANCELED') = 'CANCELED' then
			-- No Action required
			hr_utility.set_location('No Action Req. for SF52 :  ' ||
				l_subsequent_pa_req(l_rev_count).pa_request_id || '  ' || l_proc , 80);
		elsif nvl(l_subsequent_pa_req(l_rev_count).status, 'CANCELED') <> 'UPDATE_HR_COMPLETE' then
			-- SF52 has not been processed
			-- Soft Cancel this SF52
			-- No need to re-fetch object_version_number. As this must be last SF52 in the chain and
			-- OVN must not change since last fetch
			hr_utility.set_location('Soft Cancelling SF52 :  ' ||
				l_subsequent_pa_req(l_rev_count).pa_request_id || '  ' || l_proc , 90);
			ghr_sf52_api.end_sf52(
				 p_pa_request_id			=> l_sf52.pa_request_id
				,p_user_name			=> l_username
				,p_par_object_version_number	=> l_subsequent_pa_req(l_rev_count).object_version_number
				,p_action_taken			=> 'CANCELED'
			);
		else
			-- Call Cancel_correction
			hr_utility.set_location('Calling Cancel_subs_correction for SF52 :  ' ||
				l_subsequent_pa_req(l_rev_count).pa_request_id || '  ' || l_proc , 100);
			if l_sf52_canc.first_noa_code = p_sf52_data.second_noa_code then
				hr_utility.set_location('Ist NOA CODE '|| l_proc , 105);
				l_which_noa := 1;
			else
				hr_utility.set_location('2nd NOA CODE '|| l_proc , 105);
				l_which_noa := 2;
			end if;

			Cancel_subs_correction (
				p_corr_sf52_detail => l_subsequent_pa_req(l_rev_count),
				p_which_noa        => l_which_noa);
			ghr_api.g_api_dml	:= TRUE; --bug# 5389132
		end if;
		l_rev_count := l_rev_count - 1;
	end loop;

	hr_utility.set_location('Fetching original SF52 ' || l_proc , 110);

	-- Set column values in the SF50 being Cancelled;
	-- copy first/second_noa_canc_pa_request_id to first/second_noa_pa_request_id
	-- set first/second_noa_canel_correct_flag = 'ghr_history_api.g_cancel

	l_sf52.object_version_number := get_sf52_ovn ( p_pa_request_id => l_sf52.pa_request_id);

	if l_sf52.first_noa_code = p_sf52_data.second_noa_code then
		if l_sf52.first_noa_canc_pa_request_id is not null then
			hr_utility.set_location('Reset First_noa_canel_or_correct ' || l_proc , 120);
			ghr_par_upd.upd(
				 p_pa_request_id				=> l_sf52.pa_request_id
				,p_object_version_number		=> l_sf52.object_version_number
				,p_first_noa_pa_request_id		=> l_sf52.first_noa_canc_pa_request_id
				,p_first_noa_cancel_or_correct	=> ghr_history_api.g_cancel
			);

		end if;
	else
		if l_sf52.second_noa_canc_pa_request_id is not null then
			hr_utility.set_location('Reset Second_noa_canel_or_correct ' || l_proc , 120);
			ghr_par_upd.upd(
				 p_pa_request_id				=> l_sf52.pa_request_id
				,p_object_version_number		=> l_sf52.object_version_number
				,p_second_noa_pa_request_id		=> l_sf52.second_noa_canc_pa_request_id
				,p_second_noa_cancel_or_correct	=> ghr_history_api.g_cancel
			);
		end if;
	end if;

	hr_utility.set_location(' Leaving ' || l_proc , 200);
   Exception when others then
             --
             -- Reset IN OUT parameters and set OUT parameters
             --
             p_sf52_data := l_sf52_data_rec;
             raise;


End Cancel_routine;

Procedure Process_Cancel (
		p_sf52_data in out nocopy ghr_pa_requests%rowtype) is

	l_noa_family_code		varchar2(30);
	l_proc			varchar2(30):='Process_Cancel';
	l_prev_sf52_data		ghr_pa_requests%rowtype;
	l_sf52_data		      ghr_pa_requests%rowtype;

      l_posn_eff_start_date   date;
      l_posn_eff_end_date     date;
      l_prior_posn_ovn        number;


	-- Cursor to fetch noa_codes for given pa_request_id
	cursor c_sf52 (c_pa_request_id in number) is
	select
		*
	from ghr_pa_requests
	where pa_request_id = c_pa_request_id;

	-- cursor to fetch noa_family_code for the given noa_id.
	cursor c_fam (c_noa_id in number) is
	select
		fams.noa_family_code
	from  ghr_noa_families noafam,
		ghr_families     fams
	where noafam.nature_of_action_id = c_noa_id               and
		noafam.enabled_flag        = 'Y'                    and
		fams.noa_family_code 	   = noafam.noa_family_code and
		fams.enabled_flag          = 'Y'                    and
		fams.update_hr_flag = 'Y';

	-- Start of Bug# 5195518

	Cursor get_fehb_life_events(p_person_id in number,
	                           p_business_group_id in number,
				   p_effective_date in date)
	    is
	    select  per_in_ler_id, ptnl_ler_for_per_stat_cd
	    from    ben_per_in_ler pil,
	            ben_ler_f lf,
	            ben_ptnl_ler_for_per ptnl
            where pil.person_id = p_person_id
            and pil.business_group_id = p_business_group_id
            and pil.lf_evt_ocrd_dt = p_effective_date
            and pil.PER_IN_LER_STAT_CD IN ('PROCD','STRTD')
            and lf.ler_id = pil.ler_id
	    and pil.ptnl_ler_for_per_id = ptnl.ptnl_ler_for_per_id
            and name <> 'Unrestricted'
            and p_effective_date between lf.effective_start_date
                                 and lf.effective_end_date;

        Cursor get_tsp_life_events(p_person_id in number,
	                           p_business_group_id in number,
				   p_effective_date in date)
	    is
	    select per_in_ler_id,PER_IN_LER_STAT_CD
	    from ben_per_in_ler pil,ben_ler_f lf
            where pil.person_id = p_person_id
            and pil.business_group_id = p_business_group_id
            and pil.lf_evt_ocrd_dt = p_effective_date
            and PER_IN_LER_STAT_CD IN ('PROCD','STRTD')
            and lf.ler_id = pil.ler_id
            and name = 'Unrestricted'
            and p_effective_date between lf.effective_start_date
                                 and lf.effective_end_date;

	Cursor c_chk_pa_request(p_person_id in number
	                       ,p_effective_date in date)
	    is
	    select 1
	    from   ghr_pa_requests par
	    where  person_id = p_person_id
	    and    effective_date <= p_effective_date
	    and    first_noa_code not in ('100')
	    and    pa_notification_id is not null
	    and    not exists (select 1
	                       from  ghr_pa_requests b
			       where person_id = p_person_id
			       and   altered_pa_request_id = par.pa_request_id
			       and   first_noa_code = '001'
			       and   second_noa_code = par.first_noa_code);


        Cursor    c_bg_id(c_person_id per_all_people_f.person_id%type,
    		          c_effective_date per_all_people_f.effective_start_date%type)
            is
            select   business_group_id bg_id
            from     per_all_people_f
            where    person_id = c_person_id
            and      c_effective_date between effective_start_date
	                              and     effective_end_date;

        Cursor c_get_pgm_id(c_prog_name ben_pgm_f.name%type,
	                    c_business_group_id ben_pgm_f.business_group_id%type,
		            c_effective_date ben_pgm_f.effective_start_date%type)
	    is
	    select pgm.pgm_id
	    from   ben_pgm_f pgm
	    where  pgm.name = c_prog_name
	    and    pgm.business_group_id  = c_business_group_id
	    and    c_effective_date between effective_start_date and effective_end_date;

        Cursor c_get_enrt_rslt(p_person_id      per_all_people_f.person_id%type,
	                       p_pgm_id         ben_pgm_f.pgm_id%type,
			       p_per_in_ler_id  ben_per_in_ler.per_in_ler_id%type,
			       p_effective_date date)
            is
            select prtt_enrt_rslt_id,
	           object_version_number,
		   effective_start_date,
		   enrt_cvg_thru_dt
   	    from   ben_prtt_enrt_rslt_f
	    where  person_id = p_person_id
	    and    pgm_id    = p_pgm_id
	    and    per_in_ler_id = p_per_in_ler_id
	    and    p_effective_date between effective_start_date and effective_end_date
	    and    enrt_cvg_strt_dt >= p_effective_date;




        l_bg_id number;
	l_effective_start_date date;
	l_effective_end_date   date;
	l_object_version_number number;
	l_pgm_id  number;
	l_deenrtsp boolean;
	l_datetrack_mode  varchar2(30);
     	--End of Bug# 5195518
 Begin

	-- Cancellation
	hr_utility.set_location( 'Entering ' || l_proc, 10);
   l_sf52_data := p_sf52_data;
	-- get first_noa_code and second_noa_code for the pa_request that this cancellation is being
	-- applied to.
	open c_sf52( p_sf52_data.altered_pa_request_id);
	fetch c_sf52 into l_prev_sf52_data;
	if not c_sf52%found then
		close c_sf52;
		-- original SF52 not found
		hr_utility.set_location(' Parent of pa_request_id : ' ||
					p_sf52_data.pa_request_id || ' Not Found. !! ERROR !! ' || l_proc , 20);
	      hr_utility.set_message(8301 , 'GHR_38221_CORR_SF50_NOT_FOUND');
		ghr_api.g_api_dml	:= FALSE;
	      hr_utility.raise_error;
		-- raise error
	else
		hr_utility.set_location( l_proc, 30);
		if l_prev_sf52_data.first_noa_code = '002' then
			-- Cancellation of the correction
			hr_utility.set_location( l_proc, 40);
			ghr_corr_canc_sf52.Cancel_Correction_SF52( p_sf52_data);
		else
                 -------------------------------------------------
                 -- JH Bug 2983738 Position Hiring Status Changes Generic to All Cancellations.
                 -------------------------------------------------
                 --l_posn_eff_start_date date;
                 --l_posn_eff_end_date date;
                 --l_prior_posn_ovn            number;

                 hr_utility.set_location('JH Hiring Status Start'|| l_proc,45);
                 hr_utility.set_location('First NOA code = '||l_sf52_data.first_noa_code || l_proc,45);

                 IF l_sf52_data.first_noa_code = '001' THEN
                    hr_utility.set_location('From Posn ID = '||to_char(l_sf52_data.from_position_id)|| l_proc,45);
                    hr_utility.set_location('Effective Date = '||l_sf52_data.effective_date|| l_proc,45);
                    -- Tests for Position in Non-Active status ON the effective Date.
                    posn_not_active(p_position_id         => l_sf52_data.from_position_id
                                   ,p_effective_date      => l_sf52_data.effective_date
                                   ,p_posn_eff_start_date => l_posn_eff_start_date
                                   ,p_posn_eff_end_date   => l_posn_eff_end_date
                                   ,p_prior_posn_ovn      => l_prior_posn_ovn);

                    IF l_posn_eff_start_date IS NULL THEN
                       -- Test if user manually set position to non-active day AFTER the effective date.
                       posn_not_active(p_position_id         => l_sf52_data.from_position_id
                                      ,p_effective_date      => l_sf52_data.effective_date+1
                                      ,p_posn_eff_start_date => l_posn_eff_start_date
                                      ,p_posn_eff_end_date   => l_posn_eff_end_date
                                      ,p_prior_posn_ovn      => l_prior_posn_ovn);
                    END IF;

                    hr_utility.set_location('Hiring Status Start/End : '||l_posn_eff_start_date||'/'||l_posn_eff_end_date,45);

                    IF l_posn_eff_start_date IS NOT NULL THEN
                      hr_utility.set_location('Hiring Status - Calling Delete API',45);
                      hr_position_api.delete_position(p_validate              => FALSE
                                                     ,p_position_id           => to_number(l_sf52_data.from_position_id)
                                                     ,p_effective_date        => l_posn_eff_start_date-1
                                                     ,p_effective_start_date  => l_posn_eff_start_date
                                                     ,p_effective_end_date    => l_posn_eff_end_date
                                                     ,p_object_version_number => l_prior_posn_ovn
                                                     ,p_datetrack_mode        => 'DELETE_NEXT_CHANGE');
                    END IF;
                    hr_utility.set_location('Hiring Status - Exiting',45);
                  END IF; -- Cancellations Bug 2983738



			hr_utility.set_location( l_proc, 50);
			open c_fam( p_sf52_data.second_noa_id);
			fetch c_fam into
				l_noa_family_code;
			if c_fam%notfound then
				-- error
				close c_fam;
			      hr_utility.set_message(8301,'GHR_38211_NOA_FAMILY_NOTFOUND');
			      hr_utility.raise_error;
			else
				close c_fam;
			end if;
			 -- Bug # 5195518
			 IF l_noa_family_code in ('APP','CONV_APP','SEPARATION') THEN
                	   FOR l_cur_bg_id IN c_bg_id(p_sf52_data.person_id, p_sf52_data.effective_date)
			   LOOP
			       l_bg_id := l_cur_bg_id.bg_id;
                 	   END LOOP;
        		   IF ghr_utility.is_ghr_ben_fehb = 'TRUE' THEN
			      For rec_le in get_fehb_life_events(p_person_id => p_sf52_data.person_id,
                        	                                p_business_group_id => l_bg_id,
                             				        p_effective_date => p_sf52_data.effective_date)
			      loop

			        ben_back_out_life_event.back_out_life_events
                                             (p_per_in_ler_id     => rec_le.per_in_ler_id,
                                              p_business_group_id => l_bg_id,
                                              p_bckt_stat_cd      => rec_le.ptnl_ler_for_per_stat_cd,
                                              p_copy_only         => 'N' ,
                                              p_effective_date    => p_sf52_data.effective_date);
                               end loop;
			    END IF;
			  END IF;
			  --Checking whether it is reappointment after separation
			  -- it should not be deenrolled for reappointment.
			/*  For rec_pa_req in c_chk_pa_request(p_person_id => p_sf52_data.person_id
                                                            ,p_effective_date => p_sf52_data.effective_date)
			  loop
			     l_deenrtsp := TRUE;
			  end loop;

 		          IF l_deenrtsp then
              		    l_datetrack_mode := hr_api.g_delete_next_change;
           		  ELSE
              		    l_datetrack_mode :=  hr_api.g_zap;
             		  END IF;      */


			  hr_utility.set_location('p_sf52_data.effective_date'||p_sf52_data.effective_date,1000);
			  IF l_noa_family_code in ('APP','CONV_APP') THEN
			    IF ghr_utility.is_ghr_ben_tsp = 'TRUE' THEN
			      For rec_le in get_tsp_life_events(p_person_id => p_sf52_data.person_id,
                        	                                p_business_group_id => l_bg_id,
                             				        p_effective_date => p_sf52_data.effective_date)
			      loop

			         for pgm_rec in c_get_pgm_id('Federal Thrift Savings Plan (TSP)', l_bg_id, p_sf52_data.effective_date)
				 loop
				     l_pgm_id := pgm_rec.pgm_id;
          			     exit;
                                 end loop;


				 for enrt_rec in c_get_enrt_rslt(p_person_id      => p_sf52_data.person_id,
                                      	                         p_pgm_id         => l_pgm_id,
                                       			         p_per_in_ler_id  => rec_le.per_in_ler_id,
                                			         p_effective_date => p_sf52_data.effective_date)
                                 loop
				   IF  enrt_rec.effective_start_date = p_sf52_data.effective_date THEN

				       l_object_version_number := enrt_rec.object_version_number;
   			               ben_prtt_enrt_result_api.delete_enrollment
						 (p_validate              => false
						 ,p_per_in_ler_id         => rec_le.per_in_ler_id
						 ,p_prtt_enrt_rslt_id     => enrt_rec.prtt_enrt_rslt_id
						 ,p_business_group_id     => l_bg_id
						 ,p_effective_start_date  => l_effective_start_date
						 ,p_effective_end_date    => l_effective_end_date
						 ,p_object_version_number => l_object_version_number
						 ,p_effective_date        => enrt_rec.effective_start_date
						 ,p_datetrack_mode        => hr_api.g_zap
						 ,p_enrt_cvg_thru_dt      => enrt_rec.enrt_cvg_thru_dt
						 ,p_multi_row_validate    => FALSE);
			             END IF;
                                  end loop;
			       end loop;
			     END IF;
			 END IF;
			 -- End of Bug # 5195518
				if l_noa_family_code = 'APP' then
				-- must be checked for the appt. family
				-- Cancellation of an appointment
				hr_utility.set_location( l_proc, 60);
				ghr_corr_canc_sf52.Cancel_Appt_SF52( p_sf52_data);
				null;
			elsif l_noa_family_code = 'SEPARATION' then
				-- cancellation of termination
				hr_utility.set_location( l_proc, 70);
				ghr_corr_canc_sf52.cancel_term_sf52( p_sf52_data);
		--	elsif l_noa_code like '9%' then
		--		-- user defined families not supported by update to database
		--		-- should generate a message and raise_error here.
		--		hr_utility.set_location( l_proc, 80);
		--		NULL;
		-- user defined NOA would be treated as any other family in cancel_other_family_sf52
		-- if these don't belong to special families (APP/SEPARATION)
			else
				hr_utility.set_location( l_proc, 90);
				ghr_corr_canc_sf52.Cancel_Other_Family_Sf52( p_sf52_data);
			end if;




		end if;
	end if;
		close c_sf52;
   Exception when others then
             --
             -- Reset IN OUT parameters and set OUT parameters
             --
             p_sf52_data := l_sf52_data;
             raise;
End Process_Cancel;

Procedure Cancel_subs_correction (
		p_corr_sf52_detail in out nocopy pa_req_info,
		p_which_noa        in number) is

	l_proc			varchar2(30):='Cancel_subs_correction';
	l_ovn				number;
	l_canc_pa_request_id	number;
	l_noa_id			number;
	l_username			varchar2(30);
	l_dummy_number		number;
	l_sf52_canc			ghr_pa_requests%rowtype;
   l_corr_sf52_detail pa_req_info;

cursor c_get_asg_id is
          select employee_assignment_id
            from ghr_pa_requests
            where pa_request_id in
          ( select altered_pa_request_id from
             ghr_pa_requests where
             pa_request_id =  p_corr_sf52_detail.pa_request_id);
        l_asg_id            per_assignments_f.assignment_id%type;


Begin

	-- create cancellation;
	hr_utility.set_location(' Call ghr_cancel_sf52 ' || p_corr_sf52_detail.pa_request_id ||
				l_proc , 80);
   l_corr_sf52_detail := p_corr_sf52_detail;
 -- Start Bug  2542417
        -- Fetching employee_assignment_id to pass in ghr_sf52_api.update_sf52
        -- In the Cancellation of Subsequent corrections assignment id is
        -- missing in call to get_cop in ghr_sf52_api.update_sf52
        -- This passing of l_asg_id in the call below fixes the issue
        for c_get_asg_rec in c_get_asg_id LOOP
          l_asg_id := c_get_asg_rec.employee_assignment_id;
          exit;
        END LOOP;
        hr_utility.set_location(' l_asg_id is ' || l_asg_id || '   ' || l_proc , 90);
 -- End Bug  2542417


--	l_username			:= fnd_global.user_name;
	l_username			:= fnd_profile.value('USERNAME');
    -- Bug#5260624 If the profile value returns NULL, get it from fnd_global.
	IF l_username is NULL THEN
		l_username			:= fnd_global.user_name;
    END IF;

	l_ovn := NULL;

	for v_get_sf52 in c_get_sf52 ( p_corr_sf52_detail.pa_request_id)
	loop
		l_ovn    := v_get_sf52.object_version_number;
		l_noa_id := v_get_sf52.second_noa_id;
		exit;
	end loop;

	if l_ovn is NULL then
	      hr_utility.set_message(8301 , 'GHR_99999_SF52_NOT_FOUND');
	      hr_utility.raise_error;
	end if;

	hr_utility.set_location(' User name  ' || l_username || '   ' || l_proc , 90);

	l_canc_pa_request_id := ghr_approved_pa_requests.ghr_cancel_sf52(
		 p_pa_request_id			=> p_corr_sf52_detail.pa_request_id
		,p_par_object_version_number	=> l_ovn
		,p_noa_id				=> l_noa_id
		,p_which_noa			=> p_which_noa
		,p_row_id				=> p_corr_sf52_detail.row_id
		,p_username				=> l_username
                ,p_cancel_legal_authority       => p_corr_sf52_detail.cancel_legal_authority);

	-- fetch cancel sf52;
	if nvl(l_canc_pa_request_id, 0 ) = 0 then
		hr_utility.set_location(' Cancellation SF52 not created!! ERROR !! ' || l_proc , 90);
	      hr_utility.set_message(8301 , 'GHR_99999_CREA_CANC_52_FAIL');
	      hr_utility.raise_error;
	end if;
	for v_get_sf52 in c_get_sf52(l_canc_pa_request_id)
	loop
		l_sf52_canc := v_get_sf52;
		exit;
	end loop;
	if l_sf52_canc.pa_request_id is NULL then
		hr_utility.set_location(' Fetch Cancel SF52 failed. ERROR !! ' || l_proc , 100);
	      hr_utility.set_message(8301 , 'GHR_99999_SF52_NOT_FOUND');
	      hr_utility.raise_error;
	end if;

	-- Call update_sf52
	-- This is a recursive call as Process_SF52 is called from ghr_sf52_api.update_sf52
	hr_utility.set_location(' BEGIN Update_SF52 for pa_request_id : ' ||
					l_sf52_canc.pa_request_id || '  ' || l_proc , 110);
        hr_utility.set_location('l_dummy_number '||to_char(l_dummy_number),120);
	hr_utility.set_location('l_OVN '||to_char(l_sf52_canc.object_version_number),130);
	hr_utility.set_location('l_ASG '||to_char(l_asg_id),140);
	ghr_sf52_api.update_sf52(
		 p_pa_request_id			=> l_sf52_canc.pa_request_id
                 ,p_employee_assignment_id       => l_asg_id
		-- OUT parameters
		,p_par_object_version_number	=> l_sf52_canc.object_version_number
		,p_u_prh_object_version_number=> l_dummy_number
		,p_i_pa_routing_history_id	=> l_dummy_number
		,p_i_prh_object_version_number=> l_dummy_number
		,p_u_action_taken			=> 'UPDATE_HR'
		,p_u_approval_status		=> 'APPROVE'
	);

	hr_utility.set_location(' END Update_SF52 for pa_request_id : ' ||
					l_sf52_canc.pa_request_id || '  ' || l_proc , 120);

	-- Nullify Second_noa_pa_request_id from Correction SF52 beinf cancelled
	ghr_par_upd.upd(
		 p_pa_request_id			=> p_corr_sf52_detail.pa_request_id
		,p_object_version_number	=> l_ovn
		,p_second_noa_pa_request_id	=> NULL);

	-- Delete GHR_Routing_History
	delete from ghr_pa_routing_history
	where pa_request_id = l_sf52_canc.pa_request_id;

      -- Delete Pa_request_EI_shadow data
      delete ghr_pa_request_ei_shadow
      where  pa_request_id = l_sf52_canc.pa_request_id;

	-- Delete Cancelation SF50 Shadow row
	hr_utility.set_location(' Deleting Shadow ' || l_sf52_canc.pa_request_id || '  ' || l_proc , 130);
	Delete from ghr_pa_request_shadow
	where pa_request_id = l_sf52_canc.pa_request_id;

      -- Delete Pa_request_EI data
      -- for l_sf52_canc.pa_request_id;
      delete ghr_pa_request_extra_info
      where  pa_request_id = l_sf52_canc.pa_request_id;

	-- Delete pa_reques row
	l_sf52_canc.object_version_number := get_sf52_ovn( l_sf52_canc.pa_request_id);

	hr_utility.set_location(' Deleting Pa Request  ' || l_sf52_canc.pa_request_id || '  ' || l_proc , 140);
	ghr_par_del.del(
		p_pa_request_id 		=> l_sf52_canc.pa_request_id,
		p_object_version_number => l_sf52_canc.object_version_number);

	hr_utility.set_location(' Leaving ' || l_proc , 200);
  Exception when others then
            --
            -- Reset IN OUT parameters and set OUT parameters
            --
            p_corr_sf52_detail := l_corr_sf52_detail;
            raise;

End Cancel_subs_correction;
-- VSM

-- Bug#2521744 Added the following procedure
-- LOGIC :
-- Check for the element passed to this procedure.
-- If element = 'OTHER PAY' THEN
-- Check whether another other pay action processed on the same effective date;
--      IF processed then
--          fetch the other pay value using history id and element entry id.
--          update the pay_element_entry_values_f table with the correct value.
--       ELSE
--          Delete the rows from pay_element_entry_values_f, pay_element_entries_f tables;
--        END If;
-- ELSIF element IN ('Retention Allowance', 'Supervisory Differential,'AUO','Availability Pay' Then
--    Delete the rows from pay_element_entry_values_f, pay_element_entries_f tables;
-- ELSE
--    Delete the rows from pay_element_entry_values_f, pay_element_entries_f tables with id and effective start date;
-- END If;

Procedure delete_other_pay_entries(p_hist_rec in ghr_pa_history%rowtype,
                                   p_element_name IN VARCHAR2 ) IS

l_history_exists               BOOLEAN := FALSE;
l_hist_rec                     ghr_pa_history%rowtype;
l_future_othpay_effective_date DATE;
l_bus_group_id                 NUMBER;
l_element_name                 VARCHAR2(80);

CURSOR c_history_record IS
SELECT *
FROM  ghr_pa_history
WHERE table_name = 'PAY_ELEMENT_ENTRIES_F'
AND   information1 = p_hist_rec.information1
AND   information2 = p_hist_rec.information2
AND   nvl(pa_request_id,0) <> nvl(p_hist_rec.pa_request_id,0);


-- CURSOR to verify whether any future other pay action is existing or not.
CURSOR c_future_other_pay_exists(p_assignment_id NUMBER,p_effective_date DATE) IS
SELECT min(effective_date) effective_date
FROM ghr_pa_requests
where noa_family_code = 'OTHER_PAY'
and pa_notification_id is not null
and effective_date > p_effective_date
and status = 'UPDATE_HR_COMPLETE'
and employee_assignment_id = p_assignment_id
and NVL(first_noa_cancel_or_correct,'C') <> 'CANCEL';


BEGIN
    hr_utility.set_location('Entering Delete Oth Pay Entr '||p_element_name,0);

    fnd_profile.get('PER_BUSINESS_GROUP_ID',l_bus_group_id);
    l_element_name := pqp_fedhr_uspay_int_utils.return_old_element_name
                      (p_element_name,l_bus_group_id,p_hist_rec.effective_date);
    hr_utility.set_location('l_element_name IS '||l_element_name,10);
    IF l_element_name = 'Other Pay' THEN
        Open c_history_record;
        Fetch c_history_record into l_hist_rec;
        IF c_history_record%NOTFOUND THEN
           l_history_exists := FALSE;
        ELSE
           l_history_exists  := TRUE;
        END IF;
        Close c_history_record;


        IF l_history_exists THEN
            hr_utility.set_location('Same day action',70);
        ELSE
	    -- Check whether any future dated OTHER PAY Actions exists or not
	    FOR future_other_pay IN c_future_other_pay_exists(p_hist_rec.information5,p_hist_rec.effective_date)
	    LOOP
		l_future_othpay_effective_date := future_other_pay.effective_date;
	    END LOOP;
	    -- IF any Future other pay action exists,
	    --   Delete the other pay element from this effective date to the future
	    --   other pay action (effective date - 1).
	    -- Else
	    --   Delete the Other Pay element with this element entry ID.
	    -- End If;
	    IF l_future_othpay_effective_date IS NOT NULL THEN
	            hr_utility.set_location(' Inside Future Other Pay Exists',20);
		    --  DELETE THE RECORD FROM PAY_ELEMENT_ENTRY_VALUES_F;
		    DELETE pay_element_entry_values_f
		    where  element_entry_id = p_hist_rec.information1
		    AND    effective_start_date BETWEEN fnd_date.canonical_to_date(p_hist_rec.information2)
		                                    AND (l_future_othpay_effective_date - 1) ;

	            hr_utility.set_location(' After deleting Other pay element entries',30);
		    --	DELETE THE RECORD FROM PAY_ELEMENT_ENTRIES_F;
		    DELETE PAY_ELEMENT_ENTRIES_F
		    where  element_entry_id = p_hist_rec.information1
		    AND    effective_start_date BETWEEN fnd_date.canonical_to_date(p_hist_rec.information2)
		                                    AND (l_future_othpay_effective_date - 1) ;

		    -- DELETE THE HISTORY RECORDS with the same element entry ID created after the current
		    -- action and prior to the next other pay action.
		    DELETE ghr_pa_history
                    WHERE (information5 = p_hist_rec.information1
                       OR  information1 = p_hist_rec.information1)
                      AND effective_date BETWEEN (fnd_date.canonical_to_date(p_hist_rec.information2) + 1)
		                             AND (l_future_othpay_effective_date - 1);

	    ELSE
		    hr_utility.set_location(' No Future Other Pay Action exists.',40);
		    --	DELETE THE RECORD FROM PAY_ELEMENT_ENTRY_VALUES_F;
		    DELETE pay_element_entry_values_f
		    where  element_entry_id = p_hist_rec.information1;


		    --	DELETE THE RECORD FROM PAY_ELEMENT_ENTRIES_F;
		    DELETE PAY_ELEMENT_ENTRIES_F
		    where  element_entry_id = p_hist_rec.information1;

		    -- DELETE THE HISTORY RECORDS with the same element entry ID created after the
		    -- current other pay action.
		    DELETE ghr_pa_history
                    WHERE (information5 = p_hist_rec.information1 OR  information1 = p_hist_rec.information1)
                      AND effective_date > (fnd_date.canonical_to_date(p_hist_rec.information2) + 1);

	    END IF;
        END IF;
    ELSIF l_element_name IN ('Retention Allowance','Supervisory Differential','AUO',
                             'Availability Pay') THEN
	--	DELETE THE RECORD FROM PAY_ELEMENT_ENTRY_VALUES_F;

        DELETE pay_element_entry_values_f
        where  element_entry_id = p_hist_rec.information1;
        -- AND    effective_start_date = fnd_date.canonical_to_date(p_hist_rec.information2);

        --	DELETE THE RECORD FROM PAY_ELEMENT_ENTRIES_F;

        DELETE PAY_ELEMENT_ENTRIES_F
        where  element_entry_id = p_hist_rec.information1;
        -- AND    effective_start_date = fnd_date.canonical_to_date(p_hist_rec.information2);

        hr_utility.set_location('Leaving delete_other_pay_entries',170);
    ELSE
        hr_utility.set_location('Elements Other than OTHER PAY '||p_element_name,110);

        --	DELETE THE RECORD FROM PAY_ELEMENT_ENTRY_VALUES_F;

        DELETE pay_element_entry_values_f
        where  element_entry_id = p_hist_rec.information1
        AND    effective_start_date = fnd_date.canonical_to_date(p_hist_rec.information2);

        --	DELETE THE RECORD FROM PAY_ELEMENT_ENTRIES_F;

        DELETE PAY_ELEMENT_ENTRIES_F
        where  element_entry_id = p_hist_rec.information1
        AND    effective_start_date = fnd_date.canonical_to_date(p_hist_rec.information2);

        hr_utility.set_location('Leaving delete_other_pay_entries',70);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        hr_utility.set_location('ERROR: '||sqlerrm,80);
        hr_utility.set_location('Leaving delete_other_pay_entries',90);
END delete_other_pay_entries;
--
-- Bug#2521744 Added the above procedure


Function get_sf52_ovn ( p_pa_request_id in number) return number is

	cursor c_get_sf52 (c_pa_request_id in number) is
	select
		object_version_number
	from ghr_pa_requests
	where pa_request_id = c_pa_request_id;

	l_ovn		number;
	l_proc	varchar2(30):='get_sf52_ovn';
Begin
	hr_utility.set_location( 'Entering ' || l_proc, 10);
	for v_get_sf52 in c_get_sf52 (p_pa_request_id)
	loop
		l_ovn := v_get_sf52.object_version_number;
	end loop;
	hr_utility.set_location( 'Leaving ' || l_proc, 20);

	return l_ovn;
End get_sf52_ovn;

PROCEDURE get_sf52_to_details_for_ia
(p_pa_request_id in ghr_pa_requests.pa_request_id%type,
 p_retro_eff_date in ghr_pa_requests.effective_date%type,
 p_sf52_ia_rec in out nocopy ghr_pa_requests%rowtype)
IS

CURSOR c_from_data IS
SELECT * FROM ghr_pa_requests
WHERE pa_request_id = p_pa_request_id;

CURSOR c_grade_id(c_business_group_id per_grades.business_group_id%type,
		  c_pay_plan per_grades.name%type,
		  c_grade per_grades.name%type,
		  c_effective_date per_grades.date_from%type) IS
SELECT grade_id
FROM per_grades
WHERE business_group_id = c_business_group_id
AND substr(name,1,2) = c_pay_plan
AND substr(name,length(name)-1) = c_grade
AND c_effective_date BETWEEN NVL(date_from,to_date('01/01/1951','dd/mm/yyyy')) AND NVL(date_to,to_date('31/12/4712','dd/mm/yyyy'));

l_proc	          varchar2(30):='get_sf52_to_details_for_ia';
l_dummy_varchar   varchar2(30);
l_sf52_ia_rec     ghr_pa_requests%rowtype;
l_business_group_id per_grades.business_group_id%type;

BEGIN
-- First assign the current From pos items to To pos items
	hr_utility.set_location( 'Entering ' || l_proc, 5);
   l_sf52_ia_rec := p_sf52_ia_rec;
FOR c_sf52_data IN c_from_data LOOP
  hr_utility.set_location( 'Assigning the from side to sf52_ia_rec ' || l_proc, 5);
  p_sf52_ia_rec.to_position_id                := c_sf52_data.from_position_id;
  p_sf52_ia_rec.to_position_title             := c_sf52_data.from_position_title;
  p_sf52_ia_rec.to_position_number            := c_sf52_data.from_position_number;
  p_sf52_ia_rec.TO_POSITION_SEQ_NO            := c_sf52_data.FROM_POSITION_SEQ_NO;
  p_sf52_ia_rec.to_occ_code                   := c_sf52_data.from_occ_code;
  p_sf52_ia_rec.to_office_symbol              := c_sf52_data.from_office_symbol;
  -- Bug#4696860 Added the following IF Condition.
  IF NOT (c_sf52_data.noa_family_code IN ('AWARD','GHR_INCENTIVE') OR
          ghr_pa_requests_pkg.GET_NOA_PM_FAMILY(c_sf52_data.second_noa_id) IN ('AWARD','GHR_INCENTIVE')) THEN
	  p_sf52_ia_rec.to_pay_basis                  := c_sf52_data.from_pay_basis;
	  p_sf52_ia_rec.to_total_salary               := c_sf52_data.from_total_salary;
	  p_sf52_ia_rec.to_other_pay_amount           := c_sf52_data.from_other_pay_amount;
	  p_sf52_ia_rec.to_adj_basic_pay              := c_sf52_data.from_adj_basic_pay;
	  p_sf52_ia_rec.to_basic_pay                  := c_sf52_data.from_basic_pay;
	  p_sf52_ia_rec.to_grade_or_level             := c_sf52_data.from_grade_or_level;
	  p_sf52_ia_rec.to_locality_adj               := c_sf52_data.from_locality_adj;
	  p_sf52_ia_rec.to_pay_plan                   := c_sf52_data.from_pay_plan;
	  p_sf52_ia_rec.to_step_or_rate               := c_sf52_data.from_step_or_rate;
  END IF;
  -- Bug 4086845 Need to assign grade id
  fnd_profile.get('PER_BUSINESS_GROUP_ID',l_business_group_id);
  IF p_sf52_ia_rec.to_pay_plan IS NOT NULL AND
     p_sf52_ia_rec.to_grade_or_level IS NOT NULL THEN
	FOR l_get_grade_id IN c_grade_id(l_business_group_id,p_sf52_ia_rec.to_pay_plan,
					 p_sf52_ia_rec.to_grade_or_level,c_sf52_data.effective_date) LOOP
		p_sf52_ia_rec.to_grade_id := l_get_grade_id.grade_id;
		hr_utility.set_location( 'Grade ID ' || p_sf52_ia_rec.to_grade_id, 6);
	END LOOP;
  END IF;
  -- End Bug 4086845

  -- Bug 2970608 - Do not copy from side pos org details to side for 790 action
  IF  nvl(p_sf52_ia_rec.first_noa_code,hr_api.g_varchar2) <> '790' THEN
    p_sf52_ia_rec.to_position_org_line1         := c_sf52_data.from_position_org_line1;
    p_sf52_ia_rec.to_position_org_line2         := c_sf52_data.from_position_org_line2;
    p_sf52_ia_rec.to_position_org_line3         := c_sf52_data.from_position_org_line3;
    p_sf52_ia_rec.to_position_org_line4         := c_sf52_data.from_position_org_line4;
    p_sf52_ia_rec.to_position_org_line5         := c_sf52_data.from_position_org_line5;
    p_sf52_ia_rec.to_position_org_line6         := c_sf52_data.from_position_org_line6;
    -- Bug 2639509
    -- From postion org lines should be in sync with To Postion Org Lines
    p_sf52_ia_rec.from_position_org_line1         := c_sf52_data.from_position_org_line1;
    p_sf52_ia_rec.from_position_org_line2         := c_sf52_data.from_position_org_line2;
    p_sf52_ia_rec.from_position_org_line3         := c_sf52_data.from_position_org_line3;
    p_sf52_ia_rec.from_position_org_line4         := c_sf52_data.from_position_org_line4;
    p_sf52_ia_rec.from_position_org_line5         := c_sf52_data.from_position_org_line5;
    p_sf52_ia_rec.from_position_org_line6         := c_sf52_data.from_position_org_line6;
  END IF;
  -- Get position ddf data related to from_position_id
  ghr_pa_requests_pkg.get_SF52_pos_ddf_details
    (p_position_id            => c_sf52_data.from_position_id
    ,p_date_effective         => c_sf52_data.effective_date
    ,p_flsa_category          => p_sf52_ia_rec.flsa_category
    ,p_bargaining_unit_status => p_sf52_ia_rec.bargaining_unit_status
    ,p_work_schedule          => p_sf52_ia_rec.work_schedule
    ,p_functional_class       => p_sf52_ia_rec.functional_class
    ,p_supervisory_status     => p_sf52_ia_rec.supervisory_status
    ,p_position_occupied      => p_sf52_ia_rec.position_occupied
    ,p_appropriation_code1    => p_sf52_ia_rec.appropriation_code1
    ,p_appropriation_code2    => p_sf52_ia_rec.appropriation_code2
    ,p_personnel_office_id    => p_sf52_ia_rec.personnel_office_id
     ,p_office_symbol	      => l_dummy_varchar
    ,p_part_time_hours        => p_sf52_ia_rec.part_time_hours);
  EXIT;
END LOOP;
hr_utility.set_location( 'Leaving' || l_proc, 20);
Exception when others then
          --
          -- Reset IN OUT parameters and set OUT parameters
          --
          p_sf52_ia_rec := l_sf52_ia_rec;
          raise;

END get_sf52_to_details_for_ia;

-- Bug#2521744
-- This procedure will get the other pay component values
-- at the time of intervening correction.
PROCEDURE get_sf52_to_othpays_for_ia
            (p_sf52_ia_rec in out nocopy ghr_pa_requests%rowtype) IS

    CURSOR C_element_exists(p_element_name IN VARCHAR2,
                            p_assignment_id IN number,
                            p_effective_date IN DATE) IS
    SELECT  '1'
      FROM    pay_element_types_f        elt
             ,pay_element_entries_f      ele
      WHERE  elt.element_type_id    = ele.element_type_id
      AND    elt.element_name= p_element_name
      AND    ele.assignment_id      = p_assignment_id
      AND    elt.business_group_id is NULL
      AND    p_effective_date BETWEEN elt.effective_start_date AND elt.effective_end_date
      AND    p_effective_date BETWEEN ele.effective_start_date AND ele.effective_end_date;


      cursor c_noa_fam_code(p_noa_id  ghr_nature_of_actions.nature_of_action_id%type) is
       select fam.noa_family_code
        from ghr_noa_families fam
       where fam.nature_of_action_id = p_noa_id;


    l_proc	          varchar2(30):='get_sf52_to_othpays_for_ia';
    l_dummy_varchar   varchar2(1);
    l_sf52_ia_rec     ghr_pa_requests%rowtype;
    l_noa_id          ghr_nature_of_actions.nature_of_action_id%type;
    l_noa_fam_code    ghr_noa_families.noa_family_code%type;

BEGIN
    -- First assign the current From pos items to To pos items
    hr_utility.set_location( 'Entering ' || l_proc, 5);
    l_sf52_ia_rec := p_sf52_ia_rec;
    -- Bug#2521744 Added by VVL for testing the correction process.
    -- for Other pay Elements update nulls as nulls.
    -- Added the following code to check whether the Family is Salary change family or not
    -- Depending on that, assign the values of Other Pay components(Retention, Supervisory, AUO etc.)
    IF p_sf52_ia_rec.first_noa_code IN ('001','002') THEN
       l_noa_id := p_sf52_ia_rec.second_noa_id;
    ELSE
        l_noa_id := p_sf52_ia_rec.first_noa_id;
    END IF;

    FOR noa_fam_rec in c_noa_fam_code(l_noa_id) loop
        l_noa_fam_code := noa_fam_rec.noa_family_code;
        IF l_noa_fam_code like 'GHR_SAL%' THEN
            EXIT;
        END IF;
    END LOOP;
	hr_utility.set_location('NOA Family Code '||l_noa_fam_code,10000);
	IF (p_sf52_ia_rec.first_noa_code  IN ('810','818','819')  OR
	    p_sf52_ia_rec.second_noa_code IN ('810','818','819') OR
	    l_noa_fam_code like 'GHR_SAL%'
	    ) THEN
            -- Check for Retention Allowance Element
            Open C_element_exists('Retention Allowance',p_sf52_ia_rec.employee_assignment_id,p_sf52_ia_rec.effective_date);
            Fetch c_element_exists into l_dummy_varchar;
            IF c_element_exists%NOTFOUND THEN
            p_sf52_ia_rec.to_retention_allowance        := NULL;
            p_sf52_ia_rec.to_retention_allow_percentage := NULL;
            END IF;
            close c_element_exists;

            -- Check for Supervisory Differential Element
            Open C_element_exists('Supervisory Differential',p_sf52_ia_rec.employee_assignment_id,p_sf52_ia_rec.effective_date);
            Fetch c_element_exists into l_dummy_varchar;
            IF c_element_exists%NOTFOUND THEN
            p_sf52_ia_rec.to_Supervisory_Differential        := NULL;
            p_sf52_ia_rec.to_Supervisory_Diff_percentage := NULL;
            END IF;
            close c_element_exists;

            -- Check for AUO Element
            Open C_element_exists('AUO',p_sf52_ia_rec.employee_assignment_id,p_sf52_ia_rec.effective_date);
            Fetch c_element_exists into l_dummy_varchar;
            IF c_element_exists%NOTFOUND THEN
            p_sf52_ia_rec.to_au_overtime       := NULL;
            p_sf52_ia_rec.to_auo_premium_pay_indicator := NULL;
            END IF;
            close c_element_exists;
            -- Check for Availability Pay Element

            Open C_element_exists('Availability Pay',p_sf52_ia_rec.employee_assignment_id,p_sf52_ia_rec.effective_date);
            Fetch c_element_exists into l_dummy_varchar;
            IF c_element_exists%NOTFOUND THEN
            p_sf52_ia_rec.to_availability_pay        := NULL;
            p_sf52_ia_rec.to_ap_premium_pay_indicator := NULL;
            END IF;
            close c_element_exists;
        END IF;
        -- End of Bug#2521744 Changes.
        hr_utility.set_location( 'Leaving' || l_proc, 20);

EXCEPTION
    WHEN OTHERS THEN
        --
        -- Reset IN OUT parameters and set OUT parameters
        --
        p_sf52_ia_rec := l_sf52_ia_rec;
        RAISE;

END get_sf52_to_othpays_for_ia;


-- JH Bug 2983738 Position Hiring Status Changes.
PROCEDURE posn_not_active(p_position_id         in number
                         ,p_effective_date      in date
                         ,p_posn_eff_start_date OUT NOCOPY date
                         ,p_posn_eff_end_date   OUT NOCOPY date
                         ,p_prior_posn_ovn      OUT NOCOPY number)
IS

CURSOR c_posn IS
 select apf.effective_start_date, apf.effective_end_date
 from   HR_ALL_POSITIONS_F apf
 where  apf.position_id = p_position_id
 and    apf.availability_status_id <> 1
 and    p_effective_date between apf.effective_start_date and apf.effective_end_date;

CURSOR c_prior_posn IS
 select apf.object_version_number
 from   HR_ALL_POSITIONS_F apf
 where  apf.position_id = p_position_id
 and    p_posn_eff_start_date-1 between apf.effective_start_date and apf.effective_end_date;

BEGIN
 -- Note OVN returned is for Prior Record
 FOR c_posn_rec IN c_posn LOOP
   p_posn_eff_start_date := c_posn_rec.effective_start_date;
   p_posn_eff_end_date   := c_posn_rec.effective_end_date;
 END LOOP;

 FOR c_prior_posn_rec IN c_prior_posn LOOP
   p_prior_posn_ovn            := c_prior_posn_rec.object_version_number;
 END LOOP;

END posn_not_active;

--6850492
procedure apply_dual_correction(p_sf52_data in ghr_pa_requests%rowtype,
                                p_sf52_data_result in out nocopy ghr_pa_requests%rowtype,
				p_retro_action_exists in varchar2) is
cursor get_first_corr(p_pa_request_id in number)
    is
    select *
    from   ghr_pa_requests
    where  pa_request_id = p_pa_request_id;

l_first_corr ghr_pa_requests%rowtype;
begin

 open get_first_corr(p_pa_request_id => p_sf52_data.mass_action_id);
 fetch 	get_first_corr into l_first_corr;
 close get_first_corr;

 if l_first_corr.status <> 'CANCELED' and ((l_first_corr.to_position_id is not null and
     nvl(l_first_corr.from_position_id,'-1') <> nvl(l_first_corr.to_position_id,'-1')) or
    (l_first_corr.to_step_or_rate is not null and
     nvl(l_first_corr.from_step_or_rate,'-1') <> nvl(l_first_corr.to_step_or_rate,'-1')) or
     (l_first_corr.to_basic_pay is not null and
     nvl(l_first_corr.from_basic_pay,'-1') <> nvl(l_first_corr.to_basic_pay,'-1'))   or
     (l_first_corr.to_locality_adj is not null and
     nvl(l_first_corr.from_locality_adj,'-1') <> nvl(l_first_corr.to_locality_adj,'-1')) or
     (l_first_corr.to_other_pay_amount is not null and
     nvl(l_first_corr.from_other_pay_amount,'-1') <> nvl(l_first_corr.to_other_pay_amount,'-1')))
     then
    hr_utility.set_location('If the first correction is not cancelled',1000);

    p_sf52_data_result.from_position_id :=  l_first_corr.to_position_id;
    p_sf52_data_result.from_position_title := l_first_corr.to_position_title;
    p_sf52_data_result.from_position_number := l_first_corr.to_position_number;
    p_sf52_data_result.from_position_seq_no := l_first_corr.to_position_seq_no;
    p_sf52_data_result.from_pay_plan := l_first_corr.to_pay_plan;
    p_sf52_data_result.from_occ_code := l_first_corr.to_occ_code;
    p_sf52_data_result.from_grade_or_level := l_first_corr.to_grade_or_level;
    p_sf52_data_result.from_step_or_rate := l_first_corr.to_step_or_rate;
    p_sf52_data_result.from_total_salary := l_first_corr.to_total_salary;
    p_sf52_data_result.from_pay_basis := l_first_corr.to_pay_basis;
--    p_sf52_data_result.input_pay_rate_determinant := l_first_corr.pay_rate_determinant;
    p_sf52_data_result.from_pay_table_identifier := l_first_corr.to_pay_table_identifier;
    p_sf52_data_result.from_basic_pay := l_first_corr.to_basic_pay;
    p_sf52_data_result.from_locality_adj := l_first_corr.to_locality_adj;
    p_sf52_data_result.from_adj_basic_pay := l_first_corr.to_adj_basic_pay;
    p_sf52_data_result.from_other_pay_amount := l_first_corr.to_other_pay_amount;
    p_sf52_data_result.from_position_org_line1 := l_first_corr.to_position_org_line1;
    p_sf52_data_result.from_position_org_line2 := l_first_corr.to_position_org_line2;
    p_sf52_data_result.from_position_org_line3 := l_first_corr.to_position_org_line3;
    p_sf52_data_result.from_position_org_line4 := l_first_corr.to_position_org_line4;
    p_sf52_data_result.from_position_org_line5 := l_first_corr.to_position_org_line5;
    p_sf52_data_result.from_position_org_line6 := l_first_corr.to_position_org_line6;
elsif NVL(p_retro_action_exists,'N') = 'Y' then

    hr_utility.set_location('retro action exists',1000);

    p_sf52_data_result.from_position_id :=  p_sf52_data.from_position_id;
    p_sf52_data_result.from_position_title := p_sf52_data.from_position_title;
    p_sf52_data_result.from_position_number := p_sf52_data.from_position_number;
    p_sf52_data_result.from_position_seq_no := p_sf52_data.from_position_seq_no;
    p_sf52_data_result.from_pay_plan := p_sf52_data.from_pay_plan;
    p_sf52_data_result.from_occ_code := p_sf52_data.from_occ_code;
    p_sf52_data_result.from_grade_or_level := p_sf52_data.from_grade_or_level;
    p_sf52_data_result.from_step_or_rate := p_sf52_data.from_step_or_rate;
    p_sf52_data_result.from_total_salary := p_sf52_data.from_total_salary;
    p_sf52_data_result.from_pay_basis := p_sf52_data.from_pay_basis;
--    p_sf52_data_result.input_pay_rate_determinant := p_sf52_data.pay_rate_determinant;
    p_sf52_data_result.from_pay_table_identifier := p_sf52_data.to_pay_table_identifier;
    p_sf52_data_result.from_basic_pay := p_sf52_data.from_basic_pay;
    p_sf52_data_result.from_locality_adj := p_sf52_data.from_locality_adj;
    p_sf52_data_result.from_adj_basic_pay := p_sf52_data.from_adj_basic_pay;
    p_sf52_data_result.from_other_pay_amount := p_sf52_data.from_other_pay_amount;
    p_sf52_data_result.from_position_org_line1 := p_sf52_data.from_position_org_line1;
    p_sf52_data_result.from_position_org_line2 := p_sf52_data.from_position_org_line2;
    p_sf52_data_result.from_position_org_line3 := p_sf52_data.from_position_org_line3;
    p_sf52_data_result.from_position_org_line4 := p_sf52_data.from_position_org_line4;
    p_sf52_data_result.from_position_org_line5 := p_sf52_data.from_position_org_line5;
    p_sf52_data_result.from_position_org_line6 := p_sf52_data.from_position_org_line6;
elsif p_sf52_data_result.noa_family_code in ('CHG_WORK_SCHED', 'CHG_HOURS') then
hr_utility.set_location('for change in work schedule',1000);
    p_sf52_data_result.from_position_id :=  p_sf52_data_result.to_position_id;
    p_sf52_data_result.from_position_title := p_sf52_data_result.to_position_title;
    p_sf52_data_result.from_position_number := p_sf52_data_result.to_position_number;
    p_sf52_data_result.from_position_seq_no := p_sf52_data_result.to_position_seq_no;
    p_sf52_data_result.from_pay_plan := p_sf52_data_result.to_pay_plan;
    p_sf52_data_result.from_occ_code := p_sf52_data_result.to_occ_code;
    p_sf52_data_result.from_grade_or_level := p_sf52_data_result.to_grade_or_level;
    p_sf52_data_result.from_step_or_rate := p_sf52_data_result.to_step_or_rate;
    p_sf52_data_result.from_total_salary := p_sf52_data_result.to_total_salary;
    p_sf52_data_result.from_pay_basis := p_sf52_data_result.to_pay_basis;
--    p_sf52_data_result.input_pay_rate_determinant := p_sf52_data_result.pay_rate_determinant;
    p_sf52_data_result.from_pay_table_identifier := p_sf52_data_result.to_pay_table_identifier;
    p_sf52_data_result.from_basic_pay := p_sf52_data_result.to_basic_pay;
    p_sf52_data_result.from_locality_adj := p_sf52_data_result.to_locality_adj;
    p_sf52_data_result.from_adj_basic_pay := p_sf52_data_result.to_adj_basic_pay;
    p_sf52_data_result.from_other_pay_amount := p_sf52_data_result.to_other_pay_amount;
    p_sf52_data_result.from_position_org_line1 := p_sf52_data_result.to_position_org_line1;
    p_sf52_data_result.from_position_org_line2 := p_sf52_data_result.to_position_org_line2;
    p_sf52_data_result.from_position_org_line3 := p_sf52_data_result.to_position_org_line3;
    p_sf52_data_result.from_position_org_line4 := p_sf52_data_result.to_position_org_line4;
    p_sf52_data_result.from_position_org_line5 := p_sf52_data_result.to_position_org_line5;
    p_sf52_data_result.from_position_org_line6 := p_sf52_data_result.to_position_org_line6;
end if;

end  apply_dual_correction;

-- Bug 8264475 Added the procedure for dual correction for dual actions inplace of apply noa corrections
-- this will be called
Procedure apply_dual_noa_corrections(p_sf52_data        in  	      ghr_pa_requests%rowtype,
				     p_sf52_data_result in out nocopy ghr_pa_requests%rowtype ) is

   l_sf52_data_orig		ghr_pa_requests%rowtype;
   l_sf52_data_step		ghr_pa_requests%rowtype;
   l_sf52_ia_rec                   ghr_pa_requests%rowtype;
   l_sf52_dummy		ghr_pa_requests%rowtype;
   l_sf52_cursor_step_indx	number;
   l_session_var		ghr_history_api.g_session_var_type;
   -- Bug#5435374 added l_session_var1.
   l_session_var1   ghr_history_api.g_session_var_type;
   l_capped_other_pay number := hr_api.g_number;
   l_retro_eff_date        ghr_pa_requests.effective_date%type;
   l_retro_pa_request_id   ghr_pa_requests.pa_request_id%type;
   l_retro_first_noa       ghr_nature_of_actions.code%type;
   l_retro_second_noa       ghr_nature_of_actions.code%type;
   l_sf52_data_result      ghr_pa_requests%rowtype;
   -- Bug#3543213 Created l_dummy variable
   l_dummy                 VARCHAR2(30);
  -- this cursor selects all rows in the correction chain from ghr_pa_requests
   cursor  l_sf52_cursor
       is
       select 	*
       from 		ghr_pa_requests
       connect by 	prior altered_pa_request_id = pa_request_id
       start with	pa_request_id = p_sf52_data.pa_request_id
       order by 	level desc;

   cursor c_orig_details_for_ia
       is
       select pa_request_id,pa_notification_id,person_id,
              effective_date,from_position_id,
              to_position_id,noa_family_code,second_noa_code
       from ghr_pa_requests
       where pa_request_id = p_sf52_data.altered_pa_request_id;

   cursor c_get_hist_id (c_pa_request_id in number)
       is
       select min(pa_history_id)
       from ghr_pa_history
       where pa_request_id = c_pa_request_id;

   -- Bug#5435374
   l_pos_ei_grade_data  per_position_extra_info%rowtype;

   cursor c_grade_kff (grd_id number)
       is
       select gdf.segment1
             ,gdf.segment2
       from per_grades grd,
            per_grade_definitions gdf
       where grd.grade_id = grd_id
       and   grd.grade_definition_id = gdf.grade_definition_id;

   --bug #6356058 start
   l_core_chg_avbl number;
   l_prev_request_id number;
   l_curr_pa_history_id number;
   l_pos_ei_grp1_data	per_position_extra_info%rowtype;

--   8737300 Modified the cursor for improving performance
   cursor core_chg_check(p_to_position_id in number,
                      p_effective_date in date)
       is
       select  1
       from    ghr_pa_history hist_1
       where   pa_request_id is null
       and     hist_1.pa_history_id > (select min(pa_history_id)
                                       from ghr_pa_history
	  			       where pa_request_id = l_prev_request_id)
       and     hist_1.pa_history_id < nvl(l_curr_pa_history_id,999999999)
       and     information1 in   (select  to_char(position_extra_info_id)
                                  from    per_position_extra_info
                                  where   position_id          =  p_to_position_id
                                  and     information_type     in  ('GHR_US_POS_GRP1'))
       and     information5   =  'GHR_US_POS_GRP1'
       and     effective_date =  p_effective_date
       and     table_name     =  'PER_POSITION_EXTRA_INFO';
   --bug #6356058 start

   --BUG 6976052
   cursor get_position_det(p_position_id in number,
			p_effective_date in date)
       is
       SELECT pos.job_id
             ,pos.business_group_id
             ,pos.organization_id
             ,pos.location_id
       FROM  hr_all_positions_f           pos  -- Venkat -- Position DT
       WHERE pos.position_id = p_position_id
       and  p_effective_date between pos.effective_start_date
                             and pos.effective_end_date ;
    --BUG 6976052

    -- 8264545
    Cursor c_noa_family(p_noa_id in number)
        is
        Select fam.noa_family_code
        from   ghr_noa_families nof,
               ghr_families fam
        where  nof.nature_of_action_id =  p_noa_id
        and    fam.noa_family_code     = nof.noa_family_code
        and    nvl(fam.proc_method_flag,hr_api.g_varchar2) = 'Y'
        and    p_sf52_data.effective_date
        between nvl(fam.start_date_active,p_sf52_data.effective_date)
        and     nvl(fam.end_date_active,p_sf52_data.effective_date);
     -- 8264545

     cursor chk_dual_sec_corr(p_pa_request_id in number)
     is
     select 1
     from   ghr_pa_requests
     where  pa_request_id = p_pa_request_id
     and    pa_request_id > mass_action_id
     and    second_noa_code = (select second_noa_code
                               from ghr_pa_requests
   		               where pa_request_id = (select 	  min(pa_request_id)
				         	       from 	  ghr_pa_requests
						       where      pa_notification_id is not null
						       connect by pa_request_id = prior altered_pa_request_id
						       start with pa_request_id = p_pa_request_id));


l_shadow_data	ghr_pa_request_shadow%rowtype;
l_proc	varchar2(30):='apply_dual_noa_corrections';
l_dual_flag  varchar2(1);
l_retro_action_exists  varchar2(1) := 'N';
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  l_sf52_data_result := p_sf52_data_result;
  ghr_history_api.get_g_session_var(l_session_var);
   -- loop through all corrections in the correction chain, incrementally applying them by
   -- calling apply_corrections procedure.
   open l_sf52_cursor ;
   l_sf52_cursor_step_indx := 0;
   loop
     -- initialize l_sf52_data_step to nulls;
     l_sf52_data_step := l_sf52_dummy;
	-- l_sf52_data_step holds intermediate incremental values for final corrected record that is
	-- being built.
     fetch l_sf52_cursor into l_sf52_data_step;
     exit when l_sf52_cursor%notfound;
     l_sf52_cursor_step_indx := l_sf52_cursor_step_indx +1;
     if (l_sf52_cursor_step_indx = 1) then
     --Bug # 6356058 start
	l_prev_request_id := l_sf52_data_step.pa_request_id;
     --Bug # 6356058 end
	hr_utility.set_location('Fetch l_sf52_data_step original :'|| l_proc, 10);
	l_sf52_data_orig 	  := l_sf52_data_step;
	p_sf52_data_result  := l_sf52_data_step;
	hr_utility.set_location('assignment_id of original =' || l_sf52_data_step.employee_assignment_id, 14);
	hr_utility.set_location('from grd or leveloriginal =' || l_sf52_data_step.from_grade_or_level, 14);
   	hr_utility.set_location(l_proc || 'pa_request_id of original= ' || l_sf52_data_step.pa_request_id,26);
     -- .47
	-- refresh root sf52 and its correction
	-- get pa_history_id for the root pa_request_id
	open c_get_hist_id( l_sf52_data_step.pa_request_id);
	fetch c_get_hist_id into l_session_var.pa_history_id;
	if c_get_hist_id%notfound then
	   -- raise error;
	   close c_get_hist_id;
	else
	   close c_get_hist_id;
	end if;
	-- We are setting pa_history_id in session var to be able to fetch
	-- Pre-record values of the root SF52 for refresh purpose.
	-- It'll be reset after refresh has been done
	ghr_history_api.set_g_session_var(l_session_var);

	-- 8303159 Added to fetch family code for second correction of dual action before refresh
        if (p_sf52_data_result.second_noa_id is not null) then
	   if (p_sf52_data.second_noa_id = p_sf52_data_result.second_noa_id) then
	      --8264545
	     for noa_family_rec in c_noa_family(p_sf52_data.second_noa_id) loop --Bug# 8270548
                p_sf52_data_result.noa_family_code :=  noa_family_rec.noa_family_code;
             end loop;
	      --8264545
	   end if;
	end if;

	ghr_process_sf52.refresh_req_shadow(p_sf52_data		=>	p_sf52_data_result,
          				    p_shadow_data	=>	l_shadow_data);
	ghr_process_sf52.redo_pay_calc(	p_sf52_rec		=>	p_sf52_data_result,
                                        p_capped_other_pay      =>   l_capped_other_pay);
	-- reset pa_history_id in session variable.
	l_session_var.pa_history_id := null;
	ghr_history_api.set_g_session_var(l_session_var);
     -- .47
 	 -- Bug#3543213 For PRD U,V and NOA 894(Pay Adjustment) get the PRD Value from assignment
	IF p_sf52_data_result.first_noa_code = '894' AND
	   p_sf52_data_result.pay_rate_determinant IN ('U','V') THEN
	   ghr_pa_requests_pkg.get_SF52_asg_ddf_details
	                     (p_assignment_id         => p_sf52_data_result.employee_assignment_id
	                     ,p_date_effective        => p_sf52_data_result.effective_date
	                     ,p_tenure                => l_dummy
	                     ,p_annuitant_indicator   => l_dummy
	                     ,p_pay_rate_determinant  => p_sf52_data_result.pay_rate_determinant
                           ,p_work_schedule         => l_dummy
                           ,p_part_time_hours       => l_dummy);
 	END IF;
        --End of Bug#3543213
	--check if original action in correction chain was a dual action. If so, determine which of
	--the two actions this correction is for and call ghr_process_sf52.assign_new_rg to null out columns not having
        -- to do with the noa we are correcting.
	--l_dual_flag := 'N';
	 if (p_sf52_data_result.second_noa_id is not null) then
	             hr_utility.set_location('original sf52 is dual action :'|| l_proc, 11);
		     ghr_process_sf52.g_dual_action_yn := 'Y';
		     ghr_process_sf52.g_dual_first_noac := p_sf52_data_result.first_noa_code;
		     ghr_process_sf52.g_dual_second_noac := p_sf52_data_result.second_noa_code;

	   if (p_sf52_data.second_noa_id = p_sf52_data_result.second_noa_id) then
	       /*ghr_process_sf52.assign_new_rg(p_action_num			=>	2,
		 			       p_pa_req				=>	p_sf52_data_result);*/
		     -- to change the Family code for second action correction as it is raising errors
		     -- based on family code
		     ghr_process_sf52.copy_2ndNoa_to_1stNoa(p_sf52_data_result);
		     ghr_process_sf52.null_2ndNoa_cols(p_sf52_data_result);
	   else
      	     /*ghr_process_sf52.assign_new_rg(p_action_num			=>	1,
		 	 		      p_pa_req				=>	p_sf52_data_result);*/

		     -- if first action is 893, then we need to derive to_columns as both actions of
		     -- the dual action potentially could have changed the to fields (in particular,
		     -- to_step_or_rate) so we need to determine what the to_fields should be or the first action.
		     if (p_sf52_data_result.first_noa_code = '893') then--Bug# 8926400
			ghr_process_sf52.derive_to_columns(p_sf52_data	=>	p_sf52_data_result);
		     end if;
		     ghr_process_sf52.null_2ndNoa_cols(p_sf52_data_result);
	   end if;
	--			l_dual_flag := 'Y';
	  end if;
	  hr_utility.set_location('ghr_process_sf52.g_dual_flag_yn'||ghr_process_sf52.g_dual_action_yn,100);
  	  hr_utility.set_location('ghr_process_sf52.g_dual_first_noac'||ghr_process_sf52.g_dual_first_noac,100);
 	  hr_utility.set_location('ghr_process_sf52.g_dual_second_noac'||ghr_process_sf52.g_dual_second_noac,100);
	   -- Nullfy columns which must not be passed
	    p_sf52_data_result.pa_notification_id		:= NULL;
	    p_sf52_data_result.agency_code			:= NULL;
	    p_sf52_data_result.approval_date			:= NULL;
	    p_sf52_data_result.approving_official_work_title:= NULL;
	    p_sf52_data_result.employee_dept_or_agency 	:= NULL;
	    p_sf52_data_result.from_agency_code			:= NULL;
	    p_sf52_data_result.from_agency_desc			:= NULL;
	    p_sf52_data_result.from_office_symbol		:= NULL;
	    p_sf52_data_result.personnel_office_id		:= NULL;
	    p_sf52_data_result.to_office_symbol			:= NULL;
     else
	l_retro_pa_request_id := NULL;
        hr_utility.set_location('Fetch l_sf52_data_step loop :'|| l_proc, 15);
	-- all corrections will have the original sf52 information in the 2nd noa columns, so
	-- copy that information to 1st noa columns.
	hr_utility.set_location('from grd or levelbefcp2to1 =' || l_sf52_data_step.from_grade_or_level, 14);
	ghr_process_sf52.copy_2ndNoa_to_1stNoa(l_sf52_data_step);
	-- null the second noa columns since we don't want anything to be done with these now.
	hr_utility.set_location('from grd or levelaftcp2to1 =' || l_sf52_data_step.from_grade_or_level, 14);
	ghr_process_sf52.null_2ndNoa_cols(l_sf52_data_step);
	hr_utility.set_location('from grd or levelaftnull2noa =' || l_sf52_data_step.from_grade_or_level, 14);
	hr_utility.set_location(l_proc || 'pa_request_id before correction= ' || l_sf52_data_step.pa_request_id,16);
	hr_utility.set_location(l_proc || 'assignment id before correction= ' || l_sf52_data_step.employee_assignment_id,17);
	hr_utility.set_location('from grd or levelbef appcorr =' || l_sf52_data_step.from_grade_or_level, 14);
        ghr_process_sf52.print_sf52('l_sf52_step bef apply_correction',
                                    l_sf52_data_step );
        ghr_process_sf52.print_sf52('result bef copy_ia_rec_on_result',
                                     p_sf52_data_result );
        -- Start Intervening Actions Processing
        -- Processing added to assign the From side details to
        -- To side if it is a Intervening action and
        -- Original action from position_id = to position id
        -- Fetch the original action details
        FOR c_orig_det_rec in c_orig_details_for_ia
        LOOP
           hr_utility.set_location('Inside the orig_details for loop' ,15);
	   hr_utility.set_location('orig pa_request_id'||c_orig_det_rec.pa_request_id ,15);
           hr_utility.set_location('orig pa_notification_id'||c_orig_det_rec.pa_notification_id ,15);
           hr_utility.set_location('orig person_id'||c_orig_det_rec.person_id ,15);
           hr_utility.set_location('orig from_position_id'||c_orig_det_rec.from_position_id ,15);
           hr_utility.set_location('orig to_position_id'||c_orig_det_rec.to_position_id ,15);
           hr_utility.set_location('orig effective_date'||c_orig_det_rec.effective_date ,15);
	   --BUG #7216635 added the parameter p_noa_id_correct
          GHR_APPROVED_PA_REQUESTS.determine_ia(
                     p_pa_request_id => c_orig_det_rec.pa_request_id,
                     p_pa_notification_id => c_orig_det_rec.pa_notification_id,
                     p_person_id      => c_orig_det_rec.person_id,
                     p_effective_date => c_orig_det_rec.effective_date,
		     p_noa_id_correct => l_session_var.noa_id_correct,
                     p_retro_pa_request_id => l_retro_pa_request_id,
                     p_retro_eff_date => l_retro_eff_date,
                     p_retro_first_noa => l_retro_first_noa,
                     p_retro_second_noa => l_retro_second_noa);
          hr_utility.set_location('retro effective_date is '||l_retro_eff_date ,16);
          -- Bug#2521744 Splitting the single if condition into 2 separate if conditions.
          IF l_retro_eff_date is NOT NULL  THEN
            IF c_orig_det_rec.from_position_id
              = c_orig_det_rec.to_position_id THEN
              -- copy the from details
              hr_utility.set_location('Its a Intervening Action ' ,16);
              hr_utility.set_location('pa_request_id passed to get_sf52_to_det '||p_sf52_data.pa_request_id ,17);

              get_sf52_to_details_for_ia
                  (p_pa_request_id => p_sf52_data.pa_request_id,
                   p_retro_eff_date   => l_retro_eff_date,
                   p_sf52_ia_rec  => p_sf52_data_result);



              ghr_process_sf52.print_sf52('result aft get_sf52_to_details_for_ia',
                                           p_sf52_data_result );
              get_sf52_to_othpays_for_ia(p_sf52_ia_rec  => p_sf52_data_result);
              ghr_process_sf52.print_sf52('reslt aft get_sf52_to_other_pay_det_for_ia',
                                           p_sf52_data_result );
		l_retro_action_exists := 'Y';
             ELSE

                 -- Verify whether the original action is one of the salary change actions
                 -- If yes, check whether the other pay related elements are present or not
                 -- as on the effective date. If they are not present, set that other pay comp
                 -- to_value as null.
                get_sf52_to_othpays_for_ia(p_sf52_ia_rec  => p_sf52_data_result);
                ghr_process_sf52.print_sf52('Aft get_sf52_to_other_pay_det_for_ia in else',
                                            p_sf52_data_result );
             END IF;
           END IF;
         --bug #6356058 start
         IF p_sf52_data_result.from_position_id = p_sf52_data_result.to_position_id THEN
           IF l_retro_pa_request_id IS NOT NULL THEN
	      l_prev_request_id := l_retro_pa_request_id;
	   end if;
           open c_get_hist_id(l_sf52_data_step.pa_request_id);
	   fetch c_get_hist_id into l_curr_pa_history_id;
	   close c_get_hist_id;
           open core_chg_check( p_sf52_data_result.to_position_id,
	                        c_orig_det_rec.effective_date);
	   fetch core_chg_check into l_core_chg_avbl;
	   if core_chg_check%found then
	      ghr_history_api.get_g_session_var(l_session_var);
              ghr_history_api.reinit_g_session_var;
              l_session_var1.date_Effective            := l_session_var.date_Effective;
              l_session_var1.person_id                 := l_session_var.person_id;
              l_session_var1.assignment_id             := l_session_var.assignment_id;
              l_session_var1.fire_trigger    := 'N';
              l_session_var1.program_name := 'sf50';
              ghr_history_api.set_g_session_var(l_session_var1);
	      ghr_history_fetch.fetch_positionei(
                      p_position_id      => p_sf52_data_result.to_position_id,
                      p_information_type => 'GHR_US_POS_GRP1',
                      p_date_effective   => p_sf52_data_result.effective_date,
                      p_pos_ei_data      => l_pos_ei_grp1_data);
               p_sf52_data_result.supervisory_status     := l_pos_ei_grp1_data.poei_information16;
               p_sf52_data_result.part_time_hours        := l_pos_ei_grp1_data.poei_information23;
               ghr_history_api.reinit_g_session_var;
               ghr_history_api.set_g_session_var(l_session_var);
	     end if;
		close core_chg_check;
          END IF;
--bug #6356058 end
        END LOOP; -- Intervening actions
	      -- End Intervening Actions Processing

        --bug #6356058
        l_prev_request_id := l_sf52_data_step.pa_request_id;
         hr_utility.set_location('Out side the orig_details for loop' ,17);
        -- This has been added for dual actions correction processing
        --- to copy the to side details of first correction to from side details
        ---  of second correction while building the correction record
        apply_correction( p_sf52rec_correct	=>	l_sf52_data_step,
                          p_corr_pa_request_id	=>	p_sf52_data.pa_request_id,
                          p_sf52rec		=>	p_sf52_data_result );

	--6850492
        If  l_sf52_data_step.rpa_type = 'DUAL' and l_sf52_data_step.mass_action_id is not null then
          for rec_chk_sec_corr in chk_dual_sec_corr(p_pa_request_id => l_sf52_data_step.pa_request_id)
	  loop
	  hr_utility.set_location('in second correction',1000);
           apply_dual_correction(l_sf52_data_step,p_sf52_data_result,l_retro_action_exists);
	  end loop;
        end if;
        --6850492

        -- Recalculating Retention Allowance
        -- Recalculate Retention allowance if it is a OTHER_PAY action
        -- and Correction of Intervening Action
        if p_sf52_data_result.noa_family_code = 'OTHER_PAY' and
           l_retro_eff_date is NOT NULL and
           p_sf52_data_result.to_retention_allow_percentage is not null then
           --Modified for FWS
          IF p_sf52_data_result.to_pay_basis ='PH' THEN
       	     p_sf52_data_result.to_retention_allowance :=
             TRUNC(p_sf52_data_result.to_basic_pay * p_sf52_data_result.to_retention_allow_percentage/100,2);
	  ELSE
	     p_sf52_data_result.to_retention_allowance :=
             TRUNC(p_sf52_data_result.to_basic_pay * p_sf52_data_result.to_retention_allow_percentage/100,0);
          END IF;
	  p_sf52_data_result.to_other_pay_amount := nvl(p_sf52_data_result.to_au_overtime,0) +
                                                    nvl(p_sf52_data_result.to_availability_pay,0) +
                                                    nvl(p_sf52_data_result.to_retention_allowance,0) +
                                                    nvl(p_sf52_data_result.to_supervisory_differential,0) +
                                                    nvl(p_sf52_data_result.to_staffing_differential,0);
          p_sf52_data_result.to_total_salary :=  p_sf52_data_result.to_adj_basic_pay + p_sf52_data_result.to_other_pay_amount;
          if p_sf52_data_result.to_other_pay_amount = 0 then
             p_sf52_data_result.to_other_pay_amount := null;
          end if;
       end if;
 	  hr_utility.set_location( l_proc || 'assignment_id after correction=' || p_sf52_data_result.employee_assignment_id ,18);
	  hr_utility.set_location('Applied corrections :'|| l_proc, 20);
       end if;
   end loop;
   close l_sf52_cursor;

   --6976052
   --- Modified to get job id from hr_positions_f while applying all correction
   -- actions based on the position
   for rec in get_position_det(p_position_id => p_sf52_data_result.to_position_id,
         		       p_effective_date => p_sf52_data_result.effective_date)
   loop
     p_sf52_data_result.to_job_id := rec.job_id;
     p_sf52_data_result.to_organization_id := rec.organization_id;
   end loop;
   --6976052

    -- Bug#5435374 If the from and to position ids are same, verify the pay plan, grade details.
   IF p_sf52_data_result.from_position_id = p_sf52_data_result.to_position_id THEN
      -- Reinitializing the session variables to get the valid grade as on the
      -- effective date.
      ghr_history_api.get_g_session_var(l_session_var);
      ghr_history_api.reinit_g_session_var;
      l_session_var1.date_Effective            := l_session_var.date_Effective;
      l_session_var1.person_id                 := l_session_var.person_id;
      l_session_var1.assignment_id             := l_session_var.assignment_id;
      l_session_var1.fire_trigger    := 'N';
      l_session_var1.program_name := 'sf50';
      ghr_history_api.set_g_session_var(l_session_var1);

      -- Retrieve the Grade info from the POI history table
      ghr_history_fetch.fetch_positionei(
		p_position_id      => p_sf52_data_result.to_position_id,
		p_information_type => 'GHR_US_POS_VALID_GRADE',
		p_date_effective   => p_sf52_data_result.effective_date,
		p_pos_ei_data      => l_pos_ei_grade_data);

      -- Reset the session variables after getting the date effective valid grade
      -- to continue with the correction process.
      ghr_history_api.reinit_g_session_var;
      ghr_history_api.set_g_session_var(l_session_var);

      IF l_pos_ei_grade_data.position_extra_info_id IS NOT NULL THEN
	 hr_utility.set_location('GL: to grd id:'||p_sf52_data_result.to_grade_id,30);
	 hr_utility.set_location('GL: pos ei grd:'||l_pos_ei_grade_data.poei_information3,40);
	 IF l_pos_ei_grade_data.poei_information3 <> p_sf52_data_result.to_grade_id THEN
	 --Bug# 5638869
           --p_sf52_data_result.to_grade_id := l_pos_ei_grade_data.poei_information3;
           l_pos_ei_grade_data.poei_information3 := p_sf52_data_result.to_grade_id;
         --Bug# 5638869
	 FOR c_grade_kff_rec IN c_grade_kff (p_sf52_data_result.to_grade_id)
	 LOOP
	   hr_utility.set_location('GL: Inside setting pay plan grade',60);
	   p_sf52_data_result.to_pay_plan := c_grade_kff_rec.segment1  ;
	   p_sf52_data_result.to_grade_or_level := c_grade_kff_rec.segment2;
	   EXIT;
    	 END LOOP;
      END IF;
   END IF;
  END IF;
   -- Bug#5435374 End of the fix.

  hr_utility.set_location(' Leaving:'||l_proc, 25);
 Exception when others then
   --
   -- Reset IN OUT parameters and set OUT parameters
   --
   p_sf52_data_result := l_sf52_data_result;
   raise;
end apply_dual_noa_corrections;
-- Bug 8264475
--6850492

End;

/
