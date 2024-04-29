--------------------------------------------------------
--  DDL for Package Body PER_ASG_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ASG_SHD" as
/* $Header: peasgrhi.pkb 120.19.12010000.7 2009/11/20 09:42:17 sidsaxen ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)    := '  per_asg_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
Begin
  --
  Return (nvl(g_api_dml, false));
End return_api_dml_status;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
            (p_constraint_name in all_constraints.constraint_name%TYPE) Is
--
  l_proc     varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'PER_ASS_ASSIGNMENT_TYPE_CHK') Then
    hr_utility.set_message(801, 'HR_7427_ASG_INVALID_ASS_TYPE');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_ASS_MANAGER_FLAG_CHK') Then
    hr_utility.set_message(801, 'HR_7429_ASG_INV_MANAGER_FLAG');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_ASS_PRIMARY_FLAG_CHK') Then
    hr_utility.set_message(801, 'HR_7428_ASG_INV_PRIMARY_FLAG');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_ASS_UNION_MBER_FLAG_CHK') Then
    hr_utility.set_message(801, 'PER_52382_ASG_UNION_MBER_FLAG');
    hr_utility.raise_error;
  Else
    hr_utility.set_message(801, 'HR_7877_API_INVALID_CONSTRAINT');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('CONSTRAINT_NAME', p_constraint_name);
    hr_utility.raise_error;
  End If;
  --
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (p_effective_date        in date,
   p_assignment_id        in number,
   p_object_version_number    in number
  ) Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
    assignment_id,
    effective_start_date,
    effective_end_date,
    business_group_id,
    recruiter_id,
    grade_id,
    position_id,
    job_id,
    assignment_status_type_id,
    payroll_id,
    location_id,
    person_referred_by_id,
    supervisor_id,
    special_ceiling_step_id,
    person_id,
    recruitment_activity_id,
    source_organization_id,
    organization_id,
    people_group_id,
    soft_coding_keyflex_id,
    vacancy_id,
    pay_basis_id,
    assignment_sequence,
    assignment_type,
    primary_flag,
    application_id,
    assignment_number,
    change_reason,
    comment_id,
    null,
    date_probation_end,
    default_code_comb_id,
    employment_category,
    frequency,
    internal_address_line,
    manager_flag,
    normal_hours,
    perf_review_period,
    perf_review_period_frequency,
    period_of_service_id,
    probation_period,
    probation_unit,
    sal_review_period,
    sal_review_period_frequency,
    set_of_books_id,
    source_type,
    time_normal_finish,
    time_normal_start,
    bargaining_unit_code,
    labour_union_member_flag,
    hourly_salaried_code,
    request_id,
    program_application_id,
    program_id,
    program_update_date,
    ass_attribute_category,
    ass_attribute1,
    ass_attribute2,
    ass_attribute3,
    ass_attribute4,
    ass_attribute5,
    ass_attribute6,
    ass_attribute7,
    ass_attribute8,
    ass_attribute9,
    ass_attribute10,
    ass_attribute11,
    ass_attribute12,
    ass_attribute13,
    ass_attribute14,
    ass_attribute15,
    ass_attribute16,
    ass_attribute17,
    ass_attribute18,
    ass_attribute19,
    ass_attribute20,
    ass_attribute21,
    ass_attribute22,
    ass_attribute23,
    ass_attribute24,
    ass_attribute25,
    ass_attribute26,
    ass_attribute27,
    ass_attribute28,
    ass_attribute29,
    ass_attribute30,
    title,
    object_version_number ,
    contract_id,
    establishment_id,
    collective_agreement_id,
    cagr_grade_def_id,
    cagr_id_flex_num,
    notice_period,
    notice_period_uom,
    employee_category,
    work_at_home,
    job_post_source_name,
    posting_content_id,
    period_of_placement_date_start,
    vendor_id,
    vendor_employee_number,
    vendor_assignment_number,
    assignment_category,
    project_title,
    applicant_rank,
    grade_ladder_pgm_id,
    supervisor_assignment_id,
    vendor_site_id,
    po_header_id,
    po_line_id,
    projected_assignment_end
    from    per_all_assignments_f
    where    assignment_id    = p_assignment_id
    and        p_effective_date between effective_start_date
                                 and     effective_end_date;
--
  l_fct_ret    boolean;
--
Begin
  --
  If (p_effective_date is null
    or p_assignment_id is null
    or p_object_version_number is null)
  then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_assignment_id = g_old_rec.assignment_id and
        p_object_version_number = g_old_rec.object_version_number) Then
      --
      -- The g_old_rec is current therefore we must
      -- set the returning function to true
      --
      l_fct_ret := true;
    Else
      --
      -- Select the current row
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
      l_fct_ret := true;
    End If;
  End If;
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< find_dt_del_modes >---------------------------|
-- ----------------------------------------------------------------------------
Procedure find_dt_del_modes
    (p_effective_date    in  date,
     p_base_key_value    in  number,
     p_zap            out nocopy boolean,
     p_delete        out nocopy boolean,
     p_future_change    out nocopy boolean,
     p_delete_next_change    out nocopy boolean) is
--
  l_proc         varchar2(72)     := g_package||'find_dt_del_modes';
--
  l_parent_key_value1    number;
  l_parent_key_value2    number;
  --
  Cursor C_Sel1 Is
    select  asg.payroll_id,
        asg.person_id
    from    per_all_assignments_f asg
    where   asg.assignment_id = p_base_key_value
    and     p_effective_date  between asg.effective_start_date
                              and     asg.effective_end_date;
--
Begin
  Open  C_Sel1;
  Fetch C_Sel1 Into l_parent_key_value1,
            l_parent_key_value2;
  If C_Sel1%notfound then
    Close C_Sel1;
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  End If;
  Close C_Sel1;
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_del_modes
    (p_effective_date    => p_effective_date,
     p_base_table_name    => 'per_all_assignments_f',
     p_base_key_column    => 'assignment_id',
     p_base_key_value    => p_base_key_value,
     p_parent_table_name1    => 'pay_all_payrolls_f',  -- bug fix 2679167
     p_parent_key_column1    => 'payroll_id',
     p_parent_key_value1    => l_parent_key_value1,
     p_parent_table_name2    => 'per_people_f',
     p_parent_key_column2    => 'person_id',
     p_parent_key_value2    => l_parent_key_value2,
     p_zap            => p_zap,
     p_delete        => p_delete,
     p_future_change    => p_future_change,
     p_delete_next_change    => p_delete_next_change);
  --
End find_dt_del_modes;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< find_dt_upd_modes >---------------------------|
-- ----------------------------------------------------------------------------
Procedure find_dt_upd_modes
    (p_effective_date    in  date,
     p_base_key_value    in  number,
     p_correction        out nocopy boolean,
     p_update        out nocopy boolean,
     p_update_override    out nocopy boolean,
     p_update_change_insert    out nocopy boolean) is
--
Begin
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_upd_modes
    (p_effective_date    => p_effective_date,
     p_base_table_name    => 'per_all_assignments_f',
     p_base_key_column    => 'assignment_id',
     p_base_key_value    => p_base_key_value,
     p_correction        => p_correction,
     p_update        => p_update,
     p_update_override    => p_update_override,
     p_update_change_insert    => p_update_change_insert);
  --
End find_dt_upd_modes;
--
-- ----------------------------------------------------------------------------
-- |------------------------< upd_effective_end_date >------------------------|
-- ----------------------------------------------------------------------------
Procedure upd_effective_end_date
    (p_effective_date        in date,
     p_base_key_value        in number,
     p_new_effective_end_date    in date,
     p_validation_start_date    in date,
     p_validation_end_date        in date,
         p_object_version_number       out nocopy number) is
--
  l_object_version_number number;
--
Begin
  --
  -- Because we are updating a row we must get the next object
  -- version number.
  --
  l_object_version_number :=
    dt_api.get_object_version_number
    (p_base_table_name    => 'per_all_assignments_f',
     p_base_key_column    => 'assignment_id',
     p_base_key_value    => p_base_key_value);
  --
  g_api_dml := true;  -- Set the api dml status
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  per_all_assignments_f asg
  set      asg.effective_end_date    = p_new_effective_end_date,
      asg.object_version_number = l_object_version_number
  where      asg.assignment_id         = p_base_key_value
  and      p_effective_date between asg.effective_start_date
                           and     asg.effective_end_date;
  --
  g_api_dml := false;   -- Unset the api dml status
  p_object_version_number := l_object_version_number;
--
Exception
  When Others Then
    g_api_dml := false;   -- Unset the api dml status
    Raise;
End upd_effective_end_date;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
    (p_effective_date     in  date,
     p_datetrack_mode     in  varchar2,
     p_assignment_id     in  number,
     p_object_version_number in  number,
     p_validation_start_date out nocopy date,
     p_validation_end_date     out nocopy date) is
--
  l_proc          varchar2(72) := g_package||'lck';
  l_validation_start_date date;
  l_validation_end_date      date;
  l_object_invalid       exception;
  l_argument          varchar2(30);
  --
  -- Cursor C_Sel1 selects the current locked row as of session date
  -- ensuring that the object version numbers match.
  --
  Cursor C_Sel1 is
    select
    assignment_id,
    effective_start_date,
    effective_end_date,
    business_group_id,
    recruiter_id,
    grade_id,
    position_id,
    job_id,
    assignment_status_type_id,
    payroll_id,
    location_id,
    person_referred_by_id,
    supervisor_id,
    special_ceiling_step_id,
    person_id,
    recruitment_activity_id,
    source_organization_id,
    organization_id,
    people_group_id,
    soft_coding_keyflex_id,
    vacancy_id,
    pay_basis_id,
    assignment_sequence,
    assignment_type,
    primary_flag,
    application_id,
    assignment_number,
    change_reason,
    comment_id,
    null,
    date_probation_end,
    default_code_comb_id,
    employment_category,
    frequency,
    internal_address_line,
    manager_flag,
    normal_hours,
    perf_review_period,
    perf_review_period_frequency,
    period_of_service_id,
    probation_period,
    probation_unit,
    sal_review_period,
    sal_review_period_frequency,
    set_of_books_id,
    source_type,
    time_normal_finish,
    time_normal_start,
    bargaining_unit_code,
    labour_union_member_flag,
    hourly_salaried_code,
    request_id,
    program_application_id,
    program_id,
    program_update_date,
    ass_attribute_category,
    ass_attribute1,
    ass_attribute2,
    ass_attribute3,
    ass_attribute4,
    ass_attribute5,
    ass_attribute6,
    ass_attribute7,
    ass_attribute8,
    ass_attribute9,
    ass_attribute10,
    ass_attribute11,
    ass_attribute12,
    ass_attribute13,
    ass_attribute14,
    ass_attribute15,
    ass_attribute16,
    ass_attribute17,
    ass_attribute18,
    ass_attribute19,
    ass_attribute20,
    ass_attribute21,
    ass_attribute22,
    ass_attribute23,
    ass_attribute24,
    ass_attribute25,
    ass_attribute26,
    ass_attribute27,
    ass_attribute28,
    ass_attribute29,
    ass_attribute30,
    title,
    object_version_number,
    contract_id,
    establishment_id,
    collective_agreement_id,
    cagr_grade_def_id,
    cagr_id_flex_num,
    notice_period,
    notice_period_uom,
    employee_category,
    work_at_home,
    job_post_source_name,
    posting_content_id,
    period_of_placement_date_start,
    vendor_id,
    vendor_employee_number,
    vendor_assignment_number,
    assignment_category,
    project_title,
    applicant_rank,
    grade_ladder_pgm_id,
    supervisor_assignment_id,
    vendor_site_id,
    po_header_id,
    po_line_id,
    projected_assignment_end
    from    per_all_assignments_f
    where   assignment_id = p_assignment_id
    and        p_effective_date  between effective_start_date
                              and     effective_end_date
    for update nowait;
  --
  -- Cursor C_Sel3 select comment text
  --
  Cursor C_Sel3 is
    select hc.comment_text
    from   hr_comments hc
    where  hc.comment_id = per_asg_shd.g_old_rec.comment_id;
  --
Begin
  --
  -- Ensure that all the mandatory arguments are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'effective_date',
                             p_argument_value => p_effective_date);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'datetrack_mode',
                             p_argument_value => p_datetrack_mode);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'assignment_id',
                             p_argument_value => p_assignment_id);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'object_version_number',
                             p_argument_value => p_object_version_number);
  --
  -- Check to ensure the datetrack mode is not INSERT.
  --
  If (p_datetrack_mode <> 'INSERT') then
    --
    -- We must select and lock the current row.
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
      --
    End If;
    Close C_Sel1;
    --
    -- Check if the set object version number is the same as the existing
    -- object version number
    --
    If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
      End If;
    --
    -- Providing we are doing an update and a comment_id exists then
    -- we select the comment text.
    --
    If ((g_old_rec.comment_id is not null)             and
        (p_datetrack_mode = 'UPDATE'                   or
         p_datetrack_mode = 'CORRECTION'               or
         p_datetrack_mode = 'UPDATE_OVERRIDE'          or
         p_datetrack_mode = 'UPDATE_CHANGE_INSERT')) then
      Open C_Sel3;
      Fetch C_Sel3 Into per_asg_shd.g_old_rec.comment_text;
      If C_Sel3%notfound then
        --
        -- The comment_text for the specified comment_id does not exist.
        -- We must error due to data integrity problems.
        --
        Close C_Sel3;
        hr_utility.set_message(801, 'HR_7202_COMMENT_TEXT_NOT_EXIST');
        hr_utility.raise_error;
      End If;
      Close C_Sel3;
    End If;
    --
    -- Validate the datetrack mode mode getting the validation start
    -- and end dates for the specified datetrack operation.
    --
    -- Added hr_all_positions_f to validation,Oct-99 SCNair
    --
    --
    -- Removed reference to pay_payrolls_f
    -- as part of fix for bug 1056246.
    --

         --p_parent_table_name1      => 'pay_payrolls_f',
         --p_parent_key_column1      => 'payroll_id',
         --p_parent_key_value1       => g_old_rec.payroll_id,

    -- Bug 3199913
    -- Removed refernce to 'hr_all_positions_f' since assignment and position
    -- do not have parent-child relationship.

    dt_api.validate_dt_mode
        (p_effective_date          => p_effective_date,
         p_datetrack_mode          => p_datetrack_mode,
         p_base_table_name         => 'per_all_assignments_f',
         p_base_key_column         => 'assignment_id',
         p_base_key_value          => p_assignment_id,
         p_parent_table_name1      => 'per_people_f',
         p_parent_key_column1      => 'person_id',
         p_parent_key_value1       => g_old_rec.person_id,
         p_child_table_name1       => 'pay_cost_allocations_f',
         p_child_key_column1       => 'cost_allocation_id',
         p_child_table_name2       => 'pay_assignment_link_usages_f',
         p_child_key_column2       => 'assignment_link_usage_id',
         p_child_table_name3       => 'pay_personal_payment_methods_f',
         p_child_key_column3       => 'personal_payment_method_id',
         p_child_table_name4       => 'per_spinal_point_placements_f',
         p_child_key_column4       => 'placement_id',
         p_child_table_name5       => 'pay_element_entries_f',
         p_child_key_column5       => 'element_entry_id',
         p_child_table_name6       => 'pay_us_emp_fed_tax_rules_f',
         p_child_key_column6       => 'emp_fed_tax_rule_id',
         p_child_table_name7       => 'pay_us_emp_county_tax_rules_f',
         p_child_key_column7       => 'emp_county_tax_rule_id',
         p_child_table_name8       => 'pay_us_emp_state_tax_rules_f',
         p_child_key_column8       => 'emp_state_tax_rule_id',
         p_child_table_name9       => 'pay_us_emp_city_tax_rules_f',
         p_child_key_column9       => 'emp_city_tax_rule_id',
         p_enforce_foreign_locking => true,
         p_validation_start_date   => l_validation_start_date,
         p_validation_end_date     => l_validation_end_date);
  Else
    --
    -- We are doing a datetrack 'INSERT' which is illegal within this
    -- procedure therefore we must error (note: to lck on insert the
    -- private procedure ins_lck should be called).
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
    --
  End If;
  --
  -- Set the validation start and end date OUT arguments
  --
  p_validation_start_date := l_validation_start_date;
  p_validation_end_date   := l_validation_end_date;
  --
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
    hr_utility.set_message_token('TABLE_NAME', 'per_all_assignments_f');
    hr_utility.raise_error;
  When l_object_invalid then
    --
    -- The object doesn't exist or is invalid
    --
    hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
    hr_utility.set_message_token('TABLE_NAME', 'per_all_assignments_f');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
    (
    p_assignment_id                 in number,
    p_effective_start_date          in date,
    p_effective_end_date            in date,
    p_business_group_id             in number,
    p_recruiter_id                  in number,
    p_grade_id                      in number,
    p_position_id                   in number,
    p_job_id                        in number,
    p_assignment_status_type_id     in number,
    p_payroll_id                    in number,
    p_location_id                   in number,
    p_person_referred_by_id         in number,
    p_supervisor_id                 in number,
    p_special_ceiling_step_id       in number,
    p_person_id                     in number,
    p_recruitment_activity_id       in number,
    p_source_organization_id        in number,
    p_organization_id               in number,
    p_people_group_id               in number,
    p_soft_coding_keyflex_id        in number,
    p_vacancy_id                    in number,
    p_pay_basis_id                  in number,
    p_assignment_sequence           in number,
    p_assignment_type               in varchar2,
    p_primary_flag                  in varchar2,
    p_application_id                in number,
    p_assignment_number             in varchar2,
    p_change_reason                 in varchar2,
    p_comment_id                    in number,
    p_comments                      in varchar2,
    p_date_probation_end            in date,
    p_default_code_comb_id          in number,
    p_employment_category           in varchar2,
    p_frequency                     in varchar2,
    p_internal_address_line         in varchar2,
    p_manager_flag                  in varchar2,
    p_normal_hours                  in number,
    p_perf_review_period            in number,
    p_perf_review_period_frequency  in varchar2,
    p_period_of_service_id          in number,
    p_probation_period              in number,
    p_probation_unit                in varchar2,
    p_sal_review_period             in number,
    p_sal_review_period_frequency   in varchar2,
    p_set_of_books_id               in number,
    p_source_type                   in varchar2,
    p_time_normal_finish            in varchar2,
    p_time_normal_start             in varchar2,
    p_bargaining_unit_code          in varchar2,
    p_labour_union_member_flag      in varchar2,
    p_hourly_salaried_code          in varchar2,
    p_request_id                    in number,
    p_program_application_id        in number,
    p_program_id                    in number,
    p_program_update_date           in date,
    p_ass_attribute_category        in varchar2,
    p_ass_attribute1                in varchar2,
    p_ass_attribute2                in varchar2,
    p_ass_attribute3                in varchar2,
    p_ass_attribute4                in varchar2,
    p_ass_attribute5                in varchar2,
    p_ass_attribute6                in varchar2,
    p_ass_attribute7                in varchar2,
    p_ass_attribute8                in varchar2,
    p_ass_attribute9                in varchar2,
    p_ass_attribute10               in varchar2,
    p_ass_attribute11               in varchar2,
    p_ass_attribute12               in varchar2,
    p_ass_attribute13               in varchar2,
    p_ass_attribute14               in varchar2,
    p_ass_attribute15               in varchar2,
    p_ass_attribute16               in varchar2,
    p_ass_attribute17               in varchar2,
    p_ass_attribute18               in varchar2,
    p_ass_attribute19               in varchar2,
    p_ass_attribute20               in varchar2,
    p_ass_attribute21               in varchar2,
    p_ass_attribute22               in varchar2,
    p_ass_attribute23               in varchar2,
    p_ass_attribute24               in varchar2,
    p_ass_attribute25               in varchar2,
    p_ass_attribute26               in varchar2,
    p_ass_attribute27               in varchar2,
    p_ass_attribute28               in varchar2,
    p_ass_attribute29               in varchar2,
    p_ass_attribute30               in varchar2,
    p_title                         in varchar2,
    p_object_version_number         in number,
    p_contract_id                   in number,
    p_establishment_id              in number,
    p_collective_agreement_id       in number,
    p_cagr_grade_def_id             in number,
    p_cagr_id_flex_num              in number,
    p_notice_period         in number,
    p_notice_period_uom        in varchar2,
    p_employee_category        in varchar2,
    p_work_at_home          in varchar2,
    p_job_post_source_name          in varchar2,
    p_posting_content_id            in number,
    p_placement_date_start          in date,
    p_vendor_id                     in number,
    p_vendor_employee_number        in varchar2,
    p_vendor_assignment_number      in varchar2,
    p_assignment_category           in varchar2,
    p_project_title                 in varchar2,
    p_applicant_rank                in number,
    p_grade_ladder_pgm_id           in number,
    p_supervisor_assignment_id      in number,
    p_vendor_site_id                in number,
    p_po_header_id                  in number,
    p_po_line_id                    in number,
    p_projected_assignment_end      in date
   )
    Return g_rec_type is
--
  l_rec      g_rec_type;
--
Begin
  --
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.assignment_id                    := p_assignment_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.recruiter_id                     := p_recruiter_id;
  l_rec.grade_id                         := p_grade_id;
  l_rec.position_id                      := p_position_id;
  l_rec.job_id                           := p_job_id;
  l_rec.assignment_status_type_id        := p_assignment_status_type_id;
  l_rec.payroll_id                       := p_payroll_id;
  l_rec.location_id                      := p_location_id;
  l_rec.person_referred_by_id            := p_person_referred_by_id;
  l_rec.supervisor_id                    := p_supervisor_id;
  l_rec.special_ceiling_step_id          := p_special_ceiling_step_id;
  l_rec.person_id                        := p_person_id;
  l_rec.recruitment_activity_id          := p_recruitment_activity_id;
  l_rec.source_organization_id           := p_source_organization_id;
  l_rec.organization_id                  := p_organization_id;
  l_rec.people_group_id                  := p_people_group_id;
  l_rec.soft_coding_keyflex_id           := p_soft_coding_keyflex_id;
  l_rec.vacancy_id                       := p_vacancy_id;
  l_rec.pay_basis_id                     := p_pay_basis_id;
  l_rec.assignment_sequence              := p_assignment_sequence;
  l_rec.assignment_type                  := p_assignment_type;
  l_rec.primary_flag                     := p_primary_flag;
  l_rec.application_id                   := p_application_id;
  l_rec.assignment_number                := p_assignment_number;
  l_rec.change_reason                    := p_change_reason;
  l_rec.comment_id                       := p_comment_id;
  l_rec.comment_text                     := p_comments;
  l_rec.date_probation_end               := p_date_probation_end;
  l_rec.default_code_comb_id             := p_default_code_comb_id;
  l_rec.employment_category              := p_employment_category;
  l_rec.frequency                        := p_frequency;
  l_rec.internal_address_line            := p_internal_address_line;
  l_rec.manager_flag                     := p_manager_flag;
  l_rec.normal_hours                     := p_normal_hours;
  l_rec.perf_review_period               := p_perf_review_period;
  l_rec.perf_review_period_frequency     := p_perf_review_period_frequency;
  l_rec.period_of_service_id             := p_period_of_service_id;
  l_rec.probation_period                 := p_probation_period;
  l_rec.probation_unit                   := p_probation_unit;
  l_rec.sal_review_period                := p_sal_review_period;
  l_rec.sal_review_period_frequency      := p_sal_review_period_frequency;
  l_rec.set_of_books_id                  := p_set_of_books_id;
  l_rec.source_type                      := p_source_type;
  l_rec.time_normal_finish               := p_time_normal_finish;
  l_rec.time_normal_start                := p_time_normal_start;
  l_rec.bargaining_unit_code             := p_bargaining_unit_code;
  l_rec.labour_union_member_flag         := p_labour_union_member_flag;
  l_rec.hourly_salaried_code             := p_hourly_salaried_code;
  l_rec.request_id                       := p_request_id;
  l_rec.program_application_id           := p_program_application_id;
  l_rec.program_id                       := p_program_id;
  l_rec.program_update_date              := p_program_update_date;
  l_rec.ass_attribute_category           := p_ass_attribute_category;
  l_rec.ass_attribute1                   := p_ass_attribute1;
  l_rec.ass_attribute2                   := p_ass_attribute2;
  l_rec.ass_attribute3                   := p_ass_attribute3;
  l_rec.ass_attribute4                   := p_ass_attribute4;
  l_rec.ass_attribute5                   := p_ass_attribute5;
  l_rec.ass_attribute6                   := p_ass_attribute6;
  l_rec.ass_attribute7                   := p_ass_attribute7;
  l_rec.ass_attribute8                   := p_ass_attribute8;
  l_rec.ass_attribute9                   := p_ass_attribute9;
  l_rec.ass_attribute10                  := p_ass_attribute10;
  l_rec.ass_attribute11                  := p_ass_attribute11;
  l_rec.ass_attribute12                  := p_ass_attribute12;
  l_rec.ass_attribute13                  := p_ass_attribute13;
  l_rec.ass_attribute14                  := p_ass_attribute14;
  l_rec.ass_attribute15                  := p_ass_attribute15;
  l_rec.ass_attribute16                  := p_ass_attribute16;
  l_rec.ass_attribute17                  := p_ass_attribute17;
  l_rec.ass_attribute18                  := p_ass_attribute18;
  l_rec.ass_attribute19                  := p_ass_attribute19;
  l_rec.ass_attribute20                  := p_ass_attribute20;
  l_rec.ass_attribute21                  := p_ass_attribute21;
  l_rec.ass_attribute22                  := p_ass_attribute22;
  l_rec.ass_attribute23                  := p_ass_attribute23;
  l_rec.ass_attribute24                  := p_ass_attribute24;
  l_rec.ass_attribute25                  := p_ass_attribute25;
  l_rec.ass_attribute26                  := p_ass_attribute26;
  l_rec.ass_attribute27                  := p_ass_attribute27;
  l_rec.ass_attribute28                  := p_ass_attribute28;
  l_rec.ass_attribute29                  := p_ass_attribute29;
  l_rec.ass_attribute30                  := p_ass_attribute30;
  l_rec.title                            := p_title;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.contract_id                      := p_contract_id;
  l_rec.establishment_id                 := p_establishment_id;
  l_rec.collective_agreement_id          := p_collective_agreement_id;
  l_rec.cagr_grade_def_id                := p_cagr_grade_def_id;
  l_rec.cagr_id_flex_num                 := p_cagr_id_flex_num;
  l_rec.notice_period          := p_notice_period;
  l_rec.notice_period_uom      := p_notice_period_uom;
  l_rec.employee_category      := p_employee_category;
  l_rec.work_at_home        := p_work_at_home;
  l_rec.job_post_source_name             := p_job_post_source_name ;
  l_rec.posting_content_id               := p_posting_content_id;
  l_rec.period_of_placement_date_start   := p_placement_date_start;
  l_rec.vendor_id                        := p_vendor_id;
  l_rec.vendor_employee_number           := p_vendor_employee_number;
  l_rec.vendor_assignment_number         := p_vendor_assignment_number;
  l_rec.assignment_category              := p_assignment_category;
  l_rec.project_title                    := p_project_title;
  l_rec.applicant_rank                   := p_applicant_rank;
  l_rec.grade_ladder_pgm_id              := p_grade_ladder_pgm_id;
  l_rec.supervisor_assignment_id         := p_supervisor_assignment_id;
  l_rec.vendor_site_id                   := p_vendor_site_id;
  l_rec.po_header_id                     := p_po_header_id;
  l_rec.po_line_id                       := p_po_line_id;
  l_rec.projected_assignment_end         := p_projected_assignment_end;
--
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end per_asg_shd;

/
