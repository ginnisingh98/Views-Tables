--------------------------------------------------------
--  DDL for Package Body PSP_ERD_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_ERD_SHD" as
/* $Header: PSPEDRHB.pls 120.2 2006/01/25 01:49 dpaudel noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  psp_erd_shd.';  -- Global package name
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
  If (p_constraint_name = 'SYS_C00145225') Then
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
  (p_effort_report_detail_id              in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       effort_report_detail_id
      ,effort_report_id
      ,object_version_number
      ,assignment_id
      ,assignment_number
      ,gl_sum_criteria_segment_name
      ,gl_segment1
      ,gl_segment2
      ,gl_segment3
      ,gl_segment4
      ,gl_segment5
      ,gl_segment6
      ,gl_segment7
      ,gl_segment8
      ,gl_segment9
      ,gl_segment10
      ,gl_segment11
      ,gl_segment12
      ,gl_segment13
      ,gl_segment14
      ,gl_segment15
      ,gl_segment16
      ,gl_segment17
      ,gl_segment18
      ,gl_segment19
      ,gl_segment20
      ,gl_segment21
      ,gl_segment22
      ,gl_segment23
      ,gl_segment24
      ,gl_segment25
      ,gl_segment26
      ,gl_segment27
      ,gl_segment28
      ,gl_segment29
      ,gl_segment30
      ,project_id
      ,project_number
      ,project_name
      ,expenditure_organization_id
      ,exp_org_name
      ,expenditure_type
      ,task_id
      ,task_number
      ,task_name
      ,award_id
      ,award_number
      ,award_short_name
      ,actual_salary_amt
      ,payroll_percent
      ,proposed_salary_amt
      ,proposed_effort_percent
      ,committed_cost_share
      ,schedule_start_date
      ,schedule_end_date
      ,ame_transaction_id
      ,investigator_name
      ,investigator_person_id
      ,investigator_org_name
      ,investigator_primary_org_id
      ,value1
      ,value2
      ,value3
      ,value4
      ,value5
      ,value6
      ,value7
      ,value8
      ,value9
      ,value10
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,grouping_category
    from        psp_eff_report_details
    where       effort_report_detail_id = p_effort_report_detail_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_effort_report_detail_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_effort_report_detail_id
        = psp_erd_shd.g_old_rec.effort_report_detail_id and
        p_object_version_number
        = psp_erd_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into psp_erd_shd.g_old_rec;
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
          <> psp_erd_shd.g_old_rec.object_version_number) Then
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
  (p_effort_report_detail_id              in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       effort_report_detail_id
      ,effort_report_id
      ,object_version_number
      ,assignment_id
      ,assignment_number
      ,gl_sum_criteria_segment_name
      ,gl_segment1
      ,gl_segment2
      ,gl_segment3
      ,gl_segment4
      ,gl_segment5
      ,gl_segment6
      ,gl_segment7
      ,gl_segment8
      ,gl_segment9
      ,gl_segment10
      ,gl_segment11
      ,gl_segment12
      ,gl_segment13
      ,gl_segment14
      ,gl_segment15
      ,gl_segment16
      ,gl_segment17
      ,gl_segment18
      ,gl_segment19
      ,gl_segment20
      ,gl_segment21
      ,gl_segment22
      ,gl_segment23
      ,gl_segment24
      ,gl_segment25
      ,gl_segment26
      ,gl_segment27
      ,gl_segment28
      ,gl_segment29
      ,gl_segment30
      ,project_id
      ,project_number
      ,project_name
      ,expenditure_organization_id
      ,exp_org_name
      ,expenditure_type
      ,task_id
      ,task_number
      ,task_name
      ,award_id
      ,award_number
      ,award_short_name
      ,actual_salary_amt
      ,payroll_percent
      ,proposed_salary_amt
      ,proposed_effort_percent
      ,committed_cost_share
      ,schedule_start_date
      ,schedule_end_date
      ,ame_transaction_id
      ,investigator_name
      ,investigator_person_id
      ,investigator_org_name
      ,investigator_primary_org_id
      ,value1
      ,value2
      ,value3
      ,value4
      ,value5
      ,value6
      ,value7
      ,value8
      ,value9
      ,value10
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,grouping_category
    from        psp_eff_report_details
    where       effort_report_detail_id = p_effort_report_detail_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'EFFORT_REPORT_DETAIL_ID'
    ,p_argument_value     => p_effort_report_detail_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into psp_erd_shd.g_old_rec;
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
      <> psp_erd_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
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
    fnd_message.set_name('PAY', 'HR_7165_OBJECT_LOCKED');
    fnd_message.set_token('TABLE_NAME', 'psp_eff_report_details');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_effort_report_detail_id        in number
  ,p_effort_report_id               in number
  ,p_object_version_number          in number
  ,p_assignment_id                  in number
  ,p_assignment_number              in varchar2
  ,p_gl_sum_criteria_segment_name   in varchar2
  ,p_gl_segment1                    in varchar2
  ,p_gl_segment2                    in varchar2
  ,p_gl_segment3                    in varchar2
  ,p_gl_segment4                    in varchar2
  ,p_gl_segment5                    in varchar2
  ,p_gl_segment6                    in varchar2
  ,p_gl_segment7                    in varchar2
  ,p_gl_segment8                    in varchar2
  ,p_gl_segment9                    in varchar2
  ,p_gl_segment10                   in varchar2
  ,p_gl_segment11                   in varchar2
  ,p_gl_segment12                   in varchar2
  ,p_gl_segment13                   in varchar2
  ,p_gl_segment14                   in varchar2
  ,p_gl_segment15                   in varchar2
  ,p_gl_segment16                   in varchar2
  ,p_gl_segment17                   in varchar2
  ,p_gl_segment18                   in varchar2
  ,p_gl_segment19                   in varchar2
  ,p_gl_segment20                   in varchar2
  ,p_gl_segment21                   in varchar2
  ,p_gl_segment22                   in varchar2
  ,p_gl_segment23                   in varchar2
  ,p_gl_segment24                   in varchar2
  ,p_gl_segment25                   in varchar2
  ,p_gl_segment26                   in varchar2
  ,p_gl_segment27                   in varchar2
  ,p_gl_segment28                   in varchar2
  ,p_gl_segment29                   in varchar2
  ,p_gl_segment30                   in varchar2
  ,p_project_id                     in number
  ,p_project_number                 in varchar2
  ,p_project_name                   in varchar2
  ,p_expenditure_organization_id    in number
  ,p_exp_org_name                   in varchar2
  ,p_expenditure_type               in varchar2
  ,p_task_id                        in number
  ,p_task_number                    in varchar2
  ,p_task_name                      in varchar2
  ,p_award_id                       in number
  ,p_award_number                   in varchar2
  ,p_award_short_name               in varchar2
  ,p_actual_salary_amt              in number
  ,p_payroll_percent                in number
  ,p_proposed_salary_amt            in number
  ,p_proposed_effort_percent        in number
  ,p_committed_cost_share           in number
  ,p_schedule_start_date            in date
  ,p_schedule_end_date              in date
  ,p_ame_transaction_id             in varchar2
  ,p_investigator_name              in varchar2
  ,p_investigator_person_id         in number
  ,p_investigator_org_name          in varchar2
  ,p_investigator_primary_org_id    in number
  ,p_value1                         in number
  ,p_value2                         in number
  ,p_value3                         in number
  ,p_value4                         in number
  ,p_value5                         in number
  ,p_value6                         in number
  ,p_value7                         in number
  ,p_value8                         in number
  ,p_value9                         in number
  ,p_value10                        in number
  ,p_attribute1                     in varchar2
  ,p_attribute2                     in varchar2
  ,p_attribute3                     in varchar2
  ,p_attribute4                     in varchar2
  ,p_attribute5                     in varchar2
  ,p_attribute6                     in varchar2
  ,p_attribute7                     in varchar2
  ,p_attribute8                     in varchar2
  ,p_attribute9                     in varchar2
  ,p_attribute10                    in varchar2
  ,p_grouping_category              in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.effort_report_detail_id          := p_effort_report_detail_id;
  l_rec.effort_report_id                 := p_effort_report_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.assignment_id                    := p_assignment_id;
  l_rec.assignment_number                := p_assignment_number;
  l_rec.gl_sum_criteria_segment_name     := p_gl_sum_criteria_segment_name;
  l_rec.gl_segment1                      := p_gl_segment1;
  l_rec.gl_segment2                      := p_gl_segment2;
  l_rec.gl_segment3                      := p_gl_segment3;
  l_rec.gl_segment4                      := p_gl_segment4;
  l_rec.gl_segment5                      := p_gl_segment5;
  l_rec.gl_segment6                      := p_gl_segment6;
  l_rec.gl_segment7                      := p_gl_segment7;
  l_rec.gl_segment8                      := p_gl_segment8;
  l_rec.gl_segment9                      := p_gl_segment9;
  l_rec.gl_segment10                     := p_gl_segment10;
  l_rec.gl_segment11                     := p_gl_segment11;
  l_rec.gl_segment12                     := p_gl_segment12;
  l_rec.gl_segment13                     := p_gl_segment13;
  l_rec.gl_segment14                     := p_gl_segment14;
  l_rec.gl_segment15                     := p_gl_segment15;
  l_rec.gl_segment16                     := p_gl_segment16;
  l_rec.gl_segment17                     := p_gl_segment17;
  l_rec.gl_segment18                     := p_gl_segment18;
  l_rec.gl_segment19                     := p_gl_segment19;
  l_rec.gl_segment20                     := p_gl_segment20;
  l_rec.gl_segment21                     := p_gl_segment21;
  l_rec.gl_segment22                     := p_gl_segment22;
  l_rec.gl_segment23                     := p_gl_segment23;
  l_rec.gl_segment24                     := p_gl_segment24;
  l_rec.gl_segment25                     := p_gl_segment25;
  l_rec.gl_segment26                     := p_gl_segment26;
  l_rec.gl_segment27                     := p_gl_segment27;
  l_rec.gl_segment28                     := p_gl_segment28;
  l_rec.gl_segment29                     := p_gl_segment29;
  l_rec.gl_segment30                     := p_gl_segment30;
  l_rec.project_id                       := p_project_id;
  l_rec.project_number                   := p_project_number;
  l_rec.project_name                     := p_project_name;
  l_rec.expenditure_organization_id      := p_expenditure_organization_id;
  l_rec.exp_org_name                     := p_exp_org_name;
  l_rec.expenditure_type                 := p_expenditure_type;
  l_rec.task_id                          := p_task_id;
  l_rec.task_number                      := p_task_number;
  l_rec.task_name                        := p_task_name;
  l_rec.award_id                         := p_award_id;
  l_rec.award_number                     := p_award_number;
  l_rec.award_short_name                 := p_award_short_name;
  l_rec.actual_salary_amt                := p_actual_salary_amt;
  l_rec.payroll_percent                  := p_payroll_percent;
  l_rec.proposed_salary_amt              := p_proposed_salary_amt;
  l_rec.proposed_effort_percent          := p_proposed_effort_percent;
  l_rec.committed_cost_share             := p_committed_cost_share;
  l_rec.schedule_start_date              := p_schedule_start_date;
  l_rec.schedule_end_date                := p_schedule_end_date;
  l_rec.ame_transaction_id               := p_ame_transaction_id;
  l_rec.investigator_name                := p_investigator_name;
  l_rec.investigator_person_id           := p_investigator_person_id;
  l_rec.investigator_org_name            := p_investigator_org_name;
  l_rec.investigator_primary_org_id      := p_investigator_primary_org_id;
  l_rec.value1                           := p_value1;
  l_rec.value2                           := p_value2;
  l_rec.value3                           := p_value3;
  l_rec.value4                           := p_value4;
  l_rec.value5                           := p_value5;
  l_rec.value6                           := p_value6;
  l_rec.value7                           := p_value7;
  l_rec.value8                           := p_value8;
  l_rec.value9                           := p_value9;
  l_rec.value10                          := p_value10;
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
  l_rec.grouping_category                := p_grouping_category;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end psp_erd_shd;

/
