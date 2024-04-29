--------------------------------------------------------
--  DDL for Package Body PSP_PRT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_PRT_SHD" as
/* $Header: PSPRTRHB.pls 120.1 2005/07/05 23:50 dpaudel noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  psp_prt_shd.';  -- Global package name
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
  If (p_constraint_name = 'PSP_REPORT_TEMPLATES_U2') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'SYS_C00240334') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
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
  (p_template_id                          in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       template_id
      ,template_name
      ,business_group_id
      ,set_of_books_id
      ,object_version_number
      ,report_type
      ,period_frequency_id
      ,report_template_code
      ,display_all_emp_distrib_flag
      ,manual_entry_override_flag
      ,approval_type
      ,custom_approval_code
      ,sup_levels
      ,preview_effort_report_flag
      ,notification_reminder_in_days
      ,sprcd_tolerance_amt
      ,sprcd_tolerance_percent
      ,description
      ,legislation_code
      ,hundred_pcent_eff_at_per_asg
      ,selection_match_level
    from        psp_report_templates
    where       template_id = p_template_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_template_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_template_id
        = psp_prt_shd.g_old_rec.template_id and
        p_object_version_number
        = psp_prt_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into psp_prt_shd.g_old_rec;
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
          <> psp_prt_shd.g_old_rec.object_version_number) Then
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
  (p_template_id                          in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       template_id
      ,template_name
      ,business_group_id
      ,set_of_books_id
      ,object_version_number
      ,report_type
      ,period_frequency_id
      ,report_template_code
      ,display_all_emp_distrib_flag
      ,manual_entry_override_flag
      ,approval_type
      ,custom_approval_code
      ,sup_levels
      ,preview_effort_report_flag
      ,notification_reminder_in_days
      ,sprcd_tolerance_amt
      ,sprcd_tolerance_percent
      ,description
      ,legislation_code
      ,hundred_pcent_eff_at_per_asg
      ,selection_match_level
    from        psp_report_templates
    where       template_id = p_template_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'TEMPLATE_ID'
    ,p_argument_value     => p_template_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into psp_prt_shd.g_old_rec;
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
      <> psp_prt_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'psp_report_templates');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_template_id                    in number
  ,p_template_name                  in varchar2
  ,p_business_group_id              in number
  ,p_set_of_books_id                in number
  ,p_object_version_number          in number
  ,p_report_type                    in varchar2
  ,p_period_frequency_id            in number
  ,p_report_template_code           in varchar2
  ,p_display_all_emp_distrib_flag   in varchar2
  ,p_manual_entry_override_flag     in varchar2
  ,p_approval_type                  in varchar2
  ,p_custom_approval_code           in varchar2
  ,p_sup_levels                     in number
  ,p_preview_effort_report_flag     in varchar2
  ,p_notification_reminder_in_day   in number
  ,p_sprcd_tolerance_amt            in number
  ,p_sprcd_tolerance_percent        in number
  ,p_description                    in varchar2
  ,p_legislation_code               in varchar2
  ,p_hundred_pcent_eff_at_per_asg   in varchar2
  ,p_selection_match_level          in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.template_id                      := p_template_id;
  l_rec.template_name                    := p_template_name;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.set_of_books_id                  := p_set_of_books_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.report_type                      := p_report_type;
  l_rec.period_frequency_id              := p_period_frequency_id;
  l_rec.report_template_code             := p_report_template_code;
  l_rec.display_all_emp_distrib_flag     := p_display_all_emp_distrib_flag;
  l_rec.manual_entry_override_flag       := p_manual_entry_override_flag;
  l_rec.approval_type                    := p_approval_type;
  l_rec.custom_approval_code             := p_custom_approval_code;
  l_rec.sup_levels                       := p_sup_levels;
  l_rec.preview_effort_report_flag       := p_preview_effort_report_flag;
  l_rec.notification_reminder_in_days    := p_notification_reminder_in_day;
  l_rec.sprcd_tolerance_amt              := p_sprcd_tolerance_amt;
  l_rec.sprcd_tolerance_percent          := p_sprcd_tolerance_percent;
  l_rec.description                      := p_description;
  l_rec.legislation_code                 := p_legislation_code;
  l_rec.hundred_pcent_eff_at_per_asg     := p_hundred_pcent_eff_at_per_asg;
  l_rec.selection_match_level            := p_selection_match_level;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end psp_prt_shd;

/
