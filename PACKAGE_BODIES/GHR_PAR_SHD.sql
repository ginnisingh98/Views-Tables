--------------------------------------------------------
--  DDL for Package Body GHR_PAR_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PAR_SHD" as
/* $Header: ghparrhi.pkb 120.5.12010000.3 2008/10/22 07:10:55 utokachi ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ghr_par_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
            (p_constraint_name in all_constraints.constraint_name%TYPE) Is
--
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'GHR_PA_REQUESTS_FK2') Then
    hr_utility.set_message(8301, 'GHR_38058_INV_FIRST_NOA');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'GHR_PA_REQUESTS_FK10') Then
    hr_utility.set_message(8301, 'GHR_38050_INV_ROUTING_GROUP');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'GHR_PA_REQUESTS_FK11') Then -- First_noa_pa_request_id
     hr_utility.set_message(8301, 'GHR_38199_INV_F_PA_REQ');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'GHR_PA_REQUESTS_FK12') Then  -- Second Noa_pa_request_id
    hr_utility.set_message(8301, 'GHR_38125_INV_S_PA_REQ');
    hr_utility.raise_error;
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'GHR_PA_REQUESTS_FK13') Then   -- Altered Pa_request_id
    hr_utility.set_message(8301, 'GHR_38126_INV_A_PA_REQ');
    hr_utility.raise_error;
   ElsIf (p_constraint_name = 'GHR_PA_REQUESTS_FK3') Then
    hr_utility.set_message(8301, 'GHR_38166_INV_SECOND_NOA');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'GHR_PA_REQUESTS_FK1') Then
    hr_utility.set_message(8301, 'GHR_38049_INV_NOA_FAMILY');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'GHR_PA_REQUESTS_FK4') Then
    hr_utility.set_message(8301, 'GHR_38266_INV_TO_PAY_PLAN');
    hr_utility.raise_error;
 -- ElsIf (p_constraint_name = 'GHR_PA_REQUESTS_FK5') Then
  --  hr_utility.set_message(8301, 'GHR_38057_INV_TO_POSITION');
   -- hr_utility.raise_error;
  ElsIf (p_constraint_name = 'GHR_PA_REQUESTS_FK6') Then
    hr_utility.set_message(8301, 'GHR_38052_INV_JOB');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'GHR_PA_REQUESTS_FK7') Then
    hr_utility.set_message(8301, 'GHR_38053_INV_GRADE');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'GHR_PA_REQUESTS_FK8') Then
    hr_utility.set_message(8301, 'GHR_38054_INV_ORGANIZATION');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'GHR_PA_REQUESTS_FK14') Then
    hr_utility.set_message(8301, 'GHR_38265_INV_FROM_PAY_PLAN');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'GHR_PA_REQUESTS_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','70');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'GHR_PA_REQUESTS_UK1') Then
   -- hr_utility.set_message(8301, 'GHR_38127_NOTIF_MUST_BE_UNIQ');
    hr_utility.raise_error;
  Else
    hr_utility.set_message(801, 'HR_7877_API_INVALID_CONSTRAINT');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('CONSTRAINT_NAME', p_constraint_name);
    hr_utility.raise_error;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (
  p_pa_request_id                      in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
      pa_request_id,
	pa_notification_id,
	noa_family_code,
	routing_group_id,
	proposed_effective_asap_flag,
	academic_discipline,
	additional_info_person_id,
	additional_info_tel_number,
	agency_code,
	altered_pa_request_id,
	annuitant_indicator,
	annuitant_indicator_desc,
	appropriation_code1,
	appropriation_code2,
	approval_date,
      approving_official_full_name,
	approving_official_work_title,
      sf50_approval_date,
      sf50_approving_ofcl_full_name,
	sf50_approving_ofcl_work_title,
	authorized_by_person_id,
	authorized_by_title,
	award_amount,
	award_uom,
	bargaining_unit_status,
	citizenship,
	concurrence_date,
      custom_pay_calc_flag,
	duty_station_code,
	duty_station_desc,
	duty_station_id,
	duty_station_location_id,
	education_level,
	effective_date,
	employee_assignment_id,
	employee_date_of_birth,
	employee_dept_or_agency,
	employee_first_name,
	employee_last_name,
	employee_middle_names,
	employee_national_identifier,
	fegli,
	fegli_desc,
	first_action_la_code1,
	first_action_la_code2,
	first_action_la_desc1,
	first_action_la_desc2,
	first_noa_cancel_or_correct,
	first_noa_code,
	first_noa_desc,
	first_noa_id,
	first_noa_pa_request_id,
	flsa_category,
	forwarding_address_line1,
	forwarding_address_line2,
	forwarding_address_line3,
	forwarding_country,
      forwarding_country_short_name,
	forwarding_postal_code,
	forwarding_region_2,
	forwarding_town_or_city,
	from_adj_basic_pay,
	from_agency_code,
	from_agency_desc,
	from_basic_pay,
	from_grade_or_level,
	from_locality_adj,
	from_occ_code,
	from_office_symbol,
	from_other_pay_amount,
	from_pay_basis,
	from_pay_plan,
	-- FWFA Changes Bug#4444609
    input_pay_rate_determinant,
	from_pay_table_identifier,
	-- FWFA Changes
	from_position_id,
      from_position_org_line1,
      from_position_org_line2,
      from_position_org_line3,
      from_position_org_line4,
      from_position_org_line5,
      from_position_org_line6,
	from_position_number,
	from_position_seq_no,
	from_position_title,
	from_step_or_rate,
	from_total_salary,
	functional_class,
	notepad,
	part_time_hours,
	pay_rate_determinant,
	personnel_office_id,
	person_id,
	position_occupied,
	proposed_effective_date,
	requested_by_person_id,
	requested_by_title,
	requested_date,
	requesting_office_remarks_desc,
	requesting_office_remarks_flag,
	request_number,
	resign_and_retire_reason_desc,
	retirement_plan,
	retirement_plan_desc,
	second_action_la_code1,
	second_action_la_code2,
	second_action_la_desc1,
	second_action_la_desc2,
	second_noa_cancel_or_correct,
	second_noa_code,
	second_noa_desc,
	second_noa_id,
	second_noa_pa_request_id,
	service_comp_date,
        status,
	supervisory_status,
	tenure,
	to_adj_basic_pay,
	to_basic_pay,
	to_grade_id,
	to_grade_or_level,
	to_job_id,
	to_locality_adj,
      to_occ_code,
	to_office_symbol,
	to_organization_id,
	to_other_pay_amount,
      to_au_overtime,
      to_auo_premium_pay_indicator,
      to_availability_pay,
      to_ap_premium_pay_indicator,
      to_retention_allowance,
      to_supervisory_differential,
      to_staffing_differential,
	to_pay_basis,
	to_pay_plan,
	-- FWFA Changes Bug#4444609
	to_pay_table_identifier,
	-- FWFA Changes
	to_position_id,
      to_position_org_line1,
      to_position_org_line2,
      to_position_org_line3,
      to_position_org_line4,
      to_position_org_line5,
      to_position_org_line6,
	to_position_number,
	to_position_seq_no,
	to_position_title,
	to_step_or_rate,
	to_total_salary,
	veterans_preference,
	veterans_pref_for_rif,
	veterans_status,
	work_schedule,
	work_schedule_desc,
	year_degree_attained,
	first_noa_information1,
	first_noa_information2,
	first_noa_information3,
	first_noa_information4,
	first_noa_information5,
	second_lac1_information1,
	second_lac1_information2,
	second_lac1_information3,
	second_lac1_information4,
	second_lac1_information5,
	second_lac2_information1,
	second_lac2_information2,
	second_lac2_information3,
	second_lac2_information4,
	second_lac2_information5,
	second_noa_information1,
	second_noa_information2,
	second_noa_information3,
	second_noa_information4,
	second_noa_information5,
	first_lac1_information1,
	first_lac1_information2,
	first_lac1_information3,
	first_lac1_information4,
	first_lac1_information5,
	first_lac2_information1,
	first_lac2_information2,
	first_lac2_information3,
	first_lac2_information4,
	first_lac2_information5,
	attribute_category,
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10,
	attribute11,
	attribute12,
	attribute13,
	attribute14,
	attribute15,
	attribute16,
	attribute17,
	attribute18,
	attribute19,
	attribute20,
      first_noa_canc_pa_request_id  ,
      second_noa_canc_pa_request_id ,
      to_retention_allow_percentage ,
      to_supervisory_diff_percentage,
      to_staffing_diff_percentage   ,
      award_percentage              ,
      rpa_type,
      mass_action_id,
      mass_action_eligible_flag,
      mass_action_select_flag,
      mass_action_comments,
      -- Bug#    RRR Changes
      pa_incentive_payment_option,
      award_salary,
      -- Bug#    RRR Changes
	object_version_number
    from	ghr_pa_requests
    where	pa_request_id = p_pa_request_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
  --	p_pa_request_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_pa_request_id = g_old_rec.pa_request_id and
	p_object_version_number = g_old_rec.object_version_number
       ) Then
      hr_utility.set_location(l_proc, 10);
      --
      -- The g_old_rec is current therefore we must
      -- set the returning function to true
      --
      l_fct_ret := true;
    Else
      --
      -- Select the current row into g_old_rec
      --
      Open C_Sel1;
      Fetch C_Sel1 Into g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
        hr_utility.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
      End If;
      hr_utility.set_location(l_proc, 15);
      l_fct_ret := true;
    End If;
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (
  p_pa_request_id                      in number,
  p_routing_group_id                   in number,
  p_object_version_number              in number
  ) is
--
-- Cursor s the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
      pa_request_id,
	pa_notification_id,
	noa_family_code,
	routing_group_id,
	proposed_effective_asap_flag,
	academic_discipline,
	additional_info_person_id,
	additional_info_tel_number,
	agency_code,
	altered_pa_request_id,
	annuitant_indicator,
	annuitant_indicator_desc,
	appropriation_code1,
	appropriation_code2,
	approval_date,
      approving_official_full_name,
	approving_official_work_title,
	sf50_approval_date,
      sf50_approving_ofcl_full_name,
	sf50_approving_ofcl_work_title,
	authorized_by_person_id,
	authorized_by_title,
	award_amount,
	award_uom,
	bargaining_unit_status,
	citizenship,
	concurrence_date,
      custom_pay_calc_flag,
	duty_station_code,
	duty_station_desc,
	duty_station_id,
	duty_station_location_id,
	education_level,
	effective_date,
	employee_assignment_id,
	employee_date_of_birth,
	employee_dept_or_agency,
	employee_first_name,
	employee_last_name,
	employee_middle_names,
	employee_national_identifier,
	fegli,
	fegli_desc,
	first_action_la_code1,
	first_action_la_code2,
	first_action_la_desc1,
	first_action_la_desc2,
	first_noa_cancel_or_correct,
	first_noa_code,
	first_noa_desc,
	first_noa_id,
	first_noa_pa_request_id,
	flsa_category,
	forwarding_address_line1,
	forwarding_address_line2,
	forwarding_address_line3,
	forwarding_country,
      forwarding_country_short_name,
	forwarding_postal_code,
	forwarding_region_2,
	forwarding_town_or_city,
	from_adj_basic_pay,
	from_agency_code,
	from_agency_desc,
	from_basic_pay,
	from_grade_or_level,
	from_locality_adj,
	from_occ_code,
	from_office_symbol,
	from_other_pay_amount,
	from_pay_basis,
	from_pay_plan,
  	-- FWFA Changes Bug#4444609
    input_pay_rate_determinant,
	from_pay_table_identifier,
	-- FWFA Changes
	from_position_id,
      from_position_org_line1,
      from_position_org_line2,
      from_position_org_line3,
      from_position_org_line4,
      from_position_org_line5,
      from_position_org_line6,
	from_position_number,
	from_position_seq_no,
	from_position_title,
	from_step_or_rate,
	from_total_salary,
	functional_class,
	notepad,
	part_time_hours,
	pay_rate_determinant,
	personnel_office_id,
	person_id,
	position_occupied,
	proposed_effective_date,
	requested_by_person_id,
	requested_by_title,
	requested_date,
	requesting_office_remarks_desc,
	requesting_office_remarks_flag,
	request_number,
	resign_and_retire_reason_desc,
	retirement_plan,
	retirement_plan_desc,
	second_action_la_code1,
	second_action_la_code2,
	second_action_la_desc1,
	second_action_la_desc2,
	second_noa_cancel_or_correct,
	second_noa_code,
	second_noa_desc,
	second_noa_id,
	second_noa_pa_request_id,
	service_comp_date,
        status,
	supervisory_status,
	tenure,
	to_adj_basic_pay,
	to_basic_pay,
	to_grade_id,
	to_grade_or_level,
	to_job_id,
	to_locality_adj,
      to_occ_code,
	to_office_symbol,
	to_organization_id,
	to_other_pay_amount,
      to_au_overtime,
      to_auo_premium_pay_indicator,
      to_availability_pay,
      to_ap_premium_pay_indicator,
      to_retention_allowance,
      to_supervisory_differential,
      to_staffing_differential,
	to_pay_basis,
	to_pay_plan,
	-- FWFA Changes Bug#4444609
	to_pay_table_identifier,
	-- FWFA Changes
	to_position_id,
      to_position_org_line1,
      to_position_org_line2,
      to_position_org_line3,
      to_position_org_line4,
      to_position_org_line5,
      to_position_org_line6,
	to_position_number,
	to_position_seq_no,
	to_position_title,
	to_step_or_rate,
	to_total_salary,
	veterans_preference,
	veterans_pref_for_rif,
	veterans_status,
	work_schedule,
	work_schedule_desc,
	year_degree_attained,
	first_noa_information1,
	first_noa_information2,
	first_noa_information3,
	first_noa_information4,
	first_noa_information5,
	second_lac1_information1,
	second_lac1_information2,
	second_lac1_information3,
	second_lac1_information4,
	second_lac1_information5,
	second_lac2_information1,
	second_lac2_information2,
	second_lac2_information3,
	second_lac2_information4,
	second_lac2_information5,
	second_noa_information1,
	second_noa_information2,
	second_noa_information3,
	second_noa_information4,
	second_noa_information5,
	first_lac1_information1,
	first_lac1_information2,
	first_lac1_information3,
	first_lac1_information4,
	first_lac1_information5,
	first_lac2_information1,
	first_lac2_information2,
	first_lac2_information3,
	first_lac2_information4,
	first_lac2_information5,
	attribute_category,
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10,
	attribute11,
	attribute12,
	attribute13,
	attribute14,
	attribute15,
	attribute16,
	attribute17,
	attribute18,
	attribute19,
	attribute20,
      first_noa_canc_pa_request_id  ,
      second_noa_canc_pa_request_id ,
      to_retention_allow_percentage ,
      to_supervisory_diff_percentage,
      to_staffing_diff_percentage   ,
      award_percentage              ,
      rpa_type,
      mass_action_id,
      mass_action_eligible_flag,
      mass_action_select_flag,
      mass_action_comments,
      -- Bug#    RRR Changes
      pa_incentive_payment_option,
      award_salary,
      -- Bug#    RRR Changes
 	object_version_number
    from	ghr_pa_requests
    where	pa_request_id = p_pa_request_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Add any mandatory argument checking here:
  -- Example:
  -- hr_api.mandatory_arg_error
  --   (p_api_name       => l_proc,
  --    p_argument       => 'object_version_number',
  --    p_argument_value => p_object_version_number);
  --
  /*  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
    p_argument       => 'routing_group_id',
    p_argument_value => p_routing_group_id);
*/


  Open  C_Sel1;
  Fetch C_Sel1 Into g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
      End If;
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
-- We need to trap the ORA LOCK exception
--
Exception
  When HR_Api.Object_Locked then
    --
    -- The object is locked therefore we need to supply a meaningful
    -- error message.
    --
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'ghr_pa_requests');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_pa_request_id                 in number,
	p_pa_notification_id            in number,
	p_noa_family_code               in varchar2,
	p_routing_group_id              in number,
	p_proposed_effective_asap_flag  in varchar2,
	p_academic_discipline           in varchar2,
	p_additional_info_person_id     in number,
	p_additional_info_tel_number    in varchar2,
	p_agency_code                   in varchar2,
	p_altered_pa_request_id         in number,
	p_annuitant_indicator           in varchar2,
	p_annuitant_indicator_desc      in varchar2,
	p_appropriation_code1           in varchar2,
	p_appropriation_code2           in varchar2,
	p_approval_date                 in date,
      p_approving_official_full_name  in varchar2,
	p_approving_official_work_titl  in varchar2,
      p_sf50_approval_date            in date,
      p_sf50_approving_ofcl_full_nam in varchar2,
	p_sf50_approving_ofcl_work_tit in varchar2,
	p_authorized_by_person_id       in number,
	p_authorized_by_title           in varchar2,
	p_award_amount                  in number,
	p_award_uom                     in varchar2,
	p_bargaining_unit_status        in varchar2,
	p_citizenship                   in varchar2,
	p_concurrence_date              in date,
      p_custom_pay_calc_flag          in varchar2,
	p_duty_station_code             in varchar2,
	p_duty_station_desc             in varchar2,
	p_duty_station_id               in number,
	p_duty_station_location_id      in number,
	p_education_level               in varchar2,
	p_effective_date                in date,
	p_employee_assignment_id        in number,
	p_employee_date_of_birth        in date,
	p_employee_dept_or_agency       in varchar2,
	p_employee_first_name           in varchar2,
	p_employee_last_name            in varchar2,
	p_employee_middle_names         in varchar2,
	p_employee_national_identifier  in varchar2,
	p_fegli                         in varchar2,
	p_fegli_desc                    in varchar2,
	p_first_action_la_code1         in varchar2,
	p_first_action_la_code2         in varchar2,
	p_first_action_la_desc1         in varchar2,
	p_first_action_la_desc2         in varchar2,
	p_first_noa_cancel_or_correct   in varchar2,
	p_first_noa_code                in varchar2,
	p_first_noa_desc                in varchar2,
	p_first_noa_id                  in number,
	p_first_noa_pa_request_id       in number,
	p_flsa_category                 in varchar2,
	p_forwarding_address_line1      in varchar2,
	p_forwarding_address_line2      in varchar2,
	p_forwarding_address_line3      in varchar2,
	p_forwarding_country            in varchar2,
      p_forwarding_country_short_nam  in varchar2,
	p_forwarding_postal_code        in varchar2,
	p_forwarding_region_2           in varchar2,
	p_forwarding_town_or_city       in varchar2,
	p_from_adj_basic_pay            in number,
	p_from_agency_code              in varchar2,
	p_from_agency_desc              in varchar2,
	p_from_basic_pay                in number,
	p_from_grade_or_level           in varchar2,
	p_from_locality_adj             in number,
	p_from_occ_code                 in varchar2,
	p_from_office_symbol            in varchar2,
      p_from_other_pay_amount         in number,
	p_from_pay_basis                in varchar2,
	p_from_pay_plan                 in varchar2,
    -- FWFA Changes Bug#4444609
    p_input_pay_rate_determinant    in varchar2,
    p_from_pay_table_identifier     in number,
    -- FWFA Changes
      p_from_position_id              in number,
      p_from_position_org_line1       in varchar2,
      p_from_position_org_line2       in varchar2,
      p_from_position_org_line3       in varchar2,
      p_from_position_org_line4       in varchar2,
      p_from_position_org_line5       in varchar2,
      p_from_position_org_line6       in varchar2,
	p_from_position_number          in varchar2,
	p_from_position_seq_no          in number,
	p_from_position_title           in varchar2,
	p_from_step_or_rate             in varchar2,
	p_from_total_salary             in number,
	p_functional_class              in varchar2,
	p_notepad                       in varchar2,
	p_part_time_hours               in number,
	p_pay_rate_determinant          in varchar2,
	p_personnel_office_id           in varchar2,
	p_person_id                     in number,
	p_position_occupied             in varchar2,
	p_proposed_effective_date       in date,
	p_requested_by_person_id        in number,
	p_requested_by_title            in varchar2,
	p_requested_date                in date,
	p_requesting_office_remarks_de  in varchar2,
	p_requesting_office_remarks_fl  in varchar2,
	p_request_number                in varchar2,
	p_resign_and_retire_reason_des  in varchar2,
	p_retirement_plan               in varchar2,
	p_retirement_plan_desc          in varchar2,
	p_second_action_la_code1        in varchar2,
	p_second_action_la_code2        in varchar2,
	p_second_action_la_desc1        in varchar2,
	p_second_action_la_desc2        in varchar2,
	p_second_noa_cancel_or_correct  in varchar2,
	p_second_noa_code               in varchar2,
	p_second_noa_desc               in varchar2,
	p_second_noa_id                 in number,
	p_second_noa_pa_request_id      in number,
	p_service_comp_date             in date,
        p_status                        in varchar2,
	p_supervisory_status            in varchar2,
	p_tenure                        in varchar2,
	p_to_adj_basic_pay              in number,
	p_to_basic_pay                  in number,
	p_to_grade_id                   in number,
	p_to_grade_or_level             in varchar2,
	p_to_job_id                     in number,
	p_to_locality_adj               in number,
	p_to_occ_code                   in varchar2,
	p_to_office_symbol              in varchar2,
	p_to_organization_id            in number,
	p_to_other_pay_amount           in number,
      p_to_au_overtime                in number,
      p_to_auo_premium_pay_indicator  in varchar2,
      p_to_availability_pay           in number,
      p_to_ap_premium_pay_indicator   in varchar2,
      p_to_retention_allowance        in number,
      p_to_supervisory_differential   in number,
      p_to_staffing_differential      in number,
	p_to_pay_basis                  in varchar2,
	p_to_pay_plan                   in varchar2,
    -- FWFA Changes Bug#4444609
    p_to_pay_table_identifier       in number,
    -- FWFA Changes
	p_to_position_id                in number,
      p_to_position_org_line1         in varchar2,
      p_to_position_org_line2         in varchar2,
      p_to_position_org_line3         in varchar2,
      p_to_position_org_line4         in varchar2,
      p_to_position_org_line5         in varchar2,
      p_to_position_org_line6         in varchar2,
	p_to_position_number            in varchar2,
	p_to_position_seq_no            in number,
	p_to_position_title             in varchar2,
	p_to_step_or_rate               in varchar2,
	p_to_total_salary               in number,
	p_veterans_preference           in varchar2,
	p_veterans_pref_for_rif         in varchar2,
	p_veterans_status               in varchar2,
	p_work_schedule                 in varchar2,
	p_work_schedule_desc            in varchar2,
	p_year_degree_attained          in number,
	p_first_noa_information1        in varchar2,
	p_first_noa_information2        in varchar2,
	p_first_noa_information3        in varchar2,
	p_first_noa_information4        in varchar2,
	p_first_noa_information5        in varchar2,
	p_second_lac1_information1      in varchar2,
	p_second_lac1_information2      in varchar2,
	p_second_lac1_information3      in varchar2,
	p_second_lac1_information4      in varchar2,
	p_second_lac1_information5      in varchar2,
	p_second_lac2_information1      in varchar2,
	p_second_lac2_information2      in varchar2,
	p_second_lac2_information3      in varchar2,
	p_second_lac2_information4      in varchar2,
	p_second_lac2_information5      in varchar2,
	p_second_noa_information1       in varchar2,
	p_second_noa_information2       in varchar2,
	p_second_noa_information3       in varchar2,
	p_second_noa_information4       in varchar2,
	p_second_noa_information5       in varchar2,
	p_first_lac1_information1       in varchar2,
	p_first_lac1_information2       in varchar2,
	p_first_lac1_information3       in varchar2,
	p_first_lac1_information4       in varchar2,
	p_first_lac1_information5       in varchar2,
	p_first_lac2_information1       in varchar2,
	p_first_lac2_information2       in varchar2,
	p_first_lac2_information3       in varchar2,
	p_first_lac2_information4       in varchar2,
	p_first_lac2_information5       in varchar2,
	p_attribute_category            in varchar2,
	p_attribute1                    in varchar2,
	p_attribute2                    in varchar2,
	p_attribute3                    in varchar2,
	p_attribute4                    in varchar2,
	p_attribute5                    in varchar2,
	p_attribute6                    in varchar2,
	p_attribute7                    in varchar2,
	p_attribute8                    in varchar2,
	p_attribute9                    in varchar2,
	p_attribute10                   in varchar2,
	p_attribute11                   in varchar2,
	p_attribute12                   in varchar2,
	p_attribute13                   in varchar2,
	p_attribute14                   in varchar2,
	p_attribute15                   in varchar2,
	p_attribute16                   in varchar2,
	p_attribute17                   in varchar2,
	p_attribute18                   in varchar2,
	p_attribute19                   in varchar2,
	p_attribute20                   in varchar2,
        p_first_noa_canc_pa_request_id  in number  ,
        p_second_noa_canc_pa_request_i  in number  ,
        p_to_retention_allow_percentag  in number  ,
        p_to_supervisory_diff_percenta  in number  ,
        p_to_staffing_diff_percentage   in number  ,
        p_award_percentage              in number  ,
        p_rpa_type                      in varchar2,
        p_mass_action_id                in number  ,
        p_mass_action_eligible_flag     in varchar2,
        p_mass_action_select_flag       in varchar2,
        p_mass_action_comments          in varchar2,
        -- Bug#4486823 RRR Changes
        p_payment_option                in varchar2,
        p_award_salary                  in number,
        -- Bug#4486823 RRR Changes
	p_object_version_number         in number
	)
	Return g_rec_type is
