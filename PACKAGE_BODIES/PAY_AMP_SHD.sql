--------------------------------------------------------
--  DDL for Package Body PAY_AMP_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AMP_SHD" as
/* $Header: pyamprhi.pkb 120.0.12000000.1 2007/01/17 15:29:47 appldev noship $ */
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
  l_proc := g_package||'constraint_error';
  --
  If (p_constraint_name = 'PAY_AU_MODULE_PARAMETERS_CHK1') Then
    fnd_message.set_name('PER', 'PER_52500_INV_YES_NO_FLAG');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_AU_MODULE_PARAMETERS_CHK2') Then
    fnd_message.set_name('PER', 'PER_52500_INV_YES_NO_FLAG');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_AU_MODULE_PARAMETERS_CHK3') Then
    fnd_message.set_name('PER', 'PER_52500_INV_YES_NO_FLAG');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_AU_MODULE_PARAMETERS_CHK4') Then
    fnd_message.set_name('PER', 'PER_52500_INV_YES_NO_FLAG');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_AU_MODULE_PARAMETERS_CHK5') Then
    fnd_message.set_name('PER', 'PER_52500_INV_YES_NO_FLAG');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_AU_MODULE_PARAMETERS_CHK6') Then
    fnd_message.set_name('PER', 'PER_52500_INV_YES_NO_FLAG');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_AU_MODULE_PARAMETERS_CHK7') Then
    fnd_message.set_name('PAY', 'HR_AU_DATA_TYPE_MISMATCH');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_AU_MODULE_PARAMETERS_CHK8') Then
    fnd_message.set_name('PER', 'PER_52500_INV_YES_NO_FLAG');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_AU_MODULE_PARAMETERS_FK1') Then
    fnd_message.set_name('PAY','HR_NZ_INVALID_MODULE');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_AU_MODULE_PARAMETERS_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','50');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_AU_MODULE_PARAMETERS_UK1') Then
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
  (p_module_parameter_id                  in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       module_parameter_id
      ,module_id
      ,internal_name
      ,data_type
      ,input_flag
      ,context_flag
      ,output_flag
      ,result_flag
      ,error_message_flag
      ,function_return_flag
      ,enabled_flag
      ,external_name
      ,database_item_name
      ,constant_value
      ,object_version_number
    from        pay_au_module_parameters
    where       module_parameter_id = p_module_parameter_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_module_parameter_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_module_parameter_id
        = pay_amp_shd.g_old_rec.module_parameter_id and
        p_object_version_number
        = pay_amp_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into pay_amp_shd.g_old_rec;
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
          <> pay_amp_shd.g_old_rec.object_version_number) Then
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
  (p_module_parameter_id                  in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       module_parameter_id
      ,module_id
      ,internal_name
      ,data_type
      ,input_flag
      ,context_flag
      ,output_flag
      ,result_flag
      ,error_message_flag
      ,function_return_flag
      ,enabled_flag
      ,external_name
      ,database_item_name
      ,constant_value
      ,object_version_number
    from        pay_au_module_parameters
    where       module_parameter_id = p_module_parameter_id
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
    ,p_argument           => 'MODULE_PARAMETER_ID'
    ,p_argument_value     => p_module_parameter_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pay_amp_shd.g_old_rec;
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
      <> pay_amp_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'pay_au_module_parameters');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_module_parameter_id            in number
  ,p_module_id                      in number
  ,p_internal_name                  in varchar2
  ,p_data_type                      in varchar2
  ,p_input_flag                     in varchar2
  ,p_context_flag                   in varchar2
  ,p_output_flag                    in varchar2
  ,p_result_flag                    in varchar2
  ,p_error_message_flag             in varchar2
  ,p_function_return_flag           in varchar2
  ,p_enabled_flag                   in varchar2
  ,p_external_name                  in varchar2
  ,p_database_item_name             in varchar2
  ,p_constant_value                 in varchar2
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
  l_rec.module_parameter_id              := p_module_parameter_id;
  l_rec.module_id                        := p_module_id;
  l_rec.internal_name                    := p_internal_name;
  l_rec.data_type                        := p_data_type;
  l_rec.input_flag                       := p_input_flag;
  l_rec.context_flag                     := p_context_flag;
  l_rec.output_flag                      := p_output_flag;
  l_rec.result_flag                      := p_result_flag;
  l_rec.error_message_flag               := p_error_message_flag;
  l_rec.function_return_flag             := p_function_return_flag;
  l_rec.enabled_flag                     := p_enabled_flag;
  l_rec.external_name                    := p_external_name;
  l_rec.database_item_name               := p_database_item_name;
  l_rec.constant_value                   := p_constant_value;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
begin
  g_package := '  pay_amp_shd.';  -- Global package name
end pay_amp_shd;

/
