--------------------------------------------------------
--  DDL for Package Body PAY_APM_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_APM_SHD" as
/* $Header: pyapmrhi.pkb 120.0.12000000.1 2007/01/17 15:34:53 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33);  -- Global package name
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
  l_proc        varchar2(72);
--
Begin
  --
  l_proc := g_package||'constraint_error';
  --
  If (p_constraint_name = 'PAY_AU_PROCESS_MODULES_CHK1') Then
    fnd_message.set_name('PER', 'PER_52500_INV_YES_NO_FLAG');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_AU_PROCESS_MODULES_FK1') Then
    fnd_message.set_name('PAY', 'HR_AU_INVALID_PROCESS');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_AU_PROCESS_MODULES_FK2') Then
    fnd_message.set_name('PAY','HR_NZ_INVALID_MODULE');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_AU_PROCESS_MODULES_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','20');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_AU_PROCESS_MODULES_UK1') Then
    fnd_message.set_name('PAY', 'PER_7901_SYS_DUPLICATE_RECORDS');
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
  (p_process_module_id                    in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       process_module_id
      ,process_id
      ,module_id
      ,process_sequence
      ,enabled_flag
      ,object_version_number
    from        pay_au_process_modules
    where       process_module_id = p_process_module_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_process_module_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_process_module_id
        = pay_apm_shd.g_old_rec.process_module_id and
        p_object_version_number
        = pay_apm_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into pay_apm_shd.g_old_rec;
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
          <> pay_apm_shd.g_old_rec.object_version_number) Then
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
  (p_process_module_id                    in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       process_module_id
      ,process_id
      ,module_id
      ,process_sequence
      ,enabled_flag
      ,object_version_number
    from        pay_au_process_modules
    where       process_module_id = p_process_module_id
    for update nowait;
--
  l_proc        varchar2(72);
--
Begin
  l_proc := g_package||'lck';
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'PROCESS_MODULE_ID'
    ,p_argument_value     => p_process_module_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pay_apm_shd.g_old_rec;
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
      <> pay_apm_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'pay_au_process_modules');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_process_module_id              in number
  ,p_process_id                     in number
  ,p_module_id                      in number
  ,p_process_sequence               in number
  ,p_enabled_flag                   in varchar2
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
  l_rec.process_module_id                := p_process_module_id;
  l_rec.process_id                       := p_process_id;
  l_rec.module_id                        := p_module_id;
  l_rec.process_sequence                 := p_process_sequence;
  l_rec.enabled_flag                     := p_enabled_flag;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
begin
  g_package  := '  pay_apm_shd.';  -- Global package name
end pay_apm_shd;

/
