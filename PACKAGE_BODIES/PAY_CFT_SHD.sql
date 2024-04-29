--------------------------------------------------------
--  DDL for Package Body PAY_CFT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CFT_SHD" as
/* $Header: pycatrhi.pkb 120.1 2005/10/05 06:44:36 saurgupt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_cft_shd.';  -- Global package name
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
  If (p_constraint_name = 'PAY_CA_EMP_FED_TAX_RULES_PK') Then
    hr_utility.set_message(800, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  Else
    hr_utility.set_message(800, 'HR_7877_API_INVALID_CONSTRAINT');
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
  (p_effective_date		in date,
   p_emp_fed_tax_inf_id		in number,
   p_object_version_number	in number
  ) Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	emp_fed_tax_inf_id,
	effective_start_date,
	effective_end_date,
	legislation_code,
	assignment_id,
	business_group_id,
	employment_province,
	tax_credit_amount,
	claim_code,
	basic_exemption_flag,
	additional_tax,
	annual_dedn,
	total_expense_by_commission,
	total_remnrtn_by_commission,
	prescribed_zone_dedn_amt,
	other_fedtax_credits,
	cpp_qpp_exempt_flag,
	fed_exempt_flag,
	ei_exempt_flag,
	tax_calc_method,
	fed_override_amount,
	fed_override_rate,
	ca_tax_information_category,
	ca_tax_information1,
	ca_tax_information2,
	ca_tax_information3,
	ca_tax_information4,
	ca_tax_information5,
	ca_tax_information6,
	ca_tax_information7,
	ca_tax_information8,
	ca_tax_information9,
	ca_tax_information10,
	ca_tax_information11,
	ca_tax_information12,
	ca_tax_information13,
	ca_tax_information14,
	ca_tax_information15,
	ca_tax_information16,
	ca_tax_information17,
	ca_tax_information18,
	ca_tax_information19,
	ca_tax_information20,
	ca_tax_information21,
	ca_tax_information22,
	ca_tax_information23,
	ca_tax_information24,
	ca_tax_information25,
	ca_tax_information26,
	ca_tax_information27,
	ca_tax_information28,
	ca_tax_information29,
	ca_tax_information30,
	object_version_number,
	fed_lsf_amount
    from	pay_ca_emp_fed_tax_info_f
    where	emp_fed_tax_inf_id = p_emp_fed_tax_inf_id
    and		p_effective_date
    between	effective_start_date and effective_end_date;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_effective_date is null or
      p_emp_fed_tax_inf_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_emp_fed_tax_inf_id = g_old_rec.emp_fed_tax_inf_id and
        p_object_version_number = g_old_rec.object_version_number) Then
      hr_utility.set_location(l_proc, 10);
      --
      -- The g_old_rec is current therefore we must
      -- set the returning function to true
      --

      l_fct_ret := true;
    Else
      --
      -- Select the current row
      --
--     dbms_output.put_line('cannot change assignment_id 3');
      Open C_Sel1;
      Fetch C_Sel1 Into g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        hr_utility.set_message(800, 'HR_7220_INVALID_PRIMARY_KEY');
        hr_utility.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(800, 'HR_7155_OBJECT_INVALID');
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
-- |--------------------------< find_dt_del_modes >---------------------------|
-- ----------------------------------------------------------------------------
Procedure find_dt_del_modes
	(p_effective_date	in  date,
	 p_base_key_value	in  number,
	 p_zap			out nocopy boolean,
	 p_delete		out nocopy boolean,
	 p_future_change	out nocopy boolean,
	 p_delete_next_change	out nocopy boolean) is
--
  l_proc 		varchar2(72) 	:= g_package||'find_dt_del_modes';
--
  l_parent_key_value1	number;
  --
  Cursor C_Sel1 Is
    select  t.assignment_id
    from    pay_ca_emp_fed_tax_info_f t
    where   t.emp_fed_tax_inf_id = p_base_key_value
    and     p_effective_date
    between t.effective_start_date and t.effective_end_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  Open  C_Sel1;
  Fetch C_Sel1 Into l_parent_key_value1;
  If C_Sel1%notfound then
    Close C_Sel1;
    hr_utility.set_message(800, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  End If;
  Close C_Sel1;
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_del_modes
	(p_effective_date	=> p_effective_date,
	 p_base_table_name	=> 'pay_ca_emp_fed_tax_info_f',
	 p_base_key_column	=> 'emp_fed_tax_inf_id',
	 p_base_key_value	=> p_base_key_value,
	 p_parent_table_name1	=> 'per_all_assignments_f',
	 p_parent_key_column1	=> 'assignment_id',
	 p_parent_key_value1	=> l_parent_key_value1,
	 p_zap			=> p_zap,
	 p_delete		=> p_delete,
	 p_future_change	=> p_future_change,
	 p_delete_next_change	=> p_delete_next_change);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End find_dt_del_modes;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< find_dt_upd_modes >---------------------------|
-- ----------------------------------------------------------------------------
Procedure find_dt_upd_modes
	(p_effective_date	in  date,
	 p_base_key_value	in  number,
	 p_correction		out nocopy boolean,
	 p_update		out nocopy boolean,
	 p_update_override	out nocopy boolean,
	 p_update_change_insert	out nocopy boolean) is
--
  l_proc 	varchar2(72) := g_package||'find_dt_upd_modes';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_upd_modes
	(p_effective_date	=> p_effective_date,
	 p_base_table_name	=> 'pay_ca_emp_fed_tax_info_f',
	 p_base_key_column	=> 'emp_fed_tax_inf_id',
	 p_base_key_value	=> p_base_key_value,
	 p_correction		=> p_correction,
	 p_update		=> p_update,
	 p_update_override	=> p_update_override,
	 p_update_change_insert	=> p_update_change_insert);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End find_dt_upd_modes;
--
-- ----------------------------------------------------------------------------
-- |------------------------< upd_effective_end_date >------------------------|
-- ----------------------------------------------------------------------------
Procedure upd_effective_end_date
	(p_effective_date		in date,
	 p_base_key_value		in number,
	 p_new_effective_end_date	in date,
	 p_validation_start_date	in date,
	 p_validation_end_date		in date,
         p_object_version_number       out nocopy number) is
--
  l_proc 		  varchar2(72) := g_package||'upd_effective_end_date';
  l_object_version_number number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Because we are updating a row we must get the next object
  -- version number.
  --
  l_object_version_number :=
    dt_api.get_object_version_number
	(p_base_table_name	=> 'pay_ca_emp_fed_tax_info_f',
	 p_base_key_column	=> 'emp_fed_tax_inf_id',
	 p_base_key_value	=> p_base_key_value);
  --
  hr_utility.set_location(l_proc, 10);
  g_api_dml := true;  -- Set the api dml status
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  pay_ca_emp_fed_tax_info_f t
  set	  t.effective_end_date	  = p_new_effective_end_date,
	  t.object_version_number = l_object_version_number
  where	  t.emp_fed_tax_inf_id	  = p_base_key_value
  and	  p_effective_date
  between t.effective_start_date and t.effective_end_date;
  --
  g_api_dml := false;   -- Unset the api dml status
  p_object_version_number := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When Others Then
    g_api_dml := false;   -- Unset the api dml status
    Raise;
End upd_effective_end_date;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
	( p_effective_date	 in  date,
	 p_datetrack_mode	 in  varchar2,
	 p_emp_fed_tax_inf_id	 in  number,
	 p_object_version_number in  number,
	 p_validation_start_date out nocopy date,
	 p_validation_end_date	 out nocopy date) is
--
  l_proc		  varchar2(72) := g_package||'lck';
  l_validation_start_date date;
  l_validation_end_date	  date;
  l_object_invalid 	  exception;
  l_argument		  varchar2(30);
  --
  -- Cursor C_Sel1 selects the current locked row as of session date
  -- ensuring that the object version numbers match.
  --
  Cursor C_Sel1 is
    select
	emp_fed_tax_inf_id,
	effective_start_date,
	effective_end_date,
	legislation_code,
	assignment_id,
	business_group_id,
	employment_province,
	tax_credit_amount,
	claim_code,
	basic_exemption_flag,
	additional_tax,
	annual_dedn,
	total_expense_by_commission,
	total_remnrtn_by_commission,
	prescribed_zone_dedn_amt,
	other_fedtax_credits,
	cpp_qpp_exempt_flag,
	fed_exempt_flag,
	ei_exempt_flag,
	tax_calc_method,
	fed_override_amount,
	fed_override_rate,
	ca_tax_information_category,
	ca_tax_information1,
	ca_tax_information2,
	ca_tax_information3,
	ca_tax_information4,
	ca_tax_information5,
	ca_tax_information6,
	ca_tax_information7,
	ca_tax_information8,
	ca_tax_information9,
	ca_tax_information10,
	ca_tax_information11,
	ca_tax_information12,
	ca_tax_information13,
	ca_tax_information14,
	ca_tax_information15,
	ca_tax_information16,
	ca_tax_information17,
	ca_tax_information18,
	ca_tax_information19,
	ca_tax_information20,
	ca_tax_information21,
	ca_tax_information22,
	ca_tax_information23,
	ca_tax_information24,
	ca_tax_information25,
	ca_tax_information26,
	ca_tax_information27,
	ca_tax_information28,
	ca_tax_information29,
	ca_tax_information30,
	object_version_number,
	fed_lsf_amount
    from    pay_ca_emp_fed_tax_info_f
    where   emp_fed_tax_inf_id         = p_emp_fed_tax_inf_id
    and	    p_effective_date
    between effective_start_date and effective_end_date
    for update nowait;
  --
  --
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that all the mandatory arguments are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'effective_date',
                             p_argument_value => p_effective_date);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'datetrack_mode',
                             p_argument_value => p_datetrack_mode);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'emp_fed_tax_inf_id',
                             p_argument_value => p_emp_fed_tax_inf_id);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'object_version_number',
                             p_argument_value => p_object_version_number);
/*
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'assignment_id',
                             p_argument_value => p_assignment_id);

  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'legislation_code',
                             p_argument_value => p_legislation_code);

  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'business_group_id',
                             p_argument_value => p_business_group_id);
*/
  --
  -- Check to ensure the datetrack mode is not INSERT.
  --
  If (p_datetrack_mode <> 'INSERT') then
    --
    -- We must select and lock the current row.
    --
    Open  C_Sel1;
    Fetch C_Sel1 Into g_old_rec;
    If C_Sel1%notfound then
      Close C_Sel1;
      --
      -- The primary key is invalid therefore we must error
      --
      hr_utility.set_message(800, 'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
    End If;
    Close C_Sel1;
    If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(800, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
      End If;
/*
    If (p_assignment_id <> g_old_rec.assignment_id) Then
        hr_utility.set_message(800, 'HR_74027_ASSIGNMENT_ID_CHANGED');
        hr_utility.raise_error;
      End If;
*/
    hr_utility.set_location(l_proc, 15);
    --
    --
    -- Validate the datetrack mode mode getting the validation start
    -- and end dates for the specified datetrack operation.
    --
    dt_api.validate_dt_mode
	(p_effective_date	   => p_effective_date,
	 p_datetrack_mode	   => p_datetrack_mode,
	 p_base_table_name	   => 'pay_ca_emp_fed_tax_info_f',
	 p_base_key_column	   => 'emp_fed_tax_inf_id',
	 p_base_key_value 	   => p_emp_fed_tax_inf_id,
	 p_parent_table_name1      => 'per_all_assignments_f',
	 p_parent_key_column1      => 'assignment_id',
	 p_parent_key_value1       => g_old_rec.assignment_id,
         p_enforce_foreign_locking => true,
	 p_validation_start_date   => l_validation_start_date,
 	 p_validation_end_date	   => l_validation_end_date);
  Else
    --
    -- We are doing a datetrack 'INSERT' which is illegal within this
    -- procedure therefore we must error (note: to lck on insert the
    -- private procedure ins_lck should be called).
    --
    hr_utility.set_message(800, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
  End If;
  --
  -- Set the validation start and end date OUT arguments
  --
  p_validation_start_date := l_validation_start_date;
  p_validation_end_date   := l_validation_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
--
-- We need to trap the ORA LOCK exception
--
Exception
  When HR_Api.Object_Locked then
    --
    -- The object is locked therefore we need to supply a meaningful
    -- error message.
    --
    hr_utility.set_message(800, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'pay_ca_emp_fed_tax_info_f');
    hr_utility.raise_error;
  When l_object_invalid then
    --
    -- The object doesn't exist or is invalid
    --
    hr_utility.set_message(800, 'HR_7155_OBJECT_INVALID');
    hr_utility.set_message_token('TABLE_NAME', 'pay_ca_emp_fed_tax_info_f');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_emp_fed_tax_inf_id            in number,
	p_effective_start_date          in date,
	p_effective_end_date            in date,
	p_legislation_code              in varchar2,
	p_assignment_id                 in number,
	p_business_group_id             in number,
	p_employment_province           in varchar2,
	p_tax_credit_amount             in number,
	p_claim_code                    in varchar2,
	p_basic_exemption_flag          in varchar2,
	p_additional_tax                in number,
	p_annual_dedn                   in number,
	p_total_expense_by_commission   in number,
	p_total_remnrtn_by_commission   in number,
	p_prescribed_zone_dedn_amt      in number,
	p_other_fedtax_credits          in varchar2,
	p_cpp_qpp_exempt_flag           in varchar2,
	p_fed_exempt_flag               in varchar2,
	p_ei_exempt_flag                in varchar2,
	p_tax_calc_method               in varchar2,
	p_fed_override_amount           in number,
	p_fed_override_rate             in number,
	p_ca_tax_information_category   in varchar2,
	p_ca_tax_information1           in varchar2,
	p_ca_tax_information2           in varchar2,
	p_ca_tax_information3           in varchar2,
	p_ca_tax_information4           in varchar2,
	p_ca_tax_information5           in varchar2,
	p_ca_tax_information6           in varchar2,
	p_ca_tax_information7           in varchar2,
	p_ca_tax_information8           in varchar2,
	p_ca_tax_information9           in varchar2,
	p_ca_tax_information10          in varchar2,
	p_ca_tax_information11          in varchar2,
	p_ca_tax_information12          in varchar2,
	p_ca_tax_information13          in varchar2,
	p_ca_tax_information14          in varchar2,
	p_ca_tax_information15          in varchar2,
	p_ca_tax_information16          in varchar2,
	p_ca_tax_information17          in varchar2,
	p_ca_tax_information18          in varchar2,
	p_ca_tax_information19          in varchar2,
	p_ca_tax_information20          in varchar2,
	p_ca_tax_information21          in varchar2,
	p_ca_tax_information22          in varchar2,
	p_ca_tax_information23          in varchar2,
	p_ca_tax_information24          in varchar2,
	p_ca_tax_information25          in varchar2,
	p_ca_tax_information26          in varchar2,
	p_ca_tax_information27          in varchar2,
	p_ca_tax_information28          in varchar2,
	p_ca_tax_information29          in varchar2,
	p_ca_tax_information30          in varchar2,
	p_object_version_number         in number,
	p_fed_lsf_amount                in number
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
  l_rec.emp_fed_tax_inf_id               := p_emp_fed_tax_inf_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.legislation_code                 := p_legislation_code;
  l_rec.assignment_id                    := p_assignment_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.employment_province              := p_employment_province;
  l_rec.tax_credit_amount                := p_tax_credit_amount;
  l_rec.claim_code                       := p_claim_code;
  l_rec.basic_exemption_flag             := p_basic_exemption_flag;
  l_rec.additional_tax                   := p_additional_tax;
  l_rec.annual_dedn                      := p_annual_dedn;
  l_rec.total_expense_by_commission      := p_total_expense_by_commission;
  l_rec.total_remnrtn_by_commission      := p_total_remnrtn_by_commission;
  l_rec.prescribed_zone_dedn_amt         := p_prescribed_zone_dedn_amt;
  l_rec.other_fedtax_credits             := p_other_fedtax_credits;
  l_rec.cpp_qpp_exempt_flag              := p_cpp_qpp_exempt_flag;
  l_rec.fed_exempt_flag                  := p_fed_exempt_flag;
  l_rec.ei_exempt_flag                   := p_ei_exempt_flag;
  l_rec.tax_calc_method                  := p_tax_calc_method;
  l_rec.fed_override_amount              := p_fed_override_amount;
  l_rec.fed_override_rate                := p_fed_override_rate;
  l_rec.ca_tax_information_category      := p_ca_tax_information_category;
  l_rec.ca_tax_information1              := p_ca_tax_information1;
  l_rec.ca_tax_information2              := p_ca_tax_information2;
  l_rec.ca_tax_information3              := p_ca_tax_information3;
  l_rec.ca_tax_information4              := p_ca_tax_information4;
  l_rec.ca_tax_information5              := p_ca_tax_information5;
  l_rec.ca_tax_information6              := p_ca_tax_information6;
  l_rec.ca_tax_information7              := p_ca_tax_information7;
  l_rec.ca_tax_information8              := p_ca_tax_information8;
  l_rec.ca_tax_information9              := p_ca_tax_information9;
  l_rec.ca_tax_information10             := p_ca_tax_information10;
  l_rec.ca_tax_information11             := p_ca_tax_information11;
  l_rec.ca_tax_information12             := p_ca_tax_information12;
  l_rec.ca_tax_information13             := p_ca_tax_information13;
  l_rec.ca_tax_information14             := p_ca_tax_information14;
  l_rec.ca_tax_information15             := p_ca_tax_information15;
  l_rec.ca_tax_information16             := p_ca_tax_information16;
  l_rec.ca_tax_information17             := p_ca_tax_information17;
  l_rec.ca_tax_information18             := p_ca_tax_information18;
  l_rec.ca_tax_information19             := p_ca_tax_information19;
  l_rec.ca_tax_information20             := p_ca_tax_information20;
  l_rec.ca_tax_information21             := p_ca_tax_information21;
  l_rec.ca_tax_information22             := p_ca_tax_information22;
  l_rec.ca_tax_information23             := p_ca_tax_information23;
  l_rec.ca_tax_information24             := p_ca_tax_information24;
  l_rec.ca_tax_information25             := p_ca_tax_information25;
  l_rec.ca_tax_information26             := p_ca_tax_information26;
  l_rec.ca_tax_information27             := p_ca_tax_information27;
  l_rec.ca_tax_information28             := p_ca_tax_information28;
  l_rec.ca_tax_information29             := p_ca_tax_information29;
  l_rec.ca_tax_information30             := p_ca_tax_information30;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.fed_lsf_amount            	 := p_fed_lsf_amount;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end pay_cft_shd;

/
