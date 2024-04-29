--------------------------------------------------------
--  DDL for Package Body PER_SSB_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SSB_SHD" as
/* $Header: pessbrhi.pkb 115.1 2003/08/06 01:25:57 kavenkat noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_ssb_shd.';  -- Global package name
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
  If (p_constraint_name = 'PER_RI_SETUP_SUB_TASKS_PK') Then
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
  (p_setup_sub_task_code                  in     varchar2
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       setup_sub_task_code
      ,setup_task_code
      ,setup_sub_task_sequence
      ,setup_sub_task_status
      ,setup_sub_task_type
      ,setup_sub_task_data_pump_link
      ,setup_sub_task_action
      ,setup_sub_task_creation_date
      ,setup_sub_task_last_mod_date
      ,legislation_code
      ,object_version_number
    from        per_ri_setup_sub_tasks
    where       setup_sub_task_code = p_setup_sub_task_code;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_setup_sub_task_code is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_setup_sub_task_code
        = per_ssb_shd.g_old_rec.setup_sub_task_code and
        p_object_version_number
        = per_ssb_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into per_ssb_shd.g_old_rec;
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
          <> per_ssb_shd.g_old_rec.object_version_number) Then
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
  (p_setup_sub_task_code                  in     varchar2
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       setup_sub_task_code
      ,setup_task_code
      ,setup_sub_task_sequence
      ,setup_sub_task_status
      ,setup_sub_task_type
      ,setup_sub_task_data_pump_link
      ,setup_sub_task_action
      ,setup_sub_task_creation_date
      ,setup_sub_task_last_mod_date
      ,legislation_code
      ,object_version_number
    from        per_ri_setup_sub_tasks
    where       setup_sub_task_code = p_setup_sub_task_code
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'SETUP_SUB_TASK_CODE'
    ,p_argument_value     => p_setup_sub_task_code
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into per_ssb_shd.g_old_rec;
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
      <> per_ssb_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'per_ri_setup_sub_tasks');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_setup_sub_task_code            in varchar2
  ,p_setup_task_code                in varchar2
  ,p_setup_sub_task_sequence        in number
  ,p_setup_sub_task_status          in varchar2
  ,p_setup_sub_task_type            in varchar2
  ,p_setup_sub_task_data_pump_lin   in varchar2
  ,p_setup_sub_task_action          in varchar2
  ,p_setup_sub_task_creation_date   in date
  ,p_setup_sub_task_last_mod_date   in date
  ,p_legislation_code               in varchar2
  ,p_object_version_number          in number
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.setup_sub_task_code              := p_setup_sub_task_code;
  l_rec.setup_task_code                  := p_setup_task_code;
  l_rec.setup_sub_task_sequence          := p_setup_sub_task_sequence;
  l_rec.setup_sub_task_status            := p_setup_sub_task_status;
  l_rec.setup_sub_task_type              := p_setup_sub_task_type;
  l_rec.setup_sub_task_data_pump_link    := p_setup_sub_task_data_pump_lin;
  l_rec.setup_sub_task_action            := p_setup_sub_task_action;
  l_rec.setup_sub_task_creation_date     := p_setup_sub_task_creation_date;
  l_rec.setup_sub_task_last_mod_date     := p_setup_sub_task_last_mod_date;
  l_rec.legislation_code                 := p_legislation_code;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end per_ssb_shd;

/
