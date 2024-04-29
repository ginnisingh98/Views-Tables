--------------------------------------------------------
--  DDL for Package Body PER_RET_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RET_SHD" as
/* $Header: peretrhi.pkb 115.1 2002/12/06 11:29:20 eumenyio noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_ret_shd.';  -- Global package name
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
  If (p_constraint_name = 'PER_CAGR_RETAINED_RIGHTS_PK') Then
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
  (p_cagr_retained_right_id              in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       cagr_retained_right_id
      ,assignment_id
      ,cagr_entitlement_item_id
      ,collective_agreement_id
      ,cagr_entitlement_id
      ,category_name
      ,element_type_id
      ,input_value_id
      ,cagr_api_id
      ,cagr_api_param_id
      ,cagr_entitlement_line_id
      ,freeze_flag
      ,value
      ,units_of_measure
      ,start_date
      ,end_date
      ,parent_spine_id
      ,formula_id
      ,oipl_id
      ,step_id
      ,grade_spine_id
      ,column_type
      ,column_size
      ,eligy_prfl_id
      ,object_version_number
      ,cagr_entitlement_result_id
      ,business_group_id
      ,flex_value_set_id
    from        per_cagr_retained_rights
    where       cagr_retained_right_id = p_cagr_retained_right_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_cagr_retained_right_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_cagr_retained_right_id
        = per_ret_shd.g_old_rec.cagr_retained_right_id and
        p_object_version_number
        = per_ret_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into per_ret_shd.g_old_rec;
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
          <> per_ret_shd.g_old_rec.object_version_number) Then
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
  (p_cagr_retained_right_id              in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       cagr_retained_right_id
      ,assignment_id
      ,cagr_entitlement_item_id
      ,collective_agreement_id
      ,cagr_entitlement_id
      ,category_name
      ,element_type_id
      ,input_value_id
      ,cagr_api_id
      ,cagr_api_param_id
      ,cagr_entitlement_line_id
      ,freeze_flag
      ,value
      ,units_of_measure
      ,start_date
      ,end_date
      ,parent_spine_id
      ,formula_id
      ,oipl_id
      ,step_id
      ,grade_spine_id
      ,column_type
      ,column_size
      ,eligy_prfl_id
      ,object_version_number
      ,cagr_entitlement_result_id
      ,business_group_id
      ,flex_value_set_id
    from        per_cagr_retained_rights
    where       cagr_retained_right_id = p_cagr_retained_right_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'CAGR_RETAINED_RIGHTS_ID'
    ,p_argument_value     => p_cagr_retained_right_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into per_ret_shd.g_old_rec;
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
      <> per_ret_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'per_cagr_retained_rights');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_cagr_retained_right_id        in number
  ,p_assignment_id                  in number
  ,p_cagr_entitlement_item_id       in number
  ,p_collective_agreement_id        in number
  ,p_cagr_entitlement_id            in number
  ,p_category_name                  in varchar2
  ,p_element_type_id                in number
  ,p_input_value_id                 in number
  ,p_cagr_api_id                    in number
  ,p_cagr_api_param_id              in number
  ,p_cagr_entitlement_line_id       in number
  ,p_freeze_flag                    in varchar2
  ,p_value                          in varchar2
  ,p_units_of_measure               in varchar2
  ,p_start_date                     in date
  ,p_end_date                       in date
  ,p_parent_spine_id                in number
  ,p_formula_id                     in number
  ,p_oipl_id                        in number
  ,p_step_id                        in number
  ,p_grade_spine_id                 in number
  ,p_column_type                    in varchar2
  ,p_column_size                    in number
  ,p_eligy_prfl_id                  in number
  ,p_object_version_number          in number
  ,p_cagr_entitlement_result_id     in number
  ,p_business_group_id              in number
  ,p_flex_value_set_id              in number
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.cagr_retained_right_id          := p_cagr_retained_right_id;
  l_rec.assignment_id                    := p_assignment_id;
  l_rec.cagr_entitlement_item_id         := p_cagr_entitlement_item_id;
  l_rec.collective_agreement_id          := p_collective_agreement_id;
  l_rec.cagr_entitlement_id              := p_cagr_entitlement_id;
  l_rec.category_name                    := p_category_name;
  l_rec.element_type_id                  := p_element_type_id;
  l_rec.input_value_id                   := p_input_value_id;
  l_rec.cagr_api_id                      := p_cagr_api_id;
  l_rec.cagr_api_param_id                := p_cagr_api_param_id;
  l_rec.cagr_entitlement_line_id         := p_cagr_entitlement_line_id;
  l_rec.freeze_flag                      := p_freeze_flag;
  l_rec.value                            := p_value;
  l_rec.units_of_measure                 := p_units_of_measure;
  l_rec.start_date                       := p_start_date;
  l_rec.end_date                         := p_end_date;
  l_rec.parent_spine_id                  := p_parent_spine_id;
  l_rec.formula_id                       := p_formula_id;
  l_rec.oipl_id                          := p_oipl_id;
  l_rec.step_id                          := p_step_id;
  l_rec.grade_spine_id                   := p_grade_spine_id;
  l_rec.column_type                      := p_column_type;
  l_rec.column_size                      := p_column_size;
  l_rec.eligy_prfl_id                    := p_eligy_prfl_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.cagr_entitlement_result_id       := p_cagr_entitlement_result_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.flex_value_set_id                := p_flex_value_set_id;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end per_ret_shd;

/
