--------------------------------------------------------
--  DDL for Package Body PAY_SET_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SET_SHD" as
/* $Header: pysetrhi.pkb 120.0 2005/05/29 08:39:23 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_set_shd.';  -- Global package name
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
  If (p_constraint_name = 'PAY_SHADOW_ELEMENT_TYPES_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PAY_SHADOW_ELEMENT_TYPES_FK2') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PAY_SHADOW_ELEMENT_TYPES_FK3') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PAY_SHADOW_ELEMENT_TYPES_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
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
  p_element_type_id                    in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		element_type_id,
	template_id,
	classification_name,
	additional_entry_allowed_flag,
	adjustment_only_flag,
	closed_for_entry_flag,
	element_name,
	indirect_only_flag,
	multiple_entries_allowed_flag,
	multiply_value_flag,
	post_termination_rule,
	process_in_run_flag,
	relative_processing_priority,
	processing_type,
	standard_link_flag,
	input_currency_code,
	output_currency_code,
	benefit_classification_name,
	description,
	qualifying_age,
	qualifying_length_of_service,
	qualifying_units,
	reporting_name,
	attribute_category,
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10,
	attribute11,
	attribute12,
	attribute13,
	attribute14,
	attribute15,
	attribute16,
	attribute17,
	attribute18,
	attribute19,
	attribute20,
	element_information_category,
	element_information1,
	element_information2,
	element_information3,
	element_information4,
	element_information5,
	element_information6,
	element_information7,
	element_information8,
	element_information9,
	element_information10,
	element_information11,
	element_information12,
	element_information13,
	element_information14,
	element_information15,
	element_information16,
	element_information17,
	element_information18,
	element_information19,
	element_information20,
	third_party_pay_only_flag,
	skip_formula,
	payroll_formula_id,
	exclusion_rule_id,
        iterative_flag,
        iterative_priority,
        iterative_formula_name,
        process_mode,
        grossup_flag,
        advance_indicator,
        advance_payable,
        advance_deduction,
        process_advance_entry,
        proration_group,
        proration_formula,
        recalc_event_group,
        once_each_period_flag,
	object_version_number
    from	pay_shadow_element_types
    where	element_type_id = p_element_type_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_element_type_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_element_type_id = g_old_rec.element_type_id and
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
  p_element_type_id                    in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	element_type_id,
	template_id,
	classification_name,
	additional_entry_allowed_flag,
	adjustment_only_flag,
	closed_for_entry_flag,
	element_name,
	indirect_only_flag,
	multiple_entries_allowed_flag,
	multiply_value_flag,
	post_termination_rule,
	process_in_run_flag,
	relative_processing_priority,
	processing_type,
	standard_link_flag,
	input_currency_code,
	output_currency_code,
	benefit_classification_name,
	description,
	qualifying_age,
	qualifying_length_of_service,
	qualifying_units,
	reporting_name,
	attribute_category,
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10,
	attribute11,
	attribute12,
	attribute13,
	attribute14,
	attribute15,
	attribute16,
	attribute17,
	attribute18,
	attribute19,
	attribute20,
	element_information_category,
	element_information1,
	element_information2,
	element_information3,
	element_information4,
	element_information5,
	element_information6,
	element_information7,
	element_information8,
	element_information9,
	element_information10,
	element_information11,
	element_information12,
	element_information13,
	element_information14,
	element_information15,
	element_information16,
	element_information17,
	element_information18,
	element_information19,
	element_information20,
	third_party_pay_only_flag,
	skip_formula,
	payroll_formula_id,
	exclusion_rule_id,
        iterative_flag,
        iterative_priority,
        iterative_formula_name,
        process_mode,
        grossup_flag,
        advance_indicator,
        advance_payable,
        advance_deduction,
        process_advance_entry,
        proration_group,
        proration_formula,
        recalc_event_group,
        once_each_period_flag,
	object_version_number
    from	pay_shadow_element_types
    where	element_type_id = p_element_type_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'p_element_type_id',
     p_argument_value => p_element_type_id);
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'object_version_number',
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
    hr_utility.set_message_token('TABLE_NAME', 'pay_shadow_element_types');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_element_type_id               in number,
	p_template_id                   in number,
	p_classification_name           in varchar2,
	p_additional_entry_allowed_fla  in varchar2,
	p_adjustment_only_flag          in varchar2,
	p_closed_for_entry_flag         in varchar2,
	p_element_name                  in varchar2,
	p_indirect_only_flag            in varchar2,
	p_multiple_entries_allowed_fla  in varchar2,
	p_multiply_value_flag           in varchar2,
	p_post_termination_rule         in varchar2,
	p_process_in_run_flag           in varchar2,
	p_relative_processing_priority  in number,
	p_processing_type               in varchar2,
	p_standard_link_flag            in varchar2,
	p_input_currency_code           in varchar2,
	p_output_currency_code          in varchar2,
	p_benefit_classification_name   in varchar2,
	p_description                   in varchar2,
	p_qualifying_age                in number,
	p_qualifying_length_of_service  in number,
	p_qualifying_units              in varchar2,
	p_reporting_name                in varchar2,
	p_attribute_category            in varchar2,
	p_attribute1                    in varchar2,
	p_attribute2                    in varchar2,
	p_attribute3                    in varchar2,
	p_attribute4                    in varchar2,
	p_attribute5                    in varchar2,
	p_attribute6                    in varchar2,
	p_attribute7                    in varchar2,
	p_attribute8                    in varchar2,
	p_attribute9                    in varchar2,
	p_attribute10                   in varchar2,
	p_attribute11                   in varchar2,
	p_attribute12                   in varchar2,
	p_attribute13                   in varchar2,
	p_attribute14                   in varchar2,
	p_attribute15                   in varchar2,
	p_attribute16                   in varchar2,
	p_attribute17                   in varchar2,
	p_attribute18                   in varchar2,
	p_attribute19                   in varchar2,
	p_attribute20                   in varchar2,
	p_element_information_category  in varchar2,
	p_element_information1          in varchar2,
	p_element_information2          in varchar2,
	p_element_information3          in varchar2,
	p_element_information4          in varchar2,
	p_element_information5          in varchar2,
	p_element_information6          in varchar2,
	p_element_information7          in varchar2,
	p_element_information8          in varchar2,
	p_element_information9          in varchar2,
	p_element_information10         in varchar2,
	p_element_information11         in varchar2,
	p_element_information12         in varchar2,
	p_element_information13         in varchar2,
	p_element_information14         in varchar2,
	p_element_information15         in varchar2,
	p_element_information16         in varchar2,
	p_element_information17         in varchar2,
	p_element_information18         in varchar2,
	p_element_information19         in varchar2,
	p_element_information20         in varchar2,
	p_third_party_pay_only_flag     in varchar2,
	p_skip_formula                  in varchar2,
	p_payroll_formula_id            in number,
	p_exclusion_rule_id             in number,
        p_iterative_flag                in varchar2,
        p_iterative_priority            in number,
        p_iterative_formula_name        in varchar2,
        p_process_mode                  in varchar2,
        p_grossup_flag                  in varchar2,
        p_advance_indicator             in varchar2,
        p_advance_payable               in varchar2,
        p_advance_deduction             in varchar2,
        p_process_advance_entry         in varchar2,
        p_proration_group               in varchar2,
        p_proration_formula             in varchar2,
        p_recalc_event_group            in varchar2,
        p_once_each_period_flag         in varchar2,
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
  l_rec.element_type_id                  := p_element_type_id;
  l_rec.template_id                      := p_template_id;
  l_rec.classification_name              := p_classification_name;
  l_rec.additional_entry_allowed_flag    := p_additional_entry_allowed_fla;
  l_rec.adjustment_only_flag             := p_adjustment_only_flag;
  l_rec.closed_for_entry_flag            := p_closed_for_entry_flag;
  l_rec.element_name                     := p_element_name;
  l_rec.indirect_only_flag               := p_indirect_only_flag;
  l_rec.multiple_entries_allowed_flag    := p_multiple_entries_allowed_fla;
  l_rec.multiply_value_flag              := p_multiply_value_flag;
  l_rec.post_termination_rule            := p_post_termination_rule;
  l_rec.process_in_run_flag              := p_process_in_run_flag;
  l_rec.relative_processing_priority     := p_relative_processing_priority;
  l_rec.processing_type                  := p_processing_type;
  l_rec.standard_link_flag               := p_standard_link_flag;
  l_rec.input_currency_code              := p_input_currency_code;
  l_rec.output_currency_code             := p_output_currency_code;
  l_rec.benefit_classification_name      := p_benefit_classification_name;
  l_rec.description                      := p_description;
  l_rec.qualifying_age                   := p_qualifying_age;
  l_rec.qualifying_length_of_service     := p_qualifying_length_of_service;
  l_rec.qualifying_units                 := p_qualifying_units;
  l_rec.reporting_name                   := p_reporting_name;
  l_rec.attribute_category               := p_attribute_category;
  l_rec.attribute1                       := p_attribute1;
  l_rec.attribute2                       := p_attribute2;
  l_rec.attribute3                       := p_attribute3;
  l_rec.attribute4                       := p_attribute4;
  l_rec.attribute5                       := p_attribute5;
  l_rec.attribute6                       := p_attribute6;
  l_rec.attribute7                       := p_attribute7;
  l_rec.attribute8                       := p_attribute8;
  l_rec.attribute9                       := p_attribute9;
  l_rec.attribute10                      := p_attribute10;
  l_rec.attribute11                      := p_attribute11;
  l_rec.attribute12                      := p_attribute12;
  l_rec.attribute13                      := p_attribute13;
  l_rec.attribute14                      := p_attribute14;
  l_rec.attribute15                      := p_attribute15;
  l_rec.attribute16                      := p_attribute16;
  l_rec.attribute17                      := p_attribute17;
  l_rec.attribute18                      := p_attribute18;
  l_rec.attribute19                      := p_attribute19;
  l_rec.attribute20                      := p_attribute20;
  l_rec.element_information_category     := p_element_information_category;
  l_rec.element_information1             := p_element_information1;
  l_rec.element_information2             := p_element_information2;
  l_rec.element_information3             := p_element_information3;
  l_rec.element_information4             := p_element_information4;
  l_rec.element_information5             := p_element_information5;
  l_rec.element_information6             := p_element_information6;
  l_rec.element_information7             := p_element_information7;
  l_rec.element_information8             := p_element_information8;
  l_rec.element_information9             := p_element_information9;
  l_rec.element_information10            := p_element_information10;
  l_rec.element_information11            := p_element_information11;
  l_rec.element_information12            := p_element_information12;
  l_rec.element_information13            := p_element_information13;
  l_rec.element_information14            := p_element_information14;
  l_rec.element_information15            := p_element_information15;
  l_rec.element_information16            := p_element_information16;
  l_rec.element_information17            := p_element_information17;
  l_rec.element_information18            := p_element_information18;
  l_rec.element_information19            := p_element_information19;
  l_rec.element_information20            := p_element_information20;
  l_rec.third_party_pay_only_flag        := p_third_party_pay_only_flag;
  l_rec.skip_formula                     := p_skip_formula;
  l_rec.payroll_formula_id               := p_payroll_formula_id;
  l_rec.exclusion_rule_id                := p_exclusion_rule_id;
  l_rec.iterative_flag                   := p_iterative_flag;
  l_rec.iterative_priority               := p_iterative_priority;
  l_rec.iterative_formula_name           := p_iterative_formula_name;
  l_rec.process_mode                     := p_process_mode;
  l_rec.grossup_flag                     := p_grossup_flag;
  l_rec.advance_indicator                := p_advance_indicator;
  l_rec.advance_payable                  := p_advance_payable;
  l_rec.advance_deduction                := p_advance_deduction;
  l_rec.process_advance_entry            := p_process_advance_entry;
  l_rec.proration_group                  := p_proration_group;
  l_rec.proration_formula                := p_proration_formula;
  l_rec.recalc_event_group               := p_recalc_event_group;
  l_rec.once_each_period_flag            := p_once_each_period_flag;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end pay_set_shd;

/
