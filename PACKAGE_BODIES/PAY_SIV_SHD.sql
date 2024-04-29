--------------------------------------------------------
--  DDL for Package Body PAY_SIV_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SIV_SHD" as
/* $Header: pysivrhi.pkb 120.0 2005/05/29 08:52:40 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_siv_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
            (p_constraint_name in all_constraints.constraint_name%TYPE) Is
--
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'PAY_SHADOW_INPUT_VALUES_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PAY_SHADOW_INPUT_VALUES_FK2') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PAY_SHADOW_INPUT_VALUES_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
  Else
    hr_utility.set_message(801, 'HR_7877_API_INVALID_CONSTRAINT');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('CONSTRAINT_NAME', p_constraint_name);
    hr_utility.raise_error;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (
  p_input_value_id                     in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	input_value_id,
	element_type_id,
	display_sequence,
	generate_db_items_flag,
	hot_default_flag,
	mandatory_flag,
	name,
	uom,
	lookup_type,
	default_value,
	max_value,
	min_value,
	warning_or_error,
	default_value_column,
	exclusion_rule_id,
	formula_id,
	input_validation_formula,
	object_version_number
    from	pay_shadow_input_values
    where	input_value_id = p_input_value_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_input_value_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_input_value_id = g_old_rec.input_value_id and
	p_object_version_number = g_old_rec.object_version_number
       ) Then
      hr_utility.set_location(l_proc, 10);
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
      Fetch C_Sel1 Into g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
        hr_utility.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
      End If;
      hr_utility.set_location(l_proc, 15);
      l_fct_ret := true;
    End If;
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (
  p_input_value_id                     in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	input_value_id,
	element_type_id,
	display_sequence,
	generate_db_items_flag,
	hot_default_flag,
	mandatory_flag,
	name,
	uom,
	lookup_type,
	default_value,
	max_value,
	min_value,
	warning_or_error,
	default_value_column,
	exclusion_rule_id,
	formula_id,
	input_validation_formula,
	object_version_number
    from	pay_shadow_input_values
    where	input_value_id = p_input_value_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Add any mandatory argument checking here:
  -- Example:
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'p_input_value_id',
     p_argument_value => p_input_value_id);
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'p_object_version_number',
     p_argument_value => p_object_version_number);
  Open  C_Sel1;
  Fetch C_Sel1 Into g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  End If;
  Close C_Sel1;
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
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'pay_shadow_input_values');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_input_value_id                in number,
	p_element_type_id               in number,
	p_display_sequence              in number,
	p_generate_db_items_flag        in varchar2,
	p_hot_default_flag              in varchar2,
	p_mandatory_flag                in varchar2,
	p_name                          in varchar2,
	p_uom                           in varchar2,
	p_lookup_type                   in varchar2,
	p_default_value                 in varchar2,
	p_max_value                     in varchar2,
	p_min_value                     in varchar2,
	p_warning_or_error              in varchar2,
	p_default_value_column          in varchar2,
	p_exclusion_rule_id             in number,
	p_formula_id			in number,
	p_input_validation_formula	in varchar2,
	p_object_version_number         in number
	)
	Return g_rec_type is
--
  l_rec	  g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.input_value_id                   := p_input_value_id;
  l_rec.element_type_id                  := p_element_type_id;
  l_rec.display_sequence                 := p_display_sequence;
  l_rec.generate_db_items_flag           := p_generate_db_items_flag;
  l_rec.hot_default_flag                 := p_hot_default_flag;
  l_rec.mandatory_flag                   := p_mandatory_flag;
  l_rec.name                             := p_name;
  l_rec.uom                              := p_uom;
  l_rec.lookup_type                      := p_lookup_type;
  l_rec.default_value                    := p_default_value;
  l_rec.max_value                        := p_max_value;
  l_rec.min_value                        := p_min_value;
  l_rec.warning_or_error                 := p_warning_or_error;
  l_rec.default_value_column             := p_default_value_column;
  l_rec.exclusion_rule_id                := p_exclusion_rule_id;
  l_rec.formula_id			 := p_formula_id;
  l_rec.input_validation_formula	 := p_input_validation_formula;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end pay_siv_shd;

/