--
  l_rec	  g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.pa_request_id                    := p_pa_request_id;
  l_rec.pa_notification_id               := p_pa_notification_id;
  l_rec.noa_family_code                  := p_noa_family_code;
  l_rec.routing_group_id                 := p_routing_group_id;
  l_rec.proposed_effective_asap_flag     := p_proposed_effective_asap_flag;
  l_rec.academic_discipline              := p_academic_discipline;
  l_rec.additional_info_person_id        := p_additional_info_person_id;
  l_rec.additional_info_tel_number       := p_additional_info_tel_number;
  l_rec.agency_code                      := p_agency_code;
  l_rec.altered_pa_request_id            := p_altered_pa_request_id;
  l_rec.annuitant_indicator              := p_annuitant_indicator;
  l_rec.annuitant_indicator_desc         := p_annuitant_indicator_desc;
  l_rec.appropriation_code1              := p_appropriation_code1;
  l_rec.appropriation_code2              := p_appropriation_code2;
  l_rec.approval_date                    := p_approval_date;
  l_rec.approving_official_full_name     := p_approving_official_full_name;
  l_rec.approving_official_work_title    := p_approving_official_work_titl;
  l_rec.sf50_approval_date               := p_sf50_approval_date;
  l_rec.sf50_approving_ofcl_full_name    := p_sf50_approving_ofcl_full_nam;
  l_rec.sf50_approving_ofcl_work_title   := p_sf50_approving_ofcl_work_tit;
  l_rec.authorized_by_person_id          := p_authorized_by_person_id;
  l_rec.authorized_by_title              := p_authorized_by_title;
  l_rec.award_amount                     := p_award_amount;
  hr_utility.set_location('Before awarduom', 1);
 hr_utility.set_location('Award UOM' || p_award_uom,1);
  l_rec.award_uom                        := p_award_uom;
 hr_utility.set_location('L Award UOM' || l_rec.award_uom,1);
  l_rec.bargaining_unit_status           := p_bargaining_unit_status;
  l_rec.citizenship                      := p_citizenship;
  l_rec.concurrence_date                 := p_concurrence_date;
  l_rec.custom_pay_calc_flag             := p_custom_pay_calc_flag;
  l_rec.duty_station_code                := p_duty_station_code;
  l_rec.duty_station_desc                := p_duty_station_desc;
  l_rec.duty_station_id                  := p_duty_station_id;
  l_rec.duty_station_location_id         := p_duty_station_location_id;
  l_rec.education_level                  := p_education_level;
  l_rec.effective_date                   := p_effective_date;
  l_rec.employee_assignment_id           := p_employee_assignment_id;
  l_rec.employee_date_of_birth           := p_employee_date_of_birth;
  l_rec.employee_dept_or_agency          := p_employee_dept_or_agency;
  l_rec.employee_first_name              := p_employee_first_name;
  l_rec.employee_last_name               := p_employee_last_name;
  l_rec.employee_middle_names            := p_employee_middle_names;
  l_rec.employee_national_identifier     := p_employee_national_identifier;
  l_rec.fegli                            := p_fegli;
  l_rec.fegli_desc                       := p_fegli_desc;
  l_rec.first_action_la_code1            := p_first_action_la_code1;
  l_rec.first_action_la_code2            := p_first_action_la_code2;
  l_rec.first_action_la_desc1            := p_first_action_la_desc1;
  l_rec.first_action_la_desc2            := p_first_action_la_desc2;
  l_rec.first_noa_cancel_or_correct      := p_first_noa_cancel_or_correct;
  l_rec.first_noa_code                   := p_first_noa_code;
  l_rec.first_noa_desc                   := p_first_noa_desc;
  l_rec.first_noa_id                     := p_first_noa_id;
  l_rec.first_noa_pa_request_id          := p_first_noa_pa_request_id;
  l_rec.flsa_category                    := p_flsa_category;
  l_rec.forwarding_address_line1         := p_forwarding_address_line1;
  l_rec.forwarding_address_line2         := p_forwarding_address_line2;
  l_rec.forwarding_address_line3         := p_forwarding_address_line3;
  l_rec.forwarding_country               := p_forwarding_country;
  l_rec.forwarding_country_short_name    := p_forwarding_country_short_nam;
  l_rec.forwarding_postal_code           := p_forwarding_postal_code;
  l_rec.forwarding_region_2              := p_forwarding_region_2;
  l_rec.forwarding_town_or_city          := p_forwarding_town_or_city;
  l_rec.from_adj_basic_pay               := p_from_adj_basic_pay;
  l_rec.from_agency_code                 := p_from_agency_code;
  l_rec.from_agency_desc                 := p_from_agency_desc;
  l_rec.from_basic_pay                   := p_from_basic_pay;
  l_rec.from_grade_or_level              := p_from_grade_or_level;
  l_rec.from_locality_adj                := p_from_locality_adj;
  l_rec.from_occ_code                    := p_from_occ_code;
  l_rec.from_office_symbol               := p_from_office_symbol;
  l_rec.from_other_pay_amount            := p_from_other_pay_amount;
  l_rec.from_pay_basis                   := p_from_pay_basis;
  l_rec.from_pay_plan                    := p_from_pay_plan;
  -- FWFA Changes Bug#4444609
  l_rec.input_pay_rate_determinant       := p_input_pay_rate_determinant;
  l_rec.from_pay_table_identifier        := p_from_pay_table_identifier;
  -- FWFA Changes
  l_rec.from_position_id                 := p_from_position_id;
  l_rec.from_position_org_line1          := p_from_position_org_line1;
  l_rec.from_position_org_line2          := p_from_position_org_line2;
  l_rec.from_position_org_line3          := p_from_position_org_line3;
  l_rec.from_position_org_line4          := p_from_position_org_line4;
  l_rec.from_position_org_line5          := p_from_position_org_line5;
  l_rec.from_position_org_line6          := p_from_position_org_line6;
  l_rec.from_position_number             := p_from_position_number;
  l_rec.from_position_seq_no             := p_from_position_seq_no;
  l_rec.from_position_title              := p_from_position_title;
  l_rec.from_step_or_rate                := p_from_step_or_rate;
  l_rec.from_total_salary                := p_from_total_salary;
  l_rec.functional_class                 := p_functional_class;
  l_rec.notepad                          := p_notepad;
  l_rec.part_time_hours                  := p_part_time_hours;
  l_rec.pay_rate_determinant             := p_pay_rate_determinant;
  l_rec.personnel_office_id              := p_personnel_office_id;
  l_rec.person_id                        := p_person_id;
  l_rec.position_occupied                := p_position_occupied;
  l_rec.proposed_effective_date          := p_proposed_effective_date;
  l_rec.requested_by_person_id           := p_requested_by_person_id;
  l_rec.requested_by_title               := p_requested_by_title;
  l_rec.requested_date                   := p_requested_date;
  l_rec.requesting_office_remarks_desc   := p_requesting_office_remarks_de;
  l_rec.requesting_office_remarks_flag   := p_requesting_office_remarks_fl;
  l_rec.request_number                   := p_request_number;
  l_rec.resign_and_retire_reason_desc    := p_resign_and_retire_reason_des;
  l_rec.retirement_plan                  := p_retirement_plan;
  l_rec.retirement_plan_desc             := p_retirement_plan_desc;
  l_rec.second_action_la_code1           := p_second_action_la_code1;
  l_rec.second_action_la_code2           := p_second_action_la_code2;
  l_rec.second_action_la_desc1           := p_second_action_la_desc1;
  l_rec.second_action_la_desc2           := p_second_action_la_desc2;
  l_rec.second_noa_cancel_or_correct     := p_second_noa_cancel_or_correct;
  l_rec.second_noa_code                  := p_second_noa_code;
  l_rec.second_noa_desc                  := p_second_noa_desc;
  l_rec.second_noa_id                    := p_second_noa_id;
  l_rec.second_noa_pa_request_id         := p_second_noa_pa_request_id;
  l_rec.service_comp_date                := p_service_comp_date;
  l_rec.status                           := p_status;
  l_rec.supervisory_status               := p_supervisory_status;
  l_rec.tenure                           := p_tenure;
  l_rec.to_adj_basic_pay                 := p_to_adj_basic_pay;
  l_rec.to_basic_pay                     := p_to_basic_pay;
  l_rec.to_grade_id                      := p_to_grade_id;
  l_rec.to_grade_or_level                := p_to_grade_or_level;
  l_rec.to_job_id                        := p_to_job_id;
  l_rec.to_locality_adj                  := p_to_locality_adj;
  l_rec.to_occ_code                      := p_to_occ_code;
  l_rec.to_office_symbol                 := p_to_office_symbol;
  l_rec.to_organization_id               := p_to_organization_id;
  l_rec.to_other_pay_amount              := p_to_other_pay_amount;
  l_rec.to_au_overtime                   := p_to_au_overtime;
  l_rec.to_auo_premium_pay_indicator     := p_to_auo_premium_pay_indicator;
  l_rec.to_availability_pay              := p_to_availability_pay;
  l_rec.to_ap_premium_pay_indicator      := p_to_ap_premium_pay_indicator;
  l_rec.to_retention_allowance           := p_to_retention_allowance;
  l_rec.to_supervisory_differential      := p_to_supervisory_differential;
  l_rec.to_staffing_differential         := p_to_staffing_differential;
  l_rec.to_pay_basis                     := p_to_pay_basis;
  l_rec.to_pay_plan                      := p_to_pay_plan;
  -- FWFA Changes Bug#4444609
  l_rec.to_pay_table_identifier          := p_to_pay_table_identifier;
  -- FWFA Changes
  l_rec.to_position_id                   := p_to_position_id;
  l_rec.to_position_org_line1            := p_to_position_org_line1;
  l_rec.to_position_org_line2            := p_to_position_org_line2;
  l_rec.to_position_org_line3            := p_to_position_org_line3;
  l_rec.to_position_org_line4            := p_to_position_org_line4;
  l_rec.to_position_org_line5            := p_to_position_org_line5;
  l_rec.to_position_org_line6            := p_to_position_org_line6;
  l_rec.to_position_number               := p_to_position_number;
  l_rec.to_position_seq_no               := p_to_position_seq_no;
  l_rec.to_position_title                := p_to_position_title;
  l_rec.to_step_or_rate                  := p_to_step_or_rate;
  l_rec.to_total_salary                  := p_to_total_salary;
  l_rec.veterans_preference              := p_veterans_preference;
  l_rec.veterans_pref_for_rif            := p_veterans_pref_for_rif;
  l_rec.veterans_status                  := p_veterans_status;
  l_rec.work_schedule                    := p_work_schedule;
  l_rec.work_schedule_desc               := p_work_schedule_desc;
  l_rec.year_degree_attained             := p_year_degree_attained;
  l_rec.first_noa_information1           := p_first_noa_information1;
  l_rec.first_noa_information2           := p_first_noa_information2;
  l_rec.first_noa_information3           := p_first_noa_information3;
  l_rec.first_noa_information4           := p_first_noa_information4;
  l_rec.first_noa_information5           := p_first_noa_information5;
  l_rec.second_lac1_information1         := p_second_lac1_information1;
  l_rec.second_lac1_information2         := p_second_lac1_information2;
  l_rec.second_lac1_information3         := p_second_lac1_information3;
  l_rec.second_lac1_information4         := p_second_lac1_information4;
  l_rec.second_lac1_information5         := p_second_lac1_information5;
  l_rec.second_lac2_information1         := p_second_lac2_information1;
  l_rec.second_lac2_information2         := p_second_lac2_information2;
  l_rec.second_lac2_information3         := p_second_lac2_information3;
  l_rec.second_lac2_information4         := p_second_lac2_information4;
  l_rec.second_lac2_information5         := p_second_lac2_information5;
  l_rec.second_noa_information1          := p_second_noa_information1;
  l_rec.second_noa_information2          := p_second_noa_information2;
  l_rec.second_noa_information3          := p_second_noa_information3;
  l_rec.second_noa_information4          := p_second_noa_information4;
  l_rec.second_noa_information5          := p_second_noa_information5;
  l_rec.first_lac1_information1          := p_first_lac1_information1;
  l_rec.first_lac1_information2          := p_first_lac1_information2;
  l_rec.first_lac1_information3          := p_first_lac1_information3;
  l_rec.first_lac1_information4          := p_first_lac1_information4;
  l_rec.first_lac1_information5          := p_first_lac1_information5;
  l_rec.first_lac2_information1          := p_first_lac2_information1;
  l_rec.first_lac2_information2          := p_first_lac2_information2;
  l_rec.first_lac2_information3          := p_first_lac2_information3;
  l_rec.first_lac2_information4          := p_first_lac2_information4;
  l_rec.first_lac2_information5          := p_first_lac2_information5;
  l_rec.attribute_category               := p_attribute_category;
  l_rec.attribute1                       := p_attribute1;
  l_rec.attribute2                       := p_attribute2;
  l_rec.attribute3                       := p_attribute3;
  l_rec.attribute4                       := p_attribute4;
  l_rec.attribute5                       := p_attribute5;
  l_rec.attribute6                       := p_attribute6;
  l_rec.attribute7                       := p_attribute7;
  l_rec.attribute8                       := p_attribute8;
  l_rec.attribute9                       := p_attribute9;
  l_rec.attribute10                      := p_attribute10;
  l_rec.attribute11                      := p_attribute11;
  l_rec.attribute12                      := p_attribute12;
  l_rec.attribute13                      := p_attribute13;
  l_rec.attribute14                      := p_attribute14;
  l_rec.attribute15                      := p_attribute15;
  l_rec.attribute16                      := p_attribute16;
  l_rec.attribute17                      := p_attribute17;
  l_rec.attribute18                      := p_attribute18;
  l_rec.attribute19                      := p_attribute19;
  l_rec.attribute20                      := p_attribute20;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.first_noa_canc_pa_request_id     := p_first_noa_canc_pa_request_id;
  l_rec.second_noa_canc_pa_request_id    := p_second_noa_canc_pa_request_i;
  hr_utility.set_location('Before all per', 1);
  l_rec.to_retention_allow_percentage    := p_to_retention_allow_percentag;
  l_rec.to_supervisory_diff_percentage   := p_to_supervisory_diff_percenta;
  l_rec.to_staffing_diff_percentage      := p_to_staffing_diff_percentage;
  hr_utility.set_location('Before awardper', 1);
  l_rec.award_percentage                 := p_award_percentage;
  hr_utility.set_location('Before RPA Type', 1);
 hr_utility.set_location('RPA Type ' || p_rpa_type,1);
  l_rec.rpa_type                         := p_rpa_type;
  hr_utility.set_location('after RPA Type', 1);
  l_rec.mass_action_id                   := p_mass_action_id;
  hr_utility.set_location('after massactg', 1);
  l_rec.mass_action_eligible_flag        := p_mass_action_eligible_flag;
  hr_utility.set_location('elig flag value is ' || l_rec.mass_action_eligible_flag , 1);
  l_rec.mass_action_select_flag          := p_mass_action_select_flag;
  hr_utility.set_location('after seleflag', 1);
  l_rec.mass_action_comments             := p_mass_action_comments;
  -- Bug#4486823 RRR Changes
  l_rec.payment_option                   := p_payment_option;
  l_rec.award_salary                     := p_award_salary ;
  -- Bug#4486823 RRR Changes
   hr_utility.set_location('after comments', 1);
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ghr_par_shd;

/
