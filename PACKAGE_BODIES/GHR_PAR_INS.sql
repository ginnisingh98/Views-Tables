--------------------------------------------------------
--  DDL for Package Body GHR_PAR_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PAR_INS" as
/* $Header: ghparrhi.pkb 120.5.12010000.3 2008/10/22 07:10:55 utokachi ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ghr_par_ins.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic. The processing of
--   this procedure are as follows:
--   1) Initialise the object_version_number to 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To insert the row into the schema.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the ins
--   procedure and must have all mandatory attributes set (except the
--   object_version_number which is initialised within this procedure).
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be inserted into the schema.
--
-- Post Failure:
--   If a check, unique or parent integrity constraint violation is raised the
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
Procedure insert_dml(p_rec in out nocopy ghr_par_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
 --
  -- Insert the row into: ghr_pa_requests
  --
  insert into ghr_pa_requests
  (	      pa_request_id,
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
      rpa_type                      ,
      mass_action_id                ,
      mass_action_eligible_flag     ,
      mass_action_select_flag       ,
      mass_action_comments          ,
      -- Bug#     RRR Changes
      pa_incentive_payment_option,
      award_salary,
      -- Bug#     RRR Changes
	object_version_number
  )
  Values
  (	p_rec.pa_request_id,
	p_rec.pa_notification_id,
	p_rec.noa_family_code,
	p_rec.routing_group_id,
	p_rec.proposed_effective_asap_flag,
	p_rec.academic_discipline,
	p_rec.additional_info_person_id,
	p_rec.additional_info_tel_number,
	p_rec.agency_code,
	p_rec.altered_pa_request_id,
	p_rec.annuitant_indicator,
	p_rec.annuitant_indicator_desc,
	p_rec.appropriation_code1,
	p_rec.appropriation_code2,
	p_rec.approval_date,
      p_rec.approving_official_full_name,
	p_rec.approving_official_work_title,
	p_rec.sf50_approval_date,
      p_rec.sf50_approving_ofcl_full_name,
	p_rec.sf50_approving_ofcl_work_title,
	p_rec.authorized_by_person_id,
	p_rec.authorized_by_title,
	p_rec.award_amount,
	p_rec.award_uom,
	p_rec.bargaining_unit_status,
	p_rec.citizenship,
	p_rec.concurrence_date,
      p_rec.CUSTOM_PAY_CALC_FLAG,
	p_rec.duty_station_code,
	p_rec.duty_station_desc,
	p_rec.duty_station_id,
	p_rec.duty_station_location_id,
	p_rec.education_level,
	p_rec.effective_date,
	p_rec.employee_assignment_id,
	p_rec.employee_date_of_birth,
	p_rec.employee_dept_or_agency,
	p_rec.employee_first_name,
	p_rec.employee_last_name,
	p_rec.employee_middle_names,
	p_rec.employee_national_identifier,
	p_rec.fegli,
	p_rec.fegli_desc,
	p_rec.first_action_la_code1,
	p_rec.first_action_la_code2,
	p_rec.first_action_la_desc1,
	p_rec.first_action_la_desc2,
	p_rec.first_noa_cancel_or_correct,
	p_rec.first_noa_code,
	p_rec.first_noa_desc,
	p_rec.first_noa_id,
	p_rec.first_noa_pa_request_id,
	p_rec.flsa_category,
	p_rec.forwarding_address_line1,
	p_rec.forwarding_address_line2,
	p_rec.forwarding_address_line3,
	p_rec.forwarding_country,
      p_rec.forwarding_country_short_name,
	p_rec.forwarding_postal_code,
	p_rec.forwarding_region_2,
	p_rec.forwarding_town_or_city,
	p_rec.from_adj_basic_pay,
	p_rec.from_agency_code,
	p_rec.from_agency_desc,
	p_rec.from_basic_pay,
	p_rec.from_grade_or_level,
	p_rec.from_locality_adj,
	p_rec.from_occ_code,
	p_rec.from_office_symbol,
	p_rec.from_other_pay_amount,
	p_rec.from_pay_basis,
	p_rec.from_pay_plan,
    -- FWFA Changes Bug#4444609
    p_rec.input_pay_rate_determinant,
    p_rec.from_pay_table_identifier,
    -- FWFA Changes
	p_rec.from_position_id,
      p_rec.from_position_org_line1,
      p_rec.from_position_org_line2,
      p_rec.from_position_org_line3,
      p_rec.from_position_org_line4,
      p_rec.from_position_org_line5,
      p_rec.from_position_org_line6,
	p_rec.from_position_number,
	p_rec.from_position_seq_no,
	p_rec.from_position_title,
	p_rec.from_step_or_rate,
	p_rec.from_total_salary,
	p_rec.functional_class,
	p_rec.notepad,
	p_rec.part_time_hours,
	p_rec.pay_rate_determinant,
	p_rec.personnel_office_id,
	p_rec.person_id,
	p_rec.position_occupied,
	p_rec.proposed_effective_date,
	p_rec.requested_by_person_id,
	p_rec.requested_by_title,
	p_rec.requested_date,
	p_rec.requesting_office_remarks_desc,
	p_rec.requesting_office_remarks_flag,
	p_rec.request_number,
	p_rec.resign_and_retire_reason_desc,
	p_rec.retirement_plan,
	p_rec.retirement_plan_desc,
	p_rec.second_action_la_code1,
	p_rec.second_action_la_code2,
	p_rec.second_action_la_desc1,
	p_rec.second_action_la_desc2,
	p_rec.second_noa_cancel_or_correct,
	p_rec.second_noa_code,
	p_rec.second_noa_desc,
	p_rec.second_noa_id,
	p_rec.second_noa_pa_request_id,
	p_rec.service_comp_date,
        p_rec.status,
	p_rec.supervisory_status,
	p_rec.tenure,
	p_rec.to_adj_basic_pay,
	p_rec.to_basic_pay,
	p_rec.to_grade_id,
	p_rec.to_grade_or_level,
	p_rec.to_job_id,
	p_rec.to_locality_adj,
	p_rec.to_occ_code,
	p_rec.to_office_symbol,
	p_rec.to_organization_id,
	p_rec.to_other_pay_amount,
      p_rec.to_au_overtime,
      p_rec.to_auo_premium_pay_indicator,
      p_rec.to_availability_pay,
      p_rec.to_ap_premium_pay_indicator,
      p_rec.to_retention_allowance,
      p_rec.to_supervisory_differential,
      p_rec.to_staffing_differential,
	p_rec.to_pay_basis,
	p_rec.to_pay_plan,
    -- FWFA Changes Bug#4444609
    p_rec.to_pay_table_identifier,
    -- FWFA Changes
	p_rec.to_position_id,
      p_rec.to_position_org_line1,
      p_rec.to_position_org_line2,
      p_rec.to_position_org_line3,
      p_rec.to_position_org_line4,
      p_rec.to_position_org_line5,
      p_rec.to_position_org_line6,
	p_rec.to_position_number,
	p_rec.to_position_seq_no,
	p_rec.to_position_title,
	p_rec.to_step_or_rate,
	p_rec.to_total_salary,
	p_rec.veterans_preference,
	p_rec.veterans_pref_for_rif,
	p_rec.veterans_status,
	p_rec.work_schedule,
	p_rec.work_schedule_desc,
	p_rec.year_degree_attained,
	p_rec.first_noa_information1,
	p_rec.first_noa_information2,
	p_rec.first_noa_information3,
	p_rec.first_noa_information4,
	p_rec.first_noa_information5,
	p_rec.second_lac1_information1,
	p_rec.second_lac1_information2,
	p_rec.second_lac1_information3,
	p_rec.second_lac1_information4,
	p_rec.second_lac1_information5,
	p_rec.second_lac2_information1,
	p_rec.second_lac2_information2,
	p_rec.second_lac2_information3,
	p_rec.second_lac2_information4,
	p_rec.second_lac2_information5,
	p_rec.second_noa_information1,
	p_rec.second_noa_information2,
	p_rec.second_noa_information3,
	p_rec.second_noa_information4,
	p_rec.second_noa_information5,
	p_rec.first_lac1_information1,
	p_rec.first_lac1_information2,
	p_rec.first_lac1_information3,
	p_rec.first_lac1_information4,
	p_rec.first_lac1_information5,
	p_rec.first_lac2_information1,
	p_rec.first_lac2_information2,
	p_rec.first_lac2_information3,
	p_rec.first_lac2_information4,
	p_rec.first_lac2_information5,
	p_rec.attribute_category,
	p_rec.attribute1,
	p_rec.attribute2,
	p_rec.attribute3,
	p_rec.attribute4,
	p_rec.attribute5,
	p_rec.attribute6,
	p_rec.attribute7,
	p_rec.attribute8,
	p_rec.attribute9,
	p_rec.attribute10,
	p_rec.attribute11,
	p_rec.attribute12,
	p_rec.attribute13,
	p_rec.attribute14,
	p_rec.attribute15,
	p_rec.attribute16,
	p_rec.attribute17,
	p_rec.attribute18,
	p_rec.attribute19,
	p_rec.attribute20,
      p_rec.first_noa_canc_pa_request_id   ,
      p_rec.second_noa_canc_pa_request_id  ,
      p_rec.to_retention_allow_percentage  ,
      p_rec.to_supervisory_diff_percentage ,
      p_rec.to_staffing_diff_percentage    ,
      p_rec.award_percentage               ,
      p_rec.rpa_type                       ,
      p_rec.mass_action_id                 ,
      p_rec.mass_action_eligible_flag      ,
      p_rec.mass_action_select_flag        ,
      p_rec.mass_action_comments           ,
      -- Bug#     RRR Changes
      p_rec.payment_option,
      p_rec.award_salary,
      -- Bug#     RRR Changes
	p_rec.object_version_number
  );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
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
End insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the insert dml. Presently, if the entity has a corresponding primary
--   key which is maintained by an associating sequence, the primary key for
--   the entity will be populated with the next sequence value in
--   preparation for the insert dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
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
--   Any pre-processing required before the insert dml is issued should be
--   coded within this procedure. As stated above, a good example is the
--   generation of a primary key number via a corresponding sequence.
--   It is important to note that any 3rd party maintenance should be reviewed
--   before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert(p_rec  in out nocopy ghr_par_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
--
--
--
   Cursor C_Sel1 is select ghr_pa_requests_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
 if p_rec.pa_request_id is null then
  --
  --
  -- Select the next sequence number
  --
    open C_Sel1;
    Fetch C_Sel1 Into p_rec.pa_request_id;
    Close C_Sel1;
 end if;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_insert;

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   insert dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
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
--   Any post-processing required after the insert dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert(p_rec in ghr_par_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- This is a hook point and the user hook for post_insert is called here.
  --
  begin
     ghr_par_rki.after_insert	(
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
		p_sf50_approval_date              	=>	p_rec.sf50_approval_date			,
                p_sf50_approving_ofcl_full_nam      =>    p_rec.sf50_approving_ofcl_full_name       ,
		p_sf50_approving_ofcl_work_tit	=>	p_rec.sf50_approving_ofcl_work_title      ,
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
		--p_input_pay_rate_determinant     	=>	p_rec.input_pay_rate_determinant       	,
        --p_from_pay_table_identifier       =>	p_rec.from_pay_table_identifier    	,
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
        --p_to_pay_table_identifier         =>	p_rec.to_pay_table_identifier        	,
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
		p_attribute20                   	=>	p_rec.attribute20	                        ,
            p_first_noa_canc_pa_request_id      =>    p_rec.first_noa_canc_pa_request_id        ,
            p_second_noa_canc_pa_request_i      =>    p_rec.second_noa_canc_pa_request_id       ,
            p_to_retention_allow_percentag      =>    p_rec.to_retention_allow_percentage       ,
            p_to_supervisory_diff_percenta      =>    p_rec.to_supervisory_diff_percentage      ,
            p_to_staffing_diff_percentage       =>    p_rec.to_staffing_diff_percentage         ,
            p_award_percentage                  =>    p_rec.award_percentage               ,
            p_rpa_type                          =>    p_rec.rpa_type,
            p_mass_action_id                    =>    p_rec.mass_action_id,
            p_mass_action_eligible_flag         =>    p_rec.mass_action_eligible_flag,
            p_mass_action_select_flag           =>    p_rec.mass_action_select_flag,
            p_mass_action_comments              =>    p_rec.mass_action_comments
     );
     exception
        when hr_api.cannot_find_prog_unit then
             hr_api.cannot_find_prog_unit_error
		 (	p_module_name => 'GHR_PA_REQUESTS'
			,p_hook_type  => 'AI'
	        );
  end;
  -- End of API User Hook for post_insert.

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec        in out nocopy ghr_par_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ghr_par_bus.insert_validate(p_rec);
  --
  -- Call the supporting pre-insert operation
  --
  pre_insert(p_rec);
  --
  -- Insert the row
  --
  insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  post_insert(p_rec);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
 Procedure ins
 (
  p_pa_request_id                in out nocopy number,
  p_pa_notification_id           in number           default null,
  p_noa_family_code              in varchar2,
  p_routing_group_id             in number           default null,
  p_proposed_effective_asap_flag in varchar2,
  p_academic_discipline          in varchar2         default null,
  p_additional_info_person_id    in number           default null,
  p_additional_info_tel_number   in varchar2         default null,
  p_agency_code                  in varchar2         default null,
  p_altered_pa_request_id        in number           default null,
  p_annuitant_indicator          in varchar2         default null,
  p_annuitant_indicator_desc     in varchar2         default null,
  p_appropriation_code1          in varchar2         default null,
  p_appropriation_code2          in varchar2         default null,
  p_approval_date                in date             default null,
  p_approving_official_full_name in varchar2         default null,
  p_approving_official_work_titl in varchar2         default null,
  p_sf50_approval_date        in date             default null,
  p_sf50_approving_ofcl_full_nam in varchar2         default null,
  p_sf50_approving_ofcl_work_tit in varchar2         default null,
  p_authorized_by_person_id      in number           default null,
  p_authorized_by_title          in varchar2         default null,
  p_award_amount                 in number           default null,
  p_award_uom                    in varchar2         default null,
  p_bargaining_unit_status       in varchar2         default null,
  p_citizenship                  in varchar2         default null,
  p_concurrence_date             in date             default null,
  p_custom_pay_calc_flag         in varchar2         default null,
  p_duty_station_code            in varchar2         default null,
  p_duty_station_desc            in varchar2         default null,
  p_duty_station_id              in number           default null,
  p_duty_station_location_id     in number           default null,
  p_education_level              in varchar2         default null,
  p_effective_date               in date             default null,
  p_employee_assignment_id       in number           default null,
  p_employee_date_of_birth       in date             default null,
  p_employee_dept_or_agency      in varchar2         default null,
  p_employee_first_name          in varchar2         default null,
  p_employee_last_name           in varchar2         default null,
  p_employee_middle_names        in varchar2         default null,
  p_employee_national_identifier in varchar2         default null,
  p_fegli                        in varchar2         default null,
  p_fegli_desc                   in varchar2         default null,
  p_first_action_la_code1        in varchar2         default null,
  p_first_action_la_code2        in varchar2         default null,
  p_first_action_la_desc1        in varchar2         default null,
  p_first_action_la_desc2        in varchar2         default null,
  p_first_noa_cancel_or_correct  in varchar2         default null,
  p_first_noa_code               in varchar2         default null,
  p_first_noa_desc               in varchar2         default null,
  p_first_noa_id                 in number           default null,
  p_first_noa_pa_request_id      in number           default null,
  p_flsa_category                in varchar2         default null,
  p_forwarding_address_line1     in varchar2         default null,
  p_forwarding_address_line2     in varchar2         default null,
  p_forwarding_address_line3     in varchar2         default null,
  p_forwarding_country           in varchar2         default null,
  p_forwarding_country_short_nam in varchar2         default null,
  p_forwarding_postal_code       in varchar2         default null,
  p_forwarding_region_2          in varchar2         default null,
  p_forwarding_town_or_city      in varchar2         default null,
  p_from_adj_basic_pay           in number           default null,
  p_from_agency_code             in varchar2         default null,
  p_from_agency_desc             in varchar2         default null,
  p_from_basic_pay               in number           default null,
  p_from_grade_or_level          in varchar2         default null,
  p_from_locality_adj            in number           default null,
  p_from_occ_code                in varchar2         default null,
  p_from_office_symbol           in varchar2         default null,
  p_from_other_pay_amount        in number           default null,
  p_from_pay_basis               in varchar2         default null,
  p_from_pay_plan                in varchar2         default null,
  -- FWFA Changes Bug#4444609
  p_input_pay_rate_determinant   in varchar2         default null,
  p_from_pay_table_identifier    in number           default null,
  -- FWFA Changes
  p_from_position_id             in number           default null,
  p_from_position_org_line1      in varchar2         default null,
  p_from_position_org_line2      in varchar2         default null,
  p_from_position_org_line3      in varchar2         default null,
  p_from_position_org_line4      in varchar2         default null,
  p_from_position_org_line5      in varchar2         default null,
  p_from_position_org_line6      in varchar2         default null,
  p_from_position_number         in varchar2         default null,
  p_from_position_seq_no         in number           default null,
  p_from_position_title          in varchar2         default null,
  p_from_step_or_rate            in varchar2         default null,
  p_from_total_salary            in number           default null,
  p_functional_class             in varchar2         default null,
  p_notepad                      in varchar2         default null,
  p_part_time_hours              in number           default null,
  p_pay_rate_determinant         in varchar2         default null,
  p_personnel_office_id          in varchar2         default null,
  p_person_id                    in number           default null,
  p_position_occupied            in varchar2         default null,
  p_proposed_effective_date      in date             default null,
  p_requested_by_person_id       in number           default null,
  p_requested_by_title           in varchar2         default null,
  p_requested_date               in date             default null,
  p_requesting_office_remarks_de in varchar2         default null,
  p_requesting_office_remarks_fl in varchar2         default null,
  p_request_number               in varchar2         default null,
  p_resign_and_retire_reason_des in varchar2         default null,
  p_retirement_plan              in varchar2         default null,
  p_retirement_plan_desc         in varchar2         default null,
  p_second_action_la_code1       in varchar2         default null,
  p_second_action_la_code2       in varchar2         default null,
  p_second_action_la_desc1       in varchar2         default null,
  p_second_action_la_desc2       in varchar2         default null,
  p_second_noa_cancel_or_correct in varchar2         default null,
  p_second_noa_code              in varchar2         default null,
  p_second_noa_desc              in varchar2         default null,
  p_second_noa_id                in number           default null,
  p_second_noa_pa_request_id     in number           default null,
  p_service_comp_date            in date             default null,
  p_status                       in varchar2         default null,
  p_supervisory_status           in varchar2         default null,
  p_tenure                       in varchar2         default null,
  p_to_adj_basic_pay             in number           default null,
  p_to_basic_pay                 in number           default null,
  p_to_grade_id                  in number           default null,
  p_to_grade_or_level            in varchar2         default null,
  p_to_job_id                    in number           default null,
  p_to_locality_adj              in number           default null,
  p_to_occ_code                  in varchar2         default null,
  p_to_office_symbol             in varchar2         default null,
  p_to_organization_id           in number           default null,
  p_to_other_pay_amount          in number           default null,
  p_to_au_overtime               in number           default null,
  p_to_auo_premium_pay_indicator in varchar2         default null,
  p_to_availability_pay          in number           default null,
  p_to_ap_premium_pay_indicator  in varchar2         default null,
  p_to_retention_allowance       in number           default null,
  p_to_supervisory_differential  in number           default null,
  p_to_staffing_differential     in number           default null,
  p_to_pay_basis                 in varchar2         default null,
  p_to_pay_plan                  in varchar2         default null,
  -- FWFA Changes Bug#4444609
  p_to_pay_table_identifier      in number           default null,
  -- FWFA Changes
  p_to_position_id               in number           default null,
  p_to_position_org_line1        in varchar2         default null,
  p_to_position_org_line2        in varchar2         default null,
  p_to_position_org_line3        in varchar2         default null,
  p_to_position_org_line4        in varchar2         default null,
  p_to_position_org_line5        in varchar2         default null,
  p_to_position_org_line6        in varchar2         default null,
  p_to_position_number           in varchar2         default null,
  p_to_position_seq_no           in number           default null,
  p_to_position_title            in varchar2         default null,
  p_to_step_or_rate              in varchar2         default null,
  p_to_total_salary              in number           default null,
  p_veterans_preference          in varchar2         default null,
  p_veterans_pref_for_rif        in varchar2         default null,
  p_veterans_status              in varchar2         default null,
  p_work_schedule                in varchar2         default null,
  p_work_schedule_desc           in varchar2         default null,
  p_year_degree_attained         in number           default null,
  p_first_noa_information1       in varchar2         default null,
  p_first_noa_information2       in varchar2         default null,
  p_first_noa_information3       in varchar2         default null,
  p_first_noa_information4       in varchar2         default null,
  p_first_noa_information5       in varchar2         default null,
  p_second_lac1_information1     in varchar2         default null,
  p_second_lac1_information2     in varchar2         default null,
  p_second_lac1_information3     in varchar2         default null,
  p_second_lac1_information4     in varchar2         default null,
  p_second_lac1_information5     in varchar2         default null,
  p_second_lac2_information1     in varchar2         default null,
  p_second_lac2_information2     in varchar2         default null,
  p_second_lac2_information3     in varchar2         default null,
  p_second_lac2_information4     in varchar2         default null,
  p_second_lac2_information5     in varchar2         default null,
  p_second_noa_information1      in varchar2         default null,
  p_second_noa_information2      in varchar2         default null,
  p_second_noa_information3      in varchar2         default null,
  p_second_noa_information4      in varchar2         default null,
  p_second_noa_information5      in varchar2         default null,
  p_first_lac1_information1      in varchar2         default null,
  p_first_lac1_information2      in varchar2         default null,
  p_first_lac1_information3      in varchar2         default null,
  p_first_lac1_information4      in varchar2         default null,
  p_first_lac1_information5      in varchar2         default null,
  p_first_lac2_information1      in varchar2         default null,
  p_first_lac2_information2      in varchar2         default null,
  p_first_lac2_information3      in varchar2         default null,
  p_first_lac2_information4      in varchar2         default null,
  p_first_lac2_information5      in varchar2         default null,
  p_attribute_category           in varchar2         default null,
  p_attribute1                   in varchar2         default null,
  p_attribute2                   in varchar2         default null,
  p_attribute3                   in varchar2         default null,
  p_attribute4                   in varchar2         default null,
  p_attribute5                   in varchar2         default null,
  p_attribute6                   in varchar2         default null,
  p_attribute7                   in varchar2         default null,
  p_attribute8                   in varchar2         default null,
  p_attribute9                   in varchar2         default null,
  p_attribute10                  in varchar2         default null,
  p_attribute11                  in varchar2         default null,
  p_attribute12                  in varchar2         default null,
  p_attribute13                  in varchar2         default null,
  p_attribute14                  in varchar2         default null,
  p_attribute15                  in varchar2         default null,
  p_attribute16                  in varchar2         default null,
  p_attribute17                  in varchar2         default null,
  p_attribute18                  in varchar2         default null,
  p_attribute19                  in varchar2         default null,
  p_attribute20                  in varchar2         default null,
  p_first_noa_canc_pa_request_id in number           default null,
  p_second_noa_canc_pa_request_i in number           default null,
  p_to_retention_allow_percentag in number           default null,
  p_to_supervisory_diff_percenta in number           default null,
  p_to_staffing_diff_percentage  in number           default null,
  p_award_percentage             in number           default null,
  p_rpa_type                     in varchar2         default null,
  p_mass_action_id               in number           default null,
  p_mass_action_eligible_flag    in varchar2         default null,
  p_mass_action_select_flag      in varchar2         default null,
  p_mass_action_comments         in varchar2         default null,
  -- Bug# RRR Changes
  p_payment_option               in varchar2         default null,
  p_award_salary                 in number           default null,
  -- Bug# RRR Changes
  p_object_version_number        out nocopy number
  )
 is
--
  l_rec	  ghr_par_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ghr_par_shd.convert_args
  (
  p_pa_request_id,  -- null,
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
  -- FWFA Changes Bug#4444609
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
  -- FWFA Changes Bug#4444609
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
  -- Bug# RRR Changes
  p_payment_option              ,
  p_award_salary                ,
  -- Bug# RRR Changes
  null
  );
  --
  -- Having converted the arguments into the par_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_pa_request_id := l_rec.pa_request_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ghr_par_ins;

/
