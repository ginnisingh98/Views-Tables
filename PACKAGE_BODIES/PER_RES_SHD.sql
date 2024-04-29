--------------------------------------------------------
--  DDL for Package Body PER_RES_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RES_SHD" as
/* $Header: peresrhi.pkb 115.2 2003/04/02 13:38:24 eumenyio noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_res_shd.';  -- Global package name
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
  If (p_constraint_name = 'PER_CAGR_ENT_RESULTS_PK') Then
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
  (p_cagr_entitlement_result_id           in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       cagr_entitlement_result_id
      ,assignment_id
      ,start_date
      ,end_date
      ,collective_agreement_id
      ,cagr_entitlement_item_id
      ,element_type_id
      ,input_value_id
      ,cagr_api_id
      ,cagr_api_param_id
      ,category_name
      ,cagr_entitlement_id
      ,cagr_entitlement_line_id
      ,value
      ,units_of_measure
      ,range_from
      ,range_to
      ,grade_spine_id
      ,parent_spine_id
      ,step_id
      ,from_step_id
      ,to_step_id
      ,beneficial_flag
      ,oipl_id
      ,chosen_flag
      ,column_type
      ,column_size
      ,cagr_request_id
      ,business_group_id
      ,legislation_code
      ,eligy_prfl_id
      ,formula_id
      ,object_version_number
    from        per_cagr_entitlement_results
    where       cagr_entitlement_result_id = p_cagr_entitlement_result_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_cagr_entitlement_result_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_cagr_entitlement_result_id
        = per_res_shd.g_old_rec.cagr_entitlement_result_id and
        p_object_version_number
        = per_res_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into per_res_shd.g_old_rec;
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
          <> per_res_shd.g_old_rec.object_version_number) Then
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
  (p_cagr_entitlement_result_id           in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       cagr_entitlement_result_id
      ,assignment_id
      ,start_date
      ,end_date
      ,collective_agreement_id
      ,cagr_entitlement_item_id
      ,element_type_id
      ,input_value_id
      ,cagr_api_id
      ,cagr_api_param_id
      ,category_name
      ,cagr_entitlement_id
      ,cagr_entitlement_line_id
      ,value
      ,units_of_measure
      ,range_from
      ,range_to
      ,grade_spine_id
      ,parent_spine_id
      ,step_id
      ,from_step_id
      ,to_step_id
      ,beneficial_flag
      ,oipl_id
      ,chosen_flag
      ,column_type
      ,column_size
      ,cagr_request_id
      ,business_group_id
      ,legislation_code
      ,eligy_prfl_id
      ,formula_id
      ,object_version_number
    from        per_cagr_entitlement_results
    where       cagr_entitlement_result_id = p_cagr_entitlement_result_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'CAGR_ENTITLEMENT_RESULT_ID'
    ,p_argument_value     => p_cagr_entitlement_result_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into per_res_shd.g_old_rec;
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
      <> per_res_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'per_cagr_entitlement_results');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_cagr_entitlement_result_id     in number
  ,p_assignment_id                  in number
  ,p_start_date                     in date
  ,p_end_date                       in date
  ,p_collective_agreement_id        in number
  ,p_cagr_entitlement_item_id       in number
  ,p_element_type_id                in number
  ,p_input_value_id                 in number
  ,p_cagr_api_id                    in number
  ,p_cagr_api_param_id              in number
  ,p_category_name                  in varchar2
  ,p_cagr_entitlement_id            in number
  ,p_cagr_entitlement_line_id       in number
  ,p_value                          in varchar2
  ,p_units_of_measure               in varchar2
  ,p_range_from                     in varchar2
  ,p_range_to                       in varchar2
  ,p_grade_spine_id                 in number
  ,p_parent_spine_id                in number
  ,p_step_id                        in number
  ,p_from_step_id                   in number
  ,p_to_step_id                     in number
  ,p_beneficial_flag                in varchar2
  ,p_oipl_id                        in number
  ,p_chosen_flag                    in varchar2
  ,p_column_type                    in varchar2
  ,p_column_size                    in number
  ,p_cagr_request_id                in number
  ,p_business_group_id              in number
  ,p_legislation_code               in varchar2
  ,p_eligy_prfl_id                  in number
  ,p_formula_id                     in number
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
  l_rec.cagr_entitlement_result_id       := p_cagr_entitlement_result_id;
  l_rec.assignment_id                    := p_assignment_id;
  l_rec.start_date                       := p_start_date;
  l_rec.end_date                         := p_end_date;
  l_rec.collective_agreement_id          := p_collective_agreement_id;
  l_rec.cagr_entitlement_item_id         := p_cagr_entitlement_item_id;
  l_rec.element_type_id                  := p_element_type_id;
  l_rec.input_value_id                   := p_input_value_id;
  l_rec.cagr_api_id                      := p_cagr_api_id;
  l_rec.cagr_api_param_id                := p_cagr_api_param_id;
  l_rec.category_name                    := p_category_name;
  l_rec.cagr_entitlement_id              := p_cagr_entitlement_id;
  l_rec.cagr_entitlement_line_id         := p_cagr_entitlement_line_id;
  l_rec.value                            := p_value;
  l_rec.units_of_measure                 := p_units_of_measure;
  l_rec.range_from                       := p_range_from;
  l_rec.range_to                         := p_range_to;
  l_rec.grade_spine_id                   := p_grade_spine_id;
  l_rec.parent_spine_id                  := p_parent_spine_id;
  l_rec.step_id                          := p_step_id;
  l_rec.from_step_id                     := p_from_step_id;
  l_rec.to_step_id                       := p_to_step_id;
  l_rec.beneficial_flag                  := p_beneficial_flag;
  l_rec.oipl_id                          := p_oipl_id;
  l_rec.chosen_flag                      := p_chosen_flag;
  l_rec.column_type                      := p_column_type;
  l_rec.column_size                      := p_column_size;
  l_rec.cagr_request_id                  := p_cagr_request_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.legislation_code                 := p_legislation_code;
  l_rec.eligy_prfl_id                    := p_eligy_prfl_id;
  l_rec.formula_id                       := p_formula_id;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end per_res_shd;

/
