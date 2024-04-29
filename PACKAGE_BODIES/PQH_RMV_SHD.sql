--------------------------------------------------------
--  DDL for Package Body PQH_RMV_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RMV_SHD" as
/* $Header: pqrmvrhi.pkb 120.2 2005/06/23 03:41 srenukun noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_rmv_shd.';  -- Global package name
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
  If (p_constraint_name = 'PQH_RT_MATRIX_NODE_VALUES_UK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'pqh_rt_matrix_node_values_pk') Then
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
  (p_node_value_id                        in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       node_value_id
      ,rate_matrix_node_id
      ,short_code
      ,char_value1
      ,char_value2
      ,char_value3
      ,char_value4
      ,number_value1
      ,number_value2
      ,number_value3
      ,number_value4
      ,date_value1
      ,date_value2
      ,date_value3
      ,date_value4
      ,business_group_id
      ,legislation_code
      ,object_version_number
    from        pqh_rt_matrix_node_values
    where       node_value_id = p_node_value_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_node_value_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_node_value_id
        = pqh_rmv_shd.g_old_rec.node_value_id and
        p_object_version_number
        = pqh_rmv_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into pqh_rmv_shd.g_old_rec;
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
          <> pqh_rmv_shd.g_old_rec.object_version_number) Then
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
  (p_node_value_id                        in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       node_value_id
      ,rate_matrix_node_id
      ,short_code
      ,char_value1
      ,char_value2
      ,char_value3
      ,char_value4
      ,number_value1
      ,number_value2
      ,number_value3
      ,number_value4
      ,date_value1
      ,date_value2
      ,date_value3
      ,date_value4
      ,business_group_id
      ,legislation_code
      ,object_version_number
    from        pqh_rt_matrix_node_values
    where       node_value_id = p_node_value_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'NODE_VALUE_ID'
    ,p_argument_value     => p_node_value_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pqh_rmv_shd.g_old_rec;
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
      <> pqh_rmv_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'pqh_rt_matrix_node_values');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_node_value_id                  in number
  ,p_rate_matrix_node_id            in number
  ,p_short_code                     in varchar2
  ,p_char_value1                    in varchar2
  ,p_char_value2                    in varchar2
  ,p_char_value3                    in varchar2
  ,p_char_value4                    in varchar2
  ,p_number_value1                  in number
  ,p_number_value2                  in number
  ,p_number_value3                  in number
  ,p_number_value4                  in number
  ,p_date_value1                    in date
  ,p_date_value2                    in date
  ,p_date_value3                    in date
  ,p_date_value4                    in date
  ,p_business_group_id              in number
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
  l_rec.node_value_id                    := p_node_value_id;
  l_rec.rate_matrix_node_id              := p_rate_matrix_node_id;
  l_rec.short_code                       := p_short_code;
  l_rec.char_value1                      := p_char_value1;
  l_rec.char_value2                      := p_char_value2;
  l_rec.char_value3                      := p_char_value3;
  l_rec.char_value4                      := p_char_value4;
  l_rec.number_value1                    := p_number_value1;
  l_rec.number_value2                    := p_number_value2;
  l_rec.number_value3                    := p_number_value3;
  l_rec.number_value4                    := p_number_value4;
  l_rec.date_value1                      := p_date_value1;
  l_rec.date_value2                      := p_date_value2;
  l_rec.date_value3                      := p_date_value3;
  l_rec.date_value4                      := p_date_value4;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.legislation_code                 := p_legislation_code;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pqh_rmv_shd;

/
