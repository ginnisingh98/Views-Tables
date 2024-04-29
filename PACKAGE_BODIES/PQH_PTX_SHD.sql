--------------------------------------------------------
--  DDL for Package Body PQH_PTX_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PTX_SHD" as
/* $Header: pqptxrhi.pkb 120.0.12010000.2 2008/08/05 13:41:09 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_ptx_shd.';  -- Global package name
--
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
  If (p_constraint_name = 'PQH_POSITION_TRANSACTIONS_FK11') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_POSITION_TRANSACTIONS_FK12') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_POSITION_TRANSACTIONS_FK4') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_POSITION_TRANSACTIONS_FK5') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_POSITION_TRANSACTIONS_FK6') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','25');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_POSITION_TRANSACTIONS_FK8') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','30');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_POSITION_TRANSACTIONS_FK9') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','35');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_POSITION_TRANSACTIONS_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','40');
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
  p_position_transaction_id            in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		position_transaction_id,
	action_date,
	position_id,
	availability_status_id,
	business_group_id,
	entry_step_id,
	entry_grade_rule_id,
	job_id,
	location_id,
	organization_id,
	pay_freq_payroll_id,
	position_definition_id,
	prior_position_id,
	relief_position_id,
	entry_grade_id,
	successor_position_id,
	supervisor_position_id,
	amendment_date,
	amendment_recommendation,
	amendment_ref_number,
	avail_status_prop_end_date,
	bargaining_unit_cd,
	comments,
	country1,
	country2,
	country3,
	current_job_prop_end_date,
	current_org_prop_end_date,
	date_effective,
	date_end,
	earliest_hire_date,
	fill_by_date,
	frequency,
	fte,
        fte_capacity,
	location1,
	location2,
	location3,
	max_persons,
	name,
	other_requirements,
	overlap_period,
	overlap_unit_cd,
	passport_required,
	pay_term_end_day_cd,
	pay_term_end_month_cd,
	permanent_temporary_flag,
	permit_recruitment_flag,
	position_type,
	posting_description,
	probation_period,
	probation_period_unit_cd,
	relocate_domestically,
	relocate_internationally,
	replacement_required_flag,
	review_flag,
	seasonal_flag,
	security_requirements,
	service_minimum,
	term_start_day_cd,
	term_start_month_cd,
	time_normal_finish,
	time_normal_start,
	transaction_status,
	travel_required,
	working_hours,
	works_council_approval_flag,
	work_any_country,
	work_any_location,
	work_period_type_cd,
	work_schedule,
	work_duration,
	work_term_end_day_cd,
	work_term_end_month_cd,
        proposed_fte_for_layoff,
        proposed_date_for_layoff,
	information1,
	information2,
	information3,
	information4,
	information5,
	information6,
	information7,
	information8,
	information9,
	information10,
	information11,
	information12,
	information13,
	information14,
	information15,
	information16,
	information17,
	information18,
	information19,
	information20,
	information21,
	information22,
	information23,
	information24,
	information25,
	information26,
	information27,
	information28,
	information29,
	information30,
	information_category,
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
	attribute21,
	attribute22,
	attribute23,
	attribute24,
	attribute25,
	attribute26,
	attribute27,
	attribute28,
	attribute29,
	attribute30,
	attribute_category,
	object_version_number,
	pay_basis_id,
	supervisor_id,
	wf_transaction_category_id
    from	pqh_position_transactions
    where	position_transaction_id = p_position_transaction_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_position_transaction_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_position_transaction_id = g_old_rec.position_transaction_id and
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
  p_position_transaction_id            in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	position_transaction_id,
	action_date,
	position_id,
	availability_status_id,
	business_group_id,
	entry_step_id,
	entry_grade_rule_id,
	job_id,
	location_id,
	organization_id,
	pay_freq_payroll_id,
	position_definition_id,
	prior_position_id,
	relief_position_id,
	entry_grade_id,
	successor_position_id,
	supervisor_position_id,
	amendment_date,
	amendment_recommendation,
	amendment_ref_number,
	avail_status_prop_end_date,
	bargaining_unit_cd,
	comments,
	country1,
	country2,
	country3,
	current_job_prop_end_date,
	current_org_prop_end_date,
	date_effective,
	date_end,
	earliest_hire_date,
	fill_by_date,
	frequency,
	fte,
        fte_capacity,
	location1,
	location2,
	location3,
	max_persons,
	name,
	other_requirements,
	overlap_period,
	overlap_unit_cd,
	passport_required,
	pay_term_end_day_cd,
	pay_term_end_month_cd,
	permanent_temporary_flag,
	permit_recruitment_flag,
	position_type,
	posting_description,
	probation_period,
	probation_period_unit_cd,
	relocate_domestically,
	relocate_internationally,
	replacement_required_flag,
	review_flag,
	seasonal_flag,
	security_requirements,
	service_minimum,
	term_start_day_cd,
	term_start_month_cd,
	time_normal_finish,
	time_normal_start,
	transaction_status,
	travel_required,
	working_hours,
	works_council_approval_flag,
	work_any_country,
	work_any_location,
	work_period_type_cd,
	work_schedule,
	work_duration,
	work_term_end_day_cd,
	work_term_end_month_cd,
        proposed_fte_for_layoff,
        proposed_date_for_layoff,
	information1,
	information2,
	information3,
	information4,
	information5,
	information6,
	information7,
	information8,
	information9,
	information10,
	information11,
	information12,
	information13,
	information14,
	information15,
	information16,
	information17,
	information18,
	information19,
	information20,
	information21,
	information22,
	information23,
	information24,
	information25,
	information26,
	information27,
	information28,
	information29,
	information30,
	information_category,
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
	attribute21,
	attribute22,
	attribute23,
	attribute24,
	attribute25,
	attribute26,
	attribute27,
	attribute28,
	attribute29,
	attribute30,
	attribute_category,
	object_version_number,
	pay_basis_id,
	supervisor_id,
	wf_transaction_category_id
    from	pqh_position_transactions
    where	position_transaction_id = p_position_transaction_id
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
    hr_utility.set_message_token('TABLE_NAME', 'pqh_position_transactions');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_position_transaction_id       in number,
	p_action_date                   in date,
	p_position_id                   in number,
	p_availability_status_id        in number,
	p_business_group_id             in number,
	p_entry_step_id                 in number,
	p_entry_grade_rule_id                 in number,
	p_job_id                        in number,
	p_location_id                   in number,
	p_organization_id               in number,
	p_pay_freq_payroll_id           in number,
	p_position_definition_id        in number,
	p_prior_position_id             in number,
	p_relief_position_id            in number,
	p_entry_grade_id         in number,
	p_successor_position_id         in number,
	p_supervisor_position_id        in number,
	p_amendment_date                in date,
	p_amendment_recommendation      in varchar2,
	p_amendment_ref_number          in varchar2,
	p_avail_status_prop_end_date    in date,
	p_bargaining_unit_cd            in varchar2,
	p_comments                      in varchar2,
	p_country1                      in varchar2,
	p_country2                      in varchar2,
	p_country3                      in varchar2,
	p_current_job_prop_end_date     in date,
	p_current_org_prop_end_date     in date,
	p_date_effective                in date,
	p_date_end                      in date,
	p_earliest_hire_date            in date,
	p_fill_by_date                  in date,
	p_frequency                     in varchar2,
	p_fte                           in number,
        p_fte_capacity                  in varchar2,
	p_location1                     in varchar2,
	p_location2                     in varchar2,
	p_location3                     in varchar2,
	p_max_persons                   in number,
	p_name                          in varchar2,
	p_other_requirements            in varchar2,
	p_overlap_period                in number,
	p_overlap_unit_cd               in varchar2,
	p_passport_required             in varchar2,
	p_pay_term_end_day_cd           in varchar2,
	p_pay_term_end_month_cd         in varchar2,
	p_permanent_temporary_flag      in varchar2,
	p_permit_recruitment_flag       in varchar2,
	p_position_type                 in varchar2,
	p_posting_description           in varchar2,
	p_probation_period              in number,
	p_probation_period_unit_cd      in varchar2,
	p_relocate_domestically         in varchar2,
	p_relocate_internationally      in varchar2,
	p_replacement_required_flag     in varchar2,
	p_review_flag                   in varchar2,
	p_seasonal_flag                 in varchar2,
	p_security_requirements         in varchar2,
	p_service_minimum               in varchar2,
	p_term_start_day_cd             in varchar2,
	p_term_start_month_cd           in varchar2,
	p_time_normal_finish            in varchar2,
	p_time_normal_start             in varchar2,
	p_transaction_status            in varchar2,
	p_travel_required               in varchar2,
	p_working_hours                 in number,
	p_works_council_approval_flag   in varchar2,
	p_work_any_country              in varchar2,
	p_work_any_location             in varchar2,
	p_work_period_type_cd           in varchar2,
	p_work_schedule                 in varchar2,
	p_work_duration                 in varchar2,
	p_work_term_end_day_cd          in varchar2,
	p_work_term_end_month_cd        in varchar2,
        p_proposed_fte_for_layoff       in number,
        p_proposed_date_for_layoff      in date,
	p_information1                  in varchar2,
	p_information2                  in varchar2,
	p_information3                  in varchar2,
	p_information4                  in varchar2,
	p_information5                  in varchar2,
	p_information6                  in varchar2,
	p_information7                  in varchar2,
	p_information8                  in varchar2,
	p_information9                  in varchar2,
	p_information10                 in varchar2,
	p_information11                 in varchar2,
	p_information12                 in varchar2,
	p_information13                 in varchar2,
	p_information14                 in varchar2,
	p_information15                 in varchar2,
	p_information16                 in varchar2,
	p_information17                 in varchar2,
	p_information18                 in varchar2,
	p_information19                 in varchar2,
	p_information20                 in varchar2,
	p_information21                 in varchar2,
	p_information22                 in varchar2,
	p_information23                 in varchar2,
	p_information24                 in varchar2,
	p_information25                 in varchar2,
	p_information26                 in varchar2,
	p_information27                 in varchar2,
	p_information28                 in varchar2,
	p_information29                 in varchar2,
	p_information30                 in varchar2,
	p_information_category          in varchar2,
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
	p_attribute21                   in varchar2,
	p_attribute22                   in varchar2,
	p_attribute23                   in varchar2,
	p_attribute24                   in varchar2,
	p_attribute25                   in varchar2,
	p_attribute26                   in varchar2,
	p_attribute27                   in varchar2,
	p_attribute28                   in varchar2,
	p_attribute29                   in varchar2,
	p_attribute30                   in varchar2,
	p_attribute_category            in varchar2,
	p_object_version_number         in number,
	p_pay_basis_id		        in number,
	p_supervisor_id		        in number,
	p_wf_transaction_category_id    in number
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
  l_rec.position_transaction_id          := p_position_transaction_id;
  l_rec.action_date                      := p_action_date;
  l_rec.position_id                      := p_position_id;
  l_rec.availability_status_id           := p_availability_status_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.entry_step_id                    := p_entry_step_id;
  l_rec.entry_grade_rule_id                    := p_entry_grade_rule_id;
  l_rec.job_id                           := p_job_id;
  l_rec.location_id                      := p_location_id;
  l_rec.organization_id                  := p_organization_id;
  l_rec.pay_freq_payroll_id              := p_pay_freq_payroll_id;
  l_rec.position_definition_id           := p_position_definition_id;
  l_rec.prior_position_id                := p_prior_position_id;
  l_rec.relief_position_id               := p_relief_position_id;
  l_rec.entry_grade_id            := p_entry_grade_id;
  l_rec.successor_position_id            := p_successor_position_id;
  l_rec.supervisor_position_id           := p_supervisor_position_id;
  l_rec.amendment_date                   := p_amendment_date;
  l_rec.amendment_recommendation         := p_amendment_recommendation;
  l_rec.amendment_ref_number             := p_amendment_ref_number;
  l_rec.avail_status_prop_end_date       := p_avail_status_prop_end_date;
  l_rec.bargaining_unit_cd               := p_bargaining_unit_cd;
  l_rec.comments                         := p_comments;
  l_rec.country1                         := p_country1;
  l_rec.country2                         := p_country2;
  l_rec.country3                         := p_country3;
  l_rec.current_job_prop_end_date        := p_current_job_prop_end_date;
  l_rec.current_org_prop_end_date        := p_current_org_prop_end_date;
  l_rec.date_effective                   := p_date_effective;
  l_rec.date_end                         := p_date_end;
  l_rec.earliest_hire_date               := p_earliest_hire_date;
  l_rec.fill_by_date                     := p_fill_by_date;
  l_rec.frequency                        := p_frequency;
  l_rec.fte                              := p_fte;
  l_rec.fte_capacity                     := p_fte_capacity;
  l_rec.location1                        := p_location1;
  l_rec.location2                        := p_location2;
  l_rec.location3                        := p_location3;
  l_rec.max_persons                      := p_max_persons;
  l_rec.name                             := p_name;
  l_rec.other_requirements               := p_other_requirements;
  l_rec.overlap_period                   := p_overlap_period;
  l_rec.overlap_unit_cd                  := p_overlap_unit_cd;
  l_rec.passport_required                := p_passport_required;
  l_rec.pay_term_end_day_cd              := p_pay_term_end_day_cd;
  l_rec.pay_term_end_month_cd            := p_pay_term_end_month_cd;
  l_rec.permanent_temporary_flag         := p_permanent_temporary_flag;
  l_rec.permit_recruitment_flag          := p_permit_recruitment_flag;
  l_rec.position_type                    := p_position_type;
  l_rec.posting_description              := p_posting_description;
  l_rec.probation_period                 := p_probation_period;
  l_rec.probation_period_unit_cd         := p_probation_period_unit_cd;
  l_rec.relocate_domestically            := p_relocate_domestically;
  l_rec.relocate_internationally         := p_relocate_internationally;
  l_rec.replacement_required_flag        := p_replacement_required_flag;
  l_rec.review_flag                      := p_review_flag;
  l_rec.seasonal_flag                    := p_seasonal_flag;
  l_rec.security_requirements            := p_security_requirements;
  l_rec.service_minimum                  := p_service_minimum;
  l_rec.term_start_day_cd                := p_term_start_day_cd;
  l_rec.term_start_month_cd              := p_term_start_month_cd;
  l_rec.time_normal_finish               := p_time_normal_finish;
  l_rec.time_normal_start                := p_time_normal_start;
  l_rec.transaction_status               := p_transaction_status;
  l_rec.travel_required                  := p_travel_required;
  l_rec.working_hours                    := p_working_hours;
  l_rec.works_council_approval_flag      := p_works_council_approval_flag;
  l_rec.work_any_country                 := p_work_any_country;
  l_rec.work_any_location                := p_work_any_location;
  l_rec.work_period_type_cd              := p_work_period_type_cd;
  l_rec.work_schedule                    := p_work_schedule;
  l_rec.work_duration                    := p_work_duration;
  l_rec.work_term_end_day_cd             := p_work_term_end_day_cd;
  l_rec.work_term_end_month_cd           := p_work_term_end_month_cd;
  l_rec.proposed_fte_for_layoff          := p_proposed_fte_for_layoff;
  l_rec.proposed_date_for_layoff         := p_proposed_date_for_layoff;
  l_rec.information1                     := p_information1;
  l_rec.information2                     := p_information2;
  l_rec.information3                     := p_information3;
  l_rec.information4                     := p_information4;
  l_rec.information5                     := p_information5;
  l_rec.information6                     := p_information6;
  l_rec.information7                     := p_information7;
  l_rec.information8                     := p_information8;
  l_rec.information9                     := p_information9;
  l_rec.information10                    := p_information10;
  l_rec.information11                    := p_information11;
  l_rec.information12                    := p_information12;
  l_rec.information13                    := p_information13;
  l_rec.information14                    := p_information14;
  l_rec.information15                    := p_information15;
  l_rec.information16                    := p_information16;
  l_rec.information17                    := p_information17;
  l_rec.information18                    := p_information18;
  l_rec.information19                    := p_information19;
  l_rec.information20                    := p_information20;
  l_rec.information21                    := p_information21;
  l_rec.information22                    := p_information22;
  l_rec.information23                    := p_information23;
  l_rec.information24                    := p_information24;
  l_rec.information25                    := p_information25;
  l_rec.information26                    := p_information26;
  l_rec.information27                    := p_information27;
  l_rec.information28                    := p_information28;
  l_rec.information29                    := p_information29;
  l_rec.information30                    := p_information30;
  l_rec.information_category             := p_information_category;
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
  l_rec.attribute21                      := p_attribute21;
  l_rec.attribute22                      := p_attribute22;
  l_rec.attribute23                      := p_attribute23;
  l_rec.attribute24                      := p_attribute24;
  l_rec.attribute25                      := p_attribute25;
  l_rec.attribute26                      := p_attribute26;
  l_rec.attribute27                      := p_attribute27;
  l_rec.attribute28                      := p_attribute28;
  l_rec.attribute29                      := p_attribute29;
  l_rec.attribute30                      := p_attribute30;
  l_rec.attribute_category               := p_attribute_category;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.pay_basis_id               	 := p_pay_basis_id;
  l_rec.supervisor_id               	 := p_supervisor_id;
  l_rec.wf_transaction_category_id     	 := p_wf_transaction_category_id;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end pqh_ptx_shd;

/
