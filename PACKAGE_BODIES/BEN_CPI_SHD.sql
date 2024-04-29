--------------------------------------------------------
--  DDL for Package Body BEN_CPI_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CPI_SHD" as
/* $Header: becpirhi.pkb 120.0 2005/05/28 01:13:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_cpi_shd.';  -- Global package name
g_debug boolean := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
Begin
  --
  Return (nvl(g_api_dml, false));
  --
End return_api_dml_status;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
  (p_constraint_name in all_constraints.constraint_name%TYPE
  ) Is
--
  l_proc        varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'BEN_CWB_PERSON_INFO_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  Else
    fnd_message.set_name('PAY', 'HR_7877_API_INVALID_CONSTRAINT');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('CONSTRAINT_NAME', p_constraint_name);
    fnd_message.raise_error;
  End If;
  --
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (p_group_per_in_ler_id                  in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       group_per_in_ler_id
      ,assignment_id
      ,person_id
      ,supervisor_id
      ,effective_date
      ,full_name
      ,brief_name
      ,custom_name
      ,supervisor_full_name
      ,supervisor_brief_name
      ,supervisor_custom_name
      ,legislation_code
      ,years_employed
      ,years_in_job
      ,years_in_position
      ,years_in_grade
      ,employee_number
      ,start_date
      ,original_start_date
      ,adjusted_svc_date
      ,base_salary
      ,base_salary_change_date
      ,payroll_name
      ,performance_rating
      ,performance_rating_type
      ,performance_rating_date
      ,business_group_id
      ,organization_id
      ,job_id
      ,grade_id
      ,position_id
      ,people_group_id
      ,soft_coding_keyflex_id
      ,location_id
      ,pay_rate_id
      ,assignment_status_type_id
      ,frequency
      ,grade_annulization_factor
      ,pay_annulization_factor
      ,grd_min_val
      ,grd_max_val
      ,grd_mid_point
      ,grd_quartile
      ,grd_comparatio
      ,emp_category
      ,change_reason
      ,normal_hours
      ,email_address
      ,base_salary_frequency
      ,new_assgn_ovn
      ,new_perf_event_id
      ,new_perf_review_id
      ,post_process_stat_cd
      ,feedback_rating
      ,feedback_comments
      ,object_version_number
      ,custom_segment1
      ,custom_segment2
      ,custom_segment3
      ,custom_segment4
      ,custom_segment5
      ,custom_segment6
      ,custom_segment7
      ,custom_segment8
      ,custom_segment9
      ,custom_segment10
      ,custom_segment11
      ,custom_segment12
      ,custom_segment13
      ,custom_segment14
      ,custom_segment15
      ,custom_segment16
      ,custom_segment17
      ,custom_segment18
      ,custom_segment19
      ,custom_segment20
      ,people_group_name
      ,people_group_segment1
      ,people_group_segment2
      ,people_group_segment3
      ,people_group_segment4
      ,people_group_segment5
      ,people_group_segment6
      ,people_group_segment7
      ,people_group_segment8
      ,people_group_segment9
      ,people_group_segment10
      ,people_group_segment11
      ,ass_attribute_category
      ,ass_attribute1
      ,ass_attribute2
      ,ass_attribute3
      ,ass_attribute4
      ,ass_attribute5
      ,ass_attribute6
      ,ass_attribute7
      ,ass_attribute8
      ,ass_attribute9
      ,ass_attribute10
      ,ass_attribute11
      ,ass_attribute12
      ,ass_attribute13
      ,ass_attribute14
      ,ass_attribute15
      ,ass_attribute16
      ,ass_attribute17
      ,ass_attribute18
      ,ass_attribute19
      ,ass_attribute20
      ,ass_attribute21
      ,ass_attribute22
      ,ass_attribute23
      ,ass_attribute24
      ,ass_attribute25
      ,ass_attribute26
      ,ass_attribute27
      ,ass_attribute28
      ,ass_attribute29
      ,ass_attribute30
      ,ws_comments
      ,cpi_attribute_category
      ,cpi_attribute1
      ,cpi_attribute2
      ,cpi_attribute3
      ,cpi_attribute4
      ,cpi_attribute5
      ,cpi_attribute6
      ,cpi_attribute7
      ,cpi_attribute8
      ,cpi_attribute9
      ,cpi_attribute10
      ,cpi_attribute11
      ,cpi_attribute12
      ,cpi_attribute13
      ,cpi_attribute14
      ,cpi_attribute15
      ,cpi_attribute16
      ,cpi_attribute17
      ,cpi_attribute18
      ,cpi_attribute19
      ,cpi_attribute20
      ,cpi_attribute21
      ,cpi_attribute22
      ,cpi_attribute23
      ,cpi_attribute24
      ,cpi_attribute25
      ,cpi_attribute26
      ,cpi_attribute27
      ,cpi_attribute28
      ,cpi_attribute29
      ,cpi_attribute30
      ,feedback_date
    from        ben_cwb_person_info
    where       group_per_in_ler_id = p_group_per_in_ler_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_group_per_in_ler_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_group_per_in_ler_id
        = ben_cpi_shd.g_old_rec.group_per_in_ler_id and
        p_object_version_number
        = ben_cpi_shd.g_old_rec.object_version_number
       ) Then
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
      Fetch C_Sel1 Into ben_cpi_shd.g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number
          <> ben_cpi_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
      End If;
      l_fct_ret := true;
    End If;
  End If;
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (p_group_per_in_ler_id                  in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       group_per_in_ler_id
      ,assignment_id
      ,person_id
      ,supervisor_id
      ,effective_date
      ,full_name
      ,brief_name
      ,custom_name
      ,supervisor_full_name
      ,supervisor_brief_name
      ,supervisor_custom_name
      ,legislation_code
      ,years_employed
      ,years_in_job
      ,years_in_position
      ,years_in_grade
      ,employee_number
      ,start_date
      ,original_start_date
      ,adjusted_svc_date
      ,base_salary
      ,base_salary_change_date
      ,payroll_name
      ,performance_rating
      ,performance_rating_type
      ,performance_rating_date
      ,business_group_id
      ,organization_id
      ,job_id
      ,grade_id
      ,position_id
      ,people_group_id
      ,soft_coding_keyflex_id
      ,location_id
      ,pay_rate_id
      ,assignment_status_type_id
      ,frequency
      ,grade_annulization_factor
      ,pay_annulization_factor
      ,grd_min_val
      ,grd_max_val
      ,grd_mid_point
      ,grd_quartile
      ,grd_comparatio
      ,emp_category
      ,change_reason
      ,normal_hours
      ,email_address
      ,base_salary_frequency
      ,new_assgn_ovn
      ,new_perf_event_id
      ,new_perf_review_id
      ,post_process_stat_cd
      ,feedback_rating
      ,feedback_comments
      ,object_version_number
      ,custom_segment1
      ,custom_segment2
      ,custom_segment3
      ,custom_segment4
      ,custom_segment5
      ,custom_segment6
      ,custom_segment7
      ,custom_segment8
      ,custom_segment9
      ,custom_segment10
      ,custom_segment11
      ,custom_segment12
      ,custom_segment13
      ,custom_segment14
      ,custom_segment15
      ,custom_segment16
      ,custom_segment17
      ,custom_segment18
      ,custom_segment19
      ,custom_segment20
      ,people_group_name
      ,people_group_segment1
      ,people_group_segment2
      ,people_group_segment3
      ,people_group_segment4
      ,people_group_segment5
      ,people_group_segment6
      ,people_group_segment7
      ,people_group_segment8
      ,people_group_segment9
      ,people_group_segment10
      ,people_group_segment11
      ,ass_attribute_category
      ,ass_attribute1
      ,ass_attribute2
      ,ass_attribute3
      ,ass_attribute4
      ,ass_attribute5
      ,ass_attribute6
      ,ass_attribute7
      ,ass_attribute8
      ,ass_attribute9
      ,ass_attribute10
      ,ass_attribute11
      ,ass_attribute12
      ,ass_attribute13
      ,ass_attribute14
      ,ass_attribute15
      ,ass_attribute16
      ,ass_attribute17
      ,ass_attribute18
      ,ass_attribute19
      ,ass_attribute20
      ,ass_attribute21
      ,ass_attribute22
      ,ass_attribute23
      ,ass_attribute24
      ,ass_attribute25
      ,ass_attribute26
      ,ass_attribute27
      ,ass_attribute28
      ,ass_attribute29
      ,ass_attribute30
      ,ws_comments
      ,cpi_attribute_category
      ,cpi_attribute1
      ,cpi_attribute2
      ,cpi_attribute3
      ,cpi_attribute4
      ,cpi_attribute5
      ,cpi_attribute6
      ,cpi_attribute7
      ,cpi_attribute8
      ,cpi_attribute9
      ,cpi_attribute10
      ,cpi_attribute11
      ,cpi_attribute12
      ,cpi_attribute13
      ,cpi_attribute14
      ,cpi_attribute15
      ,cpi_attribute16
      ,cpi_attribute17
      ,cpi_attribute18
      ,cpi_attribute19
      ,cpi_attribute20
      ,cpi_attribute21
      ,cpi_attribute22
      ,cpi_attribute23
      ,cpi_attribute24
      ,cpi_attribute25
      ,cpi_attribute26
      ,cpi_attribute27
      ,cpi_attribute28
      ,cpi_attribute29
      ,cpi_attribute30
      ,feedback_date
    from        ben_cwb_person_info
    where       group_per_in_ler_id = p_group_per_in_ler_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'GROUP_PER_IN_LER_ID'
    ,p_argument_value     => p_group_per_in_ler_id
    );
  if g_debug then
     hr_utility.set_location(l_proc,6);
  end if;
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into ben_cpi_shd.g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number
      <> ben_cpi_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
  End If;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
  --
  -- We need to trap the ORA LOCK exception
  --
Exception
  When HR_Api.Object_Locked then
    --
    -- The object is locked therefore we need to supply a meaningful
    -- error message.
    --
    fnd_message.set_name('PAY', 'HR_7165_OBJECT_LOCKED');
    fnd_message.set_token('TABLE_NAME', 'ben_cwb_person_info');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_group_per_in_ler_id            in number
  ,p_assignment_id                  in number
  ,p_person_id                      in number
  ,p_supervisor_id                  in number
  ,p_effective_date                 in date
  ,p_full_name                      in varchar2
  ,p_brief_name                     in varchar2
  ,p_custom_name                    in varchar2
  ,p_supervisor_full_name           in varchar2
  ,p_supervisor_brief_name          in varchar2
  ,p_supervisor_custom_name         in varchar2
  ,p_legislation_code               in varchar2
  ,p_years_employed                 in number
  ,p_years_in_job                   in number
  ,p_years_in_position              in number
  ,p_years_in_grade                 in number
  ,p_employee_number                in varchar2
  ,p_start_date                     in date
  ,p_original_start_date            in date
  ,p_adjusted_svc_date              in date
  ,p_base_salary                    in number
  ,p_base_salary_change_date        in date
  ,p_payroll_name                   in varchar2
  ,p_performance_rating             in varchar2
  ,p_performance_rating_type        in varchar2
  ,p_performance_rating_date        in date
  ,p_business_group_id              in number
  ,p_organization_id                in number
  ,p_job_id                         in number
  ,p_grade_id                       in number
  ,p_position_id                    in number
  ,p_people_group_id                in number
  ,p_soft_coding_keyflex_id         in number
  ,p_location_id                    in number
  ,p_pay_rate_id                    in number
  ,p_assignment_status_type_id      in number
  ,p_frequency                      in varchar2
  ,p_grade_annulization_factor      in number
  ,p_pay_annulization_factor        in number
  ,p_grd_min_val                    in number
  ,p_grd_max_val                    in number
  ,p_grd_mid_point                  in number
  ,p_grd_quartile                   in varchar2
  ,p_grd_comparatio                 in number
  ,p_emp_category                   in varchar2
  ,p_change_reason                  in varchar2
  ,p_normal_hours                   in number
  ,p_email_address                  in varchar2
  ,p_base_salary_frequency          in varchar2
  ,p_new_assgn_ovn                  in number
  ,p_new_perf_event_id              in number
  ,p_new_perf_review_id             in number
  ,p_post_process_stat_cd           in varchar2
  ,p_feedback_rating                in varchar2
  ,p_feedback_comments              in varchar2
  ,p_object_version_number          in number
  ,p_custom_segment1                in varchar2
  ,p_custom_segment2                in varchar2
  ,p_custom_segment3                in varchar2
  ,p_custom_segment4                in varchar2
  ,p_custom_segment5                in varchar2
  ,p_custom_segment6                in varchar2
  ,p_custom_segment7                in varchar2
  ,p_custom_segment8                in varchar2
  ,p_custom_segment9                in varchar2
  ,p_custom_segment10               in varchar2
  ,p_custom_segment11               in number
  ,p_custom_segment12               in number
  ,p_custom_segment13               in number
  ,p_custom_segment14               in number
  ,p_custom_segment15               in number
  ,p_custom_segment16               in number
  ,p_custom_segment17               in number
  ,p_custom_segment18               in number
  ,p_custom_segment19               in number
  ,p_custom_segment20               in number
  ,p_people_group_name              in varchar2
  ,p_people_group_segment1          in varchar2
  ,p_people_group_segment2          in varchar2
  ,p_people_group_segment3          in varchar2
  ,p_people_group_segment4          in varchar2
  ,p_people_group_segment5          in varchar2
  ,p_people_group_segment6          in varchar2
  ,p_people_group_segment7          in varchar2
  ,p_people_group_segment8          in varchar2
  ,p_people_group_segment9          in varchar2
  ,p_people_group_segment10         in varchar2
  ,p_people_group_segment11         in varchar2
  ,p_ass_attribute_category         in varchar2
  ,p_ass_attribute1                 in varchar2
  ,p_ass_attribute2                 in varchar2
  ,p_ass_attribute3                 in varchar2
  ,p_ass_attribute4                 in varchar2
  ,p_ass_attribute5                 in varchar2
  ,p_ass_attribute6                 in varchar2
  ,p_ass_attribute7                 in varchar2
  ,p_ass_attribute8                 in varchar2
  ,p_ass_attribute9                 in varchar2
  ,p_ass_attribute10                in varchar2
  ,p_ass_attribute11                in varchar2
  ,p_ass_attribute12                in varchar2
  ,p_ass_attribute13                in varchar2
  ,p_ass_attribute14                in varchar2
  ,p_ass_attribute15                in varchar2
  ,p_ass_attribute16                in varchar2
  ,p_ass_attribute17                in varchar2
  ,p_ass_attribute18                in varchar2
  ,p_ass_attribute19                in varchar2
  ,p_ass_attribute20                in varchar2
  ,p_ass_attribute21                in varchar2
  ,p_ass_attribute22                in varchar2
  ,p_ass_attribute23                in varchar2
  ,p_ass_attribute24                in varchar2
  ,p_ass_attribute25                in varchar2
  ,p_ass_attribute26                in varchar2
  ,p_ass_attribute27                in varchar2
  ,p_ass_attribute28                in varchar2
  ,p_ass_attribute29                in varchar2
  ,p_ass_attribute30                in varchar2
  ,p_ws_comments                    in varchar2
  ,p_cpi_attribute_category         in varchar2
  ,p_cpi_attribute1                 in varchar2
  ,p_cpi_attribute2                 in varchar2
  ,p_cpi_attribute3                 in varchar2
  ,p_cpi_attribute4                 in varchar2
  ,p_cpi_attribute5                 in varchar2
  ,p_cpi_attribute6                 in varchar2
  ,p_cpi_attribute7                 in varchar2
  ,p_cpi_attribute8                 in varchar2
  ,p_cpi_attribute9                 in varchar2
  ,p_cpi_attribute10                in varchar2
  ,p_cpi_attribute11                in varchar2
  ,p_cpi_attribute12                in varchar2
  ,p_cpi_attribute13                in varchar2
  ,p_cpi_attribute14                in varchar2
  ,p_cpi_attribute15                in varchar2
  ,p_cpi_attribute16                in varchar2
  ,p_cpi_attribute17                in varchar2
  ,p_cpi_attribute18                in varchar2
  ,p_cpi_attribute19                in varchar2
  ,p_cpi_attribute20                in varchar2
  ,p_cpi_attribute21                in varchar2
  ,p_cpi_attribute22                in varchar2
  ,p_cpi_attribute23                in varchar2
  ,p_cpi_attribute24                in varchar2
  ,p_cpi_attribute25                in varchar2
  ,p_cpi_attribute26                in varchar2
  ,p_cpi_attribute27                in varchar2
  ,p_cpi_attribute28                in varchar2
  ,p_cpi_attribute29                in varchar2
  ,p_cpi_attribute30                in varchar2
  ,p_feedback_date                  in date
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.group_per_in_ler_id              := p_group_per_in_ler_id;
  l_rec.assignment_id                    := p_assignment_id;
  l_rec.person_id                        := p_person_id;
  l_rec.supervisor_id                    := p_supervisor_id;
  l_rec.effective_date                   := p_effective_date;
  l_rec.full_name                        := p_full_name;
  l_rec.brief_name                       := p_brief_name;
  l_rec.custom_name                      := p_custom_name;
  l_rec.supervisor_full_name             := p_supervisor_full_name;
  l_rec.supervisor_brief_name            := p_supervisor_brief_name;
  l_rec.supervisor_custom_name           := p_supervisor_custom_name;
  l_rec.legislation_code                 := p_legislation_code;
  l_rec.years_employed                   := p_years_employed;
  l_rec.years_in_job                     := p_years_in_job;
  l_rec.years_in_position                := p_years_in_position;
  l_rec.years_in_grade                   := p_years_in_grade;
  l_rec.employee_number                  := p_employee_number;
  l_rec.start_date                       := p_start_date;
  l_rec.original_start_date              := p_original_start_date;
  l_rec.adjusted_svc_date                := p_adjusted_svc_date;
  l_rec.base_salary                      := p_base_salary;
  l_rec.base_salary_change_date          := p_base_salary_change_date;
  l_rec.payroll_name                     := p_payroll_name;
  l_rec.performance_rating               := p_performance_rating;
  l_rec.performance_rating_type          := p_performance_rating_type;
  l_rec.performance_rating_date          := p_performance_rating_date;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.organization_id                  := p_organization_id;
  l_rec.job_id                           := p_job_id;
  l_rec.grade_id                         := p_grade_id;
  l_rec.position_id                      := p_position_id;
  l_rec.people_group_id                  := p_people_group_id;
  l_rec.soft_coding_keyflex_id           := p_soft_coding_keyflex_id;
  l_rec.location_id                      := p_location_id;
  l_rec.pay_rate_id                      := p_pay_rate_id;
  l_rec.assignment_status_type_id        := p_assignment_status_type_id;
  l_rec.frequency                        := p_frequency;
  l_rec.grade_annulization_factor        := p_grade_annulization_factor;
  l_rec.pay_annulization_factor          := p_pay_annulization_factor;
  l_rec.grd_min_val                      := p_grd_min_val;
  l_rec.grd_max_val                      := p_grd_max_val;
  l_rec.grd_mid_point                    := p_grd_mid_point;
  l_rec.grd_quartile                     := p_grd_quartile;
  l_rec.grd_comparatio                   := p_grd_comparatio;
  l_rec.emp_category                     := p_emp_category;
  l_rec.change_reason                    := p_change_reason;
  l_rec.normal_hours                     := p_normal_hours;
  l_rec.email_address                    := p_email_address;
  l_rec.base_salary_frequency            := p_base_salary_frequency;
  l_rec.new_assgn_ovn                    := p_new_assgn_ovn;
  l_rec.new_perf_event_id                := p_new_perf_event_id;
  l_rec.new_perf_review_id               := p_new_perf_review_id;
  l_rec.post_process_stat_cd             := p_post_process_stat_cd;
  l_rec.feedback_rating                  := p_feedback_rating;
  l_rec.feedback_comments                := p_feedback_comments;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.custom_segment1                  := p_custom_segment1;
  l_rec.custom_segment2                  := p_custom_segment2;
  l_rec.custom_segment3                  := p_custom_segment3;
  l_rec.custom_segment4                  := p_custom_segment4;
  l_rec.custom_segment5                  := p_custom_segment5;
  l_rec.custom_segment6                  := p_custom_segment6;
  l_rec.custom_segment7                  := p_custom_segment7;
  l_rec.custom_segment8                  := p_custom_segment8;
  l_rec.custom_segment9                  := p_custom_segment9;
  l_rec.custom_segment10                 := p_custom_segment10;
  l_rec.custom_segment11                 := p_custom_segment11;
  l_rec.custom_segment12                 := p_custom_segment12;
  l_rec.custom_segment13                 := p_custom_segment13;
  l_rec.custom_segment14                 := p_custom_segment14;
  l_rec.custom_segment15                 := p_custom_segment15;
  l_rec.custom_segment16                 := p_custom_segment16;
  l_rec.custom_segment17                 := p_custom_segment17;
  l_rec.custom_segment18                 := p_custom_segment18;
  l_rec.custom_segment19                 := p_custom_segment19;
  l_rec.custom_segment20                 := p_custom_segment20;
  l_rec.people_group_name                := p_people_group_name;
  l_rec.people_group_segment1            := p_people_group_segment1;
  l_rec.people_group_segment2            := p_people_group_segment2;
  l_rec.people_group_segment3            := p_people_group_segment3;
  l_rec.people_group_segment4            := p_people_group_segment4;
  l_rec.people_group_segment5            := p_people_group_segment5;
  l_rec.people_group_segment6            := p_people_group_segment6;
  l_rec.people_group_segment7            := p_people_group_segment7;
  l_rec.people_group_segment8            := p_people_group_segment8;
  l_rec.people_group_segment9            := p_people_group_segment9;
  l_rec.people_group_segment10           := p_people_group_segment10;
  l_rec.people_group_segment11           := p_people_group_segment11;
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
  l_rec.ws_comments                      := p_ws_comments;
  l_rec.cpi_attribute_category           := p_cpi_attribute_category;
  l_rec.cpi_attribute1                   := p_cpi_attribute1;
  l_rec.cpi_attribute2                   := p_cpi_attribute2;
  l_rec.cpi_attribute3                   := p_cpi_attribute3;
  l_rec.cpi_attribute4                   := p_cpi_attribute4;
  l_rec.cpi_attribute5                   := p_cpi_attribute5;
  l_rec.cpi_attribute6                   := p_cpi_attribute6;
  l_rec.cpi_attribute7                   := p_cpi_attribute7;
  l_rec.cpi_attribute8                   := p_cpi_attribute8;
  l_rec.cpi_attribute9                   := p_cpi_attribute9;
  l_rec.cpi_attribute10                  := p_cpi_attribute10;
  l_rec.cpi_attribute11                  := p_cpi_attribute11;
  l_rec.cpi_attribute12                  := p_cpi_attribute12;
  l_rec.cpi_attribute13                  := p_cpi_attribute13;
  l_rec.cpi_attribute14                  := p_cpi_attribute14;
  l_rec.cpi_attribute15                  := p_cpi_attribute15;
  l_rec.cpi_attribute16                  := p_cpi_attribute16;
  l_rec.cpi_attribute17                  := p_cpi_attribute17;
  l_rec.cpi_attribute18                  := p_cpi_attribute18;
  l_rec.cpi_attribute19                  := p_cpi_attribute19;
  l_rec.cpi_attribute20                  := p_cpi_attribute20;
  l_rec.cpi_attribute21                  := p_cpi_attribute21;
  l_rec.cpi_attribute22                  := p_cpi_attribute22;
  l_rec.cpi_attribute23                  := p_cpi_attribute23;
  l_rec.cpi_attribute24                  := p_cpi_attribute24;
  l_rec.cpi_attribute25                  := p_cpi_attribute25;
  l_rec.cpi_attribute26                  := p_cpi_attribute26;
  l_rec.cpi_attribute27                  := p_cpi_attribute27;
  l_rec.cpi_attribute28                  := p_cpi_attribute28;
  l_rec.cpi_attribute29                  := p_cpi_attribute29;
  l_rec.cpi_attribute30                  := p_cpi_attribute30;
  l_rec.feedback_date                    := p_feedback_date;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end ben_cpi_shd;

/
