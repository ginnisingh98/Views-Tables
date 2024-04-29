--------------------------------------------------------
--  DDL for Package Body PAY_PAP_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAP_SHD" as
/* $Header: pypaprhi.pkb 120.0 2005/05/29 07:14:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_pap_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
  l_proc 	varchar2(72) := g_package||'return_api_dml_status';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  Return (nvl(g_api_dml, false));
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End return_api_dml_status;
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
  If (p_constraint_name = 'PAY_ACCRUAL_PLANS_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PAY_ACCRUAL_PLANS_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PAY_APN_ACCRUAL_UNITS_OF_M_CHK') Then
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
  p_accrual_plan_id                    in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		accrual_plan_id,
	business_group_id,
	accrual_plan_element_type_id,
	pto_input_value_id,
	co_input_value_id,
	residual_input_value_id,
	accrual_category,
	accrual_plan_name,
	accrual_start,
	accrual_units_of_measure,
	ineligible_period_length,
	ineligible_period_type,
	accrual_formula_id,
	co_formula_id,
	co_date_input_value_id,
	co_exp_date_input_value_id,
	residual_date_input_value_id,
	description,
        ineligibility_formula_id,
        payroll_formula_id,
        defined_balance_id,
        tagging_element_type_id,
        balance_element_type_id,
	object_version_number,
        information_category,
        information1,
  	information2,
  	information3,
  	information4,
  	information5,
  	information6,
  	information7,
  	information8,
  	information9,
  	information10,
  	information11,
  	information12,
  	information13,
 	information14,
	information15,
	information16,
	information17,
  	information18,
  	information19,
  	information20,
  	information21,
  	information22,
        information23,
        information24,
        information25,
        information26,
        information27,
        information28,
        information29,
        information30

    from	pay_accrual_plans
    where	accrual_plan_id = p_accrual_plan_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_accrual_plan_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_accrual_plan_id = g_old_rec.accrual_plan_id and
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
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number <> g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
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
  p_accrual_plan_id                    in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	accrual_plan_id,
	business_group_id,
	accrual_plan_element_type_id,
	pto_input_value_id,
	co_input_value_id,
	residual_input_value_id,
	accrual_category,
	accrual_plan_name,
	accrual_start,
	accrual_units_of_measure,
	ineligible_period_length,
	ineligible_period_type,
	accrual_formula_id,
	co_formula_id,
	co_date_input_value_id,
	co_exp_date_input_value_id,
	residual_date_input_value_id,
	description,
        ineligibility_formula_id,
        payroll_formula_id,
        defined_balance_id,
        tagging_element_type_id,
        balance_element_type_id,
	object_version_number,
        information_category,
        information1,
        information2,
        information3,
        information4,
        information5,
        information6,
        information7,
        information8,
        information9,
        information10,
        information11,
        information12,
        information13,
        information14,
        information15,
        information16,
        information17,
        information18,
        information19,
        information20,
        information21,
        information22,
        information23,
        information24,
        information25,
        information26,
        information27,
        information28,
        information29,
        information30

    from	pay_accrual_plans
    where	accrual_plan_id = p_accrual_plan_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'object_version_number',
     p_argument_value => p_object_version_number);
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number <> g_old_rec.object_version_number) Then
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
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'pay_accrual_plans');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_accrual_plan_id               in number,
	p_business_group_id             in number,
	p_accrual_plan_element_type_id  in number,
	p_pto_input_value_id            in number,
	p_co_input_value_id             in number,
	p_residual_input_value_id       in number,
	p_accrual_category              in varchar2,
	p_accrual_plan_name             in varchar2,
	p_accrual_start                 in varchar2,
	p_accrual_units_of_measure      in varchar2,
	p_ineligible_period_length      in number,
	p_ineligible_period_type        in varchar2,
	p_accrual_formula_id            in number,
	p_co_formula_id                 in number,
	p_co_date_input_value_id        in number,
	p_co_exp_date_input_value_id    in number,
	p_residual_date_input_value_id  in number,
	p_description                   in varchar2,
        p_ineligibility_formula_id      in number,
        p_payroll_formula_id            in number,
        p_defined_balance_id            in number,
        p_tagging_element_type_id       in number,
        p_balance_element_type_id       in number,
	p_object_version_number         in number,
        p_information_category          in varchar2,
        p_information1                  in varchar2,
  	p_information2                  in varchar2,
	p_information3                  in varchar2,
	p_information4                  in varchar2,
	p_information5                  in varchar2,
	p_information6                  in varchar2,
	p_information7                  in varchar2,
	p_information8                  in varchar2,
	p_information9                  in varchar2,
	p_information10                 in varchar2,
	p_information11                 in varchar2,
	p_information12                 in varchar2,
	p_information13                 in varchar2,
	p_information14                 in varchar2,
	p_information15                 in varchar2,
	p_information16                 in varchar2,
	p_information17                 in varchar2,
	p_information18                 in varchar2,
	p_information19                 in varchar2,
	p_information20                 in varchar2,
	p_information21                 in varchar2,
	p_information22                 in varchar2,
	p_information23                 in varchar2,
	p_information24                 in varchar2,
	p_information25                 in varchar2,
	p_information26                 in varchar2,
	p_information27                 in varchar2,
	p_information28                 in varchar2,
	p_information29                 in varchar2,
  	p_information30                 in varchar2
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
  l_rec.accrual_plan_id                  := p_accrual_plan_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.accrual_plan_element_type_id     := p_accrual_plan_element_type_id;
  l_rec.pto_input_value_id               := p_pto_input_value_id;
  l_rec.co_input_value_id                := p_co_input_value_id;
  l_rec.residual_input_value_id          := p_residual_input_value_id;
  l_rec.accrual_category                 := p_accrual_category;
  l_rec.accrual_plan_name                := p_accrual_plan_name;
  l_rec.accrual_start                    := p_accrual_start;
  l_rec.accrual_units_of_measure         := p_accrual_units_of_measure;
  l_rec.ineligible_period_length         := p_ineligible_period_length;
  l_rec.ineligible_period_type           := p_ineligible_period_type;
  l_rec.accrual_formula_id               := p_accrual_formula_id;
  l_rec.co_formula_id                    := p_co_formula_id;
  l_rec.co_date_input_value_id           := p_co_date_input_value_id;
  l_rec.co_exp_date_input_value_id       := p_co_exp_date_input_value_id;
  l_rec.residual_date_input_value_id     := p_residual_date_input_value_id;
  l_rec.description                      := p_description;
  l_rec.ineligibility_formula_id         := p_ineligibility_formula_id;
  l_rec.payroll_formula_id               := p_payroll_formula_id;
  l_rec.defined_balance_id               := p_defined_balance_id;
  l_rec.tagging_element_type_id          := p_tagging_element_type_id;
  l_rec.balance_element_type_id          := p_balance_element_type_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.information_category         	 := p_information_category;
  l_rec.information1		 	 := p_information1;
  l_rec.information2                     := p_information2;
  l_rec.information3                     := p_information3;
  l_rec.information4                     := p_information4;
  l_rec.information5                     := p_information5;
  l_rec.information6                     := p_information6;
  l_rec.information7                     := p_information7;
  l_rec.information8                     := p_information8;
  l_rec.information9                     := p_information9;
  l_rec.information10                    := p_information10;
  l_rec.information11                    := p_information11;
  l_rec.information12                    := p_information12;
  l_rec.information13                    := p_information13;
  l_rec.information14                    := p_information14;
  l_rec.information15                    := p_information15;
  l_rec.information16                    := p_information16;
  l_rec.information17                    := p_information17;
  l_rec.information18                    := p_information18;
  l_rec.information19                    := p_information19;
  l_rec.information20                    := p_information20;
  l_rec.information21                    := p_information21;
  l_rec.information22                    := p_information22;
  l_rec.information23                    := p_information23;
  l_rec.information24                    := p_information24;
  l_rec.information25                    := p_information25;
  l_rec.information26                    := p_information26;
  l_rec.information27                    := p_information27;
  l_rec.information28                    := p_information28;
  l_rec.information29                    := p_information29;
  l_rec.information30                    := p_information30;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end pay_pap_shd;

/
