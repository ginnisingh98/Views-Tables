--------------------------------------------------------
--  DDL for Package Body PSP_ERA_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_ERA_SHD" as
/* $Header: PSPEARHB.pls 120.2 2006/03/26 01:08 dpaudel noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  psp_era_shd.';  -- Global package name
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
  If (p_constraint_name = 'SYS_C00145528') Then
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
  (p_effort_report_approval_id            in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       effort_report_approval_id
      ,effort_report_detail_id
      ,wf_role_name
      ,wf_orig_system_id
      ,wf_orig_system
      ,approver_order_num
      ,approval_status
      ,response_date
      ,actual_cost_share
      ,overwritten_effort_percent
      ,wf_item_key
      ,comments
      ,pera_information_category
      ,pera_information1
      ,pera_information2
      ,pera_information3
      ,pera_information4
      ,pera_information5
      ,pera_information6
      ,pera_information7
      ,pera_information8
      ,pera_information9
      ,pera_information10
      ,pera_information11
      ,pera_information12
      ,pera_information13
      ,pera_information14
      ,pera_information15
      ,pera_information16
      ,pera_information17
      ,pera_information18
      ,pera_information19
      ,pera_information20
      ,wf_role_display_name
      ,object_version_number
      ,notification_id
      ,eff_information_category
      ,eff_information1
      ,eff_information2
      ,eff_information3
      ,eff_information4
      ,eff_information5
      ,eff_information6
      ,eff_information7
      ,eff_information8
      ,eff_information9
      ,eff_information10
      ,eff_information11
      ,eff_information12
      ,eff_information13
      ,eff_information14
      ,eff_information15
    from        psp_eff_report_approvals
    where       effort_report_approval_id = p_effort_report_approval_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_effort_report_approval_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_effort_report_approval_id
        = psp_era_shd.g_old_rec.effort_report_approval_id and
        p_object_version_number
        = psp_era_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into psp_era_shd.g_old_rec;
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
          <> psp_era_shd.g_old_rec.object_version_number) Then
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
  (p_effort_report_approval_id            in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       effort_report_approval_id
      ,effort_report_detail_id
      ,wf_role_name
      ,wf_orig_system_id
      ,wf_orig_system
      ,approver_order_num
      ,approval_status
      ,response_date
      ,actual_cost_share
      ,overwritten_effort_percent
      ,wf_item_key
      ,comments
      ,pera_information_category
      ,pera_information1
      ,pera_information2
      ,pera_information3
      ,pera_information4
      ,pera_information5
      ,pera_information6
      ,pera_information7
      ,pera_information8
      ,pera_information9
      ,pera_information10
      ,pera_information11
      ,pera_information12
      ,pera_information13
      ,pera_information14
      ,pera_information15
      ,pera_information16
      ,pera_information17
      ,pera_information18
      ,pera_information19
      ,pera_information20
      ,wf_role_display_name
      ,object_version_number
      ,notification_id
      ,eff_information_category
      ,eff_information1
      ,eff_information2
      ,eff_information3
      ,eff_information4
      ,eff_information5
      ,eff_information6
      ,eff_information7
      ,eff_information8
      ,eff_information9
      ,eff_information10
      ,eff_information11
      ,eff_information12
      ,eff_information13
      ,eff_information14
      ,eff_information15
    from        psp_eff_report_approvals
    where       effort_report_approval_id = p_effort_report_approval_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'EFFORT_REPORT_APPROVAL_ID'
    ,p_argument_value     => p_effort_report_approval_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into psp_era_shd.g_old_rec;
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
      <> psp_era_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'psp_eff_report_approvals');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_effort_report_approval_id      in number
  ,p_effort_report_detail_id        in number
  ,p_wf_role_name                   in varchar2
  ,p_wf_orig_system_id              in number
  ,p_wf_orig_system                 in varchar2
  ,p_approver_order_num             in number
  ,p_approval_status                in varchar2
  ,p_response_date                  in date
  ,p_actual_cost_share              in number
  ,p_overwritten_effort_percent     in number
  ,p_wf_item_key                    in varchar2
  ,p_comments                       in varchar2
  ,p_pera_information_category      in varchar2
  ,p_pera_information1              in varchar2
  ,p_pera_information2              in varchar2
  ,p_pera_information3              in varchar2
  ,p_pera_information4              in varchar2
  ,p_pera_information5              in varchar2
  ,p_pera_information6              in varchar2
  ,p_pera_information7              in varchar2
  ,p_pera_information8              in varchar2
  ,p_pera_information9              in varchar2
  ,p_pera_information10             in varchar2
  ,p_pera_information11             in varchar2
  ,p_pera_information12             in varchar2
  ,p_pera_information13             in varchar2
  ,p_pera_information14             in varchar2
  ,p_pera_information15             in varchar2
  ,p_pera_information16             in varchar2
  ,p_pera_information17             in varchar2
  ,p_pera_information18             in varchar2
  ,p_pera_information19             in varchar2
  ,p_pera_information20             in varchar2
  ,p_wf_role_display_name           in varchar2
  ,p_object_version_number          in number
  ,p_notification_id                in number
  ,p_eff_information_category       in varchar2
  ,p_eff_information1               in varchar2
  ,p_eff_information2               in varchar2
  ,p_eff_information3               in varchar2
  ,p_eff_information4               in varchar2
  ,p_eff_information5               in varchar2
  ,p_eff_information6               in varchar2
  ,p_eff_information7               in varchar2
  ,p_eff_information8               in varchar2
  ,p_eff_information9               in varchar2
  ,p_eff_information10              in varchar2
  ,p_eff_information11              in varchar2
  ,p_eff_information12              in varchar2
  ,p_eff_information13              in varchar2
  ,p_eff_information14              in varchar2
  ,p_eff_information15              in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.effort_report_approval_id        := p_effort_report_approval_id;
  l_rec.effort_report_detail_id          := p_effort_report_detail_id;
  l_rec.wf_role_name                     := p_wf_role_name;
  l_rec.wf_orig_system_id                := p_wf_orig_system_id;
  l_rec.wf_orig_system                   := p_wf_orig_system;
  l_rec.approver_order_num               := p_approver_order_num;
  l_rec.approval_status                  := p_approval_status;
  l_rec.response_date                    := p_response_date;
  l_rec.actual_cost_share                := p_actual_cost_share;
  l_rec.overwritten_effort_percent       := p_overwritten_effort_percent;
  l_rec.wf_item_key                      := p_wf_item_key;
  l_rec.comments                         := p_comments;
  l_rec.pera_information_category        := p_pera_information_category;
  l_rec.pera_information1                := p_pera_information1;
  l_rec.pera_information2                := p_pera_information2;
  l_rec.pera_information3                := p_pera_information3;
  l_rec.pera_information4                := p_pera_information4;
  l_rec.pera_information5                := p_pera_information5;
  l_rec.pera_information6                := p_pera_information6;
  l_rec.pera_information7                := p_pera_information7;
  l_rec.pera_information8                := p_pera_information8;
  l_rec.pera_information9                := p_pera_information9;
  l_rec.pera_information10               := p_pera_information10;
  l_rec.pera_information11               := p_pera_information11;
  l_rec.pera_information12               := p_pera_information12;
  l_rec.pera_information13               := p_pera_information13;
  l_rec.pera_information14               := p_pera_information14;
  l_rec.pera_information15               := p_pera_information15;
  l_rec.pera_information16               := p_pera_information16;
  l_rec.pera_information17               := p_pera_information17;
  l_rec.pera_information18               := p_pera_information18;
  l_rec.pera_information19               := p_pera_information19;
  l_rec.pera_information20               := p_pera_information20;
  l_rec.wf_role_display_name             := p_wf_role_display_name;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.notification_id                  := p_notification_id;
  l_rec.eff_information_category         := p_eff_information_category;
  l_rec.eff_information1                 := p_eff_information1;
  l_rec.eff_information2                 := p_eff_information2;
  l_rec.eff_information3                 := p_eff_information3;
  l_rec.eff_information4                 := p_eff_information4;
  l_rec.eff_information5                 := p_eff_information5;
  l_rec.eff_information6                 := p_eff_information6;
  l_rec.eff_information7                 := p_eff_information7;
  l_rec.eff_information8                 := p_eff_information8;
  l_rec.eff_information9                 := p_eff_information9;
  l_rec.eff_information10                := p_eff_information10;
  l_rec.eff_information11                := p_eff_information11;
  l_rec.eff_information12                := p_eff_information12;
  l_rec.eff_information13                := p_eff_information13;
  l_rec.eff_information14                := p_eff_information14;
  l_rec.eff_information15                := p_eff_information15;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end psp_era_shd;

/
