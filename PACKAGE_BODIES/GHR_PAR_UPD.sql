--------------------------------------------------------
--  DDL for Package Body GHR_PAR_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PAR_UPD" as
/* $Header: ghparrhi.pkb 120.5.12010000.3 2008/10/22 07:10:55 utokachi ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ghr_par_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml update logic. The processing of
--   this procedure is:
--   1) Increment the object_version_number by 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To update the specified row in the schema using the primary key in
--      the predicates.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be updated in the schema.
--
-- Post Failure:
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.

--
-- Developer Implementation Notes:
--   The update 'set' attribute list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml(p_rec in out nocopy ghr_par_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  --
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  --
  -- Update the ghr_pa_requests Row
  --
  update ghr_pa_requests
  set
  pa_request_id                     = p_rec.pa_request_id,
  pa_notification_id                = p_rec.pa_notification_id,
  noa_family_code                   = p_rec.noa_family_code,
  routing_group_id                  = p_rec.routing_group_id,
  proposed_effective_asap_flag      = p_rec.proposed_effective_asap_flag,
  academic_discipline               = p_rec.academic_discipline,
  additional_info_person_id         = p_rec.additional_info_person_id,
  additional_info_tel_number        = p_rec.additional_info_tel_number,
  agency_code                       = p_rec.agency_code,
  altered_pa_request_id             = p_rec.altered_pa_request_id,
  annuitant_indicator               = p_rec.annuitant_indicator,
  annuitant_indicator_desc          = p_rec.annuitant_indicator_desc,
  appropriation_code1               = p_rec.appropriation_code1,
  appropriation_code2               = p_rec.appropriation_code2,
  approval_date                     = p_rec.approval_date,
  approving_official_full_name      = p_rec.approving_official_full_name,
  approving_official_work_title     = p_rec.approving_official_work_title,
  sf50_approval_date                = p_rec.sf50_approval_date,
  sf50_approving_ofcl_full_name     = p_rec.sf50_approving_ofcl_full_name,
  sf50_approving_ofcl_work_title    = p_rec.sf50_approving_ofcl_work_title,
  authorized_by_person_id           = p_rec.authorized_by_person_id,
  authorized_by_title               = p_rec.authorized_by_title,
  award_amount                      = p_rec.award_amount,
  award_uom                         = p_rec.award_uom,
  bargaining_unit_status            = p_rec.bargaining_unit_status,
  citizenship                       = p_rec.citizenship,
  concurrence_date                  = p_rec.concurrence_date,
  custom_pay_calc_flag              = p_rec.custom_pay_calc_flag,
  duty_station_code                 = p_rec.duty_station_code,
  duty_station_desc                 = p_rec.duty_station_desc,
  duty_station_id                   = p_rec.duty_station_id,
  duty_station_location_id          = p_rec.duty_station_location_id,
  education_level                   = p_rec.education_level,
  effective_date                    = p_rec.effective_date,
  employee_assignment_id            = p_rec.employee_assignment_id,
  employee_date_of_birth            = p_rec.employee_date_of_birth,
  employee_dept_or_agency           = p_rec.employee_dept_or_agency,
  employee_first_name               = p_rec.employee_first_name,
  employee_last_name                = p_rec.employee_last_name,
  employee_middle_names             = p_rec.employee_middle_names,
  employee_national_identifier      = p_rec.employee_national_identifier,
  fegli                             = p_rec.fegli,
  fegli_desc                        = p_rec.fegli_desc,
  first_action_la_code1             = p_rec.first_action_la_code1,
  first_action_la_code2             = p_rec.first_action_la_code2,
  first_action_la_desc1             = p_rec.first_action_la_desc1,
  first_action_la_desc2             = p_rec.first_action_la_desc2,
  first_noa_cancel_or_correct       = p_rec.first_noa_cancel_or_correct,
  first_noa_code                    = p_rec.first_noa_code,
  first_noa_desc                    = p_rec.first_noa_desc,
  first_noa_id                      = p_rec.first_noa_id,
  first_noa_pa_request_id           = p_rec.first_noa_pa_request_id,
  flsa_category                     = p_rec.flsa_category,
  forwarding_address_line1          = p_rec.forwarding_address_line1,
  forwarding_address_line2          = p_rec.forwarding_address_line2,
  forwarding_address_line3          = p_rec.forwarding_address_line3,
  forwarding_country                = p_rec.forwarding_country,
  forwarding_country_short_name     = p_rec.forwarding_country_short_name,
  forwarding_postal_code            = p_rec.forwarding_postal_code,
  forwarding_region_2               = p_rec.forwarding_region_2,
  forwarding_town_or_city           = p_rec.forwarding_town_or_city,
  from_adj_basic_pay                = p_rec.from_adj_basic_pay,
  from_agency_code                  = p_rec.from_agency_code,
  from_agency_desc                  = p_rec.from_agency_desc,
  from_basic_pay                    = p_rec.from_basic_pay,
  from_grade_or_level               = p_rec.from_grade_or_level,
  from_locality_adj                 = p_rec.from_locality_adj,
  from_occ_code                     = p_rec.from_occ_code,
  from_office_symbol                = p_rec.from_office_symbol,
  from_other_pay_amount             = p_rec.from_other_pay_amount,
  from_pay_basis                    = p_rec.from_pay_basis,
  from_pay_plan                     = p_rec.from_pay_plan,
  -- FWFA Changes Bug#4444609
  input_pay_rate_determinant        = p_rec.input_pay_rate_determinant,
  from_pay_table_identifier         = p_rec.from_pay_table_identifier,
  -- FWFA Changes
  from_position_id                  = p_rec.from_position_id,
  from_position_org_line1           = p_rec.from_position_org_line1,
  from_position_org_line2           = p_rec.from_position_org_line2,
  from_position_org_line3           = p_rec.from_position_org_line3,
  from_position_org_line4           = p_rec.from_position_org_line4,
  from_position_org_line5           = p_rec.from_position_org_line5,
  from_position_org_line6           = p_rec.from_position_org_line6,
  from_position_number              = p_rec.from_position_number,
  from_position_seq_no              = p_rec.from_position_seq_no,
  from_position_title               = p_rec.from_position_title,
  from_step_or_rate                 = p_rec.from_step_or_rate,
  from_total_salary                 = p_rec.from_total_salary,
  functional_class                  = p_rec.functional_class,
  notepad                           = p_rec.notepad,
  part_time_hours                   = p_rec.part_time_hours,
  pay_rate_determinant              = p_rec.pay_rate_determinant,
  personnel_office_id               = p_rec.personnel_office_id,
  person_id                         = p_rec.person_id,
  position_occupied                 = p_rec.position_occupied,
  proposed_effective_date           = p_rec.proposed_effective_date,
  requested_by_person_id            = p_rec.requested_by_person_id,
  requested_by_title                = p_rec.requested_by_title,
  requested_date                    = p_rec.requested_date,
  requesting_office_remarks_desc    = p_rec.requesting_office_remarks_desc,
  requesting_office_remarks_flag    = p_rec.requesting_office_remarks_flag,
  request_number                    = p_rec.request_number,
  resign_and_retire_reason_desc     = p_rec.resign_and_retire_reason_desc,
  retirement_plan                   = p_rec.retirement_plan,
  retirement_plan_desc              = p_rec.retirement_plan_desc,
  second_action_la_code1            = p_rec.second_action_la_code1,
  second_action_la_code2            = p_rec.second_action_la_code2,
  second_action_la_desc1            = p_rec.second_action_la_desc1,
  second_action_la_desc2            = p_rec.second_action_la_desc2,
  second_noa_cancel_or_correct      = p_rec.second_noa_cancel_or_correct,
  second_noa_code                   = p_rec.second_noa_code,
  second_noa_desc                   = p_rec.second_noa_desc,
  second_noa_id                     = p_rec.second_noa_id,
  second_noa_pa_request_id          = p_rec.second_noa_pa_request_id,
  service_comp_date                 = p_rec.service_comp_date,
  status                            = p_rec.status,
  supervisory_status                = p_rec.supervisory_status,
  tenure                            = p_rec.tenure,
  to_adj_basic_pay                  = p_rec.to_adj_basic_pay,
  to_basic_pay                      = p_rec.to_basic_pay,
  to_grade_id                       = p_rec.to_grade_id,
  to_grade_or_level                 = p_rec.to_grade_or_level,
  to_job_id                         = p_rec.to_job_id,
  to_locality_adj                   = p_rec.to_locality_adj,
  to_occ_code                       = p_rec.to_occ_code,
  to_office_symbol                  = p_rec.to_office_symbol,
  to_organization_id                = p_rec.to_organization_id,
  to_other_pay_amount               = p_rec.to_other_pay_amount,
  to_au_overtime                    = p_rec.to_au_overtime,
  to_auo_premium_pay_indicator      = p_rec.to_auo_premium_pay_indicator,
  to_availability_pay               = p_rec.to_availability_pay,
  to_ap_premium_pay_indicator       = p_rec.to_ap_premium_pay_indicator,
  to_retention_allowance            = p_rec.to_retention_allowance,
  to_supervisory_differential       = p_rec.to_supervisory_differential,
  to_staffing_differential          = p_rec.to_staffing_differential,
  to_pay_basis                      = p_rec.to_pay_basis,
  to_pay_plan                       = p_rec.to_pay_plan,
  -- FWFA Changes Bug#4444609
  to_pay_table_identifier           = p_rec.to_pay_table_identifier,
  -- FWFA Changes
  to_position_id                    = p_rec.to_position_id,
  to_position_org_line1             = p_rec.to_position_org_line1,
  to_position_org_line2             = p_rec.to_position_org_line2,
  to_position_org_line3             = p_rec.to_position_org_line3,
  to_position_org_line4             = p_rec.to_position_org_line4,
  to_position_org_line5             = p_rec.to_position_org_line5,
  to_position_org_line6             = p_rec.to_position_org_line6,
  to_position_number                = p_rec.to_position_number,
  to_position_seq_no                = p_rec.to_position_seq_no,
  to_position_title                 = p_rec.to_position_title,
  to_step_or_rate                   = p_rec.to_step_or_rate,
  to_total_salary                   = p_rec.to_total_salary,
  veterans_preference               = p_rec.veterans_preference,
  veterans_pref_for_rif             = p_rec.veterans_pref_for_rif,
  veterans_status                   = p_rec.veterans_status,
  work_schedule                     = p_rec.work_schedule,
  work_schedule_desc                = p_rec.work_schedule_desc,
  year_degree_attained              = p_rec.year_degree_attained,
  first_noa_information1            = p_rec.first_noa_information1,
  first_noa_information2            = p_rec.first_noa_information2,
  first_noa_information3            = p_rec.first_noa_information3,
  first_noa_information4            = p_rec.first_noa_information4,
  first_noa_information5            = p_rec.first_noa_information5,
  second_lac1_information1          = p_rec.second_lac1_information1,
  second_lac1_information2          = p_rec.second_lac1_information2,
  second_lac1_information3          = p_rec.second_lac1_information3,
  second_lac1_information4          = p_rec.second_lac1_information4,
  second_lac1_information5          = p_rec.second_lac1_information5,
  second_lac2_information1          = p_rec.second_lac2_information1,
  second_lac2_information2          = p_rec.second_lac2_information2,
  second_lac2_information3          = p_rec.second_lac2_information3,
  second_lac2_information4          = p_rec.second_lac2_information4,
  second_lac2_information5          = p_rec.second_lac2_information5,
  second_noa_information1           = p_rec.second_noa_information1,
  second_noa_information2           = p_rec.second_noa_information2,
  second_noa_information3           = p_rec.second_noa_information3,
  second_noa_information4           = p_rec.second_noa_information4,
  second_noa_information5           = p_rec.second_noa_information5,
  first_lac1_information1           = p_rec.first_lac1_information1,
  first_lac1_information2           = p_rec.first_lac1_information2,
  first_lac1_information3           = p_rec.first_lac1_information3,
  first_lac1_information4           = p_rec.first_lac1_information4,
  first_lac1_information5           = p_rec.first_lac1_information5,
  first_lac2_information1           = p_rec.first_lac2_information1,
  first_lac2_information2           = p_rec.first_lac2_information2,
  first_lac2_information3           = p_rec.first_lac2_information3,
  first_lac2_information4           = p_rec.first_lac2_information4,
  first_lac2_information5           = p_rec.first_lac2_information5,
  attribute_category                = p_rec.attribute_category,
  attribute1                        = p_rec.attribute1,
  attribute2                        = p_rec.attribute2,
  attribute3                        = p_rec.attribute3,
  attribute4                        = p_rec.attribute4,
  attribute5                        = p_rec.attribute5,
  attribute6                        = p_rec.attribute6,
  attribute7                        = p_rec.attribute7,
  attribute8                        = p_rec.attribute8,
  attribute9                        = p_rec.attribute9,
  attribute10                       = p_rec.attribute10,
  attribute11                       = p_rec.attribute11,
  attribute12                       = p_rec.attribute12,
  attribute13                       = p_rec.attribute13,
  attribute14                       = p_rec.attribute14,
  attribute15                       = p_rec.attribute15,
  attribute16                       = p_rec.attribute16,
  attribute17                       = p_rec.attribute17,
  attribute18                       = p_rec.attribute18,
  attribute19                       = p_rec.attribute19,
  attribute20                       = p_rec.attribute20,
  object_version_number             = p_rec.object_version_number               ,
  first_noa_canc_pa_request_id      = p_rec.first_noa_canc_pa_request_id        ,
  second_noa_canc_pa_request_id     = p_rec.second_noa_canc_pa_request_id       ,
  to_retention_allow_percentage     = p_rec.to_retention_allow_percentage       ,
  to_supervisory_diff_percentage    = p_rec.to_supervisory_diff_percentage      ,
  to_staffing_diff_percentage       = p_rec.to_staffing_diff_percentage         ,
  award_percentage                  = p_rec.award_percentage               ,
  rpa_type                          = p_rec.rpa_type,
  mass_action_id                    = p_rec.mass_action_id,
  mass_action_eligible_flag         = p_rec.mass_action_eligible_flag,
  mass_action_select_flag           = p_rec.mass_action_select_flag,
  mass_action_comments              = p_rec.mass_action_comments,
  -- Bug# RRR Changes
  pa_incentive_payment_option       = p_rec.payment_option,
  award_salary                      = p_rec.award_salary
  -- Bug#  RRR Changes
  where pa_request_id = p_rec.pa_request_id;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ghr_par_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ghr_par_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ghr_par_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    Raise;
End update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
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
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update(p_rec in ghr_par_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
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
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update(p_rec in ghr_par_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- This is a hook point and the user hook for post_update is called here.
  --
  begin
     ghr_par_rku.after_update	(
		p_pa_request_id                 	=>	p_rec.pa_request_id                 	,
		p_pa_notification_id            	=>	p_rec.pa_notification_id            	,
		p_noa_family_code               	=>	p_rec.noa_family_code               	,
		p_routing_group_id              	=>	p_rec.routing_group_id              	,
		p_proposed_effective_asap_flag  	=>	p_rec.proposed_effective_asap_flag  	,
		p_academic_discipline           	=>	p_rec.academic_discipline           	,
		p_additional_info_person_id     	=>	p_rec.additional_info_person_id     	,
		p_additional_info_tel_number    	=>	p_rec.additional_info_tel_number    	,
		p_agency_code                   	=>	p_rec.agency_code                   	,
		p_altered_pa_request_id         	=>	p_rec.altered_pa_request_id         	,
		p_annuitant_indicator           	=>	p_rec.annuitant_indicator           	,
		p_annuitant_indicator_desc      	=>	p_rec.annuitant_indicator_desc      	,
		p_appropriation_code1           	=>	p_rec.appropriation_code1           	,
		p_appropriation_code2           	=>	p_rec.appropriation_code2           	,
		p_approval_date                 	=>	p_rec.approval_date                 	,
            p_approving_official_full_name      =>    p_rec.approving_official_full_name        ,
		p_approving_official_work_titl  	=>	p_rec.approving_official_work_title  	,
		p_sf50_approval_date                =>	p_rec.sf50_approval_date            	,
            p_sf50_approving_ofcl_full_nam      =>    p_rec.sf50_approving_ofcl_full_name      ,
		p_sf50_approving_ofcl_work_tit  	=>	p_rec.sf50_approving_ofcl_work_title  	,
		p_authorized_by_person_id       	=>	p_rec.authorized_by_person_id       	,
		p_authorized_by_title           	=>	p_rec.authorized_by_title           	,
		p_award_amount                  	=>	p_rec.award_amount                  	,
		p_award_uom                     	=>	p_rec.award_uom                     	,
		p_bargaining_unit_status        	=>	p_rec.bargaining_unit_status        	,
		p_citizenship                   	=>	p_rec.citizenship                   	,
		p_concurrence_date              	=>	p_rec.concurrence_date              	,
		p_custom_pay_calc_flag          	=>	p_rec.custom_pay_calc_flag          	,
		p_duty_station_code             	=>	p_rec.duty_station_code             	,
		p_duty_station_desc             	=>	p_rec.duty_station_desc             	,
		p_duty_station_id               	=>	p_rec.duty_station_id               	,
		p_duty_station_location_id      	=>	p_rec.duty_station_location_id      	,
		p_education_level               	=>	p_rec.education_level               	,
		p_effective_date                	=>	p_rec.effective_date                	,
		p_employee_assignment_id        	=>	p_rec.employee_assignment_id        	,
		p_employee_date_of_birth        	=>	p_rec.employee_date_of_birth        	,
		p_employee_dept_or_agency       	=>	p_rec.employee_dept_or_agency       	,
		p_employee_first_name           	=>	p_rec.employee_first_name           	,
		p_employee_last_name            	=>	p_rec.employee_last_name            	,
		p_employee_middle_names         	=>	p_rec.employee_middle_names         	,
		p_employee_national_identifier  	=>	p_rec.employee_national_identifier  	,
		p_fegli                         	=>	p_rec.fegli                         	,
		p_fegli_desc                    	=>	p_rec.fegli_desc                    	,
		p_first_action_la_code1         	=>	p_rec.first_action_la_code1         	,
		p_first_action_la_code2         	=>	p_rec.first_action_la_code2         	,
		p_first_action_la_desc1         	=>	p_rec.first_action_la_desc1         	,
		p_first_action_la_desc2         	=>	p_rec.first_action_la_desc2         	,
		p_first_noa_cancel_or_correct   	=>	p_rec.first_noa_cancel_or_correct   	,
		p_first_noa_code                	=>	p_rec.first_noa_code                	,
		p_first_noa_desc                	=>	p_rec.first_noa_desc                	,
		p_first_noa_id                  	=>	p_rec.first_noa_id                  	,
		p_first_noa_pa_request_id       	=>	p_rec.first_noa_pa_request_id       	,
		p_flsa_category                 	=>	p_rec.flsa_category                 	,
		p_forwarding_address_line1      	=>	p_rec.forwarding_address_line1      	,
		p_forwarding_address_line2      	=>	p_rec.forwarding_address_line2      	,
		p_forwarding_address_line3      	=>	p_rec.forwarding_address_line3      	,
		p_forwarding_country            	=>	p_rec.forwarding_country            	,
		p_forwarding_country_short_nam  	=>	p_rec.forwarding_country_short_name  	,
		p_forwarding_postal_code        	=>	p_rec.forwarding_postal_code        	,
		p_forwarding_region_2           	=>	p_rec.forwarding_region_2           	,
		p_forwarding_town_or_city       	=>	p_rec.forwarding_town_or_city       	,
		p_from_adj_basic_pay            	=>	p_rec.from_adj_basic_pay            	,
		p_from_agency_code              	=>	p_rec.from_agency_code              	,
		p_from_agency_desc              	=>	p_rec.from_agency_desc              	,
		p_from_basic_pay                	=>	p_rec.from_basic_pay                	,
		p_from_grade_or_level           	=>	p_rec.from_grade_or_level           	,
		p_from_locality_adj             	=>	p_rec.from_locality_adj             	,
		p_from_occ_code                 	=>	p_rec.from_occ_code                 	,
		p_from_office_symbol            	=>	p_rec.from_office_symbol            	,
		p_from_other_pay_amount         	=>	p_rec.from_other_pay_amount         	,
		p_from_pay_basis                	=>	p_rec.from_pay_basis                	,
		p_from_pay_plan                 	=>	p_rec.from_pay_plan                 	,
        -- FWFA Changes Bug#4444609
        -- p_input_pay_rate_determinant        	=>	p_rec.input_pay_rate_determinant      	,
        -- p_from_pay_table_identifier        	=>	p_rec.from_pay_table_identifier    	,
        -- FWFA Changes
		p_from_position_id              	=>	p_rec.from_position_id              	,
		p_from_position_org_line1       	=>	p_rec.from_position_org_line1       	,
		p_from_position_org_line2       	=>	p_rec.from_position_org_line2       	,
		p_from_position_org_line3       	=>	p_rec.from_position_org_line3       	,
		p_from_position_org_line4       	=>	p_rec.from_position_org_line4       	,
		p_from_position_org_line5       	=>	p_rec.from_position_org_line5       	,
		p_from_position_org_line6       	=>	p_rec.from_position_org_line6       	,
		p_from_position_number          	=>	p_rec.from_position_number          	,
		p_from_position_seq_no          	=>	p_rec.from_position_seq_no          	,
		p_from_position_title           	=>	p_rec.from_position_title           	,
		p_from_step_or_rate             	=>	p_rec.from_step_or_rate             	,
		p_from_total_salary             	=>	p_rec.from_total_salary             	,
		p_functional_class              	=>	p_rec.functional_class              	,
		p_notepad                       	=>	p_rec.notepad                       	,
		p_part_time_hours               	=>	p_rec.part_time_hours               	,
		p_pay_rate_determinant          	=>	p_rec.pay_rate_determinant          	,
		p_personnel_office_id           	=>	p_rec.personnel_office_id           	,
		p_person_id                     	=>	p_rec.person_id                     	,
		p_position_occupied             	=>	p_rec.position_occupied             	,
		p_proposed_effective_date       	=>	p_rec.proposed_effective_date       	,
		p_requested_by_person_id        	=>	p_rec.requested_by_person_id        	,
		p_requested_by_title            	=>	p_rec.requested_by_title            	,
		p_requested_date                	=>	p_rec.requested_date                	,
		p_requesting_office_remarks_de  	=>	p_rec.requesting_office_remarks_desc  	,
		p_requesting_office_remarks_fl  	=>	p_rec.requesting_office_remarks_flag  	,
		p_request_number                	=>	p_rec.request_number                	,
		p_resign_and_retire_reason_des  	=>	p_rec.resign_and_retire_reason_desc  	,
		p_retirement_plan               	=>	p_rec.retirement_plan               	,
		p_retirement_plan_desc          	=>	p_rec.retirement_plan_desc          	,
		p_second_action_la_code1        	=>	p_rec.second_action_la_code1        	,
		p_second_action_la_code2        	=>	p_rec.second_action_la_code2        	,
		p_second_action_la_desc1        	=>	p_rec.second_action_la_desc1        	,
		p_second_action_la_desc2        	=>	p_rec.second_action_la_desc2        	,
		p_second_noa_cancel_or_correct  	=>	p_rec.second_noa_cancel_or_correct  	,
		p_second_noa_code               	=>	p_rec.second_noa_code               	,
		p_second_noa_desc               	=>	p_rec.second_noa_desc               	,
		p_second_noa_id                 	=>	p_rec.second_noa_id                 	,
		p_second_noa_pa_request_id      	=>	p_rec.second_noa_pa_request_id      	,
		p_service_comp_date             	=>	p_rec.service_comp_date             	,
                p_status                                =>      p_rec.status,
		p_supervisory_status            	=>	p_rec.supervisory_status            	,
		p_tenure                        	=>	p_rec.tenure                        	,
		p_to_adj_basic_pay              	=>	p_rec.to_adj_basic_pay              	,
		p_to_basic_pay                  	=>	p_rec.to_basic_pay                  	,
		p_to_grade_id                   	=>	p_rec.to_grade_id                   	,
		p_to_grade_or_level             	=>	p_rec.to_grade_or_level             	,
		p_to_job_id                     	=>	p_rec.to_job_id                     	,
		p_to_locality_adj               	=>	p_rec.to_locality_adj               	,
		p_to_occ_code                   	=>	p_rec.to_occ_code                   	,
		p_to_office_symbol              	=>	p_rec.to_office_symbol              	,
		p_to_organization_id            	=>	p_rec.to_organization_id            	,
		p_to_other_pay_amount           	=>	p_rec.to_other_pay_amount           	,
		p_to_au_overtime                	=>	p_rec.to_au_overtime                	,
		p_to_auo_premium_pay_indicator  	=>	p_rec.to_auo_premium_pay_indicator  	,
		p_to_availability_pay           	=>	p_rec.to_availability_pay           	,
		p_to_ap_premium_pay_indicator   	=>	p_rec.to_ap_premium_pay_indicator   	,
		p_to_retention_allowance        	=>	p_rec.to_retention_allowance        	,
		p_to_supervisory_differential   	=>	p_rec.to_supervisory_differential   	,
		p_to_staffing_differential      	=>	p_rec.to_staffing_differential      	,
		p_to_pay_basis                  	=>	p_rec.to_pay_basis                  	,
		p_to_pay_plan                   	=>	p_rec.to_pay_plan                   	,
        -- FWFA Changes Bug#4444609
        -- p_to_pay_table_identifier        	=>	p_rec.to_pay_table_identifier        	,
        -- FWFA Changes
		p_to_position_id                	=>	p_rec.to_position_id                	,
		p_to_position_org_line1         	=>	p_rec.to_position_org_line1         	,
		p_to_position_org_line2         	=>	p_rec.to_position_org_line2         	,
		p_to_position_org_line3         	=>	p_rec.to_position_org_line3         	,
		p_to_position_org_line4         	=>	p_rec.to_position_org_line4         	,
		p_to_position_org_line5         	=>	p_rec.to_position_org_line5         	,
		p_to_position_org_line6         	=>	p_rec.to_position_org_line6         	,
		p_to_position_number            	=>	p_rec.to_position_number            	,
		p_to_position_seq_no            	=>	p_rec.to_position_seq_no            	,
		p_to_position_title             	=>	p_rec.to_position_title             	,
		p_to_step_or_rate               	=>	p_rec.to_step_or_rate               	,
		p_to_total_salary               	=>	p_rec.to_total_salary               	,
		p_veterans_preference           	=>	p_rec.veterans_preference           	,
		p_veterans_pref_for_rif         	=>	p_rec.veterans_pref_for_rif         	,
		p_veterans_status               	=>	p_rec.veterans_status               	,
		p_work_schedule                 	=>	p_rec.work_schedule                 	,
		p_work_schedule_desc            	=>	p_rec.work_schedule_desc            	,
		p_year_degree_attained          	=>	p_rec.year_degree_attained          	,
		p_first_noa_information1        	=>	p_rec.first_noa_information1        	,
		p_first_noa_information2        	=>	p_rec.first_noa_information2        	,
		p_first_noa_information3        	=>	p_rec.first_noa_information3        	,
		p_first_noa_information4        	=>	p_rec.first_noa_information4        	,
		p_first_noa_information5        	=>	p_rec.first_noa_information5        	,
		p_second_lac1_information1      	=>	p_rec.second_lac1_information1      	,
		p_second_lac1_information2      	=>	p_rec.second_lac1_information2      	,
		p_second_lac1_information3      	=>	p_rec.second_lac1_information3      	,
		p_second_lac1_information4      	=>	p_rec.second_lac1_information4      	,
		p_second_lac1_information5      	=>	p_rec.second_lac1_information5      	,
		p_second_lac2_information1      	=>	p_rec.second_lac2_information1      	,
		p_second_lac2_information2      	=>	p_rec.second_lac2_information2      	,
		p_second_lac2_information3      	=>	p_rec.second_lac2_information3      	,
		p_second_lac2_information4      	=>	p_rec.second_lac2_information4      	,
		p_second_lac2_information5      	=>	p_rec.second_lac2_information5      	,
		p_second_noa_information1       	=>	p_rec.second_noa_information1       	,
		p_second_noa_information2       	=>	p_rec.second_noa_information2       	,
		p_second_noa_information3       	=>	p_rec.second_noa_information3       	,
		p_second_noa_information4       	=>	p_rec.second_noa_information4       	,
		p_second_noa_information5       	=>	p_rec.second_noa_information5       	,
		p_first_lac1_information1       	=>	p_rec.first_lac1_information1       	,
		p_first_lac1_information2       	=>	p_rec.first_lac1_information2       	,
		p_first_lac1_information3       	=>	p_rec.first_lac1_information3       	,
		p_first_lac1_information4       	=>	p_rec.first_lac1_information4       	,
		p_first_lac1_information5       	=>	p_rec.first_lac1_information5       	,
		p_first_lac2_information1       	=>	p_rec.first_lac2_information1       	,
		p_first_lac2_information2       	=>	p_rec.first_lac2_information2       	,
		p_first_lac2_information3       	=>	p_rec.first_lac2_information3       	,
		p_first_lac2_information4       	=>	p_rec.first_lac2_information4       	,
		p_first_lac2_information5       	=>	p_rec.first_lac2_information5       	,
		p_attribute_category            	=>	p_rec.attribute_category            	,
		p_attribute1                    	=>	p_rec.attribute1                    	,
		p_attribute2                    	=>	p_rec.attribute2                    	,
		p_attribute3                    	=>	p_rec.attribute3                    	,
		p_attribute4                    	=>	p_rec.attribute4                    	,
		p_attribute5                    	=>	p_rec.attribute5                    	,
		p_attribute6                    	=>	p_rec.attribute6                    	,
		p_attribute7                    	=>	p_rec.attribute7                    	,
		p_attribute8                    	=>	p_rec.attribute8                    	,
		p_attribute9                    	=>	p_rec.attribute9                    	,
		p_attribute10                   	=>	p_rec.attribute10                   	,
		p_attribute11                   	=>	p_rec.attribute11                   	,
		p_attribute12                   	=>	p_rec.attribute12                   	,
		p_attribute13                   	=>	p_rec.attribute13                   	,
		p_attribute14                   	=>	p_rec.attribute14                   	,
		p_attribute15                   	=>	p_rec.attribute15                   	,
		p_attribute16                   	=>	p_rec.attribute16                   	,
		p_attribute17                   	=>	p_rec.attribute17                   	,
		p_attribute18                   	=>	p_rec.attribute18                   	,
		p_attribute19                   	=>	p_rec.attribute19                   	,
		p_attribute20                   	=>	p_rec.attribute20                   	,
            p_first_noa_canc_pa_request_id      =>    p_rec.first_noa_canc_pa_request_id        ,
            p_second_noa_canc_pa_request_i      =>    p_rec.second_noa_canc_pa_request_id       ,
            p_to_retention_allow_percentag      =>    p_rec.to_retention_allow_percentage       ,
            p_to_supervisory_diff_percenta      =>    p_rec.to_supervisory_diff_percentage      ,
            p_to_staffing_diff_percentage       =>    p_rec.to_staffing_diff_percentage         ,
            p_award_percentage                  =>    p_rec.award_percentage                    ,
            p_rpa_type                          =>    p_rec.rpa_type,
            p_mass_action_id                    =>    p_rec.mass_action_id,
            p_mass_action_eligible_flag         =>    p_rec.mass_action_eligible_flag,
            p_mass_action_select_flag           =>    p_rec.mass_action_select_flag,
            p_mass_action_comments              =>    p_rec.mass_action_comments,
	    p_pa_notification_id_o 		=>	ghr_par_shd.g_old_rec.pa_notification_id			,
	    p_noa_family_code_o 		=>	ghr_par_shd.g_old_rec.noa_family_code			,
	    p_routing_group_id_o 		=>	ghr_par_shd.g_old_rec.routing_group_id			,
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
            p_approving_official_work_ti_o      =>    ghr_par_shd.g_old_rec.approving_official_work_title   ,
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
        -- p_input_pay_rate_determinant_o     	=>	ghr_par_shd.g_old_rec.input_pay_rate_determinant       	,
        -- p_from_pay_table_identifier_o      	=>	ghr_par_shd.g_old_rec.from_pay_table_identifier        	,
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
                p_status_o                              =>      ghr_par_shd.g_old_rec.status            ,
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
		 	,p_hook_type  => 'AU'
	        );
  end;
  -- End of API User Hook for post_insert.

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Convert_Defs procedure has one very important function:

--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding parameter value for update. When
--   we attempt to update a row through the Upd process , certain
--   parameters can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd process to determine which attributes
--   have NOT been specified we need to check if the parameter has a reserved
--   system default value. Therefore, for all parameters which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Prerequisites:
--   This private function can only be called from the upd process.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to conversion

--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs(p_rec in out nocopy ghr_par_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'convert_defs';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.pa_notification_id = hr_api.g_number) then
    p_rec.pa_notification_id :=
    ghr_par_shd.g_old_rec.pa_notification_id;
  End If;
  If (p_rec.noa_family_code = hr_api.g_varchar2) then
    p_rec.noa_family_code :=
    ghr_par_shd.g_old_rec.noa_family_code;
  End If;
  If (p_rec.routing_group_id = hr_api.g_number) then
    p_rec.routing_group_id :=
    ghr_par_shd.g_old_rec.routing_group_id;
  End If;
  If (p_rec.proposed_effective_asap_flag = hr_api.g_varchar2) then
    p_rec.proposed_effective_asap_flag :=
    ghr_par_shd.g_old_rec.proposed_effective_asap_flag;
  End If;
  If (p_rec.academic_discipline = hr_api.g_varchar2) then
    p_rec.academic_discipline :=
    ghr_par_shd.g_old_rec.academic_discipline;
  End If;
  If (p_rec.additional_info_person_id = hr_api.g_number) then
    p_rec.additional_info_person_id :=
    ghr_par_shd.g_old_rec.additional_info_person_id;
  End If;
  If (p_rec.additional_info_tel_number = hr_api.g_varchar2) then
    p_rec.additional_info_tel_number :=
    ghr_par_shd.g_old_rec.additional_info_tel_number;
  End If;
  If (p_rec.agency_code = hr_api.g_varchar2) then
    p_rec.agency_code :=
    ghr_par_shd.g_old_rec.agency_code;
  End If;
  If (p_rec.altered_pa_request_id = hr_api.g_number) then
    p_rec.altered_pa_request_id :=
    ghr_par_shd.g_old_rec.altered_pa_request_id;
  End If;
  If (p_rec.annuitant_indicator = hr_api.g_varchar2) then
    p_rec.annuitant_indicator :=
    ghr_par_shd.g_old_rec.annuitant_indicator;
  End If;
  If (p_rec.annuitant_indicator_desc = hr_api.g_varchar2) then
    p_rec.annuitant_indicator_desc :=
    ghr_par_shd.g_old_rec.annuitant_indicator_desc;
  End If;
  If (p_rec.appropriation_code1 = hr_api.g_varchar2) then
    p_rec.appropriation_code1 :=
    ghr_par_shd.g_old_rec.appropriation_code1;
  End If;
  If (p_rec.appropriation_code2 = hr_api.g_varchar2) then
    p_rec.appropriation_code2 :=
    ghr_par_shd.g_old_rec.appropriation_code2;
  End If;
  If (p_rec.approval_date = hr_api.g_date) then
    p_rec.approval_date :=
    ghr_par_shd.g_old_rec.approval_date;
  End If;
  If (p_rec.approving_official_full_name = hr_api.g_varchar2) then
    p_rec.approving_official_full_name  :=
    ghr_par_shd.g_old_rec.approving_official_full_name;
  End If;
  If (p_rec.approving_official_work_title = hr_api.g_varchar2) then
    p_rec.approving_official_work_title :=
    ghr_par_shd.g_old_rec.approving_official_work_title;
  End If;
 If (p_rec.sf50_approval_date = hr_api.g_date) then
    p_rec.sf50_approval_date :=
    ghr_par_shd.g_old_rec.sf50_approval_date;
  End If;
  If (p_rec.sf50_approving_ofcl_full_name = hr_api.g_varchar2) then
    p_rec.sf50_approving_ofcl_full_name :=
    ghr_par_shd.g_old_rec.sf50_approving_ofcl_full_name ;
  End If;
  If (p_rec.sf50_approving_ofcl_work_title  = hr_api.g_varchar2) then
    p_rec.sf50_approving_ofcl_work_title  :=
    ghr_par_shd.g_old_rec.sf50_approving_ofcl_work_title;
  End If;
  If (p_rec.authorized_by_person_id = hr_api.g_number) then
    p_rec.authorized_by_person_id :=
    ghr_par_shd.g_old_rec.authorized_by_person_id;
  End If;
  If (p_rec.authorized_by_title = hr_api.g_varchar2) then
    p_rec.authorized_by_title :=
    ghr_par_shd.g_old_rec.authorized_by_title;
  End If;
  If (p_rec.award_amount = hr_api.g_number) then
    p_rec.award_amount :=
    ghr_par_shd.g_old_rec.award_amount;
  End If;
  If (p_rec.award_uom = hr_api.g_varchar2) then
    p_rec.award_uom :=
    ghr_par_shd.g_old_rec.award_uom;
  End If;
  If (p_rec.bargaining_unit_status = hr_api.g_varchar2) then
    p_rec.bargaining_unit_status :=
    ghr_par_shd.g_old_rec.bargaining_unit_status;
  End If;
  If (p_rec.citizenship = hr_api.g_varchar2) then
    p_rec.citizenship :=
    ghr_par_shd.g_old_rec.citizenship;
  End If;
  If (p_rec.concurrence_date = hr_api.g_date) then
    p_rec.concurrence_date :=
    ghr_par_shd.g_old_rec.concurrence_date;
  End If;
  If (p_rec.custom_pay_calc_flag = hr_api.g_varchar2) then
    p_rec.custom_pay_calc_flag :=
    ghr_par_shd.g_old_rec.custom_pay_calc_flag;
  End If;
  If (p_rec.duty_station_code = hr_api.g_varchar2) then
    p_rec.duty_station_code :=
    ghr_par_shd.g_old_rec.duty_station_code;
  End If;
  If (p_rec.duty_station_desc = hr_api.g_varchar2) then
    p_rec.duty_station_desc :=
    ghr_par_shd.g_old_rec.duty_station_desc;
  End If;
  If (p_rec.duty_station_id = hr_api.g_number) then
    p_rec.duty_station_id :=
    ghr_par_shd.g_old_rec.duty_station_id;
  End If;
  If (p_rec.duty_station_location_id = hr_api.g_number) then
    p_rec.duty_station_location_id :=
    ghr_par_shd.g_old_rec.duty_station_location_id;
  End If;
  If (p_rec.education_level = hr_api.g_varchar2) then
    p_rec.education_level :=
    ghr_par_shd.g_old_rec.education_level;
  End If;
  If (p_rec.effective_date = hr_api.g_date) then
    p_rec.effective_date :=
    ghr_par_shd.g_old_rec.effective_date;
  End If;
  If (p_rec.employee_assignment_id = hr_api.g_number) then
    p_rec.employee_assignment_id :=
    ghr_par_shd.g_old_rec.employee_assignment_id;
  End If;
  If (p_rec.employee_date_of_birth = hr_api.g_date) then
    p_rec.employee_date_of_birth :=
    ghr_par_shd.g_old_rec.employee_date_of_birth;
  End If;
  If (p_rec.employee_dept_or_agency = hr_api.g_varchar2) then
    p_rec.employee_dept_or_agency :=
    ghr_par_shd.g_old_rec.employee_dept_or_agency;
  End If;
  If (p_rec.employee_first_name = hr_api.g_varchar2) then
    p_rec.employee_first_name :=
    ghr_par_shd.g_old_rec.employee_first_name;
  End If;
  If (p_rec.employee_last_name = hr_api.g_varchar2) then
    p_rec.employee_last_name :=
    ghr_par_shd.g_old_rec.employee_last_name;
  End If;
  If (p_rec.employee_middle_names = hr_api.g_varchar2) then
    p_rec.employee_middle_names :=
    ghr_par_shd.g_old_rec.employee_middle_names;
  End If;
  If (p_rec.employee_national_identifier = hr_api.g_varchar2) then
    p_rec.employee_national_identifier :=
    ghr_par_shd.g_old_rec.employee_national_identifier;
  End If;
  If (p_rec.fegli = hr_api.g_varchar2) then
    p_rec.fegli :=
    ghr_par_shd.g_old_rec.fegli;
  End If;
  If (p_rec.fegli_desc = hr_api.g_varchar2) then
    p_rec.fegli_desc :=
    ghr_par_shd.g_old_rec.fegli_desc;
  End If;
  If (p_rec.first_action_la_code1 = hr_api.g_varchar2) then
    p_rec.first_action_la_code1 :=
    ghr_par_shd.g_old_rec.first_action_la_code1;
  End If;
  If (p_rec.first_action_la_code2 = hr_api.g_varchar2) then
    p_rec.first_action_la_code2 :=
    ghr_par_shd.g_old_rec.first_action_la_code2;
  End If;
  If (p_rec.first_action_la_desc1 = hr_api.g_varchar2) then
    p_rec.first_action_la_desc1 :=
    ghr_par_shd.g_old_rec.first_action_la_desc1;
  End If;
  If (p_rec.first_action_la_desc2 = hr_api.g_varchar2) then
    p_rec.first_action_la_desc2 :=
    ghr_par_shd.g_old_rec.first_action_la_desc2;
  End If;
  If (p_rec.first_noa_cancel_or_correct = hr_api.g_varchar2) then
    p_rec.first_noa_cancel_or_correct :=
    ghr_par_shd.g_old_rec.first_noa_cancel_or_correct;
  End If;
  If (p_rec.first_noa_code = hr_api.g_varchar2) then
    p_rec.first_noa_code :=
    ghr_par_shd.g_old_rec.first_noa_code;
  End If;
  If (p_rec.first_noa_desc = hr_api.g_varchar2) then
    p_rec.first_noa_desc :=
    ghr_par_shd.g_old_rec.first_noa_desc;
  End If;
  If (p_rec.first_noa_id = hr_api.g_number) then
    p_rec.first_noa_id :=
    ghr_par_shd.g_old_rec.first_noa_id;
  End If;
  If (p_rec.first_noa_pa_request_id = hr_api.g_number) then
    p_rec.first_noa_pa_request_id :=
    ghr_par_shd.g_old_rec.first_noa_pa_request_id;
  End If;
  If (p_rec.flsa_category = hr_api.g_varchar2) then
    p_rec.flsa_category :=
    ghr_par_shd.g_old_rec.flsa_category;
  End If;
  If (p_rec.forwarding_address_line1 = hr_api.g_varchar2) then
    p_rec.forwarding_address_line1 :=
    ghr_par_shd.g_old_rec.forwarding_address_line1;
  End If;
  If (p_rec.forwarding_address_line2 = hr_api.g_varchar2) then
    p_rec.forwarding_address_line2 :=
    ghr_par_shd.g_old_rec.forwarding_address_line2;
  End If;
  If (p_rec.forwarding_address_line3 = hr_api.g_varchar2) then
    p_rec.forwarding_address_line3 :=
    ghr_par_shd.g_old_rec.forwarding_address_line3;
  End If;
  If (p_rec.forwarding_country_short_name = hr_api.g_varchar2) then
    p_rec.forwarding_country_short_name :=
    ghr_par_shd.g_old_rec.forwarding_country_short_name;
  End If;
  If (p_rec.forwarding_country = hr_api.g_varchar2) then
    p_rec.forwarding_country :=
    ghr_par_shd.g_old_rec.forwarding_country;
  End If;
  If (p_rec.forwarding_postal_code = hr_api.g_varchar2) then
    p_rec.forwarding_postal_code :=
    ghr_par_shd.g_old_rec.forwarding_postal_code;
  End If;
  If (p_rec.forwarding_region_2 = hr_api.g_varchar2) then
    p_rec.forwarding_region_2 :=
    ghr_par_shd.g_old_rec.forwarding_region_2;
  End If;
  If (p_rec.forwarding_town_or_city = hr_api.g_varchar2) then
    p_rec.forwarding_town_or_city :=
    ghr_par_shd.g_old_rec.forwarding_town_or_city;
  End If;
  If (p_rec.from_adj_basic_pay = hr_api.g_number) then
    p_rec.from_adj_basic_pay :=
    ghr_par_shd.g_old_rec.from_adj_basic_pay;
  End If;
  If (p_rec.from_agency_code = hr_api.g_varchar2) then
    p_rec.from_agency_code :=
    ghr_par_shd.g_old_rec.from_agency_code;
  End If;
  If (p_rec.from_agency_desc = hr_api.g_varchar2) then
    p_rec.from_agency_desc :=
    ghr_par_shd.g_old_rec.from_agency_desc;
  End If;
  If (p_rec.from_basic_pay = hr_api.g_number) then
    p_rec.from_basic_pay :=
    ghr_par_shd.g_old_rec.from_basic_pay;
  End If;
  If (p_rec.from_grade_or_level = hr_api.g_varchar2) then
    p_rec.from_grade_or_level :=
    ghr_par_shd.g_old_rec.from_grade_or_level;
  End If;
  If (p_rec.from_locality_adj = hr_api.g_number) then
    p_rec.from_locality_adj :=
    ghr_par_shd.g_old_rec.from_locality_adj;
  End If;
  If (p_rec.from_occ_code = hr_api.g_varchar2) then
    p_rec.from_occ_code :=
    ghr_par_shd.g_old_rec.from_occ_code;
  End If;
  If (p_rec.from_office_symbol = hr_api.g_varchar2) then
    p_rec.from_office_symbol :=
    ghr_par_shd.g_old_rec.from_office_symbol;
  End If;
  If (p_rec.from_other_pay_amount = hr_api.g_number) then
    p_rec.from_other_pay_amount :=
    ghr_par_shd.g_old_rec.from_other_pay_amount;
  End If;
  If (p_rec.from_pay_basis = hr_api.g_varchar2) then
    p_rec.from_pay_basis :=
    ghr_par_shd.g_old_rec.from_pay_basis;
  End If;
  If (p_rec.from_pay_plan = hr_api.g_varchar2) then
    p_rec.from_pay_plan :=
    ghr_par_shd.g_old_rec.from_pay_plan;
  End If;
  -- FWFA Changes Bug#4444609
  If (p_rec.input_pay_rate_determinant = hr_api.g_varchar2) then
    p_rec.input_pay_rate_determinant :=
    ghr_par_shd.g_old_rec.input_pay_rate_determinant;
  End If;
  If (p_rec.from_pay_table_identifier = hr_api.g_number) then
    p_rec.from_pay_table_identifier :=
    ghr_par_shd.g_old_rec.from_pay_table_identifier;
  End If;
  -- FWFA Changes
  If (p_rec.from_position_org_line1 = hr_api.g_varchar2) then
    p_rec.from_position_org_line1 :=
    ghr_par_shd.g_old_rec.from_position_org_line1;
  End If;
  If (p_rec.from_position_org_line2 = hr_api.g_varchar2) then
    p_rec.from_position_org_line2 :=
    ghr_par_shd.g_old_rec.from_position_org_line2;
  End If;
  If (p_rec.from_position_org_line3 = hr_api.g_varchar2) then
    p_rec.from_position_org_line3 :=
    ghr_par_shd.g_old_rec.from_position_org_line3;
  End If;
  If (p_rec.from_position_org_line4 = hr_api.g_varchar2) then
    p_rec.from_position_org_line4 :=
    ghr_par_shd.g_old_rec.from_position_org_line4;
  End If;
  If (p_rec.from_position_org_line5 = hr_api.g_varchar2) then
    p_rec.from_position_org_line5 :=
    ghr_par_shd.g_old_rec.from_position_org_line5;
  End If;
  If (p_rec.from_position_org_line6 = hr_api.g_varchar2) then
    p_rec.from_position_org_line6 :=
    ghr_par_shd.g_old_rec.from_position_org_line6;
  End If;
  If (p_rec.from_position_id = hr_api.g_number) then
    p_rec.from_position_id :=
    ghr_par_shd.g_old_rec.from_position_id;
  End If;
  If (p_rec.from_position_number = hr_api.g_varchar2) then
    p_rec.from_position_number :=
    ghr_par_shd.g_old_rec.from_position_number;
  End If;
  If (p_rec.from_position_seq_no = hr_api.g_number) then
    p_rec.from_position_seq_no :=
    ghr_par_shd.g_old_rec.from_position_seq_no;
  End If;
  If (p_rec.from_position_title = hr_api.g_varchar2) then
    p_rec.from_position_title :=
    ghr_par_shd.g_old_rec.from_position_title;
  End If;
  If (p_rec.from_step_or_rate = hr_api.g_varchar2) then
    p_rec.from_step_or_rate :=
    ghr_par_shd.g_old_rec.from_step_or_rate;
  End If;
  If (p_rec.from_total_salary = hr_api.g_number) then
    p_rec.from_total_salary :=
    ghr_par_shd.g_old_rec.from_total_salary;
  End If;
  If (p_rec.functional_class = hr_api.g_varchar2) then
    p_rec.functional_class :=
    ghr_par_shd.g_old_rec.functional_class;
  End If;
  If (p_rec.notepad = hr_api.g_varchar2) then
    p_rec.notepad :=
    ghr_par_shd.g_old_rec.notepad;
  End If;
  If (p_rec.part_time_hours = hr_api.g_number) then
    p_rec.part_time_hours :=
    ghr_par_shd.g_old_rec.part_time_hours;
  End If;
  If (p_rec.pay_rate_determinant = hr_api.g_varchar2) then
    p_rec.pay_rate_determinant :=
    ghr_par_shd.g_old_rec.pay_rate_determinant;
  End If;
  If (p_rec.personnel_office_id = hr_api.g_varchar2) then
    p_rec.personnel_office_id :=
    ghr_par_shd.g_old_rec.personnel_office_id;
  End If;
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    ghr_par_shd.g_old_rec.person_id;
  End If;
  If (p_rec.position_occupied = hr_api.g_varchar2) then
    p_rec.position_occupied :=
    ghr_par_shd.g_old_rec.position_occupied;
  End If;
  If (p_rec.proposed_effective_date = hr_api.g_date) then
    p_rec.proposed_effective_date :=
    ghr_par_shd.g_old_rec.proposed_effective_date;
  End If;
  If (p_rec.proposed_effective_asap_flag = hr_api.g_varchar2) then
    p_rec.proposed_effective_asap_flag :=
    ghr_par_shd.g_old_rec.proposed_effective_asap_flag;
  End If;

  If (p_rec.requested_by_person_id = hr_api.g_number) then
    p_rec.requested_by_person_id :=
    ghr_par_shd.g_old_rec.requested_by_person_id;
  End If;
  If (p_rec.requested_by_title = hr_api.g_varchar2) then
    p_rec.requested_by_title :=
    ghr_par_shd.g_old_rec.requested_by_title;
  End If;
  If (p_rec.requested_date = hr_api.g_date) then
    p_rec.requested_date :=
    ghr_par_shd.g_old_rec.requested_date;
  End If;
  If (p_rec.requesting_office_remarks_desc = hr_api.g_varchar2) then
    p_rec.requesting_office_remarks_desc :=
    ghr_par_shd.g_old_rec.requesting_office_remarks_desc;
  End If;
  If (p_rec.requesting_office_remarks_flag = hr_api.g_varchar2) then
    p_rec.requesting_office_remarks_flag :=
    ghr_par_shd.g_old_rec.requesting_office_remarks_flag;
  End If;
  If (p_rec.request_number = hr_api.g_varchar2) then
    p_rec.request_number :=
    ghr_par_shd.g_old_rec.request_number;
  End If;
  If (p_rec.resign_and_retire_reason_desc = hr_api.g_varchar2) then
    p_rec.resign_and_retire_reason_desc :=
    ghr_par_shd.g_old_rec.resign_and_retire_reason_desc;
  End If;
  If (p_rec.retirement_plan = hr_api.g_varchar2) then
    p_rec.retirement_plan :=
    ghr_par_shd.g_old_rec.retirement_plan;
  End If;
  If (p_rec.retirement_plan_desc = hr_api.g_varchar2) then
    p_rec.retirement_plan_desc :=
    ghr_par_shd.g_old_rec.retirement_plan_desc;
  End If;
  If (p_rec.second_action_la_code1 = hr_api.g_varchar2) then
    p_rec.second_action_la_code1 :=
    ghr_par_shd.g_old_rec.second_action_la_code1;
  End If;
  If (p_rec.second_action_la_code2 = hr_api.g_varchar2) then
    p_rec.second_action_la_code2 :=
    ghr_par_shd.g_old_rec.second_action_la_code2;
  End If;
  If (p_rec.second_action_la_desc1 = hr_api.g_varchar2) then
    p_rec.second_action_la_desc1 :=
    ghr_par_shd.g_old_rec.second_action_la_desc1;
  End If;
  If (p_rec.second_action_la_desc2 = hr_api.g_varchar2) then
    p_rec.second_action_la_desc2 :=
    ghr_par_shd.g_old_rec.second_action_la_desc2;
  End If;
  If (p_rec.second_noa_cancel_or_correct = hr_api.g_varchar2) then
    p_rec.second_noa_cancel_or_correct :=
    ghr_par_shd.g_old_rec.second_noa_cancel_or_correct;
  End If;
  If (p_rec.second_noa_code = hr_api.g_varchar2) then
    p_rec.second_noa_code :=
    ghr_par_shd.g_old_rec.second_noa_code;
  End If;
  If (p_rec.second_noa_desc = hr_api.g_varchar2) then
    p_rec.second_noa_desc :=
    ghr_par_shd.g_old_rec.second_noa_desc;
  End If;
  If (p_rec.second_noa_id = hr_api.g_number) then
    p_rec.second_noa_id :=
    ghr_par_shd.g_old_rec.second_noa_id;
  End If;
  If (p_rec.second_noa_pa_request_id = hr_api.g_number) then
    p_rec.second_noa_pa_request_id :=
    ghr_par_shd.g_old_rec.second_noa_pa_request_id;
  End If;
  If (p_rec.service_comp_date = hr_api.g_date) then
    p_rec.service_comp_date :=
    ghr_par_shd.g_old_rec.service_comp_date;
  End If;
  If (p_rec.status = hr_api.g_varchar2) then
    p_rec.status :=
    ghr_par_shd.g_old_rec.status;
  End If;
  If (p_rec.supervisory_status = hr_api.g_varchar2) then
    p_rec.supervisory_status :=
    ghr_par_shd.g_old_rec.supervisory_status;
  End If;
  If (p_rec.tenure = hr_api.g_varchar2) then
    p_rec.tenure :=
    ghr_par_shd.g_old_rec.tenure;
  End If;
  If (p_rec.to_adj_basic_pay = hr_api.g_number) then
    p_rec.to_adj_basic_pay :=
    ghr_par_shd.g_old_rec.to_adj_basic_pay;
  End If;
  If (p_rec.to_basic_pay = hr_api.g_number) then
    p_rec.to_basic_pay :=
    ghr_par_shd.g_old_rec.to_basic_pay;
  End If;
  If (p_rec.to_grade_id = hr_api.g_number) then
    p_rec.to_grade_id :=
    ghr_par_shd.g_old_rec.to_grade_id;
  End If;
  If (p_rec.to_grade_or_level = hr_api.g_varchar2) then
    p_rec.to_grade_or_level :=
    ghr_par_shd.g_old_rec.to_grade_or_level;
  End If;
  If (p_rec.to_job_id = hr_api.g_number) then
    p_rec.to_job_id :=
    ghr_par_shd.g_old_rec.to_job_id;
  End If;
  If (p_rec.to_locality_adj = hr_api.g_number) then
    p_rec.to_locality_adj :=
    ghr_par_shd.g_old_rec.to_locality_adj;
  End If;
  If (p_rec.to_occ_code = hr_api.g_varchar2) then
    p_rec.to_occ_code :=
    ghr_par_shd.g_old_rec.to_occ_code;
  End If;
  If (p_rec.to_office_symbol = hr_api.g_varchar2) then
    p_rec.to_office_symbol :=
    ghr_par_shd.g_old_rec.to_office_symbol;
  End If;
  If (p_rec.to_organization_id = hr_api.g_number) then
    p_rec.to_organization_id :=
    ghr_par_shd.g_old_rec.to_organization_id;
  End If;
  If (p_rec.to_other_pay_amount = hr_api.g_number) then
    p_rec.to_other_pay_amount :=
    ghr_par_shd.g_old_rec.to_other_pay_amount;
  End If;
  If (p_rec.to_pay_basis = hr_api.g_varchar2) then
    p_rec.to_pay_basis :=
    ghr_par_shd.g_old_rec.to_pay_basis;
  End If;
  If (p_rec.to_pay_plan = hr_api.g_varchar2) then
    p_rec.to_pay_plan :=
    ghr_par_shd.g_old_rec.to_pay_plan;
  End If;
  -- FWFA Changes Bug#4444609
  If (p_rec.to_pay_table_identifier = hr_api.g_number) then
    p_rec.to_pay_table_identifier :=
    ghr_par_shd.g_old_rec.to_pay_table_identifier;
  End If;
  -- FWFA Changes
  If (p_rec.to_position_id = hr_api.g_number) then
    p_rec.to_position_id :=
    ghr_par_shd.g_old_rec.to_position_id;
  End If;
  If (p_rec.to_position_org_line1 = hr_api.g_varchar2) then
    p_rec.to_position_org_line1 :=
    ghr_par_shd.g_old_rec.to_position_org_line1;
  End If;
  If (p_rec.to_position_org_line2 = hr_api.g_varchar2) then
    p_rec.to_position_org_line2 :=
    ghr_par_shd.g_old_rec.to_position_org_line2;
  End If;
  If (p_rec.to_position_org_line3 = hr_api.g_varchar2) then
    p_rec.to_position_org_line3 :=
    ghr_par_shd.g_old_rec.to_position_org_line3;
  End If;
  If (p_rec.to_position_org_line4 = hr_api.g_varchar2) then
    p_rec.to_position_org_line4 :=
    ghr_par_shd.g_old_rec.to_position_org_line4;
  End If;
  If (p_rec.to_position_org_line5 = hr_api.g_varchar2) then
    p_rec.to_position_org_line5 :=
    ghr_par_shd.g_old_rec.to_position_org_line5;
  End If;
  If (p_rec.to_position_org_line6 = hr_api.g_varchar2) then
    p_rec.to_position_org_line6 :=
    ghr_par_shd.g_old_rec.to_position_org_line6;
  End If;

  If (p_rec.to_position_number = hr_api.g_varchar2) then
    p_rec.to_position_number :=
    ghr_par_shd.g_old_rec.to_position_number;
  End If;
  If (p_rec.to_position_seq_no = hr_api.g_number) then
    p_rec.to_position_seq_no :=
    ghr_par_shd.g_old_rec.to_position_seq_no;
  End If;
  If (p_rec.to_position_title = hr_api.g_varchar2) then
    p_rec.to_position_title :=
    ghr_par_shd.g_old_rec.to_position_title;
  End If;
  If (p_rec.to_step_or_rate = hr_api.g_varchar2) then
    p_rec.to_step_or_rate :=
    ghr_par_shd.g_old_rec.to_step_or_rate;
  End If;

  If (p_rec.to_ap_premium_pay_indicator = hr_api.g_varchar2) then
    p_rec.to_ap_premium_pay_indicator :=
    ghr_par_shd.g_old_rec.to_ap_premium_pay_indicator;
  End If;

  If (p_rec.to_auo_premium_pay_indicator = hr_api.g_varchar2) then
    p_rec.to_auo_premium_pay_indicator :=
    ghr_par_shd.g_old_rec.to_auo_premium_pay_indicator;
  End If;

  If (p_rec.to_au_overtime = hr_api.g_number) then
    p_rec.to_au_overtime  :=
    ghr_par_shd.g_old_rec.to_au_overtime  ;
  End If;

  If (p_rec.to_availability_pay = hr_api.g_number) then
    p_rec.to_availability_pay :=
    ghr_par_shd.g_old_rec.to_availability_pay ;
  End If;

  If (p_rec.to_retention_allowance  = hr_api.g_number) then
    p_rec.to_retention_allowance  :=
    ghr_par_shd.g_old_rec.to_retention_allowance;
  End If;

  If (p_rec.to_staffing_differential  = hr_api.g_number) then
    p_rec.to_staffing_differential   :=
    ghr_par_shd.g_old_rec.to_staffing_differential ;
  End If;

   If (p_rec.to_supervisory_differential  = hr_api.g_number) then
    p_rec.to_supervisory_differential   :=
    ghr_par_shd.g_old_rec.to_supervisory_differential ;
  End If;

  If (p_rec.to_total_salary = hr_api.g_number) then
    p_rec.to_total_salary :=
    ghr_par_shd.g_old_rec.to_total_salary;
  End If;
  If (p_rec.veterans_preference = hr_api.g_varchar2) then
    p_rec.veterans_preference :=
    ghr_par_shd.g_old_rec.veterans_preference;
  End If;
  If (p_rec.veterans_pref_for_rif = hr_api.g_varchar2) then
    p_rec.veterans_pref_for_rif :=
    ghr_par_shd.g_old_rec.veterans_pref_for_rif;
  End If;
  If (p_rec.veterans_status = hr_api.g_varchar2) then
    p_rec.veterans_status :=
    ghr_par_shd.g_old_rec.veterans_status;
  End If;
  If (p_rec.work_schedule = hr_api.g_varchar2) then
    p_rec.work_schedule :=
    ghr_par_shd.g_old_rec.work_schedule;
  End If;
  If (p_rec.work_schedule_desc = hr_api.g_varchar2) then
    p_rec.work_schedule_desc :=
    ghr_par_shd.g_old_rec.work_schedule_desc;
  End If;
  If (p_rec.year_degree_attained = hr_api.g_number) then
    p_rec.year_degree_attained :=
    ghr_par_shd.g_old_rec.year_degree_attained;
  End If;
  If (p_rec.first_noa_information1 = hr_api.g_varchar2) then
    p_rec.first_noa_information1 :=
    ghr_par_shd.g_old_rec.first_noa_information1;
  End If;
  If (p_rec.first_noa_information2 = hr_api.g_varchar2) then
    p_rec.first_noa_information2 :=
    ghr_par_shd.g_old_rec.first_noa_information2;
  End If;
  If (p_rec.first_noa_information3 = hr_api.g_varchar2) then
    p_rec.first_noa_information3 :=
    ghr_par_shd.g_old_rec.first_noa_information3;
  End If;
  If (p_rec.first_noa_information4 = hr_api.g_varchar2) then
    p_rec.first_noa_information4 :=
    ghr_par_shd.g_old_rec.first_noa_information4;
  End If;
  If (p_rec.first_noa_information5 = hr_api.g_varchar2) then
    p_rec.first_noa_information5 :=
    ghr_par_shd.g_old_rec.first_noa_information5;
  End If;
  If (p_rec.second_lac1_information1 = hr_api.g_varchar2) then
    p_rec.second_lac1_information1 :=
    ghr_par_shd.g_old_rec.second_lac1_information1;
  End If;
  If (p_rec.second_lac1_information2 = hr_api.g_varchar2) then
    p_rec.second_lac1_information2 :=
    ghr_par_shd.g_old_rec.second_lac1_information2;
  End If;
  If (p_rec.second_lac1_information3 = hr_api.g_varchar2) then
    p_rec.second_lac1_information3 :=
    ghr_par_shd.g_old_rec.second_lac1_information3;
  End If;
  If (p_rec.second_lac1_information4 = hr_api.g_varchar2) then
    p_rec.second_lac1_information4 :=
    ghr_par_shd.g_old_rec.second_lac1_information4;
  End If;
  If (p_rec.second_lac1_information5 = hr_api.g_varchar2) then
    p_rec.second_lac1_information5 :=
    ghr_par_shd.g_old_rec.second_lac1_information5;
  End If;
  If (p_rec.second_lac2_information1 = hr_api.g_varchar2) then
    p_rec.second_lac2_information1 :=
    ghr_par_shd.g_old_rec.second_lac2_information1;
  End If;
  If (p_rec.second_lac2_information2 = hr_api.g_varchar2) then
    p_rec.second_lac2_information2 :=
    ghr_par_shd.g_old_rec.second_lac2_information2;
  End If;
  If (p_rec.second_lac2_information3 = hr_api.g_varchar2) then
    p_rec.second_lac2_information3 :=
    ghr_par_shd.g_old_rec.second_lac2_information3;
  End If;
  If (p_rec.second_lac2_information4 = hr_api.g_varchar2) then
    p_rec.second_lac2_information4 :=
    ghr_par_shd.g_old_rec.second_lac2_information4;
  End If;
  If (p_rec.second_lac2_information5 = hr_api.g_varchar2) then
    p_rec.second_lac2_information5 :=
    ghr_par_shd.g_old_rec.second_lac2_information5;
  End If;
  If (p_rec.second_noa_information1 = hr_api.g_varchar2) then
    p_rec.second_noa_information1 :=
    ghr_par_shd.g_old_rec.second_noa_information1;
  End If;
  If (p_rec.second_noa_information2 = hr_api.g_varchar2) then
    p_rec.second_noa_information2 :=
    ghr_par_shd.g_old_rec.second_noa_information2;
  End If;
  If (p_rec.second_noa_information3 = hr_api.g_varchar2) then
    p_rec.second_noa_information3 :=
    ghr_par_shd.g_old_rec.second_noa_information3;
  End If;
  If (p_rec.second_noa_information4 = hr_api.g_varchar2) then
    p_rec.second_noa_information4 :=
    ghr_par_shd.g_old_rec.second_noa_information4;
  End If;
  If (p_rec.second_noa_information5 = hr_api.g_varchar2) then
    p_rec.second_noa_information5 :=
    ghr_par_shd.g_old_rec.second_noa_information5;
  End If;
  If (p_rec.first_lac1_information1 = hr_api.g_varchar2) then
    p_rec.first_lac1_information1 :=
    ghr_par_shd.g_old_rec.first_lac1_information1;
  End If;
  If (p_rec.first_lac1_information2 = hr_api.g_varchar2) then
    p_rec.first_lac1_information2 :=
    ghr_par_shd.g_old_rec.first_lac1_information2;
  End If;
  If (p_rec.first_lac1_information3 = hr_api.g_varchar2) then
    p_rec.first_lac1_information3 :=
    ghr_par_shd.g_old_rec.first_lac1_information3;
  End If;
  If (p_rec.first_lac1_information4 = hr_api.g_varchar2) then
    p_rec.first_lac1_information4 :=
    ghr_par_shd.g_old_rec.first_lac1_information4;
  End If;
  If (p_rec.first_lac1_information5 = hr_api.g_varchar2) then
    p_rec.first_lac1_information5 :=
    ghr_par_shd.g_old_rec.first_lac1_information5;
  End If;
  If (p_rec.first_lac2_information1 = hr_api.g_varchar2) then
    p_rec.first_lac2_information1 :=
    ghr_par_shd.g_old_rec.first_lac2_information1;
  End If;
  If (p_rec.first_lac2_information2 = hr_api.g_varchar2) then
    p_rec.first_lac2_information2 :=
    ghr_par_shd.g_old_rec.first_lac2_information2;
  End If;
  If (p_rec.first_lac2_information3 = hr_api.g_varchar2) then
    p_rec.first_lac2_information3 :=
    ghr_par_shd.g_old_rec.first_lac2_information3;
  End If;
  If (p_rec.first_lac2_information4 = hr_api.g_varchar2) then
    p_rec.first_lac2_information4 :=
    ghr_par_shd.g_old_rec.first_lac2_information4;
  End If;
  If (p_rec.first_lac2_information5 = hr_api.g_varchar2) then
    p_rec.first_lac2_information5 :=
    ghr_par_shd.g_old_rec.first_lac2_information5;
  End If;
  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    ghr_par_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    ghr_par_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    ghr_par_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    ghr_par_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    ghr_par_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    ghr_par_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    ghr_par_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    ghr_par_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    ghr_par_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    ghr_par_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    ghr_par_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    ghr_par_shd.g_old_rec.attribute11;
  End If;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    ghr_par_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    ghr_par_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    ghr_par_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    ghr_par_shd.g_old_rec.attribute15;
  End If;
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    ghr_par_shd.g_old_rec.attribute16;
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    ghr_par_shd.g_old_rec.attribute17;
  End If;
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    ghr_par_shd.g_old_rec.attribute18;
  End If;
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    ghr_par_shd.g_old_rec.attribute19;
  End If;
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    ghr_par_shd.g_old_rec.attribute20;
  End If;

  If (p_rec.first_noa_canc_pa_request_id = hr_api.g_number) then
      p_rec.first_noa_canc_pa_request_id :=
          ghr_par_shd.g_old_rec.first_noa_canc_pa_request_id;
  End If;
  If (p_rec.second_noa_canc_pa_request_id = hr_api.g_number) then
      p_rec.second_noa_canc_pa_request_id :=
          ghr_par_shd.g_old_rec.second_noa_canc_pa_request_id;
  End If;
  If (p_rec.to_retention_allow_percentage = hr_api.g_number) then
      p_rec.to_retention_allow_percentage :=
          ghr_par_shd.g_old_rec.to_retention_allow_percentage;
  End If;
  If (p_rec.to_supervisory_diff_percentage = hr_api.g_number) then
      p_rec.to_supervisory_diff_percentage :=
          ghr_par_shd.g_old_rec.to_supervisory_diff_percentage;
  End If;
  If (p_rec.to_staffing_diff_percentage = hr_api.g_number) then
      p_rec.to_staffing_diff_percentage :=
          ghr_par_shd.g_old_rec.to_staffing_diff_percentage;
  End If;
  If (p_rec.award_percentage = hr_api.g_number) then
      p_rec.award_percentage :=
          ghr_par_shd.g_old_rec.award_percentage;
  End If;
  If (p_rec.rpa_type    = hr_api.g_varchar2) then
    p_rec.rpa_type :=
    ghr_par_shd.g_old_rec.rpa_type;
  End If;
  If (p_rec.mass_action_id   = hr_api.g_number) then
      p_rec.mass_action_id   :=
          ghr_par_shd.g_old_rec.mass_action_id;
  End If;
  If (p_rec.mass_action_eligible_flag = hr_api.g_varchar2) then
    p_rec.mass_action_eligible_flag  :=
    ghr_par_shd.g_old_rec.mass_action_eligible_flag;
  End If;
  If (p_rec.mass_action_select_flag = hr_api.g_varchar2) then
    p_rec.mass_action_select_flag  :=
    ghr_par_shd.g_old_rec.mass_action_select_flag;
  End If;
  If (p_rec.mass_action_comments = hr_api.g_varchar2) then
    p_rec.mass_action_comments  :=
    ghr_par_shd.g_old_rec.mass_action_comments;
  End If;
  -- Bug#    RRR Changes
  If (p_rec.payment_option = hr_api.g_varchar2) then
    p_rec.payment_option  :=
    ghr_par_shd.g_old_rec.payment_option;
  End If;
  If (p_rec.award_salary = hr_api.g_number) then
    p_rec.award_salary  :=
    ghr_par_shd.g_old_rec.award_salary;
  End If;
  -- Bug#    RRR Changes
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rec        in out nocopy ghr_par_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  ghr_par_shd.lck
	(
	p_rec.pa_request_id,
      p_rec.routing_group_id,
	p_rec.object_version_number
	);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  ghr_par_bus.update_validate(p_rec);
  --
  -- Call the supporting pre-update operation
  --
  pre_update(p_rec);
  --
  -- Update the row.
  --
  update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  post_update(p_rec);
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_pa_request_id                in number,
  p_pa_notification_id           in number           default hr_api.g_number,
  p_noa_family_code              in varchar2         default hr_api.g_varchar2,
  p_routing_group_id             in number           default hr_api.g_number,
  p_proposed_effective_asap_flag in varchar2         default hr_api.g_varchar2,
  p_academic_discipline          in varchar2         default hr_api.g_varchar2,
  p_additional_info_person_id    in number           default hr_api.g_number,
  p_additional_info_tel_number   in varchar2         default hr_api.g_varchar2,
  p_agency_code                  in varchar2         default hr_api.g_varchar2,
  p_altered_pa_request_id        in number           default hr_api.g_number,
  p_annuitant_indicator          in varchar2         default hr_api.g_varchar2,
  p_annuitant_indicator_desc     in varchar2         default hr_api.g_varchar2,
  p_appropriation_code1          in varchar2         default hr_api.g_varchar2,
  p_appropriation_code2          in varchar2         default hr_api.g_varchar2,
  p_approval_date                in date             default hr_api.g_date,
  p_approving_official_full_name in varchar2         default hr_api.g_varchar2,
  p_approving_official_work_titl in varchar2         default hr_api.g_varchar2,
  p_sf50_approval_date           in date             default hr_api.g_date,
  p_sf50_approving_ofcl_full_nam in varchar2         default hr_api.g_varchar2,
  p_sf50_approving_ofcl_work_tit in varchar2         default hr_api.g_varchar2,
  p_authorized_by_person_id      in number           default hr_api.g_number,
  p_authorized_by_title          in varchar2         default hr_api.g_varchar2,
  p_award_amount                 in number           default hr_api.g_number,
  p_award_uom                    in varchar2         default hr_api.g_varchar2,
  p_bargaining_unit_status       in varchar2         default hr_api.g_varchar2,
  p_citizenship                  in varchar2         default hr_api.g_varchar2,
  p_concurrence_date             in date             default hr_api.g_date,
  p_custom_pay_calc_flag         in varchar2         default hr_api.g_varchar2,
  p_duty_station_code            in varchar2         default hr_api.g_varchar2,
  p_duty_station_desc            in varchar2         default hr_api.g_varchar2,
  p_duty_station_id              in number           default hr_api.g_number,
  p_duty_station_location_id     in number           default hr_api.g_number,
  p_education_level              in varchar2         default hr_api.g_varchar2,
  p_effective_date               in date             default hr_api.g_date,
  p_employee_assignment_id       in number           default hr_api.g_number,
  p_employee_date_of_birth       in date             default hr_api.g_date,
  p_employee_dept_or_agency      in varchar2         default hr_api.g_varchar2,
  p_employee_first_name          in varchar2         default hr_api.g_varchar2,
  p_employee_last_name           in varchar2         default hr_api.g_varchar2,
  p_employee_middle_names        in varchar2         default hr_api.g_varchar2,
  p_employee_national_identifier in varchar2         default hr_api.g_varchar2,
  p_fegli                        in varchar2         default hr_api.g_varchar2,
  p_fegli_desc                   in varchar2         default hr_api.g_varchar2,
  p_first_action_la_code1        in varchar2         default hr_api.g_varchar2,
  p_first_action_la_code2        in varchar2         default hr_api.g_varchar2,
  p_first_action_la_desc1        in varchar2         default hr_api.g_varchar2,
  p_first_action_la_desc2        in varchar2         default hr_api.g_varchar2,
  p_first_noa_cancel_or_correct  in varchar2         default hr_api.g_varchar2,
  p_first_noa_code               in varchar2         default hr_api.g_varchar2,
  p_first_noa_desc               in varchar2         default hr_api.g_varchar2,
  p_first_noa_id                 in number           default hr_api.g_number,
  p_first_noa_pa_request_id      in number           default hr_api.g_number,
  p_flsa_category                in varchar2         default hr_api.g_varchar2,
  p_forwarding_address_line1     in varchar2         default hr_api.g_varchar2,
  p_forwarding_address_line2     in varchar2         default hr_api.g_varchar2,
  p_forwarding_address_line3     in varchar2         default hr_api.g_varchar2,
  p_forwarding_country           in varchar2         default hr_api.g_varchar2,
  p_forwarding_country_short_nam in varchar2         default hr_api.g_varchar2,
  p_forwarding_postal_code       in varchar2         default hr_api.g_varchar2,
  p_forwarding_region_2          in varchar2         default hr_api.g_varchar2,
  p_forwarding_town_or_city      in varchar2         default hr_api.g_varchar2,
  p_from_adj_basic_pay           in number           default hr_api.g_number,
  p_from_agency_code             in varchar2         default hr_api.g_varchar2,
  p_from_agency_desc             in varchar2         default hr_api.g_varchar2,
  p_from_basic_pay               in number           default hr_api.g_number,
  p_from_grade_or_level          in varchar2         default hr_api.g_varchar2,
  p_from_locality_adj            in number           default hr_api.g_number,
  p_from_occ_code                in varchar2         default hr_api.g_varchar2,
  p_from_office_symbol           in varchar2         default hr_api.g_varchar2,
  p_from_other_pay_amount        in number           default hr_api.g_number,
  p_from_pay_basis               in varchar2         default hr_api.g_varchar2,
  p_from_pay_plan                in varchar2         default hr_api.g_varchar2,
  -- FWFA Changes Bug#4444609
  p_input_pay_rate_determinant   in varchar2         default hr_api.g_varchar2,
  p_from_pay_table_identifier    in number           default hr_api.g_number,
  -- FWFA Changes
  p_from_position_id             in number           default hr_api.g_number,
  p_from_position_org_line1      in varchar2         default hr_api.g_varchar2,
  p_from_position_org_line2      in varchar2         default hr_api.g_varchar2,
  p_from_position_org_line3      in varchar2         default hr_api.g_varchar2,
  p_from_position_org_line4      in varchar2         default hr_api.g_varchar2,
  p_from_position_org_line5      in varchar2         default hr_api.g_varchar2,
  p_from_position_org_line6      in varchar2         default hr_api.g_varchar2,
  p_from_position_number         in varchar2         default hr_api.g_varchar2,
  p_from_position_seq_no         in number           default hr_api.g_number,
  p_from_position_title          in varchar2         default hr_api.g_varchar2,
  p_from_step_or_rate            in varchar2         default hr_api.g_varchar2,
  p_from_total_salary            in number           default hr_api.g_number,
  p_functional_class             in varchar2         default hr_api.g_varchar2,
  p_notepad                      in varchar2         default hr_api.g_varchar2,
  p_part_time_hours              in number           default hr_api.g_number,
  p_pay_rate_determinant         in varchar2         default hr_api.g_varchar2,
  p_personnel_office_id          in varchar2         default hr_api.g_varchar2,
  p_person_id                    in number           default hr_api.g_number,
  p_position_occupied            in varchar2         default hr_api.g_varchar2,
  p_proposed_effective_date      in date             default hr_api.g_date,
  p_requested_by_person_id       in number           default hr_api.g_number,
  p_requested_by_title           in varchar2         default hr_api.g_varchar2,
  p_requested_date               in date             default hr_api.g_date,
  p_requesting_office_remarks_de in varchar2         default hr_api.g_varchar2,
  p_requesting_office_remarks_fl in varchar2         default hr_api.g_varchar2,
  p_request_number               in varchar2         default hr_api.g_varchar2,
  p_resign_and_retire_reason_des in varchar2         default hr_api.g_varchar2,
  p_retirement_plan              in varchar2         default hr_api.g_varchar2,
  p_retirement_plan_desc         in varchar2         default hr_api.g_varchar2,
  p_second_action_la_code1       in varchar2         default hr_api.g_varchar2,
  p_second_action_la_code2       in varchar2         default hr_api.g_varchar2,
  p_second_action_la_desc1       in varchar2         default hr_api.g_varchar2,
  p_second_action_la_desc2       in varchar2         default hr_api.g_varchar2,
  p_second_noa_cancel_or_correct in varchar2         default hr_api.g_varchar2,
  p_second_noa_code              in varchar2         default hr_api.g_varchar2,
  p_second_noa_desc              in varchar2         default hr_api.g_varchar2,
  p_second_noa_id                in number           default hr_api.g_number,
  p_second_noa_pa_request_id     in number           default hr_api.g_number,
  p_service_comp_date            in date             default hr_api.g_date,
  p_status                       in varchar2         default hr_api.g_varchar2,
  p_supervisory_status           in varchar2         default hr_api.g_varchar2,
  p_tenure                       in varchar2         default hr_api.g_varchar2,
  p_to_adj_basic_pay             in number           default hr_api.g_number,
  p_to_basic_pay                 in number           default hr_api.g_number,
  p_to_grade_id                  in number           default hr_api.g_number,
  p_to_grade_or_level            in varchar2         default hr_api.g_varchar2,
  p_to_job_id                    in number           default hr_api.g_number,
  p_to_locality_adj              in number           default hr_api.g_number,
  p_to_occ_code                  in varchar2         default hr_api.g_varchar2,
  p_to_office_symbol             in varchar2         default hr_api.g_varchar2,
  p_to_organization_id           in number           default hr_api.g_number,
  p_to_other_pay_amount          in number           default hr_api.g_number,
  p_to_au_overtime               in number           default hr_api.g_number,
  p_to_auo_premium_pay_indicator in varchar2         default hr_api.g_varchar2,
  p_to_availability_pay          in number           default hr_api.g_number,
  p_to_ap_premium_pay_indicator  in varchar2         default hr_api.g_varchar2,
  p_to_retention_allowance       in number           default hr_api.g_number,
  p_to_supervisory_differential  in number           default hr_api.g_number,
  p_to_staffing_differential     in number           default hr_api.g_number,
  p_to_pay_basis                 in varchar2         default hr_api.g_varchar2,
  p_to_pay_plan                  in varchar2         default hr_api.g_varchar2,
    -- FWFA Changes Bug#4444609
  p_to_pay_table_identifier      in number           default hr_api.g_number,
  -- FWFA Changes
  p_to_position_id               in number           default hr_api.g_number,
  p_to_position_org_line1        in varchar2         default hr_api.g_varchar2,
  p_to_position_org_line2        in varchar2         default hr_api.g_varchar2,
  p_to_position_org_line3        in varchar2         default hr_api.g_varchar2,
  p_to_position_org_line4        in varchar2         default hr_api.g_varchar2,
  p_to_position_org_line5        in varchar2         default hr_api.g_varchar2,
  p_to_position_org_line6        in varchar2         default hr_api.g_varchar2,
  p_to_position_number           in varchar2         default hr_api.g_varchar2,
  p_to_position_seq_no           in number           default hr_api.g_number,
  p_to_position_title            in varchar2         default hr_api.g_varchar2,
  p_to_step_or_rate              in varchar2         default hr_api.g_varchar2,
  p_to_total_salary              in number           default hr_api.g_number,
  p_veterans_preference          in varchar2         default hr_api.g_varchar2,
  p_veterans_pref_for_rif        in varchar2         default hr_api.g_varchar2,
  p_veterans_status              in varchar2         default hr_api.g_varchar2,
  p_work_schedule                in varchar2         default hr_api.g_varchar2,
  p_work_schedule_desc           in varchar2         default hr_api.g_varchar2,
  p_year_degree_attained         in number           default hr_api.g_number,
  p_first_noa_information1       in varchar2         default hr_api.g_varchar2,
  p_first_noa_information2       in varchar2         default hr_api.g_varchar2,
  p_first_noa_information3       in varchar2         default hr_api.g_varchar2,
  p_first_noa_information4       in varchar2         default hr_api.g_varchar2,
  p_first_noa_information5       in varchar2         default hr_api.g_varchar2,
  p_second_lac1_information1     in varchar2         default hr_api.g_varchar2,
  p_second_lac1_information2     in varchar2         default hr_api.g_varchar2,
  p_second_lac1_information3     in varchar2         default hr_api.g_varchar2,
  p_second_lac1_information4     in varchar2         default hr_api.g_varchar2,
  p_second_lac1_information5     in varchar2         default hr_api.g_varchar2,
  p_second_lac2_information1     in varchar2         default hr_api.g_varchar2,
  p_second_lac2_information2     in varchar2         default hr_api.g_varchar2,
  p_second_lac2_information3     in varchar2         default hr_api.g_varchar2,
  p_second_lac2_information4     in varchar2         default hr_api.g_varchar2,
  p_second_lac2_information5     in varchar2         default hr_api.g_varchar2,
  p_second_noa_information1      in varchar2         default hr_api.g_varchar2,
  p_second_noa_information2      in varchar2         default hr_api.g_varchar2,
  p_second_noa_information3      in varchar2         default hr_api.g_varchar2,
  p_second_noa_information4      in varchar2         default hr_api.g_varchar2,
  p_second_noa_information5      in varchar2         default hr_api.g_varchar2,
  p_first_lac1_information1      in varchar2         default hr_api.g_varchar2,
  p_first_lac1_information2      in varchar2         default hr_api.g_varchar2,
  p_first_lac1_information3      in varchar2         default hr_api.g_varchar2,
  p_first_lac1_information4      in varchar2         default hr_api.g_varchar2,
  p_first_lac1_information5      in varchar2         default hr_api.g_varchar2,
  p_first_lac2_information1      in varchar2         default hr_api.g_varchar2,
  p_first_lac2_information2      in varchar2         default hr_api.g_varchar2,
  p_first_lac2_information3      in varchar2         default hr_api.g_varchar2,
  p_first_lac2_information4      in varchar2         default hr_api.g_varchar2,
  p_first_lac2_information5      in varchar2         default hr_api.g_varchar2,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
  p_first_noa_canc_pa_request_id in number           default hr_api.g_number,
  p_second_noa_canc_pa_request_i in number           default hr_api.g_number,
  p_to_retention_allow_percentag in number           default hr_api.g_number,
  p_to_supervisory_diff_percenta in number           default hr_api.g_number,
  p_to_staffing_diff_percentage  in number           default hr_api.g_number,
  p_award_percentage             in number           default hr_api.g_number,
  p_rpa_type                     in varchar2         default hr_api.g_varchar2,
  p_mass_action_id               in number           default hr_api.g_number,
  p_mass_action_eligible_flag    in varchar2         default hr_api.g_varchar2,
  p_mass_action_select_flag      in varchar2         default hr_api.g_varchar2,
  p_mass_action_comments         in varchar2         default hr_api.g_varchar2,
  -- Bug#    RRR Changes
  p_payment_option               in varchar2         default hr_api.g_varchar2,
  p_award_salary                 in number           default hr_api.g_number,
  -- Bug#    RRR Changes
  p_object_version_number        in out nocopy number
  )
 is
--
  l_rec	  ghr_par_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ghr_par_shd.convert_args
(
p_pa_request_id,
p_pa_notification_id,
p_noa_family_code,
p_routing_group_id,
p_proposed_effective_asap_flag,
p_academic_discipline,
p_additional_info_person_id,
p_additional_info_tel_number,
p_agency_code,
p_altered_pa_request_id,
p_annuitant_indicator,
p_annuitant_indicator_desc,
p_appropriation_code1,
p_appropriation_code2,
p_approval_date,
p_approving_official_full_name,
p_approving_official_work_titl,
p_sf50_approval_date,
p_sf50_approving_ofcl_full_nam,
p_sf50_approving_ofcl_work_tit,
p_authorized_by_person_id,
p_authorized_by_title,
p_award_amount,
p_award_uom,
p_bargaining_unit_status,
p_citizenship,
p_concurrence_date,
p_custom_pay_calc_flag,
p_duty_station_code,
p_duty_station_desc,
p_duty_station_id,
p_duty_station_location_id,
p_education_level,
p_effective_date,
p_employee_assignment_id,
p_employee_date_of_birth,
p_employee_dept_or_agency,
p_employee_first_name,
p_employee_last_name,
p_employee_middle_names,
p_employee_national_identifier,
p_fegli,
p_fegli_desc,
p_first_action_la_code1,
p_first_action_la_code2,
p_first_action_la_desc1,
p_first_action_la_desc2,
p_first_noa_cancel_or_correct,
p_first_noa_code,
p_first_noa_desc,
p_first_noa_id,
p_first_noa_pa_request_id,
p_flsa_category,
p_forwarding_address_line1,
p_forwarding_address_line2,
p_forwarding_address_line3,
p_forwarding_country,
p_forwarding_country_short_nam,
p_forwarding_postal_code,
p_forwarding_region_2,
p_forwarding_town_or_city,
p_from_adj_basic_pay,
p_from_agency_code,
p_from_agency_desc,
p_from_basic_pay,
p_from_grade_or_level,
p_from_locality_adj,
p_from_occ_code,
p_from_office_symbol,
p_from_other_pay_amount,
p_from_pay_basis,
p_from_pay_plan,
-- FWFA Chagnes Bug#4444609
p_input_pay_rate_determinant,
p_from_pay_table_identifier,
-- FWFA Changes
p_from_position_id,
p_from_position_org_line1,
p_from_position_org_line2,
p_from_position_org_line3,
p_from_position_org_line4,
p_from_position_org_line5,
p_from_position_org_line6,
p_from_position_number,
p_from_position_seq_no,
p_from_position_title,
p_from_step_or_rate,
p_from_total_salary,
p_functional_class,
p_notepad,
p_part_time_hours,
p_pay_rate_determinant,
p_personnel_office_id,
p_person_id,
p_position_occupied,
p_proposed_effective_date,
p_requested_by_person_id,
p_requested_by_title,
p_requested_date,
p_requesting_office_remarks_de,
p_requesting_office_remarks_fl,
p_request_number,
p_resign_and_retire_reason_des,
p_retirement_plan,
p_retirement_plan_desc,
p_second_action_la_code1,
p_second_action_la_code2,
p_second_action_la_desc1,
p_second_action_la_desc2,
p_second_noa_cancel_or_correct,
p_second_noa_code,
p_second_noa_desc,
p_second_noa_id,
p_second_noa_pa_request_id,
p_service_comp_date,
p_status,
p_supervisory_status,
p_tenure,
p_to_adj_basic_pay,
p_to_basic_pay,
p_to_grade_id,
p_to_grade_or_level,
p_to_job_id,
p_to_locality_adj,
p_to_occ_code,
p_to_office_symbol,
p_to_organization_id,
p_to_other_pay_amount,
p_to_au_overtime,
p_to_auo_premium_pay_indicator,
p_to_availability_pay,
p_to_ap_premium_pay_indicator,
p_to_retention_allowance,
p_to_supervisory_differential,
p_to_staffing_differential,
p_to_pay_basis,
p_to_pay_plan,
-- FWFA Chagnes Bug#4444609
p_to_pay_table_identifier,
-- FWFA Changes
p_to_position_id,
p_to_position_org_line1,
p_to_position_org_line2,
p_to_position_org_line3,
p_to_position_org_line4,
p_to_position_org_line5,
p_to_position_org_line6,
p_to_position_number,
p_to_position_seq_no,
p_to_position_title,
p_to_step_or_rate,
p_to_total_salary,
p_veterans_preference,
p_veterans_pref_for_rif,
p_veterans_status,
p_work_schedule,
p_work_schedule_desc,
p_year_degree_attained,
p_first_noa_information1,
p_first_noa_information2,
p_first_noa_information3,
p_first_noa_information4,
p_first_noa_information5,
p_second_lac1_information1,
p_second_lac1_information2,
p_second_lac1_information3,
p_second_lac1_information4,
p_second_lac1_information5,
p_second_lac2_information1,
p_second_lac2_information2,
p_second_lac2_information3,
p_second_lac2_information4,
p_second_lac2_information5,
p_second_noa_information1,
p_second_noa_information2,
p_second_noa_information3,
p_second_noa_information4,
p_second_noa_information5,
p_first_lac1_information1,
p_first_lac1_information2,
p_first_lac1_information3,
p_first_lac1_information4,
p_first_lac1_information5,
p_first_lac2_information1,
p_first_lac2_information2,
p_first_lac2_information3,
p_first_lac2_information4,
p_first_lac2_information5,
p_attribute_category,
p_attribute1,
p_attribute2,
p_attribute3,
p_attribute4,
p_attribute5,
p_attribute6,
p_attribute7,
p_attribute8,
p_attribute9,
p_attribute10,
p_attribute11,
p_attribute12,
p_attribute13,
p_attribute14,
p_attribute15,
p_attribute16,
p_attribute17,
p_attribute18,
p_attribute19,
p_attribute20,
p_first_noa_canc_pa_request_id,
p_second_noa_canc_pa_request_i,
p_to_retention_allow_percentag,
p_to_supervisory_diff_percenta,
p_to_staffing_diff_percentage ,
p_award_percentage            ,
p_rpa_type                    ,
p_mass_action_id              ,
p_mass_action_eligible_flag   ,
p_mass_action_select_flag     ,
p_mass_action_comments        ,
-- Bug#     RRR Changes
p_payment_option              ,
p_award_salary                ,
-- Bug#     RRR Changes
p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec);
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ghr_par_upd;

/
