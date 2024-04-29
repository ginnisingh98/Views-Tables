--------------------------------------------------------
--  DDL for Package Body FF_FFP_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FF_FFP_SHD" as
/* $Header: ffffprhi.pkb 120.1 2005/10/05 01:51 adkumar noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ff_ffp_shd.';  -- Global package name
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
  If (p_constraint_name = 'FF_FP_CLASS_CHK') Then
    fnd_message.set_name('PAY', 'HR_52966_INVALID_LOOKUP');
    fnd_message.set_token('COLUMN', 'CLASS');
    fnd_message.set_token('LOOKUP_TYPE','PARAMETER_CLASS');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'FF_FP_CLASS_RULE_CHK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','35');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'FF_FP_CONTINUING_PARAMETER_CHK') Then
    fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
    fnd_message.set_token('COLUMN_NAME', 'Continuing Parameter');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'FF_FP_DATA_TYPE_CHK') Then
    fnd_message.set_name('PAY', 'HR_52966_INVALID_LOOKUP');
    fnd_message.set_token('COLUMN', 'DATA_TYPE');
    fnd_message.set_token('LOOKUP_TYPE','DATA_TYPE');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'FF_FP_OPTIONAL_CHK') Then
    fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
    fnd_message.set_token('COLUMN_NAME', 'Optional');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'FF_FUNCTION_PARAMETERS_FK1') Then
    fnd_message.set_name('PAY', 'PAY_33174_PARENT_ID_INVALID');
    fnd_message.set_token('PARENT' , 'Function Id' );
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'FF_FUNCTION_PARAMETERS_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','35');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'FF_FUNCTION_PARAMETERS_UK2') Then
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
  (p_function_id                          in     number
  ,p_sequence_number                      in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       function_id
      ,sequence_number
      ,class
      ,continuing_parameter
      ,data_type
      ,name
      ,optional
      ,object_version_number
    from        ff_function_parameters
    where       function_id = p_function_id
    and   sequence_number = p_sequence_number;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_function_id is null and
      p_sequence_number is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_function_id
        = ff_ffp_shd.g_old_rec.function_id and
        p_sequence_number
        = ff_ffp_shd.g_old_rec.sequence_number and
        p_object_version_number
        = ff_ffp_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into ff_ffp_shd.g_old_rec;
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
          <> ff_ffp_shd.g_old_rec.object_version_number) Then
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
  (p_function_id                          in     number
  ,p_sequence_number                      in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       function_id
      ,sequence_number
      ,class
      ,continuing_parameter
      ,data_type
      ,name
      ,optional
      ,object_version_number
    from        ff_function_parameters
    where       function_id = p_function_id
    and   sequence_number = p_sequence_number
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'FUNCTION_ID'
    ,p_argument_value     => p_function_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'SEQUENCE_NUMBER'
    ,p_argument_value     => p_sequence_number
    );
  hr_utility.set_location(l_proc,7);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into ff_ffp_shd.g_old_rec;
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
      <> ff_ffp_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'ff_function_parameters');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_function_id                    in number
  ,p_sequence_number                in number
  ,p_class                          in varchar2
  ,p_continuing_parameter           in varchar2
  ,p_data_type                      in varchar2
  ,p_name                           in varchar2
  ,p_optional                       in varchar2
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
  l_rec.function_id                      := p_function_id;
  l_rec.sequence_number                  := p_sequence_number;
  l_rec.class                            := p_class;
  l_rec.continuing_parameter             := p_continuing_parameter;
  l_rec.data_type                        := p_data_type;
  l_rec.name                             := p_name;
  l_rec.optional                         := p_optional;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end ff_ffp_shd;

/
