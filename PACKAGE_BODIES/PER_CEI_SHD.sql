--------------------------------------------------------
--  DDL for Package Body PER_CEI_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CEI_SHD" AS
/* $Header: peceirhi.pkb 120.1 2006/10/18 08:58:46 grreddy noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)    := '  per_cei_shd.';  -- Global package name
--
--
--  ---------------------------------------------------------------------------
--  |---------------------< entitlement_item_in_use >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--  Check to see if the entitlement item is being used by a collective
--  agreement. If it is then it returns TRUE otherwise it returns FALSE
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_cagr_entitlement_item_id
--    p_item_name
--    p_cagr_api_id
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Developement use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
FUNCTION entitlement_item_in_use
  (p_cagr_entitlement_item_id IN per_cagr_entitlement_items.cagr_entitlement_item_id%TYPE)
  RETURN BOOLEAN IS
  --
  CURSOR csr_get_entitlements IS
    SELECT pce.cagr_entitlement_item_id
    FROM   per_cagr_entitlements pce
    WHERE  pce.cagr_entitlement_item_id = p_cagr_entitlement_item_id;
  --
  l_return_value BOOLEAN;
  l_dummy_item   per_cagr_entitlement_items.cagr_entitlement_item_id%TYPE;
  l_proc         VARCHAR2(72) := g_package||'entitlement_item_in_use';
  --
BEGIN
  --
  hr_utility.set_location('Entering : '||p_cagr_entitlement_item_id||'/'||l_proc,10);
  --
  -- Check mandatory parameter is set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'cagr_entitlement_item_id'
    ,p_argument_value => p_cagr_entitlement_item_id
    );
  --
  OPEN  csr_get_entitlements;
  FETCH csr_get_entitlements INTO l_dummy_item;
  --
  IF csr_get_entitlements%FOUND THEN
    --
    hr_utility.set_location(l_proc,20);
    --
    CLOSE csr_get_entitlements;
    --
    l_return_value := TRUE;
    --
  ELSE
    --
    hr_utility.set_location(l_proc,30);
    --
    CLOSE csr_get_entitlements;
    --
    l_return_value := FALSE;
    --
  END IF;
  --
  hr_utility.set_location('Leaving  : '||l_proc,100);
  --
  RETURN(l_return_value);
  --
END entitlement_item_in_use;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
  (p_constraint_name in all_constraints.constraint_name%TYPE
  ) Is
--
  l_proc     varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'PER_CAGR_ENTITLEMENT_ITEMS_PK') Then
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
  (p_cagr_entitlement_item_id             in     number
  )
  Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       cagr_entitlement_item_id
      ,item_name
      ,element_type_id
      ,input_value_id
	  ,column_type
	  ,column_size
      ,legislation_code
      ,cagr_api_id
      ,cagr_api_param_id
      ,business_group_id
      ,beneficial_rule
      ,category_name
      ,uom
      ,flex_value_set_id
      ,beneficial_formula_id
      ,object_version_number
      ,beneficial_rule_value_set_id
      ,multiple_entries_allowed_flag
      ,auto_create_entries_flag -- CEI Enh
      ,opt_id
    from    per_cagr_entitlement_items
    where    cagr_entitlement_item_id = p_cagr_entitlement_item_id;
--
  l_fct_ret    boolean;
--
Begin
  --
  If (p_cagr_entitlement_item_id is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_cagr_entitlement_item_id
        = per_cei_shd.g_old_rec.cagr_entitlement_item_id
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
      Fetch C_Sel1 Into per_cei_shd.g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
      --
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
  (p_cagr_entitlement_item_id             in     number ,
   p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
      cagr_entitlement_item_id
     ,item_name
     ,element_type_id
     ,input_value_id
	 ,column_type
	 ,column_size
     ,legislation_code
     ,cagr_api_id
     ,cagr_api_param_id
     ,business_group_id
     ,beneficial_rule
     ,category_name
     ,uom
     ,flex_value_set_id
     ,beneficial_formula_id
     ,object_version_number
     ,beneficial_rule_value_set_id
     ,multiple_entries_allowed_flag
     ,auto_create_entries_flag -- CEI Enh
     ,opt_id
    from    per_cagr_entitlement_items
    where    cagr_entitlement_item_id = p_cagr_entitlement_item_id
    for    update nowait;
--
  l_proc    varchar2(72) := g_package||'lck';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'CAGR_ENTITLEMENT_ITEM_ID'
    ,p_argument_value     => p_cagr_entitlement_item_id
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into per_cei_shd.g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  End If;
  Close C_Sel1;
  --
  If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
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
    fnd_message.set_token('TABLE_NAME', 'per_cagr_entitlement_items');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_cagr_entitlement_item_id       in number
  ,p_item_name                      in varchar2
  ,p_element_type_id                in number
  ,p_input_value_id                 in varchar2
  ,p_column_type                    in varchar2
  ,p_column_size                    in number
  ,p_legislation_code               in varchar2
  ,p_cagr_api_id                    in number
  ,p_cagr_api_param_id              in number
  ,p_business_group_id              in number
  ,p_beneficial_rule                in varchar2
  ,p_category_name                  in varchar2
  ,p_uom                            in varchar2
  ,p_flex_value_set_id              in number
  ,p_beneficial_formula_id          in number
  ,p_object_version_number          in number
  ,p_ben_rule_value_set_id          in number
  ,p_mult_entries_allowed_flag      in varchar2
  ,p_auto_create_entries_flag       in varchar2 -- CEI Enh
  ,p_opt_id                         in number) Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.cagr_entitlement_item_id         := p_cagr_entitlement_item_id;
  l_rec.item_name                        := p_item_name;
  l_rec.element_type_id                  := p_element_type_id;
  l_rec.input_value_id                   := p_input_value_id;
  l_rec.column_type                      := p_column_type;
  l_rec.column_size                      := p_column_size;
  l_rec.legislation_code                      := p_legislation_code;
  l_rec.beneficial_rule                  := p_beneficial_rule;
  l_rec.cagr_api_id                      := p_cagr_api_id;
  l_rec.cagr_api_param_id                := p_cagr_api_param_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.beneficial_rule                  := p_beneficial_rule;
  l_rec.category_name                    := p_category_name;
  l_rec.uom                              := p_uom;
  l_rec.flex_value_set_id                := p_flex_value_set_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.beneficial_formula_id            := p_beneficial_formula_id;
  l_rec.ben_rule_value_set_id            := p_ben_rule_value_set_id;
  l_rec.mult_entries_allowed_flag        := p_mult_entries_allowed_flag;
  l_rec.auto_create_entries_flag         := p_auto_create_entries_flag; -- CEI Enh
  l_rec.opt_id                           := p_opt_id;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end per_cei_shd;

/
