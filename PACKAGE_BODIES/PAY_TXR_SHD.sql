--------------------------------------------------------
--  DDL for Package Body PAY_TXR_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_TXR_SHD" as
/* $Header: pytxrrhi.pkb 120.0 2005/05/29 09:09 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_txr_shd.';  -- Global package name
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
  If (p_constraint_name = 'PAY_TAXABILITY_RULES_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_TAXABILITY_RULES_FK2') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_TAXABILITY_RULES_FK3') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_TAXABILITY_RULES_UK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','20');
    fnd_message.raise_error;
/*
  ElsIf (p_constraint_name = 'PAY_TAXABILITY_RULES_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_TXR_TAX_TYPE_CHK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','20');
    fnd_message.raise_error;
*/
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
  (p_jurisdiction_code                    in     varchar2
  ,p_tax_type                             in     varchar2 default null
  ,p_tax_category                         in     varchar2 default null
  ,p_classification_id                    in     number   default null
  ,p_taxability_rules_date_id             in     number
  ,p_secondary_classification_id          in     number   default null
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       jurisdiction_code
      ,tax_type
      ,tax_category
      ,classification_id
      ,taxability_rules_date_id
      ,legislation_code
      ,status
      ,secondary_classification_id
    from        pay_taxability_rules
    where       jurisdiction_code = p_jurisdiction_code
    and   nvl(tax_type, 'X') = nvl(p_tax_type ,'X')
    and   nvl(tax_category, 'X') = nvl(p_tax_category ,'X')
    and   nvl(classification_id, 0) = nvl(p_classification_id, 0)
    and   nvl(secondary_classification_id, 0) =
                       nvl(p_secondary_classification_id, 0)
    and   taxability_rules_date_id = p_taxability_rules_date_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_jurisdiction_code is null and
--      p_tax_type is null and
--      p_tax_category is null and
--      p_classification_id is null and
      p_taxability_rules_date_id is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_jurisdiction_code
        = pay_txr_shd.g_old_rec.jurisdiction_code and
        nvl(p_tax_type, 'X')
        = nvl(pay_txr_shd.g_old_rec.tax_type, 'X') and
        nvl(p_tax_category, 'X')
        = nvl(pay_txr_shd.g_old_rec.tax_category, 'X') and
        nvl(p_classification_id, 0)
        = nvl(pay_txr_shd.g_old_rec.classification_id, 0) and
        nvl(p_secondary_classification_id, 0)
        = nvl(pay_txr_shd.g_old_rec.secondary_classification_id, 0) and
        p_taxability_rules_date_id
        = pay_txr_shd.g_old_rec.taxability_rules_date_id
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
      Fetch C_Sel1 Into pay_txr_shd.g_old_rec;
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
  (p_jurisdiction_code                    in     varchar2
  ,p_tax_type                             in     varchar2 default null
  ,p_tax_category                         in     varchar2 default null
  ,p_classification_id                    in     number   default null
  ,p_taxability_rules_date_id             in     number
  ,p_secondary_classification_id          in     number   default null
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       jurisdiction_code
      ,tax_type
      ,tax_category
      ,classification_id
      ,taxability_rules_date_id
      ,legislation_code
      ,status
      ,secondary_classification_id
    from        pay_taxability_rules
    where       jurisdiction_code = p_jurisdiction_code
    and   nvl(tax_type, 'X') = nvl(p_tax_type, 'X')
    and   nvl(tax_category, 'X') = nvl(p_tax_category, 'X')
    and   nvl(classification_id, 0) = nvl(p_classification_id, 0)
    and   nvl(secondary_classification_id, 0) =
                         nvl(p_secondary_classification_id, 0)
    and   taxability_rules_date_id = p_taxability_rules_date_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'JURISDICTION_CODE'
    ,p_argument_value     => p_jurisdiction_code
    );
  hr_utility.set_location(l_proc,6);
/*  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'TAX_TYPE'
    ,p_argument_value     => p_tax_type
    );
  hr_utility.set_location(l_proc,7);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'TAX_CATEGORY'
    ,p_argument_value     => p_tax_category
    );
  hr_utility.set_location(l_proc,8);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'CLASSIFICATION_ID'
    ,p_argument_value     => p_classification_id
    );
*/
  hr_utility.set_location(l_proc,9);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'TAXABILITY_RULES_DATE_ID'
    ,p_argument_value     => p_taxability_rules_date_id
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pay_txr_shd.g_old_rec;
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
    fnd_message.set_token('TABLE_NAME', 'pay_taxability_rules');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_jurisdiction_code              in varchar2
  ,p_tax_type                       in varchar2 default null
  ,p_tax_category                   in varchar2 default null
  ,p_classification_id              in number   default null
  ,p_taxability_rules_date_id       in number
  ,p_legislation_code               in varchar2
  ,p_status                         in varchar2
  ,p_secondary_classification_id    in number   default null
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  hr_utility.trace('Entering Convert arguments');
  hr_utility.trace('p_jurisdiction_code = '||p_jurisdiction_code);

  l_rec.jurisdiction_code                := p_jurisdiction_code;
  hr_utility.trace('Assigned p_jurisdiction_code = '||l_rec.jurisdiction_code);
  l_rec.tax_type                         := p_tax_type;
  l_rec.tax_category                     := p_tax_category;
  l_rec.classification_id                := p_classification_id;
  l_rec.taxability_rules_date_id         := p_taxability_rules_date_id;
  l_rec.legislation_code                 := p_legislation_code;
  l_rec.status                           := p_status;
  l_rec.secondary_classification_id      := p_secondary_classification_id;
  --Before
  -- Return the plsql record structure.
  --
  hr_utility.trace('Leaving Convert arguments');
  Return(l_rec);
--

   Exception
    When Others THEN
     hr_utility.trace('Error in  Convert arguments = '||SQLERRM);

End convert_args;
--
end pay_txr_shd;

/
