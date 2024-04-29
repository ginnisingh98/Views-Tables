--------------------------------------------------------
--  DDL for Package Body PER_NAA_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_NAA_SHD" as
/* $Header: penaarhi.pkb 120.1 2006/04/25 06:01:33 niljain noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_naa_shd.';  -- Global package name
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
  If (p_constraint_name = 'PER_NL_ABSENCE_ACTIONS_PK') Then
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
  (p_absence_action_id                    in     number
  ,p_absence_attendance_id                in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       absence_action_id
      ,absence_attendance_id
      ,expected_date
      ,description
      ,actual_start_date
      ,actual_end_date
      ,holder
      ,comments
      ,document_file_name
      ,last_updated_by
      ,object_version_number
      ,enabled
    from        per_nl_absence_actions
    where       absence_action_id = p_absence_action_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_absence_action_id is null and
      p_absence_attendance_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_absence_action_id
        = per_naa_shd.g_old_rec.absence_action_id and
        p_absence_attendance_id
        = per_naa_shd.g_old_rec.absence_attendance_id and
        p_object_version_number
        = per_naa_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into per_naa_shd.g_old_rec;
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
          <> per_naa_shd.g_old_rec.object_version_number) Then
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
  (p_absence_action_id                    in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       absence_action_id
      ,absence_attendance_id
      ,expected_date
      ,description
      ,actual_start_date
      ,actual_end_date
      ,holder
      ,comments
      ,document_file_name
      ,last_updated_by
      ,object_version_number
      ,enabled
    from        per_nl_absence_actions
    where       absence_action_id = p_absence_action_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'ABSENCE_ACTION_ID'
    ,p_argument_value     => p_absence_action_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into per_naa_shd.g_old_rec;
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
      <> per_naa_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'per_nl_absence_actions');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_absence_action_id              in number
  ,p_absence_attendance_id          in number
  ,p_expected_date                  in date
  ,p_description                    in varchar2
  ,p_actual_start_date              in date
  ,p_actual_end_date                in date
  ,p_holder                         in varchar2
  ,p_comments                       in varchar2
  ,p_document_file_name             in varchar2
  ,p_last_updated_by                 in number
  ,p_object_version_number          in number
  ,p_enabled                        in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.absence_action_id                := p_absence_action_id;
  l_rec.absence_attendance_id            := p_absence_attendance_id;
  l_rec.expected_date                    := p_expected_date;
  l_rec.description                      := p_description;
  l_rec.actual_start_date                := p_actual_start_date;
  l_rec.actual_end_date                  := p_actual_end_date;
  l_rec.holder                           := p_holder;
  l_rec.comments                         := p_comments;
  l_rec.document_file_name               := p_document_file_name;
  l_rec.last_updated_by                   := p_last_updated_by;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.enabled                          := p_enabled;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end per_naa_shd;

/
