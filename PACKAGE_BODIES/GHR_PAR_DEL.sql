--------------------------------------------------------
--  DDL for Package Body GHR_PAR_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PAR_DEL" as
/* $Header: ghparrhi.pkb 120.5.12010000.3 2008/10/22 07:10:55 utokachi ship $ */

-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ghr_par_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic. The functions of
--   this procedure are as follows:
--   1) To delete the specified row from the schema using the primary key in
--      the predicates.
--   2) To trap any constraint violations that may have occurred.
--   3) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the del
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be delete from the schema.
--
-- Post Failure:
--   If a child integrity constraint violation is raised the
--   constraint_error procedure will be called.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_dml(p_rec in ghr_par_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Delete the ghr_pa_requests row.
  --
  delete from ghr_pa_requests
  where pa_request_id = p_rec.pa_request_id;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    ghr_par_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    Raise;
End delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the delete dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the del procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any pre-processing required before the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete(p_rec in ghr_par_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_delete;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   delete dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the del procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any post-processing required after the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_delete(p_rec in ghr_par_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- This is a hook point and the user hook for post_delete is called here.
  --
  begin
     ghr_par_rkd.after_delete	(
		p_pa_request_id               	=>	ghr_par_shd.g_old_rec.pa_request_id      			,
		p_pa_notification_id_o 			=>	ghr_par_shd.g_old_rec.pa_notification_id			,
		p_noa_family_code_o 			=>	ghr_par_shd.g_old_rec.noa_family_code			,
		p_routing_group_id_o 			=>	ghr_par_shd.g_old_rec.routing_group_id			,
		p_proposed_effective_asap_fl_o 	=>	ghr_par_shd.g_old_rec.proposed_effective_asap_flag	,
		p_academic_discipline_o 		=>	ghr_par_shd.g_old_rec.academic_discipline			,
		p_additional_info_person_id_o 	=>	ghr_par_shd.g_old_rec.additional_info_person_id		,
		p_additional_info_tel_number_o 	=>	ghr_par_shd.g_old_rec.additional_info_tel_number	,
		p_agency_code_o 				=>	ghr_par_shd.g_old_rec.agency_code				,
		p_altered_pa_request_id_o	 	=>	ghr_par_shd.g_old_rec.altered_pa_request_id		,
		p_annuitant_indicator_o 		=>	ghr_par_shd.g_old_rec.annuitant_indicator			,
		p_annuitant_indicator_desc_o	 	=>	ghr_par_shd.g_old_rec.annuitant_indicator_desc		,
		p_appropriation_code1_o 		=>	ghr_par_shd.g_old_rec.appropriation_code1			,
		p_appropriation_code2_o	 		=>	ghr_par_shd.g_old_rec.appropriation_code2			,
		p_approval_date_o 			=>	ghr_par_shd.g_old_rec.approval_date				,
            p_approving_official_full_na_o      =>    ghr_par_shd.g_old_rec.approving_official_full_name    ,
		p_approving_official_work_ti_o 	=>	ghr_par_shd.g_old_rec.approving_official_work_title	,
     		p_sf50_approval_date_o            	=>	ghr_par_shd.g_old_rec.sf50_approval_date           	,
		p_sf50_approving_ofcl_full_n_o      =>	ghr_par_shd.g_old_rec.sf50_approving_ofcl_full_name   ,
		p_sf50_approving_ofcl_work_t_o      =>	ghr_par_shd.g_old_rec.sf50_approving_ofcl_work_title  ,
		p_authorized_by_person_id_o	 	=>	ghr_par_shd.g_old_rec.authorized_by_person_id		,
		p_authorized_by_title_o 		=>	ghr_par_shd.g_old_rec.authorized_by_title			,
		p_award_amount_o 				=>	ghr_par_shd.g_old_rec.award_amount				,
		p_award_uom_o 				=>	ghr_par_shd.g_old_rec.award_uom				,
		p_bargaining_unit_status_o 		=>	ghr_par_shd.g_old_rec.bargaining_unit_status		,
		p_citizenship_o		 		=>	ghr_par_shd.g_old_rec.citizenship				,
		p_concurrence_date_o 			=>	ghr_par_shd.g_old_rec.concurrence_date			,
		p_custom_pay_calc_flag_o 		=>	ghr_par_shd.g_old_rec.custom_pay_calc_flag		,
		p_duty_station_code_o 			=>	ghr_par_shd.g_old_rec.duty_station_code			,
		p_duty_station_desc_o	 		=>	ghr_par_shd.g_old_rec.duty_station_desc			,
		p_duty_station_id_o 			=>	ghr_par_shd.g_old_rec.duty_station_id			,
		p_duty_station_location_id_o 		=>	ghr_par_shd.g_old_rec.duty_station_location_id		,
		p_education_level_o 			=>	ghr_par_shd.g_old_rec.education_level			,
		p_effective_date_o 			=>	ghr_par_shd.g_old_rec.effective_date			,
		p_employee_assignment_id_o 		=>	ghr_par_shd.g_old_rec.employee_assignment_id		,
		p_employee_date_of_birth_o 		=>	ghr_par_shd.g_old_rec.employee_date_of_birth		,
		p_employee_dept_or_agency_o 		=>	ghr_par_shd.g_old_rec.employee_dept_or_agency		,
		p_employee_first_name_o 		=>	ghr_par_shd.g_old_rec.employee_first_name			,
		p_employee_last_name_o 			=>	ghr_par_shd.g_old_rec.employee_last_name			,
		p_employee_middle_names_o 		=>	ghr_par_shd.g_old_rec.employee_middle_names		,
		p_employee_national_identifi_o 	=>	ghr_par_shd.g_old_rec.employee_national_identifier	,
		p_fegli_o 					=>	ghr_par_shd.g_old_rec.fegli					,
		p_fegli_desc_o 				=>	ghr_par_shd.g_old_rec.fegli_desc				,
		p_first_action_la_code1_o 		=>	ghr_par_shd.g_old_rec.first_action_la_code1		,
		p_first_action_la_code2_o 		=>	ghr_par_shd.g_old_rec.first_action_la_code2		,
		p_first_action_la_desc1_o 		=>	ghr_par_shd.g_old_rec.first_action_la_desc1		,
		p_first_action_la_desc2_o 		=>	ghr_par_shd.g_old_rec.first_action_la_desc2		,
		p_first_noa_cancel_or_correc_o 	=>	ghr_par_shd.g_old_rec.first_noa_cancel_or_correct	,
		p_first_noa_code_o 			=>	ghr_par_shd.g_old_rec.first_noa_code			,
		p_first_noa_desc_o 			=>	ghr_par_shd.g_old_rec.first_noa_desc			,
		p_first_noa_id_o 				=>	ghr_par_shd.g_old_rec.first_noa_id				,
		p_first_noa_pa_request_id_o 		=>	ghr_par_shd.g_old_rec.first_noa_pa_request_id		,
		p_flsa_category_o 			=>	ghr_par_shd.g_old_rec.flsa_category				,
		p_forwarding_address_line1_o	 	=>	ghr_par_shd.g_old_rec.forwarding_address_line1		,
		p_forwarding_address_line2_o 		=>	ghr_par_shd.g_old_rec.forwarding_address_line2		,
		p_forwarding_address_line3_o 		=>	ghr_par_shd.g_old_rec.forwarding_address_line3		,
		p_forwarding_country_o 			=>	ghr_par_shd.g_old_rec.forwarding_country			,
		p_forwarding_country_short_n_o 	=>	ghr_par_shd.g_old_rec.forwarding_country_short_name	,
		p_forwarding_postal_code_o 		=>	ghr_par_shd.g_old_rec.forwarding_postal_code		,
		p_forwarding_region_2_o 		=>	ghr_par_shd.g_old_rec.forwarding_region_2			,
		p_forwarding_town_or_city_o 		=>	ghr_par_shd.g_old_rec.forwarding_town_or_city		,
		p_from_adj_basic_pay_o 			=>	ghr_par_shd.g_old_rec.from_adj_basic_pay			,
		p_from_agency_code_o	 		=>	ghr_par_shd.g_old_rec.from_agency_code			,
		p_from_agency_desc_o 			=>	ghr_par_shd.g_old_rec.from_agency_desc			,
		p_from_basic_pay_o 			=>	ghr_par_shd.g_old_rec.from_basic_pay			,
		p_from_grade_or_level_o 		=>	ghr_par_shd.g_old_rec.from_grade_or_level			,
		p_from_locality_adj_o 			=>	ghr_par_shd.g_old_rec.from_locality_adj			,
		p_from_occ_code_o 			=>	ghr_par_shd.g_old_rec.from_occ_code				,
		p_from_office_symbol_o 			=>	ghr_par_shd.g_old_rec.from_office_symbol			,
		p_from_other_pay_amount_o 		=>	ghr_par_shd.g_old_rec.from_other_pay_amount		,
		p_from_pay_basis_o 			=>	ghr_par_shd.g_old_rec.from_pay_basis			,
		p_from_pay_plan_o		 		=>	ghr_par_shd.g_old_rec.from_pay_plan				,
        -- FWFA Changes Bug#4444609
        -- p_input_pay_rate_determinant_o          => ghr_par_shd.g_old_rec.input_pay_rate_determinant ,
        -- p_from_pay_table_identifier_o      	=>	ghr_par_shd.g_old_rec.from_pay_table_identifier   	,
        -- FWFA Changes
		p_from_position_id_o 			=>	ghr_par_shd.g_old_rec.from_position_id			,
		p_from_position_org_line1_o 		=>	ghr_par_shd.g_old_rec.from_position_org_line1		,
		p_from_position_org_line2_o 		=>	ghr_par_shd.g_old_rec.from_position_org_line2		,
		p_from_position_org_line3_o 		=>	ghr_par_shd.g_old_rec.from_position_org_line3		,
		p_from_position_org_line4_o 		=>	ghr_par_shd.g_old_rec.from_position_org_line4		,
		p_from_position_org_line5_o 		=>	ghr_par_shd.g_old_rec.from_position_org_line5		,
		p_from_position_org_line6_o 		=>	ghr_par_shd.g_old_rec.from_position_org_line6		,
		p_from_position_number_o 		=>	ghr_par_shd.g_old_rec.from_position_number		,
		p_from_position_seq_no_o 		=>	ghr_par_shd.g_old_rec.from_position_seq_no		,
		p_from_position_title_o 		=>	ghr_par_shd.g_old_rec.from_position_title			,
		p_from_step_or_rate_o 			=>	ghr_par_shd.g_old_rec.from_step_or_rate			,
		p_from_total_salary_o 			=>	ghr_par_shd.g_old_rec.from_total_salary			,
		p_functional_class_o 			=>	ghr_par_shd.g_old_rec.functional_class			,
		p_notepad_o 				=>	ghr_par_shd.g_old_rec.notepad					,
		p_part_time_hours_o 			=>	ghr_par_shd.g_old_rec.part_time_hours			,
		p_pay_rate_determinant_o	 	=>	ghr_par_shd.g_old_rec.pay_rate_determinant		,
		p_personnel_office_id_o 		=>	ghr_par_shd.g_old_rec.personnel_office_id			,
		p_person_id_o			 	=>	ghr_par_shd.g_old_rec.person_id				,
		p_position_occupied_o	 		=>	ghr_par_shd.g_old_rec.position_occupied			,
		p_proposed_effective_date_o 		=>	ghr_par_shd.g_old_rec.proposed_effective_date		,
		p_requested_by_person_id_o 		=>	ghr_par_shd.g_old_rec.requested_by_person_id		,
		p_requested_by_title_o 			=>	ghr_par_shd.g_old_rec.requested_by_title			,
		p_requested_date_o			=>	ghr_par_shd.g_old_rec.requested_date			,
		p_requesting_office_remark_d_o 	=>	ghr_par_shd.g_old_rec.requesting_office_remarks_desc	,
		p_requesting_office_remark_f_o 	=>	ghr_par_shd.g_old_rec.requesting_office_remarks_flag	,
		p_request_number_o 			=>	ghr_par_shd.g_old_rec.request_number			,
		p_resign_and_retire_reason_d_o 	=>	ghr_par_shd.g_old_rec.resign_and_retire_reason_desc	,
		p_retirement_plan_o			=>	ghr_par_shd.g_old_rec.retirement_plan			,
		p_retirement_plan_desc_o	 	=>	ghr_par_shd.g_old_rec.retirement_plan_desc		,
		p_second_action_la_code1_o 		=>	ghr_par_shd.g_old_rec.second_action_la_code1		,
		p_second_action_la_code2_o 		=>	ghr_par_shd.g_old_rec.second_action_la_code2		,
		p_second_action_la_desc1_o 		=>	ghr_par_shd.g_old_rec.second_action_la_desc1		,
		p_second_action_la_desc2_o 		=>	ghr_par_shd.g_old_rec.second_action_la_desc2		,
		p_second_noa_cancel_or_corre_o	=>	ghr_par_shd.g_old_rec.second_noa_cancel_or_correct	,
		p_second_noa_code_o			=>	ghr_par_shd.g_old_rec.second_noa_code			,
		p_second_noa_desc_o			=>	ghr_par_shd.g_old_rec.second_noa_desc			,
		p_second_noa_id_o				=>	ghr_par_shd.g_old_rec.second_noa_id				,
		p_second_noa_pa_request_id_o		=>	ghr_par_shd.g_old_rec.second_noa_pa_request_id		,
		p_service_comp_date_o			=>	ghr_par_shd.g_old_rec.service_comp_date			,
                p_status_o                              =>      ghr_par_shd.g_old_rec.status                           ,
		p_supervisory_status_o			=>	ghr_par_shd.g_old_rec.supervisory_status			,
		p_tenure_o					=>	ghr_par_shd.g_old_rec.tenure					,
		p_to_adj_basic_pay_o			=>	ghr_par_shd.g_old_rec.to_adj_basic_pay			,
		p_to_basic_pay_o				=>	ghr_par_shd.g_old_rec.to_basic_pay				,
		p_to_grade_id_o				=>	ghr_par_shd.g_old_rec.to_grade_id				,
		p_to_grade_or_level_o			=>	ghr_par_shd.g_old_rec.to_grade_or_level			,
		p_to_job_id_o				=>	ghr_par_shd.g_old_rec.to_job_id				,
		p_to_locality_adj_o			=>	ghr_par_shd.g_old_rec.to_locality_adj			,
		p_to_occ_code_o				=>	ghr_par_shd.g_old_rec.to_occ_code				,
		p_to_office_symbol_o			=>	ghr_par_shd.g_old_rec.to_office_symbol			,
		p_to_organization_id_o			=>	ghr_par_shd.g_old_rec.to_organization_id			,
		p_to_other_pay_amount_o			=>	ghr_par_shd.g_old_rec.to_other_pay_amount			,
		p_to_au_overtime_o			=>	ghr_par_shd.g_old_rec.to_au_overtime			,
		p_to_auo_premium_pay_indicat_o	=>	ghr_par_shd.g_old_rec.to_auo_premium_pay_indicator	,
		p_to_availability_pay_o			=>	ghr_par_shd.g_old_rec.to_availability_pay			,
		p_to_ap_premium_pay_indicato_o	=>	ghr_par_shd.g_old_rec.to_ap_premium_pay_indicator	,
		p_to_retention_allowance_o		=>	ghr_par_shd.g_old_rec.to_retention_allowance		,
		p_to_supervisory_differentia_o	=>	ghr_par_shd.g_old_rec.to_supervisory_differential	,
		p_to_staffing_differential_o		=>	ghr_par_shd.g_old_rec.to_staffing_differential		,
		p_to_pay_basis_o				=>	ghr_par_shd.g_old_rec.to_pay_basis				,
		p_to_pay_plan_o				=>	ghr_par_shd.g_old_rec.to_pay_plan				,
        -- FWFA Changes Bug#4444609
        -- p_to_pay_table_identifier_o      	=>	ghr_par_shd.g_old_rec.to_pay_table_identifier        	,
        -- FWFA Changes
		p_to_position_id_o			=>	ghr_par_shd.g_old_rec.to_position_id			,
		p_to_position_org_line1_o		=>	ghr_par_shd.g_old_rec.to_position_org_line1		,
		p_to_position_org_line2_o		=>	ghr_par_shd.g_old_rec.to_position_org_line2		,
		p_to_position_org_line3_o		=>	ghr_par_shd.g_old_rec.to_position_org_line3		,
		p_to_position_org_line4_o		=>	ghr_par_shd.g_old_rec.to_position_org_line4		,
		p_to_position_org_line5_o		=>	ghr_par_shd.g_old_rec.to_position_org_line5		,
		p_to_position_org_line6_o		=>	ghr_par_shd.g_old_rec.to_position_org_line6		,
		p_to_position_number_o			=>	ghr_par_shd.g_old_rec.to_position_number			,
		p_to_position_seq_no_o			=>	ghr_par_shd.g_old_rec.to_position_seq_no			,
		p_to_position_title_o			=>	ghr_par_shd.g_old_rec.to_position_title			,
		p_to_step_or_rate_o			=>	ghr_par_shd.g_old_rec.to_step_or_rate			,
		p_to_total_salary_o			=>	ghr_par_shd.g_old_rec.to_total_salary			,
		p_veterans_preference_o			=>	ghr_par_shd.g_old_rec.veterans_preference			,
		p_veterans_pref_for_rif_o		=>	ghr_par_shd.g_old_rec.veterans_pref_for_rif		,
		p_veterans_status_o			=>	ghr_par_shd.g_old_rec.veterans_status			,
		p_work_schedule_o				=>	ghr_par_shd.g_old_rec.work_schedule				,
		p_work_schedule_desc_o			=>	ghr_par_shd.g_old_rec.work_schedule_desc			,
		p_year_degree_attained_o		=>	ghr_par_shd.g_old_rec.year_degree_attained		,
		p_first_noa_information1_o		=>	ghr_par_shd.g_old_rec.first_noa_information1		,
		p_first_noa_information2_o		=>	ghr_par_shd.g_old_rec.first_noa_information2		,
		p_first_noa_information3_o		=>	ghr_par_shd.g_old_rec.first_noa_information3		,
		p_first_noa_information4_o		=>	ghr_par_shd.g_old_rec.first_noa_information4		,
		p_first_noa_information5_o		=>	ghr_par_shd.g_old_rec.first_noa_information5	,
		p_second_lac1_information1_o		=>	ghr_par_shd.g_old_rec.second_lac1_information1	,
		p_second_lac1_information2_o		=>	ghr_par_shd.g_old_rec.second_lac1_information2	,
		p_second_lac1_information3_o		=>	ghr_par_shd.g_old_rec.second_lac1_information3	,
		p_second_lac1_information4_o		=>	ghr_par_shd.g_old_rec.second_lac1_information4	,
		p_second_lac1_information5_o		=>	ghr_par_shd.g_old_rec.second_lac1_information5	,
		p_second_lac2_information1_o		=>	ghr_par_shd.g_old_rec.second_lac2_information1	,
		p_second_lac2_information2_o		=>	ghr_par_shd.g_old_rec.second_lac2_information2	,
		p_second_lac2_information3_o		=>	ghr_par_shd.g_old_rec.second_lac2_information3	,
		p_second_lac2_information4_o		=>	ghr_par_shd.g_old_rec.second_lac2_information4	,
		p_second_lac2_information5_o		=>	ghr_par_shd.g_old_rec.second_lac2_information5	,
		p_second_noa_information1_o		=>	ghr_par_shd.g_old_rec.second_noa_information1	,
		p_second_noa_information2_o		=>	ghr_par_shd.g_old_rec.second_noa_information2	,
		p_second_noa_information3_o		=>	ghr_par_shd.g_old_rec.second_noa_information3	,
		p_second_noa_information4_o		=>	ghr_par_shd.g_old_rec.second_noa_information4	,
		p_second_noa_information5_o		=>	ghr_par_shd.g_old_rec.second_noa_information5	,
		p_first_lac1_information1_o		=>	ghr_par_shd.g_old_rec.first_lac1_information1	,
		p_first_lac1_information2_o		=>	ghr_par_shd.g_old_rec.first_lac1_information2	,
		p_first_lac1_information3_o		=>	ghr_par_shd.g_old_rec.first_lac1_information3	,
		p_first_lac1_information4_o		=>	ghr_par_shd.g_old_rec.first_lac1_information4	,
		p_first_lac1_information5_o		=>	ghr_par_shd.g_old_rec.first_lac1_information5	,
		p_first_lac2_information1_o		=>	ghr_par_shd.g_old_rec.first_lac2_information1	,
		p_first_lac2_information2_o		=>	ghr_par_shd.g_old_rec.first_lac2_information2	,
		p_first_lac2_information3_o		=>	ghr_par_shd.g_old_rec.first_lac2_information3	,
		p_first_lac2_information4_o		=>	ghr_par_shd.g_old_rec.first_lac2_information4	,
		p_first_lac2_information5_o		=>	ghr_par_shd.g_old_rec.first_lac2_information5	,
		p_attribute_category_o			=>	ghr_par_shd.g_old_rec.attribute_category		,
		p_attribute1_o				=>	ghr_par_shd.g_old_rec.attribute1			,
		p_attribute2_o				=>	ghr_par_shd.g_old_rec.attribute2			,
		p_attribute3_o				=>	ghr_par_shd.g_old_rec.attribute3			,
		p_attribute4_o				=>	ghr_par_shd.g_old_rec.attribute4			,
		p_attribute5_o				=>	ghr_par_shd.g_old_rec.attribute5			,
		p_attribute6_o				=>	ghr_par_shd.g_old_rec.attribute6			,
		p_attribute7_o				=>	ghr_par_shd.g_old_rec.attribute7			,
		p_attribute8_o				=>	ghr_par_shd.g_old_rec.attribute8			,
		p_attribute9_o				=>	ghr_par_shd.g_old_rec.attribute9			,
		p_attribute10_o				=>	ghr_par_shd.g_old_rec.attribute10			,
		p_attribute11_o				=>	ghr_par_shd.g_old_rec.attribute11			,
		p_attribute12_o				=>	ghr_par_shd.g_old_rec.attribute12			,
		p_attribute13_o				=>	ghr_par_shd.g_old_rec.attribute13			,
		p_attribute14_o				=>	ghr_par_shd.g_old_rec.attribute14			,
		p_attribute15_o				=>	ghr_par_shd.g_old_rec.attribute15			,
		p_attribute16_o				=>	ghr_par_shd.g_old_rec.attribute16			,
		p_attribute17_o				=>	ghr_par_shd.g_old_rec.attribute17			,
		p_attribute18_o				=>	ghr_par_shd.g_old_rec.attribute18			,
		p_attribute19_o				=>	ghr_par_shd.g_old_rec.attribute19			,
		p_attribute20_o				=>	ghr_par_shd.g_old_rec.attribute20		      ,
            p_first_noa_canc_pa_request_o       =>    ghr_par_shd.g_old_rec.first_noa_canc_pa_request_id  ,
            p_second_noa_canc_pa_request_o      =>    ghr_par_shd.g_old_rec.second_noa_canc_pa_request_id ,
            p_to_retention_allow_percent_o      =>    ghr_par_shd.g_old_rec.to_retention_allow_percentage ,
            p_to_supervisory_diff_percen_o      =>    ghr_par_shd.g_old_rec.to_supervisory_diff_percentage,
            p_to_staffing_diff_percentag_o      =>    ghr_par_shd.g_old_rec.to_staffing_diff_percentage   ,
            p_award_percentage_o                =>    ghr_par_shd.g_old_rec.award_percentage               ,
            p_rpa_type_o                        =>    ghr_par_shd.g_old_rec.rpa_type,
            p_mass_action_id_o                  =>    ghr_par_shd.g_old_rec.mass_action_id,
            p_mass_action_eligible_flag_o       =>    ghr_par_shd.g_old_rec.mass_action_eligible_flag,
            p_mass_action_select_flag_o         =>    ghr_par_shd.g_old_rec.mass_action_select_flag,
            p_mass_action_comments_o            =>    ghr_par_shd.g_old_rec.mass_action_comments
     );
     exception
        when hr_api.cannot_find_prog_unit then
             hr_api.cannot_find_prog_unit_error
		 (	p_module_name => 'GHR_PA_REQUESTS'
		 	,p_hook_type  => 'AD'
	        );
  end;
  -- End of API User Hook for post_delete.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_rec	      in ghr_par_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  ghr_par_shd.lck
	(
	p_rec.pa_request_id,
      p_rec.routing_group_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  ghr_par_bus.delete_validate(p_rec);
  --
  -- Call the supporting pre-delete operation
  --
  pre_delete(p_rec);
  --
  -- Delete the row.
  --
  delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  post_delete(p_rec);
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_pa_request_id                      in number,
  p_object_version_number              in number
  ) is
--
  l_rec	  ghr_par_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.pa_request_id:= p_pa_request_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the par_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end ghr_par_del;

/
